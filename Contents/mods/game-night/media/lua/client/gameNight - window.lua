require "ISUI/ISPanelJoypad"
local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

---@class gameNightWindow : ISPanelJoypad
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")


function gameNightWindow:update()
    if (not self.player) or (not self.square) or (self.square~=self.player:getSquare() and (not luautils.isSquareAdjacentToSquare(self.square, self.player:getSquare()))) then
        self:closeAndRemove()
        return
    end
end

function gameNightWindow:initialise()
    ISPanelJoypad.initialise(self)

    local btnWid = 100
    local btnHgt = 25
    local padBottom = 10

    self.close = ISButton:new(self.padding, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, gameNightWindow.onClick)
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)

    local playerNum = self.player:getPlayerNum()

    local inventory = getPlayerInventory(playerNum)
    if inventory then inventory:refreshBackpacks() end

    local loot = getPlayerLoot(playerNum)
    if loot then loot:refreshBackpacks() end
end


function gameNightWindow:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightWindow:dropItemsOn(x, y)
    if not self:getIsVisible() then return end
    local dragging = ISMouseDrag.dragging
    if (dragging ~= nil) then
        local itemFound = {}
        local draggingItems = ISInventoryPane.getActualItems(dragging)
        for i,v in ipairs(draggingItems) do
            if deckActionHandler.isDeckItem(v) or gamePieceAndBoardHandler.isGamePiece(v) then
                local transfer = (not v:isFavorite()) and true
                if transfer then
                    table.insert(itemFound, v)
                end
            end
        end

        local playerNum = self.player:getPlayerNum()
        getPlayerLoot(playerNum).inventoryPane.selected = {}
        getPlayerInventory(playerNum).inventoryPane.selected = {}

        local boundsDifference = self.padding*2
        local scaledX = (x/(self.width-boundsDifference))
        local scaledY = (y/(self.height-boundsDifference))

        local surfaceZ = 0

        for _,element in pairs(self.elements) do
            ---@type InventoryItem
            local item = element.item
            local worldItem = item:getWorldItem()
            if worldItem then surfaceZ = worldItem:getWorldPosZ()-worldItem:getZ() break end
        end

        for _,item in pairs(itemFound) do

            local sound = item:getModData()["gameNight_sound"]
            if sound then self.player:getEmitter():playSound(sound) end

            if luautils.haveToBeTransfered(self.player, item) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(self.player, item, item:getContainer(), self.player:getInventory()))
            end

            local dropAction = ISDropWorldItemAction:new(self.player, item, self.square, scaledX, scaledY, surfaceZ, 0, false)
            dropAction.maxTime = 1
            ISTimedActionQueue.add(dropAction)

        end
    end

    if ISMouseDrag.draggingFocus then
        ISMouseDrag.draggingFocus:onMouseUp(0,0)
        ISMouseDrag.draggingFocus = nil
    end
    ISMouseDrag.dragging = nil
end


function gameNightWindow:processMouseUp(old, x, y)
    if not self.moveWithMouse then
        local piece = self.movingPiece
        if piece then
            local posX, posY = self:getMouseX(), self:getMouseY()
            if deckActionHandler.isDeckItem(piece) then
                local offsetX, offsetY = self.movingPieceOffset[1], self.movingPieceOffset[2]
                local placeX, placeY = x-offsetX, y-offsetY
                local selection
                for _,element in pairs(self.elements) do
                    if (element.item~=piece) and deckActionHandler.isDeckItem(element.item) then
                        local inBounds = (math.abs(element.x-placeX) <= 4) and (math.abs(element.y-placeY) <= 4)
                        if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                    end
                end
                if selection then
                    deckActionHandler.mergeDecks(piece.item, selection.item, self.player)
                    self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
                    self.movingPiece = nil
                    return
                end
            end
            self:moveElement(piece, posX, posY)
        end
    end
    old(self, x, y)
    self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
    self.movingPiece = nil
end


function gameNightWindow:onMouseUpOutside(x, y)
    if self:isVisible() and self.movingPiece then
        self:processMouseUp(ISPanelJoypad.onMouseUpOutside, x, y)
        return
    end
    ISPanelJoypad.onMouseUpOutside(self, x, y)
end


function gameNightWindow:onMouseUp(x, y)
    if self:isVisible() then
        if ISMouseDrag.dragging then self:dropItemsOn(x, y) end
        self:processMouseUp(ISPanelJoypad.onMouseUp, x, y)
        return
    end
    ISPanelJoypad.onMouseUp(self, x, y)
end


