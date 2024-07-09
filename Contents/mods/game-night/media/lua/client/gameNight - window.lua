require "ISUI/ISPanelJoypad"

local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

local uiInfo = require "gameNight - uiInfo"
local cursorHandler = isClient() and require "gameNight - cursorHandler"

local volumetricRender = require "gameNight - volumetricRender"

---@class gameNightWindow : ISPanelJoypad
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")

gameNightWindow.scaleSize = 0.75
gameNightWindow.scaleMatrix = {0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}

function gameNightWindow:toggleScale()

    if gameNightWindow.scaleSize == gameNightWindow.scaleMatrix[#gameNightWindow.scaleMatrix] then
        gameNightWindow.scaleSize = gameNightWindow.scaleMatrix[1]
    else
        for i,_ in ipairs(gameNightWindow.scaleMatrix) do
            if gameNightWindow.scaleSize == gameNightWindow.scaleMatrix[i] then
                gameNightWindow.scaleSize = gameNightWindow.scaleMatrix[i+1]
                break
            end
        end
    end

    local newWidth = self.defaultSize.width * gameNightWindow.scaleSize
    local newHeight = self.defaultSize.height * gameNightWindow.scaleSize
    
    -- if window is larger than screen and we are already not at the smallest scale, move to smallest scale
    if (newWidth > getCore():getScreenWidth() or newHeight > getCore():getScreenHeight()) and gameNightWindow.scaleSize ~= 0.5 then
        gameNightWindow.scaleSize = 0.5
        newWidth = self.defaultSize.width * gameNightWindow.scaleSize
        newHeight = self.defaultSize.height * gameNightWindow.scaleSize
    end
    
    self:setHeight(newHeight)
    self:setWidth(newWidth)

    self.bounds = {x1=self.padding, y1=self.padding, x2=self.width-self.padding, y2=self.height-self.padding}

    self.waitCursor.xOffset = (self.waitCursor.texture:getWidth()/2) * gameNightWindow.scaleSize
    self.waitCursor.yOffset = (self.waitCursor.texture:getHeight()/2) * gameNightWindow.scaleSize

    self.lockedCursor.xOffset = (self.lockedCursor.texture:getWidth()*1.5) * gameNightWindow.scaleSize

    self.close:setY(self:getHeight()-self.btnOffsetFromBottom)
    self.resize:setY(self:getHeight()-self.btnOffsetFromBottom)
    self.infoButton:setY(self:getHeight()-16-8)
end


function gameNightWindow:update()
    if (not self.player) or (not self.square) or ( self.square:DistToProper(self.player) > 1.5 ) then self:closeAndRemove() return end

    local coolDown = gamePieceAndBoardHandler.itemCoolDown(self.movingPiece)
    local coolDownMismatch = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
    local busy = gamePieceAndBoardHandler.itemIsBusy(self.movingPiece)
    if busy or coolDownMismatch then self:clearMovingPiece() return end

    local item = self.player:getPrimaryHandItem()
    if item and gameNightDeckSearch and deckActionHandler.isDeckItem(item) then
        local handUI = gameNightDeckSearch.instances[item]
        if ((not handUI) or (not handUI.held)) then gameNightHand.open(self.player, item) end
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

    uiInfo.applyToUI(self, 8, self:getHeight()-16-8, getText("UI_GameNightWindow"))

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

        ---@type IsoWorldInventoryObject|IsoObject
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
    self:clearMovingPiece(x, y)
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
    self.movingPiece = nil
    self.movingPieceOriginStamp = nil
    self.rotatingPieceDegree = 0
end

gameNightWindow.rotatingPieceDegree = 0

function gameNightWindow:onMouseWheel(del)

    local piece = self.movingPiece
    if not piece then return end

    local fullType = piece:getFullType()
    local specialCase = fullType and gamePieceAndBoardHandler.specials[fullType]
    local noRotate = specialCase and specialCase.noRotate
    if noRotate then
        self.rotatingPieceDegree = 0
        return true
    end

    self.rotatingPieceDegree = self.rotatingPieceDegree+(del*5)

    return true
end


function gameNightWindow:processMouseUp(old, x, y)
    if not self.moveWithMouse then
        ---@type InventoryItem
        local piece = self.movingPiece

        if piece then

            local coolDown = gamePieceAndBoardHandler.itemCoolDown(piece)
            local coolDownMismatch = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
            local busy = gamePieceAndBoardHandler.itemIsBusy(piece)
            if busy or coolDownMismatch then
                old(self, x, y)
                self:clearMovingPiece()
                return
            end


            local posX, posY = self:getMouseX(), self:getMouseY()

            local isDeck = deckActionHandler.isDeckItem(piece)
            local isStack = gamePieceAndBoardHandler.canStackPiece(piece)

            if isDeck or isStack then

                local offsetX, offsetY = self.movingPieceOffset and self.movingPieceOffset[1] or 0, self.movingPieceOffset and self.movingPieceOffset[2] or 0
                local placeX, placeY = x-offsetX, y-offsetY
                local selection
                for _,element in pairs(self.elements) do
                    if (element.item~=piece) and piece:getType() == element.item:getType() then
                        local inBounds = (math.abs(element.x-placeX) <= 8) and (math.abs(element.y-(element.depth or 0)-placeY) <= 8)
                        if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                    end
                end
                if selection then
                    local itemIsBusy = gamePieceAndBoardHandler.itemIsBusy(selection.item)
                    if itemIsBusy then self:clearMovingPiece() return end

                    if isDeck then deckActionHandler.mergeDecks(piece, selection.item, self.player) end
                    if isStack then gamePieceAndBoardHandler.tryStack(piece, selection.item, self.player) end

                    old(self, x, y)
                    self:clearMovingPiece(x, y)
                    return
                end
            end

            local shiftActionID, _ = gameNightWindow.fetchShiftAction(piece)
            local handler = isDeck and deckActionHandler or gamePieceAndBoardHandler
            local shiftAction = shiftActionID and handler[shiftActionID]
            local rX, rY, rZ

            if shiftAction then
                local element = self.elements[piece:getID()]
                if not element then return end
                rX, rY, rZ = self:determineScaledWorldXY(posX, posY, element)
                shiftAction(piece, self.player, (rX or posX), (rY or posY))
            else
                self:moveElement(piece, posX, posY, handler.handleDetails)
            end
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
        self:clearMovingPiece(x, y)
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
        self:clearMovingPiece(x, y)
        local clickedOn = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if clickedOn and (not clickedOn.locked) then

            if gamePieceAndBoardHandler.itemIsBusy(clickedOn.item) then return end

            ---@type IsoWorldInventoryObject|IsoObject
            local worldItem = clickedOn.item and clickedOn.item:getWorldItem()
            if worldItem then

                self.movingPiece = clickedOn.item

                local oldZ = 0
                oldZ = worldItem:getWorldPosZ()-worldItem:getZ()

                self.movingPieceOriginStamp = gamePieceAndBoardHandler.itemCoolDown(clickedOn.item)
                self.movingPieceOffset = {self:getMouseX()-clickedOn.x,self:getMouseY()-clickedOn.y,oldZ}
                self.moveWithMouse = false
            end
        else
            self.moveWithMouse = ((x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2))
        end
        ISPanelJoypad.onMouseDown(self, x, y)
    end
end


function gameNightWindow:determineScaledWorldXY(x, y, element)

    if not element then return x, y end

    local offsetX = self.movingPieceOffset and self.movingPieceOffset[1] or 0
    local offsetY = self.movingPieceOffset and self.movingPieceOffset[2] or 0
    local offsetZ = self.movingPieceOffset and self.movingPieceOffset[3] or 0

    local oW, oH = element.w, element.h
    local w, h = gameNightWindow.calculate_rotated_dimensions((element.w/2), (element.h/2), element.rot, element.depth)

    local newX = (x-(oW/2))-offsetX
    local newY = (y-(oH/2))-offsetY
    local depth = element.depth and (element.depth/2) or 0

    newX = math.min(math.max(newX, (self.bounds.x1+w-(oW/2)) ), (self.bounds.x2-(w)-(oW/2)) )
    newY = math.min(math.max(newY, (self.bounds.y1+h-(oH/2)) ), (self.bounds.y2-(h)-(oH/2)+depth) )

    local boundsDifference = self.padding*2
    local scaledX = ( newX / (self.width-boundsDifference) )
    local scaledY = ( newY / (self.height-boundsDifference) )

    return scaledX, scaledY, offsetZ
end


function gameNightWindow:moveElement(gamePiece, x, y, detailsFunc)
    if not self.movingPiece or gamePiece~=self.movingPiece then return end
    ---@type IsoObject|InventoryItem
    local item = gamePiece
    if not item then return end

    local element = self.elements[item:getID()]
    if not element then return end

    local scaledX, scaledY, offsetZ = self:determineScaledWorldXY(x, y, element)
    local angleChange = self.rotatingPieceDegree

    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(self.player, item, nil, detailsFunc, scaledX, scaledY, offsetZ, nil, angleChange)
end


function gameNightWindow:onContextSelection(element, x, y)

    if gamePieceAndBoardHandler.itemIsBusy(element.item) then return end

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


function gameNightWindow.calculate_rotated_dimensions(width, height, rot, depth)
    local angle_radians = (rot * math.pi / 180)
    local placed_width = math.abs(width * math.cos(angle_radians)) + math.abs(height * math.sin(angle_radians))
    local placed_height = math.abs(width * math.sin(angle_radians)) + math.abs(height * math.cos(angle_radians))

    if depth then placed_height = placed_height+(depth/2) end

    return placed_width, placed_height
end


function gameNightWindow:getClickedPriorityPiece(x, y, clicked)
    local offsetX, offsetY = clicked and clicked.x or 0, clicked and clicked.y or 0
    local cursorX, cursorY = x+offsetX, y+offsetY

    local selection = clicked
    for item,element in pairs(self.elements) do
        local w, h = gameNightWindow.calculate_rotated_dimensions((element.w/2), (element.h/2), element.rot, element.depth)

        local d = element.depth and element.depth/2 or 0

        local x1 = (element.x-w)
        local y1 = (element.y-h)-d

        local x2 = (element.x+w)
        local y2 = (element.y+h)-d

        --[[
        if getDebug() then
            self:drawRectBorder(element.x, element.y, 2, 2, 0.9, 0, 1, 1)
            self:drawRectBorder(x1, y1, w*2, h*2, 0.4, 1, 0.5, 0)
        end
        --]]

        local inBounds = ((cursorX >= x1) and (cursorY >= y1) and (cursorX <= x2) and (cursorY <= y2))
        if inBounds and ((not selection) or element.priority > selection.priority) then
            selection = element
        end
    end

    return selection
end


function gameNightWindow.round(number, digit_position)
    local precision = math.pow(10, digit_position)
    number = number + (precision / 2)
    return math.floor(number / precision) * precision
end

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

    local x = self.round( ((object:getWorldPosX()-object:getX()) * (self.width-(self.padding*2))) + w/2, -5)
    local y = self.round( ((object:getWorldPosY()-object:getY()) * (self.height-(self.padding*2))) + h/2, -5)

    local rot = item:getModData()["gameNight_rotation"] or 0
    local locked = item:getModData()["gameNight_locked"]

    self.elements[item:getID()] = {x=x, y=y, w=w, h=h, item=item, rot=rot, priority=priority, locked=locked}

    local tmpTexture = Texture.new(texture)
    tmpTexture:setHeight(h)
    tmpTexture:setWidth(w)

    local deckStates, flippedStates = deckActionHandler.getDeckStates(item)
    local stack = item:getModData()["gameNight_stacked"]

    --TODO: merge cards and game pieces into one concrete system to avoid crap like this
    local altRend = specialCase and specialCase.alternateStackRendering
    if altRend or deckStates or stack then
        local depthFactor = altRend and altRend.depth or (deckStates and 0.33) or 1
        local depth = (deckStates and #deckStates * depthFactor) or stack or depthFactor
        if depth then
            self.elements[item:getID()].depth = depth
            local func = altRend and altRend.func or (deckStates and "DrawTextureCardFace") or "DrawTextureRoundFace"
            local r, g, b = 1, 1, 1
            if altRend and altRend.rgb then r, g, b = unpack(altRend.rgb) end
            local sides = altRend and altRend.sides or 12 or 0
            local sideTexture = altRend and altRend.sideTexture
            volumetricRender[func](self, tmpTexture, sideTexture, x, y, rot, depth, sides, r, g, b, 1)
            return
        end
    end
    self:DrawTextureAngle(tmpTexture, x, y, rot)
end


function gameNightWindow:DrawTextureAngle(tex, centerX, centerY, angle, r, g, b, a)
    if self.javaObject ~= nil then
        self.javaObject:DrawTextureAngle(tex, centerX, centerY, angle, (r or 1), (g or 1), (b or 1), (a or 1))
    end
end


function gameNightWindow.compareElements(a, b)
    return (a.object:getWorldPosY() < b.object:getWorldPosY()) and ((a.item:getDisplayCategory() == b.item:getDisplayCategory()) or (a.item:getDisplayCategory() ~= "GameBoard" and b.item:getDisplayCategory() ~= "GameBoard"))
end


function gameNightWindow:prerender()
    ISPanelJoypad.prerender(self)
    self:drawRect(self.padding, self.padding, (self.width-(self.padding*2)), (self.height-(self.padding*2)), 0.6, 0.43, 0.42, 0.39)
    self:backMost()
end


gameNightWindow.cachedActionIcons = {}
function gameNightWindow.fetchShiftAction(gamePiece)
    --isShiftKeyDown() --isAltKeyDown()

    if not isShiftKeyDown() then return end

    local specialCase = gamePieceAndBoardHandler.specials[gamePiece:getFullType()]
    local shiftAction = specialCase and specialCase.shiftAction

    local shiftActionID
    local tbl = shiftAction and type(shiftAction)=="table"
    local tblAction1 = tbl and shiftAction[1]
    local tblAction2 = tbl and shiftAction[2]

    local deckStates, flippedStates = deckActionHandler.getDeckStates(gamePiece)
    if deckStates then
        shiftActionID = (#deckStates <= 1) and (tblAction1 or ((not tbl) and shiftAction) or "flipCard") or (tblAction2 or ((not tbl) and shiftAction) or "dealCard")
    else
        shiftActionID = tblAction1 or shiftAction
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
    gameNightWindow.cursorW = gameNightWindow.cursorW or (gameNightWindow.cursor and gameNightWindow.cursor:getWidth())
    gameNightWindow.cursorH = gameNightWindow.cursorH or (gameNightWindow.cursor and gameNightWindow.cursor:getHeight())

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

        local coolDown = gamePieceAndBoardHandler.itemCoolDown(movingPiece)
        local coolDownMistmach = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
        local busy = gamePieceAndBoardHandler.itemIsBusy(movingPiece)
        if busy or coolDownMistmach then
            self:clearMovingPiece()
            return
        end

        local examine = self.examine
        if examine then examine:closeAndRemove() end

        ---@type Texture
        local texture = movingPiece:getModData()["gameNight_textureInPlay"] or movingPiece:getTexture()
        local offsetX, offsetY = self.movingPieceOffset and self.movingPieceOffset[1] or 0, self.movingPieceOffset and self.movingPieceOffset[2] or 0
        local x, y = self:getMouseX()-(offsetX), self:getMouseY()-(offsetY)
        local movingElement = self.elements[movingPiece:getID()]
        if movingElement then
            local w, h = movingElement.w, movingElement.h

            local rot = (movingPiece:getModData()["gameNight_rotation"] or 0) + self.rotatingPieceDegree

            local tmpTexture = Texture.new(texture)
            tmpTexture:setHeight(h)
            tmpTexture:setWidth(w)

            self:DrawTextureAngle(tmpTexture, x, y, rot, 1, 1, 1, 0.7)
        end

        local selection
        if deckActionHandler.isDeckItem(movingPiece) or gamePieceAndBoardHandler.canStackPiece(movingPiece) then
            for _,element in pairs(self.elements) do
                if (element.item~=movingPiece) and (movingPiece:getType() == element.item:getType()) then
                    local inBounds = (math.abs(element.x-x) <= 8) and (math.abs(element.y-(element.depth or 0)-y) <= 8)
                    if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                end
            end
        end
        if selection then
            gameNightWindow.cachedActionIcons.mergeCards = gameNightWindow.cachedActionIcons.mergeCards or getTexture("media/textures/actionIcons/mergeCards.png")
            local mergeCards = gameNightWindow.cachedActionIcons.mergeCards
            self:drawTextureScaledUniform(mergeCards, x, y, gameNightWindow.scaleSize, 0.75, 1, 1, 1)
        else
            local _, shiftActionTexture = gameNightWindow.fetchShiftAction(movingPiece)
            if shiftActionTexture and shiftActionTexture~=true then self:drawTextureScaledUniform(shiftActionTexture, x, y, gameNightWindow.scaleSize, 0.65, 1, 1, 1) end
        end

    else
        local mouseOver = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)

        local examine = self.examine
        if examine and ((not mouseOver) or mouseOver.item ~= examine.item) then examine:closeAndRemove() end

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

        ---special tooltips
        local fullType = element.item:getFullType()
        local specialCase = fullType and gamePieceAndBoardHandler.specials[fullType]

        if specialCase and specialCase.examineScale and (not self.examine) then
            self.examine = gameNightExamine.open(self.player, element.item, false, nil, self)
        end

        local nameTag = (element.item and element.item:getName())
        if nameTag then

            local mX, mY = self:getMouseX(), self:getMouseY()
            local tooltips = specialCase and specialCase.tooltips
            if tooltips then
                local tX, tY = mX-element.x, mY-element.y
                local tooltipScale = gameNightWindow.scaleSize * 2
                for _,tt in pairs(tooltips) do
                    if tX >= tt.x*tooltipScale and tX <= (tt.x+tt.w)*tooltipScale and tY >= tt.y*tooltipScale and tY <= (tt.y+tt.h)*tooltipScale then
                        --self:drawRect((tt.x*tooltipScale)+element.x, (tt.y*tooltipScale)+element.y, tt.w*tooltipScale, tt.h*tooltipScale, 0.7, 0.7, 0, 0)
                        nameTag = nameTag.." ("..tt.text..") "
                    end
                end
            end

            local busy = gamePieceAndBoardHandler.itemIsBusy(element.item)
            if busy then
                local waitX, waitY = element.x-self.waitCursor.xOffset, element.y-self.waitCursor.yOffset
                self:drawTextureScaledUniform(self.lockedCursor.texture, waitX, waitY, gameNightWindow.scaleSize,1, 1, 1, 1)
            end

            local nameTagWidth = getTextManager():MeasureStringX(UIFont.NewSmall, " "..nameTag.." ")
            local nameTagHeight = getTextManager():getFontHeight(UIFont.NewSmall)

            local x, y = mX+((self.cursorW*0.66) or 0), mY-((self.cursorH*0.66) or 0)
            self:drawRect(x, y, nameTagWidth, nameTagHeight, 0.7, 0, 0, 0)
            self:drawTextCentre(nameTag, x+(nameTagWidth/2), y, 1, 1, 1, 0.7, UIFont.NewSmall)

            if element.item:getModData()["gameNight_locked"] then
                self:drawTextureScaledUniform(self.lockedCursor.texture, x-self.lockedCursor.xOffset, y, gameNightWindow.scaleSize,0.75, 1, 1, 1)
            end
        end
    end
end


function gameNightWindow:closeAndRemove()
    self:setVisible(false)
    local examine = self.examine
    if examine then examine:closeAndRemove() end

    local item = self.player:getPrimaryHandItem()
    if item and gameNightDeckSearch and deckActionHandler.isDeckItem(item) then
        local handUI = gameNightDeckSearch.instances[item]
        if handUI and handUI.held then handUI:closeAndRemove() end
    end

    self.elements = {}
    self:clearMovingPiece()
    self:removeFromUIManager()
    if gameNightWindow.instance == self then gameNightWindow.instance = nil end
end


function gameNightWindow.OnPlayerDeath(playerObj)
    local ui = gameNightWindow.instance
    if ui then ui:closeAndRemove() end
end
Events.OnPlayerDeath.Add(gameNightWindow.OnPlayerDeath)


function gameNightWindow.open(worldObjects, player, square)

    if gameNightWindow.instance then gameNightWindow.instance:closeAndRemove() end

    local window = gameNightWindow:new(nil, nil, 1000, 1000, player, square)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window:bringToTop()

    if cursorHandler and SandboxVars.GameNight.DisplayPlayerCursors==true then Events.OnPlayerUpdate.Add(cursorHandler.sendUpdate) end

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

    o.lockedCursor = {}
    o.lockedCursor.texture = getTexture("media/textures/actionIcons/lock.png")
    o.lockedCursor.xOffset = (o.lockedCursor.texture:getWidth()*1.5) * gameNightWindow.scaleSize

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