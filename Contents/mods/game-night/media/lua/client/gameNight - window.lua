require "ISUI/ISPanelJoypad"
local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

---@class gameNightWindow : ISPanelJoypad
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")

gameNightWindow.scaleSize = 1
function gameNightWindow:toggleScale()
    gameNightWindow.scaleSize = gameNightWindow.scaleSize==1 and 1.5 or gameNightWindow.scaleSize==1.5 and 2 or 1
    self:setHeight(self.defaultSize.width * gameNightWindow.scaleSize)
    self:setWidth(self.defaultSize.height * gameNightWindow.scaleSize)

    self.bounds = {x1=self.padding, y1=self.padding, x2=self.width-self.padding, y2=self.height-self.padding}

    self.waitCursor.xOffset = (self.waitCursor.texture:getWidth()/2) * gameNightWindow.scaleSize
    self.waitCursor.yOffset = (self.waitCursor.texture:getHeight()/2) * gameNightWindow.scaleSize

    self.close:setY(self:getHeight()-self.btnOffsetFromBottom)
    self.resize:setY(self:getHeight()-self.btnOffsetFromBottom)
end


function gameNightWindow:update()
    if (not self.player) or (not self.square) or ( self.square:DistToProper(self.player) > 1.5 ) then
        self:closeAndRemove()
        return
    end

    local worldItem = self.movingPiece and self.movingPiece:getWorldItem()
    local userUsing = worldItem and worldItem:getModData().gameNightInUse
    local wrongUser = userUsing and userUsing~=self.player:getUsername()
    local coolDown = wrongUser and worldItem and worldItem:getModData().gameNightCoolDown and worldItem:getModData().gameNightCoolDown>getTimestampMs()
    if wrongUser or coolDown then
        self:clearMovingPiece()
        return
    end
end

function gameNightWindow:initialise()
    ISPanelJoypad.initialise(self)

    local btnWid = 100
    local btnHgt = 25
    local padBottom = 10

    self.btnOffsetFromBottom = padBottom+btnHgt

    self.close = ISButton:new(self.padding, self:getHeight()-self.btnOffsetFromBottom, btnWid, btnHgt, getText("UI_Close"), self, gameNightWindow.onClick)
    self.close.offsetFromBottom = padBottom+btnHgt
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)

    self.resize = ISButton:new(self.close.x+self.close.width+padBottom, self:getHeight()-self.btnOffsetFromBottom, btnHgt, btnHgt, "+", self, gameNightWindow.toggleScale)
    self.resize.borderColor = {r=1, g=1, b=1, a=0.4}
    self.resize:initialise()
    self.resize:instantiate()
    self:addChild(self.resize)

    local playerNum = self.player:getPlayerNum()

    local inventory = getPlayerInventory(playerNum)
    if inventory then inventory:refreshBackpacks() end

    local loot = getPlayerLoot(playerNum)
    if loot then loot:refreshBackpacks() end
end


function gameNightWindow:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightWindow:calculateItemDrop(x, y, items)
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

    for n,item in pairs(items) do

        local sound = item:getModData()["gameNight_sound"]
        if sound then self.player:getEmitter():playSound(sound) end

        if n > 1 then
            scaledX = scaledX+ZombRandFloat(-0.02,0.02)
            scaledY = scaledY+ZombRandFloat(-0.02,0.02)
        end
        gamePieceAndBoardHandler.pickupAndPlaceGamePiece(self.player, item, nil, nil, scaledX, scaledY, surfaceZ, self.square)
    end
end

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

        self:calculateItemDrop(x, y, itemFound)
    end

    if ISMouseDrag.draggingFocus then
        ISMouseDrag.draggingFocus:onMouseUp(0,0)
        ISMouseDrag.draggingFocus = nil
    end
    ISMouseDrag.dragging = nil
end


function gameNightWindow:clearMovingPiece(x, y)
    if x and y then self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2)) end

    local piece = self.movingPiece
    if piece then
        local worldItem = piece:getWorldItem()
        local inUse = worldItem and worldItem:getModData().gameNightInUse
        if inUse and (inUse~=self.player:getUsername()) then
            worldItem:getModData().gameNightInUse = nil
            worldItem:transmitModData()
        end
    end
    self.movingPiece = nil
end