function gameNightWindow:onRightMouseDown(x, y)
    if self:isVisible() then
        local clickedOn = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if clickedOn then self:onContextSelection(clickedOn, x, y) end
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end


function gameNightWindow:onMouseDown(x, y)
    if self:isVisible() then
        local clickedOn = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if clickedOn then
            self.movingPiece = clickedOn.item

            local worldItemObj = clickedOn.item:getWorldItem()
            local oldZ = 0
            if worldItemObj then
                oldZ = worldItemObj:getWorldPosZ()-worldItemObj:getZ()

                self.movingPieceOffset = {self:getMouseX()-clickedOn.x,self:getMouseY()-clickedOn.y,oldZ}
                self.moveWithMouse = false

                --ISTimedActionQueue.add(ISGrabItemAction:new(self.player, worldItemObj, 1))
            end

        else
            self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
        end
        ISPanelJoypad.onMouseDown(self, x, y)
    end
end


function gameNightWindow:moveElement(gamePiece, x, y)

    if not self.movingPiece or gamePiece~=self.movingPiece then return end
    self.movingPiece = nil

    ---@type IsoObject|InventoryItem
    local item = gamePiece
    if not item then return end

    local offsetX = self.movingPieceOffset and self.movingPieceOffset[1] or 0
    local offsetY = self.movingPieceOffset and self.movingPieceOffset[2] or 0
    local offsetZ = self.movingPieceOffset and self.movingPieceOffset[3] or 0

    local newX = x-offsetX
    local newY = y-offsetY

    newX = math.min(math.max(newX, self.bounds.x1), self.bounds.x2)
    newY = math.min(math.max(newY, self.bounds.y1), self.bounds.y2)

    if newX < self.bounds.x1 or newY < self.bounds.y1 or newX > self.bounds.x2 or newY > self.bounds.y2 then return end

    local boundsDifference = self.padding*2
    local scaledX = (newX/(self.width-boundsDifference))
    local scaledY = (newY/(self.height-boundsDifference))

    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(self.player, item, nil, nil, scaledX, scaledY, offsetZ)

    local pBD = self.player:getBodyDamage()
    pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-0.5))
end


function gameNightWindow:onContextSelection(element, x, y)

    ---@type IsoPlayer|IsoGameCharacter
    local playerObj = self.player
    local playerID = playerObj:getPlayerNum()

    ---@type InventoryItem
    local item = element.item
    local itemContainer = item and item:getContainer() or false
    local isInInv = itemContainer and itemContainer:isInCharacterInventory(playerObj) or false

    local contextMenuItems = {item}
    if element.toolRender then element.toolRender:setVisible(false) end

    ---@type ISContextMenu
    local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, getMouseX(), getMouseY())

    return true
end


function gameNightWindow:getClickedPriorityPiece(x, y, clicked)
    local offsetX, offsetY = clicked and clicked.x or 0, clicked and clicked.y or 0
    local cursorX, cursorY = x+offsetX, y+offsetY

    local selection = clicked
    for item,element in pairs(self.elements) do
        local inBounds = ((cursorX >= element.x) and (cursorY >= element.y) and (cursorX <= element.x+element.w) and (cursorY <= element.y+element.h))
        if inBounds and ((not selection) or element.priority > selection.priority) then
            selection = element
        end
    end

    return selection
end


local applyItemDetails = require "gameNight - applyItemDetails"
---@param item IsoObject|InventoryItem
---@param object IsoObject|IsoWorldInventoryObject
function gameNightWindow:generateElement(item, object, priority)

    ---@type Texture
    local texture = item:getModData()["gameNight_textureInPlay"] or item:getTexture()
    local w, h = texture:getWidth(), texture:getHeight()
    local x = (object:getWorldPosX()-object:getX()) * (self.width-(self.padding*2))
    local y = (object:getWorldPosY()-object:getY()) * (self.height-(self.padding*2))

    x = math.min(math.max(x, self.bounds.x1), self.bounds.x2-w)
    y = math.min(math.max(y, self.bounds.y1), self.bounds.y2-h)

    self.elements[item:getID()] = {x=x, y=y, w=w, h=h, item=item, priority=priority}
    
    texture = texture or item:getModData()["gameNight_textureInPlay"] or item:getTexture()
    self:drawTexture(texture, x, y, w, h, 1, 1, 1, 1)
end


function gameNightWindow.compareElements(a, b)
    return (a.object:getWorldPosY() < b.object:getWorldPosY()) and ((a.item:getDisplayCategory() == b.item:getDisplayCategory()) or (a.item:getDisplayCategory() ~= "GameBoard" and b.item:getDisplayCategory() ~= "GameBoard"))
end


