require "ISUI/ISPanelJoypad"
require "gameNight - gameElement"

---@class gameNightWindow : ISPanel
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")

gameNightWindow.elements = {}

function gameNightWindow:initialise()
    ISPanelJoypad.initialise(self)

    local btnWid = 100
    local btnHgt = 25
    local padBottom = 10

    self.close = ISButton:new(45, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, gameNightWindow.onClick)
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)
end


function gameNightWindow:onClick(button)
    if button.internal == "CLOSE" then
        self:setVisible(false)
        --self:removeFromUIManager()
    end
end


function gameNightWindow:prerender()
    ISPanelJoypad.prerender(self)
    for item,element in pairs(self.elements) do element:setVisible(false) end
end



function gameNightWindow:render()
    ---@type IsoGridSquare
    local square = self.square
    if not square then return end

    local padding = 45
    self:drawRectBorder(padding, padding, (self.width-(padding*2)), (self.height-(padding*2)), 0.8, 0.8, 0.8, 0.8)

    for i=0, square:getObjects():size()-1 do
        ---@type IsoObject|IsoWorldInventoryObject
        local object = square:getObjects():get(i)
        if object and instanceof(object, "IsoWorldInventoryObject") then
            local item = object:getItem()
            if item and item:getTags():contains("gameNight") then

                ---@type gameNightElement
                local element = self.elements[item]
                local x = (object:getWorldPosX()-object:getX()) * (self.width-45)
                local y = (object:getWorldPosY()-object:getY()) * (self.height-45)
                local texture = item:getTexture()

                if not element then
                    print(item:getName())
                    local w, h = texture:getWidth(), texture:getHeight()
                    self.elements[item] = gameNightElement:new(x, y, w, h, item, self)
                    element = self.elements[item]
                    self:addChild(element)
                end

                if element then
                    element:setVisible(true)
                    element:setX(x)
                    element:setY(y)
                    element:drawTexture(texture, 0, 0, 1, 1, 1, 1)
                end
                --print(item:getName(), " : ", textureX, ", ", textureY)
            end
        end
    end
end


function gameNightWindow.open(self, player, square)

    if not gameNightWindow.instance then
        gameNightWindow:new(nil, nil, 500, 500, player, square)

        gameNightWindow.instance:initialise()
        gameNightWindow.instance:addToUIManager()
        --gameNightWindow.instance:setVisible(false)
        --gameNightWindow.instance:removeFromUIManager()
    end
    gameNightWindow.instance.square = square
    gameNightWindow.instance:setVisible(true)

    return gameNightWindow.instance
end


function gameNightWindow:new(x, y, width, height, player, square)
    local o = {}
    x = x or getCore():getScreenWidth() / 2 - (width / 2)
    y = y or getCore():getScreenHeight() / 2 - (height / 2)
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}

    o.width = width
    o.height = height
    o.player = player
    o.square = square

    o.moveWithMouse = true
    o.selectedItem = nil
    o.pendingRequest = false

    gameNightWindow.instance = o

    return o
end