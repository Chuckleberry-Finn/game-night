CHUCKLEBERRY_DONATION_SYSTEM = (CHUCKLEBERRY_DONATION_SYSTEM or 0) + 1

require "ISUI/ISPanelJoypad"
---@class donationSystem : ISPanelJoypad
local donationSystem = ISPanelJoypad:derive("donationSystem")


function donationSystem:prerender()
    ISPanelJoypad.prerender(self)

    if MainScreen.instance and MainScreen.instance.bottomPanel then
        local isMenu = MainScreen.instance.bottomPanel:isVisible()
        self:setVisible(isMenu)
        if not isMenu then return end
    end
    
    self:drawRect(self.padding, self.padding, self.width-(self.padding*2), self.height-(self.padding*2), 0.5, 0, 0, 0)

    local headerX, headerY = self.padding*1.6, self.padding*1.3
    self:drawText("Welcome to GAME NIGHT!", headerX, headerY, 1, 1, 1, 0.9, donationSystem.headerFont)

    local bodyX, bodyY = self.padding*1.7, (self.padding*1.4)+donationSystem.headerHeight
    self:drawText("If you enjoy Chuckleberry Finn's work,\nconsider showing your support.", bodyX, bodyY, 1, 1, 1, 0.8, donationSystem.bodyFont)

    self:drawRectBorder(self.padding, self.padding, self.width-(self.padding*2), self.height-(self.padding*2), 0.6, 1, 1, 1)
end

function donationSystem:render()
    ISPanelJoypad.render(self)
    if donationSystem.texture then self:drawTexture(donationSystem.texture, donationSystem.texturePos[1], donationSystem.texturePos[2], 1, 1, 1, 1) end
end


function donationSystem:onClickDonate() openUrl("https://ko-fi.com/chuckleberryfinn") end


function donationSystem:initialise()
    ISPanelJoypad.initialise(self)

    local btnWid = 100
    local btnHgt = 20

    self.donate = ISButton:new(((self.width-btnWid)/2)-self.padding*1.3, self:getHeight()-(self.padding*1.3)-btnHgt, btnWid, btnHgt, "Donate", self, donationSystem.onClickDonate)
    self.donate.borderColor = {r=0.64, g=0.8, b=0.02, a=0.9}
    self.donate.backgroundColor = {r=0, g=0, b=0, a=0.6}
    --self.donate.backgroundColorMouseOver = {r=1, g=1, b=1, a=0.8}
    self.donate.textColor = {r=0.64, g=0.8, b=0.02, a=1}
    self.donate:initialise()
    self.donate:instantiate()
    self:addChild(self.donate)
end


function donationSystem.display()

    donationSystem.texture = donationSystem.texture or getTexture("media/textures/gamenightDonate.png")

    local textManager = getTextManager()
    donationSystem.headerFont = UIFont.NewLarge
    donationSystem.headerHeight = textManager:getFontHeight(donationSystem.headerFont)
    donationSystem.bodyFont = UIFont.AutoNormSmall

    local FONT_SMALL = textManager:getFontHeight(UIFont.Small)

    local windowW, windowH = 400, 150
    local textureW, textureH = donationSystem.texture:getWidth(), donationSystem.texture:getHeight()
    local textureOffsetX, textureOffsetY = (textureW*0.85), (textureH*0.22)
    local x = getCore():getScreenWidth() - windowW - (textureW*0.15)
    local y = getCore():getScreenHeight() - FONT_SMALL - 70 - windowH - (textureH*0.1)

    donationSystem.texturePos = {windowW-textureOffsetX,0-textureOffsetY}

    local alert = donationSystem.instance or donationSystem:new(x, y, windowW, windowH)
    alert:initialise()
    MainScreen.instance.donateAlert = alert
    MainScreen.instance:addChild(alert)
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

local MainScreen_onEnterFromGame = MainScreen.onEnterFromGame
function MainScreen:onEnterFromGame()
    MainScreen_onEnterFromGame(self)
    donationSystem.display()
end