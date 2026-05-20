require "ISUI/ISPanelJoypad"

local applyItemDetails = require "gameNight-applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local  gamePieceHandler = applyItemDetails. gamePieceHandler

local uiInfo = require "gameNight-uiInfo"
local cursorHandler = isClient() and require "gameNight-cursorHandler"

local volumetricRender = require "gameNight-volumetricRender"
local gameNightPhysics = require "gameNight-physics"
local gnTags = require "gameNight-tags"

require "gameNight-boxSidebar"

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
    self.elementsDirty = true
end

function gameNightWindow:update()
    if (not self.player) or (not self.square) or ( self.square:DistToProper(self.player) > 1.5 ) then self:closeAndRemove() return end

    if self.movingPiece then
        local coolDown =  gamePieceHandler.itemCoolDown(self.movingPiece)
        local coolDownMismatch = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
        local busy =  gamePieceHandler.itemIsBusy(self.movingPiece)
        if busy or coolDownMismatch then self:clearMovingPiece() end
    end
    
    local item = self.player:getPrimaryHandItem()
    if item and gameNightDeckSearch and deckActionHandler.isDeckItem(item) then
        local handUI = gameNightDeckSearch.instances[item]
        if ((not handUI) or (not handUI.held)) then
            gameNightHand.open(self.player, item)
        end
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
    local boundW = (self.width-boundsDifference)
    local scaledX = (x/boundW)
    local boundH = (self.height-boundsDifference)
    local scaledY = (y/boundH)
    local surfaceZ = 0

    for _,element in pairs(self.elements) do
        ---@type InventoryItem
        local item = element.item

        ---@type IsoWorldInventoryObject|IsoObject
        local worldItem = item:getWorldItem()

        if worldItem then surfaceZ = worldItem:getWorldPosZ()-worldItem:getZ() break end
    end

    for n,item in pairs(items) do

        local element = self.elements[item:getID()]
        local rW, rH = element and gameNightWindow.calculate_rotated_dimensions((element.w/2), (element.h/2), element.rot, element.depth)
        local eW = rW and rW/boundW or 0
        local eH = rH and rH/boundH or 0

        local sound = item:getModData()["gameNight_sound"]
        if sound then self.player:getEmitter():playSound(sound) end

        if n > 1 then
            scaledX = scaledX+ZombRandFloat(-0.02,0.02)
            scaledY = scaledY+ZombRandFloat(-0.02,0.02)
        end
        scaledX = math.max(math.min(scaledX,1.045-eW),0.045+eW)
        scaledY = math.max(math.min(scaledY,1.045-eH),0.045+eH)
         gamePieceHandler.pickupAndPlaceGamePiece(self.player, item, nil, nil, scaledX, scaledY, surfaceZ, self.square)
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
            if deckActionHandler.isDeckItem(v) or  gamePieceHandler.isGamePiece(v) then
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
    self.movingPieceFromBox = nil
    self.movingPieceOriginStamp = nil
    self.movingPieceStartX = nil
    self.movingPieceStartY = nil
    self.rotatingPieceDegree = 0
    self.elementsDirty = true
end

gameNightWindow.rotatingPieceDegree = 0

function gameNightWindow:onMouseWheel(del)

    local piece = self.movingPiece
    if not piece then return end

    local fullType = piece:getFullType()
    local specialCase = fullType and  gamePieceHandler.specials[fullType]
    local noRotate = specialCase and specialCase.noRotate
    if noRotate then
        self.rotatingPieceDegree = 0
        return true
    end

    self.rotatingPieceDegree = self.rotatingPieceDegree+(del*5)

    return true
end



gameNightWindow.shakeConfig = {
    WINDOW = 30,
    MIN_REVERSALS = 3,
    MAX_SPREAD = 360,
    DOT_THRESH = 0,
    MIN_MOVE = 1,
    T_STEP = 1.0,
    T_DECAY = 0.02,
}

function gameNightWindow:resetShake()
    local s = self.shake
    s.history = {}
    s.reversals = {}
    s.eventCount = 0
    s.grouped = false
    s.energy = 0
    s.T = 0
    s.originX = nil
    s.originY = nil
    s.prevDX = 0
    s.prevDY = 0
end

