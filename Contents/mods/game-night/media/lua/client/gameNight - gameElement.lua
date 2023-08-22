require "ISUI/ISPanelJoypad"

---@class gameNightElement : ISPanelJoypad
gameNightElement = ISPanelJoypad:derive("gameNightElement")

function gameNightElement:initialise()
    ISPanelJoypad.initialise(self)
end


function gameNightElement:onClick(button)

end


function gameNightElement:onRightMouseUp(x, y)

    local window = gameNightWindow.instance
    if not window or not window:isVisible() or not window.mouseOver then return end

    ---@type IsoPlayer|IsoGameCharacter
    local playerObj = window.player
    local playerID = playerObj:getPlayerNum()

    ---@type InventoryItem
    local item = self.itemObject
    local isInInv = item:getContainer():isInCharacterInventory(playerObj)

    local contextMenuItems = {item}
    if self.toolRender then self.toolRender:setVisible(false) end

    local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, self:getAbsoluteX()+x, self:getAbsoluteY()+y+self:getYScroll());

    return true
end


function gameNightElement:onMoveElement(old, x, y)

    local window = gameNightWindow.instance--self:getParent()
    if not window or not window:isVisible() or not window.mouseOver then return end

    if not self.moving then return end

    local padding = 45
    local bounds = padding*2

    ---@type IsoObject|IsoWorldInventoryObject
    local item = self.itemObject
    if not item then return end

    print("item: ", tostring(item))

    old(self, x, y)

    local windowW, windowH = (window.width-padding), (window.height-padding)

    local selfW, selfH = self:getWidth(), self:getHeight()

    local newX = (self:getX()+x)-window.x-(selfW/2)
    local newY = (self:getY()+y)-window.y-(selfH/2)

    local windowBounds = {x1=padding, y1=padding, x2=window.width-padding, y2=window.height-padding}

    newX = math.min(math.max(newX, windowBounds.x1), windowBounds.x2-selfW)
    newY = math.min(math.max(newY, windowBounds.y1), windowBounds.y2-selfH)

    if newX < windowBounds.x1 or newY < windowBounds.y1 or newX > windowBounds.x2 or newY > windowBounds.y2 then
        return
    end

    local scaledX = newX/(window.width-bounds)
    local scaledY = newY/(window.height-bounds)

    print(x,", ",y," -> ", scaledX, ", ", scaledY)
    --self:setX(x)
    --self:setY(y)
    local maintain_z = item:getWorldItem() and item:getWorldItem():getWorldPosZ() or 0
    ISTimedActionQueue.add(ISInventoryTransferAction:new(window.player, item, item:getContainer(), window.player:getInventory(), 0))
    local dropAction = ISDropWorldItemAction:new(window.player, item, window.square, scaledX, scaledY, maintain_z, 0, false)
    dropAction.maxTime = 1
    ISTimedActionQueue.add(dropAction)

end


function gameNightElement:onMouseUpOutside(x, y) self:onMoveElement(ISPanelJoypad.onMouseUpOutside, x, y) end

function gameNightElement:onMouseUp(x, y) self:onMoveElement(ISPanelJoypad.onMouseUp, x, y) end


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



function gameNightElement:render()

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