function gameNightWindow:processMouseUp(old, x, y)
    if not self.moveWithMouse then
        ---@type InventoryItem
        local piece = self.movingPiece

        if piece then

            local worldItem = piece:getWorldItem()
            local inUse = worldItem and worldItem:getModData().gameNightInUse
            local wrongUser = inUse and (inUse~=self.player:getUsername())
            if wrongUser then self:clearMovingPiece(x, y) return end

            ---@type gameNightWindow
            local deckSearch = gameNightDeckSearch.instance
            if deckSearch and deckSearch:isMouseOver() then
                local selection, inBetween = deckSearch:getCardAtXY(deckSearch.cardDisplay:getMouseX(), deckSearch.cardDisplay:getMouseY())

                local deckSearchWorldItem = deckSearch.deck and deckSearch.deck:getWorldItem()
                local deckSearchCoolDown = deckSearchWorldItem:getModData().gameNightCoolDown and (deckSearchWorldItem:getModData().gameNightCoolDown>getTimestampMs())
                local deckSearchInUse = deckSearchWorldItem:getModData().gameNightInUse
                local userUsing = deckSearchInUse and getPlayerFromUsername(deckSearchInUse)
                if deckSearchCoolDown or userUsing then self:clearMovingPiece() return end

                deckActionHandler.mergeDecks(piece, deckSearch.deck, self.player, selection+(inBetween and 0 or 1))

                self:clearMovingPiece(x, y)
                return
            end

            local posX, posY = self:getMouseX(), self:getMouseY()
            local isDeck = false
            if deckActionHandler.isDeckItem(piece) then
                isDeck = true
                local offsetX, offsetY = self.movingPieceOffset and self.movingPieceOffset[1] or 0, self.movingPieceOffset and self.movingPieceOffset[2] or 0
                local placeX, placeY = x-offsetX, y-offsetY
                local selection
                for _,element in pairs(self.elements) do
                    if (element.item~=piece) and deckActionHandler.isDeckItem(element.item) then
                        local inBounds = (math.abs(element.x-placeX) <= 5) and (math.abs(element.y-placeY) <= 5)
                        if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                    end
                end
                if selection then

                    local mouseOverWorldItem = selection.item and selection.item:getWorldItem()
                    local deckSearchCoolDown = mouseOverWorldItem:getModData().gameNightCoolDown and (mouseOverWorldItem:getModData().gameNightCoolDown>getTimestampMs())
                    local deckSearchInUse = mouseOverWorldItem:getModData().gameNightInUse
                    local userUsing = deckSearchInUse and getPlayerFromUsername(deckSearchInUse)
                    if deckSearchCoolDown or userUsing then self:clearMovingPiece() return end

                    deckActionHandler.mergeDecks(piece, selection.item, self.player)
                    self:clearMovingPiece(x, y)
                    return
                end
            end

            local moveDeckItem = true
            local shiftAction, _ = gameNightWindow.fetchShiftAction(piece)
            if shiftAction then

                if isDeck and deckActionHandler[shiftAction] then
                    moveDeckItem = (not deckActionHandler.staticDeckActions[shiftAction])
                    local rX, rY = self:determineScaledWorldXY(posX, posY)
                    deckActionHandler[shiftAction](piece, self.player, rX, rY)
                end

                if gamePieceAndBoardHandler[shiftAction] then
                    gamePieceAndBoardHandler[shiftAction](piece, self.player)
                end
            end

            if moveDeckItem then self:moveElement(piece, posX, posY) end
        end
    end
    old(self, x, y)
    self:clearMovingPiece(x, y)
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
        if clickedOn then
            self:onContextSelection(clickedOn, x, y)
        end
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end


--isShiftKeyDown() --isAltKeyDown()
function gameNightWindow:onMouseDown(x, y)
    if self:isVisible() then
        local clickedOn = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if clickedOn then

            ---@type IsoWorldInventoryObject|IsoObject
            local worldItem = clickedOn.item and clickedOn.item:getWorldItem()
            local inUse = worldItem:getModData().gameNightInUse
            local userUsing = inUse and getPlayerFromUsername(inUse)
            local coolDown = worldItem:getModData().gameNightCoolDown and (worldItem:getModData().gameNightCoolDown>getTimestampMs())
            if coolDown or userUsing then self:clearMovingPiece() return end

            if worldItem then
                local worldItemModData = worldItem:getModData()
                worldItemModData.gameNightInUse = self.player:getUsername()
                worldItemModData.gameNightCoolDown = getTimestampMs()+750
                worldItem:transmitModData()

                self.movingPiece = clickedOn.item

                local oldZ = 0
                oldZ = worldItem:getWorldPosZ()-worldItem:getZ()

                self.movingPieceOffset = {self:getMouseX()-clickedOn.x,self:getMouseY()-clickedOn.y,oldZ}
                self.moveWithMouse = false
                self.moveWithMouse = false
            end
        else
            self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
        end
        ISPanelJoypad.onMouseDown(self, x, y)
    end
