require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"

---@class gameNightDeckSearch : ISPanel
gameNightDeckSearch = ISPanel:derive("gameNightDeckSearch")


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



--[[
function gameNightDeckSearch:onMouseUpOutside(x, y)
    ISPanel.onMouseUpOutside(self, x, y)
end


function gameNightDeckSearch:onMouseDownOutside(x, y)
    ISPanel.onMouseDownOutside(self, x, y)
end


function gameNightDeckSearch:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)
end


function gameNightDeckSearch:onMouseDown(x, y)
    ISPanel.onMouseDown(self, x, y)
end
--]]


function gameNightDeckSearch:onMouseWheel(del)
    if self.hiddenHeight > 0 then self.scrollY = math.max(0,math.min(self.hiddenHeight, (self.scrollY or 0)+(del*24))) end
    return true
end

function gameNightDeckSearch:getCardOver()
    local x, y = self:getMouseX(), self:getMouseY()

end


function gameNightDeckSearch:prerender()
    ISPanel.prerender(self)
end


function gameNightDeckSearch:render()
    self:setStencilRect(self.cardDisplay.x, self.cardDisplay.y, self.cardDisplay.width, self.cardDisplay.height)
    ISPanel.render(self)
    local cardData, cardFlipStates = self.deckActionHandler.getDeckStates(self.deck)
    local itemType = self.deck:getType()

    local halfPad = self.padding/2
    local xOffset, yOffset = halfPad, halfPad
    local resetXOffset = xOffset

    for n=#cardData, 1, -1 do

        local card = cardData[n]
        local flipped = cardFlipStates[n]

        local texturePath = (flipped and "media/textures/Item_"..itemType.."/FlippedInPlay.png") or "media/textures/Item_"..itemType.."/"..card..".png"
        local texture = getTexture(texturePath)

        if self.cardWidth+xOffset > self.cardDisplay.width+halfPad then
            xOffset = resetXOffset
            yOffset = yOffset+self.cardHeight+halfPad
        end

        self.cardDisplay:drawTexture(texture, xOffset, yOffset-(self.scrollY or 0), 1, 1, 1, 1)
        xOffset = xOffset+self.cardWidth+halfPad
    end
    self.hiddenHeight = math.max(0, yOffset-(self.cardDisplay.height-halfPad-self.cardHeight))
    self:clearStencilRect()
end


function gameNightDeckSearch:initialise()
    ISPanel.initialise(self)

    local closeText = getText("UI_Close")
    local btnWid = getTextManager():MeasureStringX(UIFont.Small, closeText)+10
    local btnHgt = 25
    local pd = self.padding

    self.bounds = {x1=pd, y1=btnHgt+(pd*2), x2=self.width-pd, y2=self.height-pd}

    self.close = ISButton:new(self.width-pd-btnWid, pd, btnWid, btnHgt, closeText, self, gameNightDeckSearch.onClick)
    self.close.internal = "CLOSE"
    self.close.borderColor = {r=1, g=1, b=1, a=0.4}
    self.close:initialise()
    self.close:instantiate()
    self:addChild(self.close)

    self.cardDisplay = ISPanelJoypad:new(self.bounds.x1, self.bounds.y1, self.bounds.x2-self.padding, self.bounds.y2-self.close.height-(self.padding*2))
    self.cardDisplay:initialise()
    self.cardDisplay:instantiate()
    self:addChild(self.cardDisplay)

    self.deckActionHandler = require "gameNight - deckActionHandler"
end



function gameNightDeckSearch.open(player, deckItem)

    if gameNightDeckSearch.instance then gameNightDeckSearch.instance:closeAndRemove() end

    local window = gameNightDeckSearch:new(nil, nil, 470, 350, player, deckItem)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)

    return window
end



function gameNightDeckSearch:new(x, y, width, height, player, deckItem)
    local o = {}
    x = x or getCore():getScreenWidth()/2 - (width/2)
    y = y or getCore():getScreenHeight()/2 - (height/2)
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}

    o.moveWithMouse = true

    o.cardHeight = 48
    o.cardWidth = 32

    o.width = width
    o.height = height
    o.player = player
    o.deck = deckItem

    o.padding = 10

    gameNightDeckSearch.instance = o
    return o
end