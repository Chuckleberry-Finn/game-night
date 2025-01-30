local uiInfo = {}

uiInfo.texture = getTexture("media/ui/Panel_info_button.png")


function uiInfo:setInfo(text)
    if not text or (text == "") then
        self.infoButton:setVisible(false)
        if self.infoRichText then self.infoRichText:removeFromUIManager() end
        return
    end

    self.infoButton:setVisible(true)
    self.infoText = text
    if self.infoRichText then
        self.infoRichText.chatText.text = text
        self.infoRichText.chatText:paginate()
        self.infoRichText:setHeightToContents()
        self.infoRichText:setY(getCore():getScreenHeight()/2-(self.infoRichText:getHeight()/2))
        self.infoRichText:updateButtons()
    end
end


function uiInfo:onInfo()
    if not self.infoRichText then
        self.infoRichText = ISModalRichText:new(getCore():getScreenWidth()/2-400,getCore():getScreenHeight()/2-300,600,600,self.infoText, false)
        self.infoRichText:initialise()
        self.infoRichText.backgroundColor = {r=0, g=0, b=0, a=0.9}
        self.infoRichText.alwaysOnTop = true
        self.infoRichText.chatText:paginate()
        self.infoRichText:setHeightToContents()
        self.infoRichText:ignoreHeightChange()
        self.infoRichText:setY(getCore():getScreenHeight()/2-(self.infoRichText:getHeight()/2))
    end

    if self.infoRichText:isReallyVisible() then
        self.infoRichText:removeFromUIManager()
    else
        self.infoRichText:setVisible(true)
        self.infoRichText:addToUIManager()
    end
end


function uiInfo.applyToUI(ui, x, y, text)
    ui.infoButton = ISButton:new(x, y, 16, 16, "", ui, uiInfo.onInfo)
    ui.infoButton:initialise()
    ui.infoButton.borderColor.a = 0.0
    ui.infoButton.backgroundColor.a = 0.0
    ui.infoButton.backgroundColorMouseOver.a = 0.7
    ui.infoButton:setImage(uiInfo.texture)
    ui:addChild(ui.infoButton)
    uiInfo.setInfo(ui, text)
end


return uiInfo