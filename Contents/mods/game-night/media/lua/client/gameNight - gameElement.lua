require "ISUI/ISPanelJoypad"

---@class gameNightElement : ISPanelJoypad
gameNightElement = ISPanelJoypad:derive("gameNightElement")


function gameNightElement:initialise() ISPanelJoypad.initialise(self) end


--[[
function gameNightElement:onRightMouseUp(x, y)
    self.moveWithMouse = not self.moveWithMouse
    self.borderColor = {r=1, g=1, b=1, a=(self.moveWithMouse and 0 or 0.6)}
end
--]]


function gameNightElement:onMouseUpOutside(x, y) self:moveElement(x, y) end
function gameNightElement:onMouseUp(x, y) self:moveElement(x, y) end
function gameNightElement:moveElement(x, y)

    if not self.moveWithMouse or not self.moving then return end
    self.moving = false

    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    ---@type IsoObject|IsoWorldInventoryObject
    local item = self.itemObject
    if not item then return end

    --old(self, x, y)

    local selfW, selfH = self:getWidth(), self:getHeight()

    local newX = (self:getX()+x)-window.x-(selfW/2)
    local newY = (self:getY()+y)-window.y-(selfH/2)

    newX = math.min(math.max(newX, window.bounds.x1), window.bounds.x2-selfW)
    newY = math.min(math.max(newY, window.bounds.y1), window.bounds.y2-selfH)

    if newX < window.bounds.x1 or newY < window.bounds.y1 or newX > window.bounds.x2 or newY > window.bounds.y2 then return end

    local boundsDifference = window.padding*2
    local scaledX = newX/(window.width-boundsDifference)
    local scaledY = newY/(window.height-boundsDifference)

    local maintain_z = item:getWorldItem() and item:getWorldItem():getWorldPosZ() or 0
    ISTimedActionQueue.add(ISInventoryTransferAction:new(window.player, item, item:getContainer(), window.player:getInventory(), 0))
    local dropAction = ISDropWorldItemAction:new(window.player, item, window.square, scaledX, scaledY, maintain_z, 0, false)
    dropAction.maxTime = 1
    ISTimedActionQueue.add(dropAction)
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
    local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, oX, oY)
    return true
end


function gameNightElement:getPriorityPiece(x, y, window)
    local cursorX, cursorY = x+self.x, y+self.y
    local selection = self
    for item,element in pairs(window.elements) do
        if element:isVisible() then
            local inBounds = ((cursorX >= element.x) and (cursorY >= element.y) and (cursorX <= element.x+element.width) and (cursorY <= element.y+element.height))
            if inBounds and element.priority > selection.priority then
                selection = element
            end
        end
    end
    return selection
end


function gameNightElement:onRightMouseDown(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    local selection = self:getPriorityPiece(x, y, window)
    selection:onContextSelection(self, x, y)
end


function gameNightElement:onMouseDown(x, y)
    if self.moving then return end
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    local selection = self:getPriorityPiece(x, y, window)
    --ISPanelJoypad.onMouseDown(selection, x, y)
    selection.moving = true
end


function gameNightElement:prerender()
    ISPanelJoypad.prerender(self)
    local window = gameNightWindow.instance--self:getParent()
    if not window or not window:isVisible() then
        self:setVisible(false)
    end

    if self.moving then
        local selfW, selfH = self:getWidth(), self:getHeight()
        local texture = self.itemObject:getModData()["gameNight_textureInPlay"] or self.itemObject:getTexture()
        self:drawTexture(texture, self:getMouseX()-(selfW/2), self:getMouseY()-(selfH/2), 0.55, 1, 1, 1)
    end
end


function gameNightElement:render() ISPanelJoypad.render(self) end


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