function gameNightWindow:prerender()
    ISPanelJoypad.prerender(self)
    self:drawRectBorder(self.padding, self.padding, (self.width-(self.padding*2)), (self.height-(self.padding*2)), 0.8, 0.8, 0.8, 0.8)
end


function gameNightWindow:render()
    ISPanelJoypad.render(self)
    local movingElement = self.movingPiece

    ---@type IsoGridSquare
    local square = self.square
    if not square then return end

    local loadOrder = {}
    for i=0, square:getObjects():size()-1 do
        ---@type IsoObject|IsoWorldInventoryObject
        local object = square:getObjects():get(i)
        if object and instanceof(object, "IsoWorldInventoryObject") then
            local item = object:getItem()
            if item and item:getTags():contains("gameNight") then
                local position = item:getDisplayCategory() == "GameBoard" and 1 or #loadOrder+1
                table.insert(loadOrder, position, {item=item, object=object})
            end
        end
    end
    table.sort(loadOrder, gameNightWindow.compareElements)

    self.elements = {}
    for priority,stuff in pairs(loadOrder) do self:generateElement(stuff.item, stuff.object, priority) end

    gameNightWindow.cursor = gameNightWindow.cursor or getTexture("media/textures/gamenight_cursor.png")
    gameNightWindow.cursorW = gameNightWindow.cursorW or gameNightWindow.cursor:getWidth()
    gameNightWindow.cursorH = gameNightWindow.cursorH or gameNightWindow.cursor:getHeight()

    for username,data in pairs(self.cursorDraws) do
        data.ticks = data.ticks - 1
        self:drawTexture(gameNightWindow.cursor, data.x, data.y, 1, data.r, data.g, data.b)
        self:drawText(username, data.x+gameNightWindow.cursorW, data.y, data.r, data.g, data.b, 1, UIFont.NewSmall)
        if data.ticks <= 0 then self.cursorDraws[username] = nil end
    end
    --self.cursorDraws = {}

    if movingElement then
        if not isMouseButtonDown(0) then return end
        local texture = movingElement:getModData()["gameNight_textureInPlay"] or movingElement:getTexture()
        local offsetX, offsetY = self.movingPieceOffset[1], self.movingPieceOffset[2]
        self:drawTexture(texture, self:getMouseX()-(offsetX), self:getMouseY()-(offsetY), 0.55, 1, 1, 1)
    else
        local mouseOver = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if mouseOver then self:labelWithName(mouseOver) end
    end
end


function gameNightWindow:labelWithName(element)
    local sandbox = SandboxVars.GameNight.DisplayItemNames
    if sandbox and (not self.movingPiece) then
        local nameTag = (element.item and element.item:getName())
        if nameTag then
            local nameTagWidth = getTextManager():MeasureStringX(UIFont.NewSmall, " "..nameTag.." ")
            local nameTagHeight = getTextManager():getFontHeight(UIFont.NewSmall)

            local x, y = self:getMouseX()+((self.cursorW*0.66) or 0), self:getMouseY()-((self.cursorH*0.66) or 0)
            self:drawRect(x, y, nameTagWidth, nameTagHeight, 0.7, 0, 0, 0)
            self:drawTextCentre(nameTag, x+(nameTagWidth/2), y, 1, 1, 1, 0.7, UIFont.NewSmall)
        end
    end
end


function gameNightWindow:closeAndRemove()
    self:setVisible(false)
    self.elements = {}
    self.movingPiece = nil
    self:removeFromUIManager()
end


local cursorHandler = isClient() and require "gameNight - cursorHandler"
function gameNightWindow.open(worldObjects, player, square)

    if gameNightWindow.instance then gameNightWindow.instance:closeAndRemove() end

    local window = gameNightWindow:new(nil, nil, 500, 500, player, square)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window:bringToTop()

    if cursorHandler then Events.OnPlayerUpdate.Add(cursorHandler.sendUpdate) end

    return window
end


function gameNightWindow:new(x, y, width, height, player, square)
    local o = {}
    x = x or getCore():getScreenWidth()/2 - (width/2)
    y = y or getCore():getScreenHeight()/2 - (height/2)
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}

    o.width = width
    o.height = height
    o.player = player
    o.square = square

    o.elements = {}

    o.cursorDraws = {}
    o.cursor = nil
    o.cursorW = nil
    o.cursorH = nil

    o.padding = 45
    o.bounds = {x1=o.padding, y1=o.padding, x2=o.width-o.padding, y2=o.height-o.padding}

    o.selectedItem = nil
    o.pendingRequest = false

    gameNightWindow.instance = o

    return o
end