function gameNightWindow:onMouseMove(dx, dy)
    local cmx, cmy = self:getMouseX(), self:getMouseY()
    local mag = math.sqrt(dx * dx + dy * dy)

    local hist = self.shake.history
    hist[#hist + 1] = mag
    if #hist > 30 then table.remove(hist, 1) end
    local energy = 0
    for _, d in ipairs(hist) do energy = energy + d end
    self.shake.energy = energy

    if self.movingPiece then
        local vhist = self.dragVelHistory
        vhist[#vhist + 1] = {dx = dx, dy = dy}
        if #vhist > 6 then table.remove(vhist, 1) end
        local sumX, sumY = 0, 0
        for _, v in ipairs(vhist) do sumX = sumX + v.dx; sumY = sumY + v.dy end
        self.dragVelX = sumX / #vhist
        self.dragVelY = sumY / #vhist
    else
        self.dragVelHistory = {}
        self.dragVelX = 0
        self.dragVelY = 0
    end

    local hasGroup = self.movingPiece and self.movingGroup
    local isMovingCard = self.movingPiece and deckActionHandler.isDeckItem(self.movingPiece)

    if self.movingPiece and (hasGroup or isMovingCard) and not self.shake.grouped then

        self.shake.eventCount = self.shake.eventCount + 1

        if self.shake.originX then
            local driftSq = (cmx - self.shake.originX) ^ 2 + (cmy - self.shake.originY) ^ 2
            if driftSq > self.shakeConfig.MAX_SPREAD * self.shakeConfig.MAX_SPREAD then
                self.shake.reversals = {}
                self.shake.originX = cmx
                self.shake.originY = cmy
                self.shake.T = math.max(0, self.shake.T - 0.1)
            end
        else
            self.shake.originX = cmx
            self.shake.originY = cmy
        end

        if mag >= self.shakeConfig.MIN_MOVE and self.shake.prevDX ~= 0 then
            local dot = dx * self.shake.prevDX + dy * self.shake.prevDY
            if dot < self.shakeConfig.DOT_THRESH then
                self.shake.reversals[#self.shake.reversals + 1] = self.shake.eventCount
            end
        end

        while self.shake.reversals[1] and
              (self.shake.eventCount - self.shake.reversals[1]) > self.shakeConfig.WINDOW do
            table.remove(self.shake.reversals, 1)
        end

        self.shake.prevDX = dx
        self.shake.prevDY = dy

        local wasGrouped = self.shake.grouped
        if #self.shake.reversals >= self.shakeConfig.MIN_REVERSALS then
            self.shake.T = math.min(1, self.shake.T + self.shakeConfig.T_STEP)
            if self.shake.T >= 1 then self.shake.grouped = true end
        else
            self.shake.T = math.max(0, self.shake.T - self.shakeConfig.T_DECAY)
        end

        if self.shake.grouped and not wasGrouped then
            self:onShakeTriggered(cmx, cmy, isMovingCard)
        end

    else
        if not self.movingGroup then
            self:resetShake()
        end
    end

    ISPanelJoypad.onMouseMove(self, dx, dy)
end


---@param cmx number  current mouse X in window-local coords
---@param cmy number  current mouse Y in window-local coords
---@param isMovingCard boolean
function gameNightWindow:onShakeTriggered(cmx, cmy, isMovingCard)
    if isMovingCard then
        local piece = self.movingPiece
        local offsetX = self.movingPieceOffset and self.movingPieceOffset[1] or 0
        local offsetY = self.movingPieceOffset and self.movingPieceOffset[2] or 0
        local pieceX = cmx - offsetX
        local pieceY = cmy - offsetY

        local overlapTarget = nil
        for _, el in pairs(self.elements) do
            if el.item and el.item ~= piece then
                local inGroup = false
                if self.movingGroup then
                    for _, gItem in ipairs(self.movingGroup) do
                        if gItem == el.item then inGroup = true; break end
                    end
                end
                if not inGroup and deckActionHandler.isDeckItem(el.item) then
                    if math.abs(el.x - pieceX) <= 8 and math.abs(el.y - pieceY) <= 8 then
                        overlapTarget = el
                        break
                    end
                end
            end
        end

        local deckStates = deckActionHandler.getDeckStates(piece)
        local cardCount = deckStates and #deckStates or 0
        local resultPiece = piece
        local nonCardGroup = {}

        if self.movingGroup and #self.movingGroup > 0 then

            for _, groupItem in ipairs(self.movingGroup) do
                if deckActionHandler.isDeckItem(groupItem) then
                    deckActionHandler.mergeDecks(groupItem, piece, self.player)
                else
                    nonCardGroup[#nonCardGroup + 1] = groupItem
                end
            end
            if overlapTarget then
                deckActionHandler.mergeDecks(piece, overlapTarget.item, self.player)
                resultPiece = overlapTarget.item
            end
        elseif cardCount > 1 then
            deckActionHandler.shuffleCards(piece, self.player)
        elseif overlapTarget then
            deckActionHandler.mergeDecks(piece, overlapTarget.item, self.player)
            resultPiece = overlapTarget.item
        end

        self.movingPiece = resultPiece
        self.movingPieceFromBox = nil
        self.movingPieceOriginStamp = nil
        self.rotatingPieceDegree = 0
        self.elementsDirty = true
        gamePieceHandler.coolDownArray[resultPiece:getID()] = nil

        local resultEl = self.elements[resultPiece:getID()]
        if resultEl then
            self.movingPieceOffset = {cmx - resultEl.x, cmy - resultEl.y, 0}
        end

        self.movingGroup = #nonCardGroup > 0 and nonCardGroup or nil
        self.selection = self.movingGroup and self.selection or {}
        if not self.movingGroup then
            self:resetShake()
        end
    end
end


function gameNightWindow:processMouseUp(old, x, y)
    if not self.moveWithMouse then
        ---@type InventoryItem
        local piece = self.movingPiece

        if piece then

            local coolDown =  gamePieceHandler.itemCoolDown(piece)
            local coolDownMismatch = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
            local busy =  gamePieceHandler.itemIsBusy(piece)
            if busy or coolDownMismatch then
                old(self, x, y)
                self:clearMovingPiece()
                return
            end

            local posX, posY = self:getMouseX(), self:getMouseY()

            local isDeck = deckActionHandler.isDeckItem(piece)
            local isStack =  gamePieceHandler.canStackPiece(piece)

            if isDeck or isStack then

                local offsetX, offsetY = self.movingPieceOffset and self.movingPieceOffset[1] or 0, self.movingPieceOffset and self.movingPieceOffset[2] or 0
                local placeX, placeY = x-offsetX, y-offsetY
                local selection
                for _,element in pairs(self.elements) do
                    if element.item and (element.item~=piece) and piece:getType() == element.item:getType() then
                        local inBounds = (math.abs(element.x-placeX) <= 8) and (math.abs(element.y-(element.depth or 0)-placeY) <= 8)
                        if inBounds and ((not selection) or element.priority > selection.priority) then selection = element end
                    end
                end
                if selection then
                    local itemIsBusy =  gamePieceHandler.itemIsBusy(selection.item)
                    if itemIsBusy then self:clearMovingPiece() return end

                    if isDeck then deckActionHandler.mergeDecks(piece, selection.item, self.player) end
                    if isStack then  gamePieceHandler.tryStack(piece, selection.item, self.player) end

                    old(self, x, y)
                    self:clearMovingPiece(x, y)
                    return
                end
            end


            local sidebar = gameNightBoxSidebar.instance
            if sidebar and sidebar:containsPoint(getMouseX(), getMouseY()) then
                sidebar:receiveItem(piece)
                old(self, x, y)
                self:clearMovingPiece(x, y)
                return
            end

            local shiftActionID, _ = gameNightWindow.fetchShiftAction(piece)
            local handler = isDeck and deckActionHandler or  gamePieceHandler
            local batchEntry = shiftActionID and gameNightWindow.batchActions[shiftActionID]
            local shiftAction = shiftActionID and handler[shiftActionID]
            local rX, rY, rZ

            if batchEntry or shiftAction then
                local element = self.elements[piece:getID()]
                if not element then return end
                rX, rY, rZ = self:determineScaledWorldXY(posX, posY, element)
                if batchEntry then
                    batchEntry.fn(piece, self, rX, rY)
                else
                    shiftAction(piece, self.player, rX or posX, rY or posY, rZ, self.square)
                end

                if self.movingGroup then
                    local angleChange = self.rotatingPieceDegree
                    local wW = self.width - self.padding * 2
                    local wH = self.height - self.padding * 2
                    local count = #self.movingGroup
                    local t = self.shake.T
                    for i, groupItem in ipairs(self.movingGroup) do
                        local gID = gameNightWindow.fetchShiftAction(groupItem, true)
                        local gBatch = gID and gameNightWindow.batchActions[gID]
                        local gFn = gBatch and gBatch.fn
                        local behavior = gameNightWindow.getGroupBehavior(groupItem)
                        local radius = behavior and behavior.clusterRadius or 18
                        local angle = count > 1 and ((i-1) / count) * math.pi * 2 or 0
                        local ge = self.elements[groupItem:getID()]
                        local relX = ge and (rX + (ge.x - element.x) / wW) or rX
                        local relY = ge and (rY + (ge.y - element.y) / wH) or rY
                        local clustX = rX + math.cos(angle) * radius / wW
                        local clustY = rY + math.sin(angle) * radius / wH
                        local gX = relX + (clustX - relX) * t
                        local gY = relY + (clustY - relY) * t
                        if gFn then
                            gFn(groupItem, self, gX, gY)
                        elseif behavior and behavior.onRelease then
                            behavior.onRelease(groupItem, self, gX, gY)
                        elseif ge then
                             gamePieceHandler.pickupAndPlaceGamePiece(
                                self.player, groupItem, nil, handler.handleDetails,
                                gX, gY, rZ or 0, self.square, angleChange)
                        end
                    end
                    self.movingGroup = nil
                    self.selection = {}
                    self:resetShake()
                end
            else
                local startX = self.movingPieceStartX
                local startY = self.movingPieceStartY
                if not startX
                or math.abs(posX - startX) > 4
                or math.abs(posY - startY) > 4 then
                    self:moveElement(piece, posX, posY, handler.handleDetails)
                end
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
        if self.dragSelect then self:finalizeDragSelect(x, y) end
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
            if self.selection and clickedOn.item and self.selection[clickedOn.item:getID()] then
                self:onBatchContextSelection(x, y)
            else
                self:onContextSelection(clickedOn, x, y)
            end
        end
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end
--isShiftKeyDown() --isAltKeyDown()


function gameNightWindow:onMouseDown(x, y)
    if self:isVisible() then
        self:clearMovingPiece(x, y)
        local clickedOn = self:getClickedPriorityPiece(self:getMouseX(), self:getMouseY(), false)
        if clickedOn then

            if  gamePieceHandler.itemIsBusy(clickedOn.item or clickedOn.boxItem) then return end

            if isAltKeyDown() and clickedOn.item then
                local id = clickedOn.item:getID()
                if self.selection[id] then
                    self.selection[id] = nil
                else
                    self.selection[id] = clickedOn
                end
                ISPanelJoypad.onMouseDown(self, x, y)
                return
            end

            local isLocked = clickedOn.item and clickedOn.item:getModData()["gameNight_locked"]
            if not isLocked then
                ---@type IsoWorldInventoryObject|IsoObject
                local worldItem = clickedOn.item and clickedOn.item:getWorldItem()
                if worldItem then

                    self.movingPiece = clickedOn.item
                    self.movingPieceStartX = self:getMouseX()
                    self.movingPieceStartY = self:getMouseY()

                    local oldZ = worldItem:getWorldPosZ()-worldItem:getZ()

                    self.movingPieceOriginStamp =  gamePieceHandler.itemCoolDown(clickedOn.item)
                    self.movingPieceOffset = {self:getMouseX()-clickedOn.x,self:getMouseY()-clickedOn.y,oldZ}
                    self.moveWithMouse = false

                    if clickedOn.item and self.selection and self.selection[clickedOn.item:getID()] then
                        local group = {}
                        for _, sel in pairs(self.selection) do
                            if sel.item and sel.item ~= clickedOn.item then
                                table.insert(group, sel.item)
                            end
                        end
                        self.movingGroup = #group > 0 and group or nil
                    else
                        self.movingGroup = nil
                    end
                end
            end
        else
            local outOfBounds = (x < self.bounds.x1) or (y < self.bounds.y1) or (x > self.bounds.x2) or (y > self.bounds.y2)
            self.moveWithMouse = outOfBounds
            if not outOfBounds then
                self.selection = {}
                self.dragSelect = {x1=x, y1=y, x2=x, y2=y}
            end
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

    if self.movingPieceFromBox then
        local mx, my = self:getMouseX(), self:getMouseY()
        local inBounds = mx >= self.bounds.x1 and mx <= self.bounds.x2
                      and my >= self.bounds.y1 and my <= self.bounds.y2
        local fromBox = self.movingPieceFromBox
        self.movingPieceFromBox = nil
        if not inBounds then return end
        local sidebar = gameNightBoxSidebar.instance
        if sidebar then sidebar:takeFromBox(item, fromBox) end
    end

    local scaledX, scaledY, offsetZ = self:determineScaledWorldXY(x, y, element)
    local angleChange = self.rotatingPieceDegree

     gamePieceHandler.pickupAndPlaceGamePiece(self.player, item, nil, detailsFunc, scaledX, scaledY, offsetZ, self.square, angleChange)

    if self.movingGroup then
        local wW = self.width - self.padding * 2
        local wH = self.height - self.padding * 2
        local count = #self.movingGroup
        local t = self.shake.T
        for i, groupItem in ipairs(self.movingGroup) do
            local ge = self.elements[groupItem:getID()]
            if ge then
                local behavior = gameNightWindow.getGroupBehavior(groupItem)
                local radius = behavior and behavior.clusterRadius or 18
                local angle = count > 1 and ((i-1) / count) * math.pi * 2 or 0
                local relX = scaledX + (ge.x - element.x) / wW
                local relY = scaledY + (ge.y - element.y) / wH
                local clustX = scaledX + math.cos(angle) * radius / wW
                local clustY = scaledY + math.sin(angle) * radius / wH
                local gx = relX + (clustX - relX) * t
                local gy = relY + (clustY - relY) * t
                if behavior and behavior.onRelease then
                    behavior.onRelease(groupItem, self, gx, gy)
                else
                     gamePieceHandler.pickupAndPlaceGamePiece(
                        self.player, groupItem, nil, detailsFunc, gx, gy, offsetZ, self.square, angleChange)
                end
            end
        end
        self.movingGroup = nil
        self.selection = {}
        self:resetShake()
    end
end


function gameNightWindow:onContextSelection(element, x, y)

    if  gamePieceHandler.itemIsBusy(element.item) then return end

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


function gameNightWindow:finalizeDragSelect(x, y)
    local ds = self.dragSelect
    self.dragSelect = nil
    if not ds then return end

    local x1 = math.min(ds.x1, ds.x2)
    local y1 = math.min(ds.y1, ds.y2)
    local x2 = math.max(ds.x1, ds.x2)
    local y2 = math.max(ds.y1, ds.y2)

    if (x2-x1) < 4 and (y2-y1) < 4 then return end

    self.selection = {}
    for id, element in pairs(self.elements) do
        if element.x >= x1 and element.x <= x2 and element.y >= y1 and element.y <= y2 then
            self.selection[id] = element
        end
    end
end


function gameNightWindow:onBatchContextSelection(x, y)
    local selected = self.selection
    local hasItems = false
    for _ in pairs(selected) do hasItems = true break end
    if not hasItems then return end

    local player = self.player
    local playerID = player:getPlayerNum()
    local window = self

    local items = {}
    for _, element in pairs(selected) do
        if element.item and not  gamePieceHandler.itemIsBusy(element.item) then
            table.insert(items, element.item)
        end
    end
    if #items == 0 then return end

    local context = ISContextMenu.get(playerID, getMouseX(), getMouseY())

    for _, action in ipairs(gameNightWindow.batchActionList) do
        local matching = {}
        for _, item in ipairs(items) do
            if action.filter(item) then
                table.insert(matching, item)
            end
        end
        if #matching > 0 then
            local lbl = action.label(#matching)
            local fn = action.fn
            context:addOption(lbl, matching, function(itms)
                for _, itm in ipairs(itms) do
                    fn(itm, window)
                end
            end)
        end
    end

    local function pickUpAll(itms)
        for _, item in ipairs(itms) do
             gamePieceHandler.pickupGamePiece(player, item)
        end
        window.selection = {}
        window.elementsDirty = true
    end
    context:addOption(getText("IGUI_pickUpAll"), items, pickUpAll)
end


function gameNightWindow:animateAndRollDie(item, player, x, y, z)
    local fullType = item:getFullType()
    local special =  gamePieceHandler.specials[fullType]
    local sides = special and special.actions and special.actions.rollDie
    if not sides then return end

    local addTextureDir = special and special.addTextureDir or ""
    local faceTextures = {}
    for face = 1, sides do
        local faceAltState = face > 1 and (item:getType()..face) or nil
        local tex =  gamePieceHandler.fetchIconState(item, "Item_InPlayTextures", addTextureDir, faceAltState)
        if tex then faceTextures[face] = tex end
    end

    local el = self.elements[item:getID()]
    local mx, my = self:getMouseX(), self:getMouseY()
    local dragDX = el and (mx - el.x) or 0
    local dragDY = el and (my - el.y) or 0
    local dragDist = math.sqrt(dragDX * dragDX + dragDY * dragDY)
    local shakeT = self.shake.T
    local effectiveDist = dragDist + self.shake.energy * 1.5 * shakeT

    local speed = math.min(dragDist * 0.18, 90)
    local vx, vy
    if dragDist > 5 then
        vx = (dragDX / dragDist) * speed + ZombRandFloat(-2, 2)
        vy = (dragDY / dragDist) * speed + ZombRandFloat(-2, 2)
    else
        vx = (ZombRand(2) == 0 and 1 or -1) * ZombRandFloat(20, 30)
        vy = (ZombRand(2) == 0 and 1 or -1) * ZombRandFloat(15, 24)
    end

    gameNightPhysics.spawn(item, "die", {
        x = el and el.x or (self.width / 2),
        y = el and el.y or (self.height / 2),
        rot = el and el.rot or 0,
        vx = vx,
        vy = vy,
        angularV = ZombRandFloat(-14, 14) * math.max(1, effectiveDist * 0.07),
        mass = el and el.mass or 1,
        data = { faceTextures = faceTextures },
    })

     gamePieceHandler.rollDie_direct(item, player, nil, x, y, z)
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
function gameNightWindow:buildElement(item, object, priority)

    applyItemDetails.applyGameNightToItem(item)

    local md = item:getModData()
    ---@type Texture
    local texture = md["gameNight_textureInPlay"] or item:getTexture()

    local fullType = item:getFullType()
    local specialCase = fullType and  gamePieceHandler.specials[fullType]
    local specialTextureSize = specialCase and specialCase.textureSize

    local w = (specialTextureSize and specialTextureSize[1] or texture:getWidth()) * gameNightWindow.scaleSize
    local h = (specialTextureSize and specialTextureSize[2] or texture:getHeight()) * gameNightWindow.scaleSize

    local pad = self.padding*2
    local windowW = self.width-pad
    local windowH = self.height-pad
    local x = self.round(((object:getWorldPosX()-object:getX()) * windowW) + w/2, -5)
    local y = self.round(((object:getWorldPosY()-object:getY()) * windowH) + h/2, -5)
    x = math.min(math.max(x, w/2), self.width-(w/2))
    y = math.min(math.max(y, h/2), self.height-(h/2))

    local rot = md["gameNight_rotation"] or 0
    local locked = md["gameNight_locked"]

    local tex = Texture.new(texture)
    tex:setHeight(h)
    tex:setWidth(w)

    local altRend = specialCase and specialCase.alternateStackRendering
    local depth, drawFunc, drawR, drawG, drawB, drawSides, drawSideTex

    depth, drawFunc =  gamePieceHandler.getDepthAndFunc(item, specialCase)
    if depth then
        drawR, drawG, drawB = 1, 1, 1
        if altRend and altRend.rgb then drawR, drawG, drawB = unpack(altRend.rgb) end
        drawSides = altRend and altRend.sides or 12
        drawSideTex = altRend and altRend.sideTexture
    end

    self.elements[item:getID()] = {
        x=x, y=y, w=w, h=h, item=item, rot=rot, priority=priority, locked=locked,
        depth=depth, tex=tex,
        drawFunc=drawFunc, drawR=drawR, drawG=drawG, drawB=drawB,
        drawSides=drawSides, drawSideTex=drawSideTex,
        solid = specialCase and specialCase.solid,
        noRotate = specialCase and specialCase.noRotate,
        mass = specialCase and specialCase.mass or 1,
        physicsType = specialCase and specialCase.physicsType,
    }
end


function gameNightWindow:drawElement(element)
    local x, y, rot = element.x, element.y, element.rot
    local rawTex = element.item:getModData()["gameNight_textureInPlay"] or element.item:getTexture()
    local tex = Texture.new(rawTex)
    tex:setWidth(element.w)
    tex:setHeight(element.h)

    local physObj = gameNightPhysics.objects[element.item:getID()]
    if physObj then
        if gameNightPhysics.update(physObj, element, self) then
            local customRender = physObj.props.render
            if customRender then
                customRender(physObj, element, self)
            else
                if element.drawFunc then
                    volumetricRender[element.drawFunc](self, tex, element.drawSideTex,
                        physObj.x, physObj.y, physObj.rot,
                        element.depth, element.drawSides,
                        element.drawR, element.drawG, element.drawB, 1)
                else
                    self:DrawTextureAngle(tex, physObj.x, physObj.y, physObj.rot, 1, 1, 1, 0.9)
                end
            end
        end
        return
    end

    if element.drawFunc then
        volumetricRender[element.drawFunc](self, tex, element.drawSideTex,
            x, y, rot, element.depth, element.drawSides,
            element.drawR, element.drawG, element.drawB, 1)
    else
        if not tex then return end
        self:DrawTextureAngle(tex, x, y, rot)
    end

    local w2, h2 = element.w/2, element.h/2
    if self.selection and self.selection[element.item:getID()] then
        self:drawRectBorder(x-w2, y-h2, element.w, element.h, 0.85, 0.25, 0.75, 0.9)
    elseif  gamePieceHandler.itemIsBusy(element.item) then
        self:drawRectBorder(x-w2, y-h2, element.w, element.h, 0.8, 0.85, 0.55, 0.1)
    end
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
gameNightWindow.batchActions = {} -- keyed by actionID, for O(1) dispatch lookup
gameNightWindow.batchActionList = {} -- ordered array

---@param actionID string
---@param props table|function
function gameNightWindow.registerBatchAction(actionID, props)
    if type(props) == "function" then
        props = { fn = props }
    end

    local entry = {
        id = actionID,
        fn = props.fn,
        filter = props.filter or function(item)
            local sp =  gamePieceHandler.specials[item:getFullType()]
            return sp and sp.actions and sp.actions[actionID]
        end,
        label = props.label or function(_)
            return getText("IGUI_"..actionID) .. getText("IGUI_SpecialActionAll")
        end,
    }

    gameNightWindow.batchActions[actionID] = entry
    for i, b in ipairs(gameNightWindow.batchActionList) do
        if b.id == actionID then
            gameNightWindow.batchActionList[i] = entry
            return
        end
    end
    table.insert(gameNightWindow.batchActionList, entry)
end


gameNightWindow.groupBehaviors = {}


function gameNightWindow.registerGroupBehavior(name, props)
    for i, b in ipairs(gameNightWindow.groupBehaviors) do
        if b.name == name then
            gameNightWindow.groupBehaviors[i] = {name=name, props=props}
            return
        end
    end
    table.insert(gameNightWindow.groupBehaviors, {name=name, props=props})
end


function gameNightWindow.getGroupBehavior(item)
    for _, b in ipairs(gameNightWindow.groupBehaviors) do
        if b.props.match and b.props.match(item) then return b.props end
    end
    return nil
end


function gameNightWindow.fetchShiftAction(gamePiece, forceShift)
    if not forceShift and not isShiftKeyDown() then return end

    local specialCase =  gamePieceHandler.specials[gamePiece:getFullType()]
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
            if item and item:hasTag(gnTags.GAME_NIGHT) then
                local sp = gamePieceHandler.specials[item:getFullType()]
                if not (sp and sp.hideUI) then
                    local position = item:getDisplayCategory() == "GameBoard" and 1 or #loadOrder+1
                    table.insert(loadOrder, position, {item=item, object=object})
                end
            end
        end
    end

    local currentCount = #loadOrder
    if self.elementsDirty or currentCount ~= self.lastElementCount then
        table.sort(loadOrder, gameNightWindow.compareElements)
        self.elements = {}
        for priority,stuff in pairs(loadOrder) do self:buildElement(stuff.item, stuff.object, priority) end
        self.lastElementCount = currentCount
        self.elementsDirty = false
    end

    for _,element in pairs(self.elements) do self:drawElement(element) end

    do
        local cmx, cmy = self:getMouseX(), self:getMouseY()
        self.prevMouseX = cmx
        self.prevMouseY = cmy
    end


    if self.dragSelect then
        if isMouseButtonDown(0) then
            self.dragSelect.x2 = self:getMouseX()
            self.dragSelect.y2 = self:getMouseY()
            local ds = self.dragSelect
            local rx = math.min(ds.x1, ds.x2)
            local ry = math.min(ds.y1, ds.y2)
            local rw = math.abs(ds.x2 - ds.x1)
            local rh = math.abs(ds.y2 - ds.y1)
            self:drawRect(rx, ry, rw, rh, 0.12, 0.25, 0.65, 0.9)
            self:drawRectBorder(rx, ry, rw, rh, 0.7, 0.25, 0.65, 0.9)
        else
            self:finalizeDragSelect(self:getMouseX(), self:getMouseY())
        end
    end

    gameNightWindow.cursor = gameNightWindow.cursor or getTexture("media/textures/actionIcons/gamenight_cursor.png")
    gameNightWindow.cursorW = gameNightWindow.cursorW or (gameNightWindow.cursor and gameNightWindow.cursor:getWidth())
    gameNightWindow.cursorH = gameNightWindow.cursorH or (gameNightWindow.cursor and gameNightWindow.cursor:getHeight())

    if gameNightWindow.cursor then
        for username,data in pairs(self.cursorDraws) do
            if data then
                data.ticks = data.ticks - 1
                self:drawTextureScaledUniform(gameNightWindow.cursor, data.x, data.y, gameNightWindow.scaleSize, 1, data.r, data.g, data.b)
                if data.x then
                    self:drawText(username, data.x+(gameNightWindow.cursorW or 0), data.y, data.r, data.g, data.b, 1, UIFont.NewSmall)
                end
                if data.ticks <= 0 then self.cursorDraws[username] = nil end
            end
        end
    end

    if movingPiece then
        if not isMouseButtonDown(0) then return end

        local coolDown =  gamePieceHandler.itemCoolDown(movingPiece)
        local coolDownMismatch = (self.movingPieceOriginStamp and coolDown and self.movingPieceOriginStamp ~= coolDown)
        local busy =  gamePieceHandler.itemIsBusy(movingPiece)
        if busy or coolDownMismatch then
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

            if self.movingGroup then
                local count = #self.movingGroup
                for gi, groupItem in ipairs(self.movingGroup) do
                    local ge = self.elements[groupItem:getID()]
                    if ge then
                        local gTex = groupItem:getModData()["gameNight_textureInPlay"] or groupItem:getTexture()
                        local gRot = (groupItem:getModData()["gameNight_rotation"] or 0) + self.rotatingPieceDegree
                        local gTmp = Texture.new(gTex)
                        gTmp:setWidth(ge.w)
                        gTmp:setHeight(ge.h)
                        local behavior = gameNightWindow.getGroupBehavior(groupItem)
                        local radius = behavior and behavior.clusterRadius or 18
                        local angle = count > 1 and ((gi-1) / count) * math.pi * 2 or 0
                        local relX = x + (ge.x - movingElement.x)
                        local relY = y + (ge.y - movingElement.y)
                        local clustX = x + math.cos(angle) * radius
                        local clustY = y + math.sin(angle) * radius
                        local gx = relX + (clustX - relX) * self.shake.T
                        local gy = relY + (clustY - relY) * self.shake.T
                        self:DrawTextureAngle(gTmp, gx, gy, gRot, 1, 1, 1, 0.55)
                    end
                end
            end
        end

        local selection
        if deckActionHandler.isDeckItem(movingPiece) or  gamePieceHandler.canStackPiece(movingPiece) then
            for _,element in pairs(self.elements) do
                if element.item and (element.item~=movingPiece) and (movingPiece:getType() == element.item:getType()) then
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
        if not element.item then return end
        local fullType = element.item:getFullType()
        local specialCase = fullType and  gamePieceHandler.specials[fullType]

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

            local busy =  gamePieceHandler.itemIsBusy(element.item)
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
    local sidebar = gameNightBoxSidebar.instance
    if sidebar then sidebar:close() end

    for k in pairs(gameNightPhysics.objects) do gameNightPhysics.objects[k] = nil end
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

    gameNightBoxSidebar.open(player, window)

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
    o.elementsDirty = true
    o.lastElementCount = 0
    o.selection = {}
    o.dragSelect = nil
    o.movingGroup = nil
    o.movingPieceFromBox = nil
    o.prevMouseX = nil
    o.prevMouseY = nil
    o.shake = {
        history = {},
        reversals = {},
        eventCount = 0,
        grouped = false,
        energy = 0,
        T = 0,
        originX = nil,
        originY = nil,
        prevDX = 0,
        prevDY = 0,
    }
    o.dragVelHistory = {}
    o.dragVelX = 0
    o.dragVelY = 0

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


local function dieOnRest(obj, window)
    local el = window.elements[obj.item:getID()]
    local sx, sy = gameNightPhysics.toWorldCoords(obj, el or {w=0, h=0}, window)
     gamePieceHandler.pickupAndPlaceGamePiece(
        window.player, obj.item, nil,
         gamePieceHandler.handleDetails,
        sx, sy, 0, window.square)
    window.elementsDirty = true
end

local function dieRender(obj, element, window)
    local faceTextures = obj.data.faceTextures
    local faceCount = faceTextures and #faceTextures or 0
    local frameTex = (faceCount > 0) and faceTextures[ZombRand(faceCount) + 1] or element.tex
    local progress = 1 - (obj.ticks / obj.maxTicks)
    local wobble = obj.rot + ZombRandFloat(-65, 65) * progress
    local tmp = Texture.new(frameTex)
    tmp:setWidth(element.w)
    tmp:setHeight(element.h)
    window:DrawTextureAngle(tmp, obj.x, obj.y, wobble, 1, 1, 1, 1)
end

gameNightPhysics.registerType("die", {
    friction = 0.91,
    restitution = 1.0,
    angularFriction = 0.93,
    minSpeed = 1.2,
    duration = 90,
    collide = true,
    onRest = dieOnRest,
    render = dieRender,
})

gameNightPhysics.registerType("piece", {
    friction = 0.87,
    restitution = 0.35,
    angularFriction = 0.85,
    minSpeed = 0.8,
    duration = 120,
    collide = true,
    onRest = dieOnRest,
})


for actionID, meta in pairs(gamePieceHandler.batchMeta) do
    gameNightWindow.registerBatchAction(actionID, {
        fn = meta.fn or function(item, window, x, y)
            local fn =  gamePieceHandler[actionID]
            if fn then fn(item, window.player, x, y, 0, window.square) end
        end,
        filter = meta.filter,
        label = meta.label,
    })
end


for name, meta in pairs( gamePieceHandler.groupMeta) do
    gameNightWindow.registerGroupBehavior(name, {
        match = meta.match,
        clusterRadius = meta.clusterRadius or 6,
        onRelease = meta.onRelease or function(item, window, x, y)
             gamePieceHandler.pickupAndPlaceGamePiece(
                window.player, item, nil,  gamePieceHandler.handleDetails, x, y, 0, window.square, window.rotatingPieceDegree)
        end,
    })
end


gameNightWindow.registerGroupBehavior("default", {
    match = function(item) return true end,
    clusterRadius = 6,
    onRelease = function(item, window, x, y)
         gamePieceHandler.pickupAndPlaceGamePiece(
            window.player, item, nil,  gamePieceHandler.handleDetails, x, y, 0, window.square, window.rotatingPieceDegree)
    end,
})