end


function gameNightWindow:determineScaledWorldXY(x, y)
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

    return scaledX, scaledY, offsetZ
end


function gameNightWindow:moveElement(gamePiece, x, y)
    if not self.movingPiece or gamePiece~=self.movingPiece then return end
    ---@type IsoObject|InventoryItem
    local item = gamePiece
    if not item then return end
    local scaledX, scaledY, offsetZ = self:determineScaledWorldXY(x, y)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(self.player, item, nil, nil, scaledX, scaledY, offsetZ)
end


function gameNightWindow:onContextSelection(element, x, y)

    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = element.item and element.item:getWorldItem()
    local inUse = worldItem:getModData().gameNightInUse
    local userUsing = inUse and getPlayerFromUsername(inUse)
    local coolDown = worldItem:getModData().gameNightCoolDown and (worldItem:getModData().gameNightCoolDown>getTimestampMs())
    if userUsing or coolDown then return end

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

    applyItemDetails.applyGameNightToItem(item)

    ---@type Texture
    local texture = item:getModData()["gameNight_textureInPlay"] or item:getTexture()

    local fullType = item:getFullType()
    local specialCase = fullType and gamePieceAndBoardHandler.specials[fullType]
    local specialTextureSize = specialCase and specialCase.textureSize

    local w = specialTextureSize and specialTextureSize[1] or texture:getWidth()
    local h = specialTextureSize and specialTextureSize[2] or texture:getHeight()

    w = w * gameNightWindow.scaleSize
    h = h * gameNightWindow.scaleSize

    local x = (object:getWorldPosX()-object:getX()) * (self.width-(self.padding*2))
    local y = (object:getWorldPosY()-object:getY()) * (self.height-(self.padding*2))

    x = math.min(math.max(x, self.bounds.x1), self.bounds.x2-w)
    y = math.min(math.max(y, self.bounds.y1), self.bounds.y2-h)

    self.elements[item:getID()] = {x=x, y=y, w=w, h=h, item=item, priority=priority}
    
    self:drawTextureScaledAspect(texture, x, y, w, h, 1, 1, 1, 1)
end


function gameNightWindow.compareElements(a, b)
    return (a.object:getWorldPosY() < b.object:getWorldPosY()) and ((a.item:getDisplayCategory() == b.item:getDisplayCategory()) or (a.item:getDisplayCategory() ~= "GameBoard" and b.item:getDisplayCategory() ~= "GameBoard"))
end


function gameNightWindow:prerender()
    ISPanelJoypad.prerender(self)
    self:drawRectBorder(self.padding, self.padding, (self.width-(self.padding*2)), (self.height-(self.padding*2)), 0.8, 0.8, 0.8, 0.8)
end


