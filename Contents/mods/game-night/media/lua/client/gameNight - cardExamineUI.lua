require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
require "gameNight - window"

local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler
--local uiInfo = require "gameNight - uiInfo"

---@class gameNightCardExamine : ISPanel
gameNightCardExamine = ISPanel:derive("gameNightCardExamine")

gameNightCardExamine.instances = {}

function gameNightCardExamine:closeAndRemove()
    gameNightCardExamine.instances[(self.attachedUI or self.deck)] = nil
    if self.attachedUI then self.attachedUI.cardExamine = nil end
    self:setVisible(false)
    self:removeFromUIManager()
end

function gameNightCardExamine:update()
    if (not self.player) or (not self.deck) then self:closeAndRemove() return end

    --if (not self.attachedUI.instance) then self:closeAndRemove() return end

    ---@type InventoryItem
    local item = self.deck

    local values,flipped = deckActionHandler.getDeckStates(item)
    if not values or #values < 1 then self:closeAndRemove() return end

    if values[self.index] ~= self.card then self:closeAndRemove() return end
    local flippedValue = flipped[self.index]

    local textureToUse = deckActionHandler.fetchAltIcon(self.card, self.deck)
    local texturePath = (flippedValue and "media/textures/Item_"..self.deck:getType().."/FlippedInPlay.png") or "media/textures/Item_"..self.cardFaceType.."/"..textureToUse..".png"
    self.texture = getTexture(texturePath)

    local playerInv = self.player:getInventory()
    if playerInv:contains(item) then return end

    local outerMostCont = item:getOutermostContainer()
    local contParent = outerMostCont and outerMostCont:getParent()
    local contParentSq = contParent and contParent:getSquare()
    if contParentSq and ( contParentSq:DistToProper(self.player) > 2 ) then
        self:closeAndRemove()
        return
    end

    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = item:getWorldItem()
    local worldItemSq = worldItem and worldItem:getSquare()
    if worldItemSq and ( worldItemSq:DistToProper(self.player) > 2 ) then
        self:closeAndRemove()
        return
    end
end


function gameNightCardExamine:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightCardExamine:prerender()
    ISPanel.prerender(self)
    if self.attachedUI then
        local aUI = self.attachedUI
        self:setX(aUI:getX()+aUI:getWidth()+self.padding)
        self:setY(aUI:getY())
    end
    self:drawTextureScaledUniform(self.texture, self.padding, self.padding, self.examineScale, 1, 1, 1, 1)
end


function gameNightCardExamine:render() ISPanel.render(self) end


function gameNightCardExamine:initialise()
    ISPanel.initialise(self)

    local closeText = getText("UI_Close")
    local btnWid = getTextManager():MeasureStringX(UIFont.Small, closeText)+10
    local btnHgt = self.btnHgt
    local pd = self.padding

    local attachedUI = self.attachedUI
    local bottomPad = (not attachedUI) and (pd+btnHgt) or 0

    local textureToUse = deckActionHandler.fetchAltIcon(self.card, self.deck)
    local texturePath = (self.flipped and "media/textures/Item_"..self.deck:getType().."/FlippedInPlay.png") or "media/textures/Item_"..self.cardFaceType.."/"..textureToUse..".png"
    self.texture = getTexture(texturePath)

    if self.card then
        self.width = self.texture:getWidth()*self.examineScale
        self.height = self.texture:getHeight()*self.examineScale
        self:setWidth(self.width+(pd*2))
        self:setHeight(self.height+(pd*2)+bottomPad)
    end

    if self.throughContext then
        self:setX(getCore():getScreenWidth()/2 - (self.width/2))
        self:setY(getCore():getScreenHeight()/2 - (self.height/2))

        self.close = ISButton:new((self.width-btnWid)/2, self.height-pd-btnHgt, btnWid, btnHgt, closeText, self, gameNightCardExamine.onClick)
        self.close.internal = "CLOSE"
        self.close.borderColor = {r=1, g=1, b=1, a=0.4}
        self.close:initialise()
        self.close:instantiate()
        self:addChild(self.close)
    end

    if attachedUI then
        self:setX(attachedUI:getX()+attachedUI:getWidth()+self.padding)
        self:setY(attachedUI:getY())
    end

    --uiInfo.applyToUI(self, self.close.x-24, self.close.y, getText("UI_GameNightExamine"))
end


function gameNightCardExamine.open(player, deckItem, throughContext, index, attachedUI)

    local cardExamine = gameNightCardExamine.instances[(attachedUI or deckItem)]
    if cardExamine then cardExamine:closeAndRemove() end

    local window = gameNightCardExamine:new(deckItem, nil, nil, player, throughContext, index, attachedUI)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)

    return window
end


function gameNightCardExamine:new(deckItem, x, y, player, throughContext, index, attachedUI)
    local o = {}
    o = ISPanel:new(-10, -10, 10, 10)
    setmetatable(o, self)
    self.__index = self

    o.throughContext = throughContext
    o.attachedUI = attachedUI

    local cardData, cardFlipStates = deckActionHandler.getDeckStates(deckItem)

    local itemType = deckItem:getType()
    local fullType = deckItem:getFullType()

    local special = gamePieceAndBoardHandler.specials[fullType]
    local cardFaceType = special and special.cardFaceType or itemType
    o.cardFaceType = cardFaceType

    local examineScale = special and special.examineScale or 1
    o.examineScale = examineScale

    local cardInt = index and type(index)=="number" and index or #cardData
    o.index = cardInt

    local card = cardData[cardInt]
    o.card = card

    local flipped = cardFlipStates[cardInt]
    o.flipped = flipped

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}
    o.moveWithMouse = true
    o.padding = 10
    o.btnHgt = 25

    o.player = player
    o.deck = deckItem

    gameNightCardExamine.instances[(attachedUI or deckItem)] = o
    return o
end