require "ISUI/ISPanelJoypad"

---@class gameNightWindow : ISPanel
gameNightWindow = ISPanelJoypad:derive("gameNightWindow")

function gameNightWindow:initialise()
    ISPanelJoypad.initialise(self)
end


function gameNightWindow:prerender()
end


function gameNightWindow:render()
end


function gameNightWindow:open(player, locX, locY)

    if not gameNightWindow.instance then
        gameNightWindow:new(nil, nil, 500, 500, player, locX, locY)

        gameNightWindow.instance:initialise()
        gameNightWindow.instance:addToUIManager()
        --gameNightWindow.instance:setVisible(false)
        --gameNightWindow.instance:removeFromUIManager()
    end
    gameNightWindow.instance:setVisible(true)

    return gameNightWindow.instance
end


function gameNightWindow:new(x, y, width, height, player, locX, locY)
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
    o.locX = locX
    o.locY = locY

    o.moveWithMouse = true
    o.selectedItem = nil
    o.pendingRequest = false

    gameNightWindow.instance = o

    return o
end