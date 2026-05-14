require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
 require("gameNight-window.lua")

local applyItemDetails = require("gameNight-applyItemDetails.lua")
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceHandler = applyItemDetails.gamePieceHandler
--local uiInfo = require("gameNight-uiInfo.lua")

---@class gameNightExamine : ISPanel
gameNightExamine = ISPanel:derive("gameNightExamine")

gameNightExamine.instances = {}

function gameNightExamine:closeAndRemove()
    local pos = self.savedPos
    if pos and not self.attachedUI then
        local gw = gameNightWindow and gameNightWindow.instance
        local item = self.item
        if gw and gw.square == pos.square and item then
            item:getModData()["gameNight_rotation"] = pos.rotation
            gamePieceHandler.coolDownArray[item:getID()] = nil
            gamePieceHandler.pickupAndPlaceGamePiece(
                self.player, item, nil,
                gamePieceHandler.handleDetails,
                pos.scaledX, pos.scaledY, 0, gw.square)
        end
        self.savedPos = nil
    end
    gameNightExamine.instances[(self.attachedUI or self.item)] = nil
    if self.attachedUI then self.attachedUI.examine = nil end
    self:setVisible(false)
    self:removeFromUIManager()
end


function gameNightExamine.OnPlayerDeath(playerObj)
    for item,ui in pairs(gameNightExamine.instances) do ui:closeAndRemove() end
end
Events.OnPlayerDeath.Add(gameNightExamine.OnPlayerDeath)


function gameNightExamine:update()
    if (not self.player) or (not self.item) then self:closeAndRemove() return end

    --if (not self.attachedUI.instance) then self:closeAndRemove() return end

    ---@type InventoryItem
    local item = self.item

    if self.card then
        local values,flipped = deckActionHandler.getDeckStates(item)
        if not values or #values < 1 then self:closeAndRemove() return end

        if values[self.index] ~= self.card then self:closeAndRemove() return end
        local flippedValue = flipped[self.index]

        local textureToUse = deckActionHandler.fetchAltIcon(self.card, self.item)
        local texturePath = (flippedValue and "media/textures/Item_"..self.item:getType().."/FlippedInPlay.png") or "media/textures/Item_"..self.cardFaceType.."/"..textureToUse..".png"
        self.texture = getTexture(texturePath)
    else
        self.texture = self.item:getModData()["gameNight_textureInPlay"] or self.item:getTexture()
    end

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


function gameNightExamine:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightExamine:onRightMouseDown(x, y)
    if self:isVisible() and self.throughContext then

        if gamePieceHandler.itemIsBusy(self.item) then return end

        ---@type IsoPlayer|IsoGameCharacter
        local playerObj = self.player
        local playerID = playerObj:getPlayerNum()

        ---@type InventoryItem
        local item = self.item
        local itemContainer = item and item:getContainer() or false
        local isInInv = itemContainer and itemContainer:isInCharacterInventory(playerObj) or false

        local contextMenuItems = {item}

        ---@type ISContextMenu
        local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, getMouseX(), getMouseY())

        return true
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end


function gameNightExamine:prerender()
    ISPanel.prerender(self)
    if self.attachedUI then
        local aUI = self.attachedUI

        local aUIX = aUI:getX()+aUI:getWidth()+self.padding
        local aUIY = aUI:getY()
        
        self:setX(aUIX)
        self:setY(aUIY)
    end
    self:drawTextureScaledUniform(self.texture, self.padding, self.padding, self.examineScale, 1, 1, 1, 1)
end


function gameNightExamine:render() ISPanel.render(self) end


function gameNightExamine:initialise()
    ISPanel.initialise(self)

    local closeText = getText("UI_Close")
    local btnWid = getTextManager():MeasureStringX(UIFont.Small, closeText)+10
    local btnHgt = self.btnHgt
    local pd = self.padding

    local attachedUI = self.attachedUI
    local bottomPad = (not attachedUI) and (pd+btnHgt) or 0

    if self.card then
        local textureToUse = deckActionHandler.fetchAltIcon(self.card, self.item)
        local texturePath = (self.flipped and "media/textures/Item_"..self.item:getType().."/FlippedInPlay.png") or "media/textures/Item_"..self.cardFaceType.."/"..textureToUse..".png"
        self.texture = getTexture(texturePath)
    else
        self.texture = self.item:getModData()["gameNight_textureInPlay"] or self.item:getTexture()
    end


    if not self.texture then self:closeAndRemove() return end

    self.width = self.texture:getWidth()*self.examineScale
    self.height = self.texture:getHeight()*self.examineScale
    self:setWidth(self.width+(pd*2))
    self:setHeight(self.height+(pd*2)+bottomPad)

    if self.throughContext then
        self:setX(getCore():getScreenWidth()/2 - (self.width/2))
        self:setY(getCore():getScreenHeight()/2 - (self.height/2))

        self.close = ISButton:new((self.width-btnWid)/2, self.height-pd-btnHgt, btnWid, btnHgt, closeText, self, gameNightExamine.onClick)
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


function gameNightExamine.open(player, deckItem, throughContext, index, attachedUI)
    local examine = gameNightExamine.instances[(attachedUI or deckItem)]
    if examine then examine:closeAndRemove() end

    local window = gameNightExamine:new(deckItem, nil, nil, player, throughContext, index, attachedUI)

    if throughContext and not attachedUI then
        local gw = gameNightWindow and gameNightWindow.instance
        if gw then
            local el = gw.elements and gw.elements[deckItem:getID()]
            if el then
                local boundW = gw.width - gw.padding * 2
                local boundH = gw.height - gw.padding * 2
                window.savedPos = {
                    scaledX = el.x / boundW,
                    scaledY = el.y / boundH,
                    rotation = deckItem:getModData()["gameNight_rotation"],
                    square = gw.square,
                }
            end
        end
    end

    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    return window
end


function gameNightExamine:new(item, x, y, player, throughContext, index, attachedUI)
    local o = {}

    o = ISPanel:new(-10, -10, 10, 10)
    setmetatable(o, self)
    self.__index = self

    o.throughContext = throughContext
    o.attachedUI = attachedUI

    local cardData, cardFlipStates = deckActionHandler.getDeckStates(item)

    local itemType = item:getType()
    local fullType = item:getFullType()

    local special = gamePieceHandler.specials[fullType]
    local cardFaceType = special and special.cardFaceType or itemType
    o.cardFaceType = cardFaceType

    local examineScale = special and special.examineScale or 1
    o.examineScale = examineScale

    local cardInt = cardData and (index and type(index)=="number" and index or #cardData)
    o.index = cardInt

    local card = cardData and cardData[cardInt]
    o.card = card

    local flipped = cardFlipStates and cardFlipStates[cardInt]
    o.flipped = flipped

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}
    o.moveWithMouse = true
    o.padding = 10
    o.btnHgt = 25

    o.player = player
    o.item = item

    gameNightExamine.instances[(attachedUI or item)] = o
    return o
end