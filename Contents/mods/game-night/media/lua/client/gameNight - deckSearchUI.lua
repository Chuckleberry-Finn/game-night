require "ISUI/ISPanelJoypad"

---@class gameNightDeckSearch : ISPanelJoypad
gameNightDeckSearch = ISPanelJoypad:derive("gameNightDeckSearch")


function gameNightDeckSearch:closeAndRemove()
    self:setVisible(false)
    self:removeFromUIManager()
end


function gameNightDeckSearch:update()
    --TODO: Make this check if item is in inventory
    --if (not self.player) or (not self.square) or (not luautils.isSquareAdjacentToSquare(self.square, self.player:getSquare())) then
    --    self:closeAndRemove()
     --   return
    --end
end


function gameNightDeckSearch:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end




function gameNightDeckSearch:onMouseUpOutside(x, y)
    ISPanelJoypad.onMouseUpOutside(self, x, y)
end


function gameNightDeckSearch:onMouseDownOutside(x, y)
    ISPanelJoypad.onMouseDownOutside(self, x, y)
end


function gameNightDeckSearch:onMouseUp(x, y)
    ISPanelJoypad.onMouseUp(self, x, y)
end


function gameNightDeckSearch:onMouseDown(x, y)
    ISPanelJoypad.onMouseDown(self, x, y)
end


function gameNightDeckSearch:getCardOver()
    local x, y = self:getMouseX(), self:getMouseY()


end


function gameNightDeckSearch:prerender()
    ISPanelJoypad.prerender(self)

    local cardData, cardFlipStates = self.deckActionHandler.getDeckStates(self.deck)
    local itemType = self.deck:getType()

    local halfPad = self.padding/2
    local xOffset, yOffset = self.bounds.x1+halfPad, self.bounds.y1+halfPad
    local resetXOffset = xOffset

    for n=#cardData, 1, -1 do

        local card = cardData[n]
        local flipped = cardFlipStates[n]

        local texturePath = (flipped and "media/textures/Item_"..itemType.."/FlippedInPlay.png") or "media/textures/Item_"..itemType.."/"..card..".png"
        local texture = getTexture(texturePath)

        if self.cardSize+xOffset > self.bounds.x2 then
            xOffset = resetXOffset
            yOffset = yOffset+self.cardSize
        end

        self:drawTexture(texture, xOffset, yOffset, 1, 1, 1, 1)
        xOffset = xOffset+self.cardSize+halfPad

    end

    self:drawRectBorder(self.bounds.x1, self.bounds.y1,
            self.bounds.x2-self.padding, self.bounds.y2-self.close.height-(self.padding*2),
            self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
end


function gameNightDeckSearch:render() ISPanelJoypad.render(self) end


function gameNightDeckSearch:initialise()
    ISPanelJoypad.initialise(self)

    local closeText = getText("UI_Close")
    local btnWid = getTextManager():MeasureStringX(UIFont.Small, closeText)+10
    local btnHgt = 25
    local pd = self.padding

    self.close = ISButton:new(self.width-pd-btnWid, pd, btnWid, btnHgt, closeText, self, gameNightDeckSearch.onClick)
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)

    self.deckActionHandler = require "gameNight - deckActionHandler"

    self.bounds = {x1=pd, y1=btnHgt+(pd*2), x2=self.width-pd, y2=self.height-pd}
end



function gameNightDeckSearch.open(player, deckItem)

    if gameNightDeckSearch.instance then gameNightDeckSearch.instance:closeAndRemove() end

    local window = gameNightDeckSearch:new(nil, nil, 470, 500, player, deckItem)
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

    o.moveWithMouse = true

    o.cardSize = 48

    o.width = width
    o.height = height
    o.player = player
    o.deck = deckItem

    o.padding = 10

    gameNightDeckSearch.instance = o
    return o
end