gameNightWindow.cachedActionIcons = {}
function gameNightWindow.fetchShiftAction(gamePiece)
    --isShiftKeyDown() --isAltKeyDown()
    if not isShiftKeyDown() then return end

    local specialCase = gamePieceAndBoardHandler.specials[gamePiece:getFullType()]
    local shiftActionID = specialCase and specialCase.shiftAction

    local deckStates, flippedStates = deckActionHandler.getDeckStates(gamePiece)
    if (not specialCase) and deckStates then
        shiftActionID = (#deckStates <= 1) and "flipCard" or "dealCard"
    end

    if shiftActionID then
        if not gameNightWindow.cachedActionIcons[shiftActionID] then
            gameNightWindow.cachedActionIcons[shiftActionID] = getTexture("media/textures/actionIcons/"..shiftActionID..".png") or true
        end
        local texture = gameNightWindow.cachedActionIcons[shiftActionID]
        return shiftActionID, texture
    end
end


function gameNightWindow:render()
    ISPanelJoypad.render(self)
    local movingPiece = self.movingPiece

    ---@type IsoGridSquare
    local square = self.square
    if not square then return end

    local loadOrder = {}

    local sqObjects = square:getObjects()
    for i=0, sqObjects:size()-1 do
        ---@type IsoObject|IsoWorldInventoryObject
        local object = sqObjects:get(i)
        if object and instanceof(object, "IsoWorldInventoryObject") then
            ---@type InventoryItem
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

    gameNightWindow.cursor = gameNightWindow.cursor or getTexture("media/textures/actionIcons/gamenight_cursor.png")
    gameNightWindow.cursorW = gameNightWindow.cursorW or gameNightWindow.cursor:getWidth()
    gameNightWindow.cursorH = gameNightWindow.cursorH or gameNightWindow.cursor:getHeight()

    if gameNightWindow.cursor then
        for username,data in pairs(self.cursorDraws) do
            data.ticks = data.ticks - 1
            self:drawTextureScaledUniform(gameNightWindow.cursor, data.x, data.y, gameNightWindow.scaleSize, 1, data.r, data.g, data.b)
            self:drawText(username, data.x+(gameNightWindow.cursorW or 0), data.y, data.r, data.g, data.b, 1, UIFont.NewSmall)
            if data.ticks <= 0 then self.cursorDraws[username] = nil end
        end
    end
    --self.cursorDraws = {}

    if movingPiece then
        if not isMouseButtonDown(0) then return end
        local texture = movingPiece:getModData()["gameNight_textureInPlay"] or movingPiece:getTexture()
        local offsetX, offsetY = self.movingPieceOffset and self.movingPieceOffset[1] or 0, self.movingPieceOffset and self.movingPieceOffset[2] or 0
        local x, y = self:getMouseX()-(offsetX), self:getMouseY()-(offsetY)
        local movingElement = self.elements[movingPiece:getID()]
        local w, h = movingElement.w, movingElement.h
        self:drawTextureScaled(texture, self:getMouseX()-(offsetX), self:getMouseY()-(offsetY), w, h, 0.55, 1, 1, 1)

        local selection
        for _,element in pairs(self.elements) do
            if (element.item~=movingPiece) and deckActionHandler.isDeckItem(element.item) then
                local inBounds = (math.abs(element.x-x) <= 5) and (math.abs(element.y-y) <= 5)
                if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
            end
        end
        if selection then
            gameNightWindow.cachedActionIcons.mergeCards = gameNightWindow.cachedActionIcons.mergeCards or getTexture("media/textures/actionIcons/mergeCards.png")
            local mergeCards = gameNightWindow.cachedActionIcons.mergeCards
            self:drawTextureScaledUniform(mergeCards, x, y, gameNightWindow.scaleSize, 0.65, 1, 1, 1)
        else
            local _, shiftActionTexture = gameNightWindow.fetchShiftAction(movingPiece)
            if shiftActionTexture and shiftActionTexture~=true then self:drawTextureScaledUniform(shiftActionTexture, x, y, gameNightWindow.scaleSize, 0.65, 1, 1, 1) end
        end

    else
        local mouseOver = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if mouseOver then
            self:labelWithName(mouseOver)

            local _, texture = gameNightWindow.fetchShiftAction(mouseOver.item)
            if texture and texture~=true then self:drawTextureScaledUniform(texture, mouseOver.x, mouseOver.y, gameNightWindow.scaleSize, 0.75, 1, 1, 1) end
        end
    end
end


function gameNightWindow:labelWithName(element)
    local sandbox = SandboxVars.GameNight.DisplayItemNames
    if sandbox and (not self.movingPiece) then

        local nameTag = (element.item and element.item:getName())
        if nameTag then

            local worldItem = element.item:getWorldItem()
            local coolDown = worldItem:getModData().gameNightCoolDown and worldItem:getModData().gameNightCoolDown>getTimestampMs()
            local inUse = worldItem and worldItem:getModData().gameNightInUse

            local needsClear = inUse and inUse==self.player:getUsername() and (self.movingPiece~=element.item)
            if needsClear then
                worldItem:getModData().gameNightInUse = nil
                worldItem:transmitModData()
            end
            
            local wrongUser = (inUse and inUse~=self.player:getUsername())
            if wrongUser then nameTag = nameTag.." [In Use]" end

            if coolDown then
                local waitX, waitY = element.x+(element.w/2)-self.waitCursor.xOffset, element.y+(element.h/2)-self.waitCursor.yOffset
                self:drawTextureScaledUniform(self.waitCursor.texture, waitX, waitY, gameNightWindow.scaleSize,1, 1, 1, 1)
            end

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
    self:clearMovingPiece()
    self:removeFromUIManager()
    if gameNightWindow.instance == self then gameNightWindow.instance = nil end
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

    o.defaultSize = {width=width, height=height}
    o.width = width * gameNightWindow.scaleSize
    o.height = height * gameNightWindow.scaleSize
    o.player = player
    o.square = square

    o.waitCursor = {}
    o.waitCursor.texture = getTexture("media/textures/actionIcons/gamenight_wait.png")
    o.waitCursor.xOffset = (o.waitCursor.texture:getWidth()/2) * gameNightWindow.scaleSize
    o.waitCursor.yOffset = (o.waitCursor.texture:getHeight()/2) * gameNightWindow.scaleSize

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