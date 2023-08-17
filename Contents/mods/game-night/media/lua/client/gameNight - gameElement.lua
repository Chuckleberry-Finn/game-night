require "ISUI/ISPanelJoypad"

---@class gameNightElement : ISPanelJoypad
gameNightElement = ISPanelJoypad:derive("gameNightElement")

function gameNightElement:initialise()
    ISPanelJoypad.initialise(self)
end


function gameNightElement:onClick(button)

end

function gameNightElement:onMouseUp(x, y)
    ---@type IsoObject|IsoWorldInventoryObject
    local item = self.item
    if not item then return end

    ISPanelJoypad.onMouseUp(self, x, y)

    local window = self:getParent()
    local windowW, windowH = (window.width-45), (window.height-45)

    local newX = x/windowW
    local newY = y/windowH

    print(newX, ", ", newY)

    ISTimedActionQueue.add(ISInventoryTransferAction:new(window.player, item, item:getContainer(), window.player:getInventory(), 0))
    ISTimedActionQueue.add(ISDropWorldItemAction:new(window.player, item, window.square, newX, newY, 0, 0, false))
    --self:setX(x)
    --self:setY(y)
end

function gameNightElement:prerender()
    ISPanelJoypad.prerender(self)
end



function gameNightElement:render()

end


function gameNightElement:new(x, y, width, height, item)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.item = item

    o.borderColor = {r=0, g=0, b=0, a=0}
    o.backgroundColor = {r=0, g=0, b=0, a=0}

    o.moveWithMouse = true
    o.selectedItem = nil
    o.pendingRequest = false

    return o
end