require "ISUI/ISPanelJoypad"
require "gameNight - gameElement"
local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

---@class gameNightWindow : ISPanelJoypad
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")

gameNightWindow.elements = {}

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
            local item = element.itemObject
            local worldItem = item:getWorldItem()
            if worldItem then surfaceZ = worldItem:getWorldPosZ()-worldItem:getZ() break end
        end

        for _,item in pairs(itemFound) do

            local sound = item:getModData()["gameNight_sound"]
            if sound then self.player:getEmitter():playSound(sound) end

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
        if piece and piece:isVisible() and piece.moveWithMouse then
            local posX, posY = piece:getMouseX(), piece:getMouseY()
            if deckActionHandler.isDeckItem(piece.itemObject) then
                local offsetX, offsetY = self.movingPieceOffset[1], self.movingPieceOffset[2]
                local placeX, placeY = x+self.x-offsetX, y+self.y-offsetY
                local selection
                for item,element in pairs(self.elements) do
                    if (element~=piece) and element:isVisible() and deckActionHandler.isDeckItem(element.itemObject) then
                        local inBounds = (math.abs(element.x-placeX) <= 4) and (math.abs(element.y-placeY) <= 4)
                        if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                    end
                end
                if selection then
                    deckActionHandler.mergeDecks(piece.itemObject, selection.itemObject, self.player)
                    self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
                    self.movingPiece = nil
                    return
                end
            end
            piece:moveElement(posX, posY)
        end
    end
    old(self, x, y)
    self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
    self.movingPiece = nil
end


function gameNightWindow:onMouseUpOutside(x, y)
    if self:isVisible() then
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
        local clickedOn = self:getClickedPriorityPiece(getMouseX(), getMouseY(), false)
        if clickedOn then self:onContextSelection(clickedOn, x, y) end
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end


function gameNightWindow:onMouseDown(x, y)
    if self:isVisible() then
        local clickedOn = self:getClickedPriorityPiece(getMouseX(), getMouseY(), false)
        if clickedOn then
            self.movingPiece = clickedOn
            self.movingPieceOffset = {clickedOn:getMouseX(),clickedOn:getMouseY()}
            self.moveWithMouse = false
        else
            self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
        end
        ISPanelJoypad.onMouseDown(self, x, y)
    end
end


function gameNightWindow:onContextSelection(element, x, y)

    ---@type IsoPlayer|IsoGameCharacter
    local playerObj = self.player
    local playerID = playerObj:getPlayerNum()

    ---@type InventoryItem
    local item = element.itemObject
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
        if element:isVisible() and element.moveWithMouse then
            local inBounds = ((cursorX >= element.x) and (cursorY >= element.y) and (cursorX <= element.x+element.width) and (cursorY <= element.y+element.height))
            if inBounds and ((not selection) or element.priority > selection.priority) then
                selection = element
            end
        end
    end

    return selection
end


local applyItemDetails = require "gameNight - applyItemDetails"
---@param item IsoObject|InventoryItem
---@param object IsoObject|IsoWorldInventoryObject
function gameNightWindow:generateElement(item, object, priority)
    ---@type gameNightElement
    local element = self.elements[item:getID()]
    local x = (object:getWorldPosX()-object:getX()) * (self.width-(self.padding*2))
    local y = (object:getWorldPosY()-object:getY()) * (self.height-(self.padding*2))

    applyItemDetails.applyGameNightToItem(item)
    
    ---@type Texture
    local texture = item:getModData()["gameNight_textureInPlay"] or item:getTexture()
    local w, h = texture:getWidth(), texture:getHeight()

    if not element then
        self.elements[item:getID()] = gameNightElement:new(x, y, w, h, item)
        element = self.elements[item:getID()]
        element:addToUIManager()
    end

    if element then
        element:setVisible(true)
        element:backMost()
        x = math.min(math.max(x, self.bounds.x1), self.bounds.x2-element:getWidth())
        y = math.min(math.max(y, self.bounds.y1), self.bounds.y2-element:getHeight())

        element:setX(self.x+x)
        element:setY(self.y+y)
        element:drawTextureScaledAspect(texture, 0, 0, w, h, 1, 1, 1, 1)
        element.priority = priority
    end
end


function gameNightWindow.compareElements(a, b)
    return (a.object:getWorldPosY() < b.object:getWorldPosY()) and ((a.item:getDisplayCategory() == b.item:getDisplayCategory()) or (a.item:getDisplayCategory() ~= "GameBoard" and b.item:getDisplayCategory() ~= "GameBoard"))
end


function gameNightWindow:prerender()
    ISPanelJoypad.prerender(self)
    for item,element in pairs(self.elements) do
        element:setVisible(false)
        element:setX(-10-self.width)
        element:setY(-10-self.height)
    end

    self:drawRectBorder(self.padding, self.padding, (self.width-(self.padding*2)), (self.height-(self.padding*2)), 0.8, 0.8, 0.8, 0.8)
end

gameNightWindow.cursorDraws = {}
gameNightWindow.cursor = nil
gameNightWindow.cursorW = nil
gameNightWindow.cursorH = nil

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
        local texture = movingElement.itemObject:getModData()["gameNight_textureInPlay"] or movingElement.itemObject:getTexture()
        local offsetX, offsetY = self.movingPieceOffset[1], self.movingPieceOffset[2]
        movingElement:drawTexture(texture, movingElement:getMouseX()-(offsetX), movingElement:getMouseY()-(offsetY), 0.55, 1, 1, 1)
    else
        local mouseOver = self:getClickedPriorityPiece(getMouseX(), getMouseY(), false)
        if mouseOver then self:labelWithName(mouseOver) end
    end
end


function gameNightWindow:labelWithName(element)
    if not self:isVisible() then return end

    local sandbox = SandboxVars.GameNight.DisplayItemNames
    if sandbox and (not self.movingPiece) then
        local nameTag = (element.itemObject and element.itemObject:getName())
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

    for item,element in pairs(self.elements) do
        element:setVisible(false)
        element:removeFromUIManager()
    end

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

    o.padding = 45
    o.bounds = {x1=o.padding, y1=o.padding, x2=o.width-o.padding, y2=o.height-o.padding}

    o.selectedItem = nil
    o.pendingRequest = false

    gameNightWindow.instance = o

    return o
end