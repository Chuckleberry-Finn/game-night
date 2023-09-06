require "ISUI/ISPanelJoypad"

---@class gameNightDeckSearch : ISPanelJoypad
gameNightDeckSearch = ISPanelJoypad:derive("gameNightDeckSearch")


function gameNightDeckSearch:closeAndRemove()
    self:setVisible(false)
    self:removeFromUIManager()
end


function gameNightWindow:update()
    --TODO: Make this check if item is in inventory
    --if (not self.player) or (not self.square) or (not luautils.isSquareAdjacentToSquare(self.square, self.player:getSquare())) then
    --    self:closeAndRemove()
     --   return
    --end
end


function gameNightDeckSearch:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightDeckSearch:initialise()
    ISPanelJoypad.initialise(self)

    local btnWid = 100
    local btnHgt = 25
    local padBottom = 10

    self.close = ISButton:new(self.width - self.padding, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, gameNightDeckSearch.onClick)
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)

end



function gameNightDeckSearch.open(player, deckItem)

    if gameNightDeckSearch.instance then gameNightDeckSearch.instance:closeAndRemove() end

    local window = gameNightDeckSearch:new(nil, nil, 500, 500, player, deckItem)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)

    return window
end



function gameNightDeckSearch:new(x, y, width, height, player, deckItem)
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
    o.deck = deckItem

    o.padding = 10

    gameNightDeckSearch.instance = o
    return o
end