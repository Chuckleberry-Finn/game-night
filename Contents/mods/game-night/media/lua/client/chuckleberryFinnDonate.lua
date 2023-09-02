CHUCKLEBERRY_DONATION_SYSTEM = (CHUCKLEBERRY_DONATION_SYSTEM or 0) + 1

require "ISUI/ISPanelJoypad"
---@class donationSystem : ISPanel
local donationSystem = ISPanelJoypad:derive("donationSystem")


function donationSystem:prerender()
    ISPanelJoypad.prerender(self)
    self:drawRect(self.padding, self.padding, self.width-(self.padding*2), self.height-(self.padding*2), 0.5, 0, 0, 0)

    local headerX, headerY = self.padding*1.6, self.padding*1.3
    self:drawText("Welcome to GAME NIGHT!", headerX, headerY, 1, 1, 1, 0.9, donationSystem.headerFont)

    local bodyX, bodyY = self.padding*1.7, (self.padding*1.4)+donationSystem.headerHeight
    self:drawText("If you enjoy Chuckleberry Finn's work:", bodyX, bodyY, 1, 1, 1, 0.8, donationSystem.bodyFont)

    self:drawRectBorder(self.padding, self.padding, self.width-(self.padding*2), self.height-(self.padding*2), 0.6, 1, 1, 1)
end

function donationSystem:render()
    ISPanelJoypad.render(self)
    if donationSystem.texture then self:drawTexture(donationSystem.texture, donationSystem.texturePos[1], donationSystem.texturePos[2], 1, 1, 1, 1) end
end


function donationSystem:onClickDonate() openUrl("https://ko-fi.com/chuckleberryfinn") end


function donationSystem:initialise()
    ISPanelJoypad.initialise(self)

    donationSystem.buttonTexture = donationSystem.buttonTexture or getTexture("media/textures/kofi.png")

    local btnWid = donationSystem.buttonTexture:getWidth()
    local btnHgt = donationSystem.buttonTexture:getHeight()

    self.donate = ISButton:new(((self.width-btnWid)/2)-self.padding*1.3, self:getHeight()-(self.padding*1.3)-btnHgt, btnWid, btnHgt, "", self, donationSystem.onClickDonate)
    self.donate.borderColor = {r=0, g=0, b=0, a=0.}
    self.donate.backgroundColor = {r=0, g=0, b=0, a=0}
    self.donate:setImage(donationSystem.buttonTexture)
    self.donate:initialise()
    self.donate:instantiate()
    self:addChild(self.donate)
end


function donationSystem.display()

    donationSystem.texture = donationSystem.texture or getTexture("media/textures/gamenightDonate.png")

    local textManager = getTextManager()
    donationSystem.headerFont = UIFont.NewLarge
    donationSystem.headerHeight = textManager:MeasureFont(donationSystem.headerFont)
    donationSystem.bodyFont = UIFont.AutoNormSmall

    local windowW, windowH = 400, 150
    local textureW, textureH = donationSystem.texture:getWidth(), donationSystem.texture:getHeight()
    local textureOffsetX, textureOffsetY = (textureW*0.8), (textureH*0.2)
    local x = getCore():getScreenWidth() - windowW - (textureW*0.2) - MainScreen.instance.bottomPanel.x
    local y = MainScreen.instance.resetLua.y - windowH - (textureH*0.2) - MainScreen.instance.bottomPanel.y

    donationSystem.texturePos = {windowW-textureOffsetX,0-textureOffsetY}

    local window = donationSystem.instance or donationSystem:new(x, y, windowW, windowH)
    window:initialise()
    --window:addToUIManager()
    --window:setVisible(true)
    MainScreen.instance.bottomPanel:addChild(window)
end


function donationSystem:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.padding = 24
    o.borderColor = {r=0, g=0, b=0, a=0}
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.width, o.height = width, height
    donationSystem.instance = o
    return o
end


Events.OnMainMenuEnter.Add(donationSystem.display)