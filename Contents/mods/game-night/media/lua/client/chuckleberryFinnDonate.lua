CHUCKLEBERRY_DONATION_SYSTEM = (CHUCKLEBERRY_DONATION_SYSTEM or 0) + 1

require "ISUI/ISPanelJoypad"
---@class donationSystem : ISPanelJoypad
local donationSystem = ISPanelJoypad:derive("donationSystem")

function donationSystem.RestoreLayout(self, name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if layout.collapsed == 'true' then self:onClickCollapse(true) end
end

function donationSystem.SaveLayout(self, name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    if self.collapsed then layout.collapsed = 'true' else layout.collapsed = 'false' end
end

function donationSystem:prerender()
    ISPanelJoypad.prerender(self)

    local collapseWidth = not self.collapsed and self.width or self.collapse.width*2

    self:drawRect(donationSystem.padding, donationSystem.padding, collapseWidth, self.height-(donationSystem.padding*2), 0.5, 0, 0, 0)

    if not self.collapsed then
        local centerX = (self.width/2)
        local headerY = donationSystem.padding*1.3
        self:drawTextCentre(donationSystem.header, centerX, headerY, 1, 1, 1, 0.9, donationSystem.headerFont)

        local bodyY = (donationSystem.padding*1.6)+(donationSystem.headerH)
        self:drawTextCentre(donationSystem.body, centerX, bodyY, 1, 1, 1, 0.8, donationSystem.bodyFont)
    end

    self:drawRectBorder(donationSystem.padding, donationSystem.padding, collapseWidth, self.height-(donationSystem.padding*2), 0.6, 1, 1, 1)
end


function donationSystem:render()
    ISPanelJoypad.render(self)
    if donationSystem.texture and (not self.collapsed) then
        local textureYOffset = (self.height-(donationSystem.texture:getHeight()*donationSystem.textureScale))/2
        self:drawTextureScaledUniform(donationSystem.texture, self.width-donationSystem.padding*2, textureYOffset, donationSystem.textureScale, 1, 1, 1, 1)
    end
end


function donationSystem:onClickDonate() openUrl("https://ko-fi.com/chuckleberryfinn") end
function donationSystem:onClickRate() openUrl("https://steamcommunity.com/sharedfiles/filedetails/?id=3058279917") end
function donationSystem:onClickCollapse(override)
    self.collapsed = override or not self.collapsed

    self.rate:setVisible(not self.collapsed)
    self.donate:setVisible(not self.collapsed)

    if self.collapseTexture and self.expandTexture then
        self.collapse:setImage(not self.collapsed and self.collapseTexture or self.expandTexture)
    end

    self:setX(not self.collapsed and self.originalX or getCore():getScreenWidth()-(self.collapse.width*2)-donationSystem.padding)
end

function donationSystem:initialise()
    ISPanelJoypad.initialise(self)

    local btnHgt = donationSystem.btnHgt
    local btnWid = donationSystem.btnWid

    self.expandTexture = self.expandTexture or getTexture("media/textures/gamenightDonate/expand.png")
    self.collapseTexture = self.collapseTexture or getTexture("media/textures/gamenightDonate/collapse.png")

    self.collapse = ISButton:new(donationSystem.padding+5, self:getHeight()-(donationSystem.padding)-20, 10, 16, "", self, donationSystem.onClickCollapse)
    self.collapse:setImage(self.collapseTexture)
    self.collapse.borderColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.collapse:initialise()
    self.collapse:instantiate()
    self:addChild(self.collapse)

    self.donate = ISButton:new(((self.width-btnWid)/2), self:getHeight()-(donationSystem.padding*1.5)-btnHgt, btnWid, btnHgt, "Go to Chuck's Kofi", self, donationSystem.onClickDonate)
    self.donate.borderColor = {r=0.64, g=0.8, b=0.02, a=0.9}
    self.donate.backgroundColor = {r=0, g=0, b=0, a=0.6}
    self.donate.textColor = {r=0.64, g=0.8, b=0.02, a=1}
    self.donate:initialise()
    self.donate:instantiate()
    self:addChild(self.donate)

    self.rateTexture = self.rateTexture or getTexture("media/textures/gamenightDonate/rate.png")
    self.rate = ISButton:new(self.donate.x-btnHgt-6, self:getHeight()-(donationSystem.padding*1.5)-btnHgt, btnHgt, btnHgt, "", self, donationSystem.onClickRate)
    self.rate:setImage(self.rateTexture)
    self.rate.borderColor = {r=0.39, g=0.66, b=0.3, a=0.9}
    self.rate.backgroundColor = {r=0.07, g=0.13, b=0.19, a=1}
    self.rate:initialise()
    self.rate:instantiate()
    self:addChild(self.rate)
end


function donationSystem.display(visible)
    local rand = ZombRand(2)+1
    donationSystem.texture = donationSystem.texture or getTexture("media/textures/gamenightDonate/"..rand..".png")
    donationSystem.textureScale = 0.8

    local textManager = getTextManager()
    donationSystem.headerFont = UIFont.NewLarge
    donationSystem.bodyFont = UIFont.AutoNormSmall

    donationSystem.padding = 24
    donationSystem.btnWid = 100
    donationSystem.btnHgt = 20

    donationSystem.header = "Welcome to GAME NIGHT!"
    donationSystem.headerW = textManager:MeasureStringX(donationSystem.headerFont, donationSystem.header)
    donationSystem.headerH = textManager:MeasureStringY(donationSystem.headerFont, donationSystem.header)

    donationSystem.body = "If you enjoy Chuckleberry Finn's work,\nconsider showing your support."
    donationSystem.bodyW = textManager:MeasureStringX(donationSystem.bodyFont, donationSystem.body)
    donationSystem.bodyH = textManager:MeasureStringY(donationSystem.bodyFont, donationSystem.body)

    local alertH = (donationSystem.padding*4) + donationSystem.headerH + donationSystem.bodyH + donationSystem.btnHgt
    local windowW, windowH = (donationSystem.headerW+(donationSystem.padding*3)), alertH

    local textureW = donationSystem.texture:getWidth()*donationSystem.textureScale
    local textureH = donationSystem.texture:getHeight()*donationSystem.textureScale

    local x = getCore():getScreenWidth() - windowW - textureW + (donationSystem.padding*1.5)
    local y = getCore():getScreenHeight() - math.max(windowH,textureH) - 80 - donationSystem.padding

    local alert = MainScreen.instance.donateAlert
    if not MainScreen.instance.donateAlert then
        alert = donationSystem:new(x, y, windowW, windowH)
        alert:initialise()
        MainScreen.instance.donateAlert = alert
        MainScreen.instance:addChild(alert)
    end

    if visible ~= false and visible ~= true then visible = MainScreen.instance:isVisible() end
    alert:setVisible(visible)
end


function donationSystem:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor, o.backgroundColor = {r=0, g=0, b=0, a=0}, {r=0, g=0, b=0, a=0}
    o.originalX = x
    o.width, o.height =  width, height
    return o
end


local MainScreen_onEnterFromGame = MainScreen.onEnterFromGame
function MainScreen:onEnterFromGame()
    MainScreen_onEnterFromGame(self)
    donationSystem.display(true)
end

local MainScreen_setBottomPanelVisible = MainScreen.setBottomPanelVisible
function MainScreen:setBottomPanelVisible(visible)
    MainScreen_setBottomPanelVisible(self, visible)
    donationSystem.display(visible)
end

Events.OnMainMenuEnter.Add(function() donationSystem.display(true) end)