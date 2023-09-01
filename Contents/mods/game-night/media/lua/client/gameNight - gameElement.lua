require "ISUI/ISPanelJoypad"

---@class gameNightElement : ISPanelJoypad
gameNightElement = ISPanelJoypad:derive("gameNightElement")


function gameNightElement:initialise() ISPanelJoypad.initialise(self) end


function gameNightElement:onMouseUp(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    window:onMouseUp(window:getMouseX(), window:getMouseY())
end


function gameNightElement:moveElement(x, y)

    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    if not self.moveWithMouse or not window.movingPiece or self~=window.movingPiece then return end

    window.movingPiece = nil

    ---@type IsoObject|IsoWorldInventoryObject
    local item = self.itemObject
    if not item then return end

    local selfW, selfH = self:getWidth(), self:getHeight()

    local offsetX = window.movingPieceOffset and window.movingPieceOffset[1] or 0
    local offsetY = window.movingPieceOffset and window.movingPieceOffset[2] or 0

    local newX = (self:getX()+x)-window.x-(offsetX)
    local newY = (self:getY()+y)-window.y-(offsetY)

    newX = math.min(math.max(newX, window.bounds.x1), window.bounds.x2-selfW)
    newY = math.min(math.max(newY, window.bounds.y1), window.bounds.y2-selfH)

    if newX < window.bounds.x1 or newY < window.bounds.y1 or newX > window.bounds.x2 or newY > window.bounds.y2 then return end

    local boundsDifference = window.padding*2
    local scaledX = (newX/(window.width-boundsDifference))
    local scaledY = (newY/(window.height-boundsDifference))

    local sound = item:getModData()["gameNight_sound"]
    if sound then window.player:getEmitter():playSound(sound) end

    if luautils.haveToBeTransfered(window.player, item, true) then
        local pickUpAction = ISInventoryTransferAction:new(window.player, item, item:getContainer(), window.player:getInventory(), 0)
        ISTimedActionQueue.add(pickUpAction)
    end

    local dropAction = ISDropWorldItemAction:new(window.player, item, window.square, scaledX, scaledY, 0, 0, false)
    dropAction.maxTime = 0
    ISTimedActionQueue.add(dropAction)

    local pBD = window.player:getBodyDamage()
    pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-0.5))
end

function gameNightElement.lockInPlace()
    self.moveWithMouse = not self.moveWithMouse
    self.javaObject:setConsumeMouseEvents(self.moveWithMouse)
end

function gameNightElement:onContextSelection(o, x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    ---@type IsoPlayer|IsoGameCharacter
    local playerObj = window.player
    local playerID = playerObj:getPlayerNum()

    ---@type InventoryItem
    local item = self.itemObject
    local itemContainer = item and item:getContainer() or false
    local isInInv = itemContainer and itemContainer:isInCharacterInventory(playerObj) or false

    local contextMenuItems = {item}
    if self.toolRender then self.toolRender:setVisible(false) end

    local oX, oY = o:getAbsoluteX()+x, o:getAbsoluteY()+y+o:getYScroll()
    ---@type ISContextMenu
    local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, oX, oY)
    menu:addOption(getText("IGUI_lockElement"), self, gameNightElement.lockInPlace)
    return true
end


function gameNightElement:onRightMouseDown(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    local selection = window:getClickedPriorityPiece(x, y, self)
    selection:onContextSelection(self, x, y)
    ISPanelJoypad.onRightMouseDown(selection)
end


function gameNightElement:onMouseDown(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() or not self.moveWithMouse then return end
    local selection = window:getClickedPriorityPiece(x, y, self)
    window.movingPiece = selection
    window.movingPieceOffset = {selection:getMouseX(),selection:getMouseY()}
    ISPanelJoypad.onMouseDown(selection)
end


function gameNightElement:prerender()
    ISPanelJoypad.prerender(self)
    if not self:isVisible() then return end

    ---@type ISPanelJoypad
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    local sandbox = SandboxVars.GameNight.DisplayItemNames
    if sandbox and self:isMouseOver() and (not window.movingPiece) then
        self.nameTag = self.nameTag or (self.itemObject and self.itemObject:getName())
        self.nameTagWidth = self.nameTagWidth or getTextManager():MeasureStringX(UIFont.NewSmall, " "..self.nameTag.." ")
        self.nameTagHeight = self.nameTagHeight or getTextManager():getFontHeight(UIFont.NewSmall)

        local x, y = self:getMouseX()+(window.cursorW or 0), self:getMouseY()-(window.cursorH or 0)
        self:drawRect(x, y, self.nameTagWidth, self.nameTagHeight, 0.7, 0, 0, 0)
        self:drawTextCentre(self.nameTag, x+(self.nameTagWidth/2), y, 1, 1, 1, 0.7, UIFont.NewSmall)
    end
end


function gameNightElement:render()
    ISPanelJoypad.render(self)
end


function gameNightElement:new(x, y, width, height, itemObject)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.itemObject = itemObject

    o.borderColor = {r=1, g=1, b=1, a=0}
    o.backgroundColor = {r=1, g=1, b=1, a=0}

    o.moveWithMouse = true
    o.selectedItem = nil
    o.pendingRequest = false

    return o
end