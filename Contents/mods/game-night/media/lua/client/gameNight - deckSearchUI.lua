require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
require "gameNight - window"

local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

local uiInfo = require "gameNight - uiInfo"

---@class gameNightDeckSearch : ISPanel
gameNightDeckSearch = ISPanel:derive("gameNightDeckSearch")
gameNightDeckSearch.instances = {}


function gameNightDeckSearch:closeAndRemove()
    local examine = self.examine
    if examine then examine:closeAndRemove() end
    self:setVisible(false)
    self:removeFromUIManager()
    gameNightDeckSearch.instances[self.deck] = nil
end


function gameNightDeckSearch.OnPlayerDeath(playerObj)
    for item,ui in pairs(gameNightDeckSearch.instances) do ui:closeAndRemove() end
end
Events.OnPlayerDeath.Add(gameNightDeckSearch.OnPlayerDeath)


function gameNightDeckSearch:update()
    if (not self.player) or (not self.deck) then self:closeAndRemove() return end

    local gameNightWin = gameNightWindow.instance
    if self.held and (not gameNightWin) then self:closeAndRemove() return end

    ---@type InventoryItem
    local item = self.deck
    ---@type IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
    local player = self.player

    if self.held and item ~= player:getPrimaryHandItem() then self:closeAndRemove() return end

    local values,flipped = deckActionHandler.getDeckStates(item)
    if not values or ((self.held and #values<1) and ((not self.held) and #values<=1)) then
        self:closeAndRemove()
        return
    end

    local playerInv = self.player:getInventory()
    if playerInv:contains(item) then return end

    local worldItem = item:getWorldItem()
    local cont = item:getContainer()

    if (self.container~=cont) or (self.worldItem ~= worldItem) then self:closeAndRemove() return end
    if (not worldItem) and (not cont) then self:closeAndRemove() return end

    local outerMostCont = item:getOutermostContainer()
    local contParent = outerMostCont and outerMostCont:getParent()
    local contParentSq = contParent and contParent:getSquare()
    if contParentSq and ( contParentSq:DistToProper(player) > 1.5 ) then
        self:closeAndRemove()
        return
    end

    ---@type IsoWorldInventoryObject|IsoObject

    local worldItemSq = worldItem and worldItem:getSquare()
    if worldItemSq and ( worldItemSq:DistToProper(player) > 1.5 ) then
        self:closeAndRemove()
        return
    end
end


function gameNightDeckSearch:onClick(button) if button.internal == "CLOSE" then self:closeAndRemove() end end


function gameNightDeckSearch:onMouseWheel(del)
    if self.hiddenHeight > 0 then self.scrollY = math.max(0,math.min(self.hiddenHeight, (self.scrollY or 0)+(del*24))) end
    return true
end


function gameNightDeckSearch:getCardAtXY(x, y)
    local halfPad = math.floor((self.padding/2)+0.5)

    if x < halfPad or x > self.cardDisplay.width-halfPad then return end
    if y < halfPad or y > self.cardDisplay.height-halfPad then return end

    local colFactor = math.floor(((self.cardDisplay.width-self.padding) / (self.cardWidth+halfPad)) + 0.5)
    y = y + (self.scrollY or 0)

    local colMod = (x-halfPad) % (self.cardWidth+halfPad)
    local rowMod = (y-halfPad) % (self.cardHeight+halfPad)

    --if colMod > self.cardWidth then return end
    if rowMod > self.cardHeight then return end

    local col = math.floor( (x-halfPad) / (self.cardWidth+halfPad) )
    local row = math.floor( (y-halfPad) / (self.cardHeight+halfPad) )

    local cardData, _ = deckActionHandler.getDeckStates(self.deck)
    local selected = #cardData - math.floor(col + (row*colFactor))

    local inBetween = (colMod > self.cardWidth)

    if selected < 0 then
        selected = 0
        inBetween = true
    end

    return selected, inBetween
end


function gameNightDeckSearch:clearDragging()
    self.dragging = nil
    self.draggingTexture = nil
    self.draggingOver = nil
    self.dragInBetween = nil
end


function gameNightDeckSearch:cardOnRightMouseUp(x, y)
    local searchWindow = self.parent
    local selected, _ = searchWindow:getCardAtXY(x, y)
    if selected and selected>0 then
        local context = ISContextMenu.get(searchWindow.player:getPlayerNum(), getMouseX(), getMouseY())

        local pPrimaryItem = searchWindow.player:getPrimaryHandItem()
        if (not pPrimaryItem) or (pPrimaryItem and pPrimaryItem ~= searchWindow.deck) then
            context:addOption(getText("IGUI_draw"), searchWindow.deck, deckActionHandler.drawSpecificCard, searchWindow.player, selected)
        end

        context:addOption(getText("IGUI_flipCard"), searchWindow.deck, deckActionHandler.flipSpecificCard, searchWindow.player, selected)
    end
    searchWindow:clearDragging()
    ISPanelJoypad.onRightMouseUp(self, x, y)
end


function gameNightDeckSearch:onMouseMove(dx, dy)
    --if not self:isMouseOver() then return end

    ---@type gameNightWindow
    local gameNightWin = gameNightWindow.instance
    local piece = gameNightWin and gameNightWin.movingPiece

    local draggingCard
    for sDeck,sWin in pairs(gameNightDeckSearch.instances) do if sWin.dragging then draggingCard = sWin.dragging break end end

    if draggingCard or piece then
        local x = self.cardDisplay:getMouseX()
        local y = self.cardDisplay:getMouseY()
        local selected, inBetween = self:getCardAtXY(x, y)
        if selected and selected>=0 then
            self.draggingOver = math.max(1,selected)
            self.dragInBetween = inBetween
        end
    end
    ISPanel.onMouseMove(self, dx, dy)
end


function gameNightDeckSearch:cardOnMouseUpOutside(x, y)
    local searchWindow = self.parent

    ---@type gameNightWindow
    local gameNightWin = gameNightWindow.instance
    if gameNightWin and gameNightWin:isMouseOver() then
        local deckItem = searchWindow.deck
        local cardBeingDragged = searchWindow.dragging

        if cardBeingDragged then
            local cardDrawn = deckActionHandler._drawCardIndex(deckItem, nil, cardBeingDragged, nil, true)
            if cardDrawn then gameNightWin:calculateItemDrop(gameNightWin:getMouseX(), gameNightWin:getMouseY(), {cardDrawn}) end
        end
    end

    local sisWindow
    for sDeck,sWin in pairs(gameNightDeckSearch.instances) do
        if (sWin ~= searchWindow) and sWin.cardDisplay and sWin.cardDisplay:isMouseOver() then
            sisWindow = sWin break
        end
    end
    if sisWindow then
        local deckItem = searchWindow.deck
        local cardBeingDragged = searchWindow.dragging
        if cardBeingDragged then
            local sisDeck = sisWindow.deck

            local overX, overY = sisWindow.cardDisplay:getMouseX(), sisWindow.cardDisplay:getMouseY()
            local selection, inBetween = sisWindow:getCardAtXY(overX, overY)

            if selection then
                local cardDrawn = deckActionHandler._drawCardIndex(deckItem, nil, cardBeingDragged, nil, true)
                if cardDrawn then deckActionHandler.mergeDecks(cardDrawn, sisDeck, searchWindow.player, selection+(inBetween and 0 or 1)) end
            end
        end
    end

    searchWindow:clearDragging()
    ISPanelJoypad.onMouseUpOutside(self, x, y)
end


function gameNightDeckSearch:cardOnMouseUp(x, y)
    local searchWindow = self.parent

    local selection, inBetween = searchWindow:getCardAtXY(x, y)
    local deckItem = searchWindow.deck
    local cardData, flippedStates = deckActionHandler.getDeckStates(deckItem)

    if searchWindow.dragging and selection and selection >= 1 then
        local cardA, flippedA = cardData[searchWindow.dragging], flippedStates[searchWindow.dragging]
        if searchWindow.dragInBetween then
            local selectionDrag = -1
            if searchWindow.dragging < selection then
                selectionDrag = 1
                selection = selection-1
            end

            for n=searchWindow.dragging, selection, selectionDrag do
                local nextCard, nextFlip = cardData[n+selectionDrag], flippedStates[n+selectionDrag]
                cardData[n] = nextCard
                flippedStates[n] = nextFlip
            end

            cardData[selection] = cardA
            flippedStates[selection] = flippedA
        else
            local cardB, flippedB = cardData[selection], flippedStates[selection]

            cardData[searchWindow.dragging] = cardB
            flippedStates[searchWindow.dragging] = flippedB

            cardData[selection] = cardA
            flippedStates[selection] = flippedA
        end
        gamePieceAndBoardHandler.playSound(deckItem, searchWindow.player)
        deckActionHandler.handleDetails(deckItem)
    end

    local gameWindow = gameNightWindow and gameNightWindow.instance
    local card = gameWindow and gameWindow.movingPiece
    if card then
        if selection and selection >= 0 then
            if gamePieceAndBoardHandler.itemIsBusy(card) then gameWindow:clearMovingPiece(x, y) return end
            local notCompatible = card:getType() ~= deckItem:getType()
            if notCompatible then gameWindow:clearMovingPiece() return end

            deckActionHandler.mergeDecks(card, deckItem, searchWindow.player, selection+(inBetween and 0 or 1))
        end
        gameWindow:clearMovingPiece(x, y)
    end

    searchWindow:clearDragging()
    ISPanelJoypad.onMouseUp(self, x, y)
end


function gameNightDeckSearch:cardOnMouseDownOutside(x, y)
    local searchWindow = self.parent
    searchWindow:clearDragging()
    ISPanelJoypad.onMouseDownOutside(self, x, y)
end


function gameNightDeckSearch:cardOnMouseDown(x, y)
    local searchWindow = self.parent
    searchWindow:clearDragging()
    local selected, _ = searchWindow:getCardAtXY(x, y)
    if selected  and selected>0 then
        searchWindow.dragging = selected

        local cardData, flippedStates = deckActionHandler.getDeckStates(searchWindow.deck)
        if cardData and cardData[selected] then
            local itemType = searchWindow.deck:getType()
            local fullType = searchWindow.deck:getFullType()
            local special = gamePieceAndBoardHandler.specials[fullType]
            local texture

            if flippedStates[selected] ~= true then
                local cardName = cardData[selected]
                local cardFaceType = special and special.cardFaceType or itemType
                local textureToUse = deckActionHandler.fetchAltIcon(cardName, searchWindow.deck)
                texture = getTexture("media/textures/Item_"..cardFaceType.."/"..textureToUse..".png")
            else
                texture = getTexture("media/textures/Item_"..itemType.."/FlippedInPlay.png")
            end

            local specialTextureSize = special and special.textureSize
            searchWindow.draggingTextureSize = specialTextureSize
            searchWindow.draggingTexture = texture
        end
    end
    ISPanelJoypad.onMouseDown(self, x, y)
end


function gameNightDeckSearch:prerender()
    ISPanel.prerender(self)
end


function gameNightDeckSearch:onRightMouseDown(x, y)
    if self:isVisible() and not self.held then
        local nameLength = getTextManager():MeasureStringX(self.font, self.deck:getDisplayName())
        if x >= self.padding and y >= 2 and x <= self.padding+48+nameLength then

            if gamePieceAndBoardHandler.itemIsBusy(self.deck) then return end

            ---@type IsoPlayer|IsoGameCharacter
            local playerObj = self.player
            local playerID = playerObj:getPlayerNum()

            ---@type InventoryItem
            local item = self.deck
            local itemContainer = item and item:getContainer() or false
            local isInInv = itemContainer and itemContainer:isInCharacterInventory(playerObj) or false

            local contextMenuItems = {item}

            ---@type ISContextMenu
            local menu = ISInventoryPaneContextMenu.createMenu(playerID, isInInv, contextMenuItems, getMouseX(), getMouseY())

            return true
        end
    end
    ISPanelJoypad.onRightMouseDown(x, y)
end


---gameNightDeckSearch.sizedOnce
function gameNightDeckSearch:render()
    self.cardDisplay:setStencilRect(0, 0, self.cardDisplay.width, self.cardDisplay.height)
    ISPanel.render(self)
    local cardData, cardFlipStates = deckActionHandler.getDeckStates(self.deck)

    local itemType = self.deck:getType()
    local fullType = self.deck:getFullType()
    local special = gamePieceAndBoardHandler.specials[fullType]
    local cardFaceType = special and special.cardFaceType or itemType

    local halfPad = math.floor((self.padding/2)+0.5)
    local xOffset, yOffset = halfPad, halfPad
    local resetXOffset = xOffset

    local specialCase = fullType and gamePieceAndBoardHandler.specials[fullType]
    local specialTextureSize = specialCase and specialCase.textureSize

    if #cardData < 1 then return end

    local gameWindow = gameNightWindow and gameNightWindow.instance
    local cardFromOtherWindow = gameWindow and gameWindow.movingPiece

    local draggingCard
    for sDeck,sWin in pairs(gameNightDeckSearch.instances) do if sWin.dragging then draggingCard = sWin.dragging break end end

    for n=#cardData, 1, -1 do

        local card = cardData[n]
        local flipped = cardFlipStates[n]

        if card then

            local textureToUse = deckActionHandler.fetchAltIcon(card, self.deck)

            local texturePath = (flipped and "media/textures/Item_"..itemType.."/FlippedInPlay.png") or "media/textures/Item_"..cardFaceType.."/"..textureToUse..".png"
            local origTexture = getTexture(texturePath)
            if origTexture then

                local textureW = specialTextureSize and specialTextureSize[1] or origTexture:getWidth()
                local textureH = specialTextureSize and specialTextureSize[2] or origTexture:getHeight()

                local tmpTexture = textureW and textureH and Texture.new(origTexture)
                if tmpTexture then
                    tmpTexture:setHeight(textureH)
                    tmpTexture:setWidth(textureW)
                end

                local texture = tmpTexture or origTexture

                if not self.cardHeight or not self.cardWidth then
                    self.cardHeight = textureH*0.5*self.scaleSize
                    self.cardWidth = textureW*0.5*self.scaleSize
                end

                if self.cardWidth+xOffset > self.cardDisplay.width+halfPad then

                    if not self.sizedOnce then
                        self.sizedOnce = true
                        self.cardDisplay:setWidth(self.cardWidth+xOffset+halfPad)
                        self:setWidth(self.cardDisplay.width+(self.padding*2))
                        if self.closeBtn then self.closeBtn:setX(self.width-self.padding-self.closeBtn:getWidth()) end
                        if self.infoButton then self.infoButton:setX(self.closeBtn:getX()-24) end
                    end

                    xOffset = resetXOffset
                    yOffset = yOffset+self.cardHeight+halfPad
                end

                self.cardDisplay:drawTextureScaledUniform(texture, xOffset, yOffset-(self.scrollY or 0), 0.5*self.scaleSize, 1, 1, 1, 1)

                if (draggingCard or self.draggingOver) and self:isMouseOver() then

                    if self.dragging and self.dragging == n and (not cardFromOtherWindow) then
                        self.cardDisplay:drawRectBorder(xOffset, yOffset-(self.scrollY or 0), self.cardWidth, self.cardHeight, 1, 0.4, 0.6, 0.9)
                    elseif self.draggingOver and self.draggingOver == n then

                        local x = self.dragInBetween and xOffset+self.cardWidth or xOffset-(cardFromOtherWindow and 4 or 0)
                        local w = (self.dragInBetween or cardFromOtherWindow) and 4 or self.cardWidth
                        local a = (self.dragInBetween or cardFromOtherWindow) and 0.9 or 0.3
                        self.cardDisplay:drawRect(x, yOffset-(self.scrollY or 0), w, self.cardHeight, a, 0.4, 0.6, 0.9)
                    end
                end
            end
            xOffset = xOffset+self.cardWidth+halfPad
        end
    end
    self.hiddenHeight = math.max(0, yOffset-(self.cardDisplay.height-halfPad-self.cardHeight))
    self.cardDisplay:clearStencilRect()

    if not self.held then
        ---@type InventoryItem|IsoObject|IsoMovingObject
        local deckTexture = self.deck:getTexture()
        local deckDisplayName = self.deck:getDisplayName()

        self:drawTextureScaledAspect(deckTexture, self.padding+4, halfPad, 32, 32,1, 1, 1, 1)
        self:drawText(deckDisplayName, self.padding+48, halfPad+(self.fontHgt/3), 1, 1, 1, 0.9, self.font)
    end

    local mouseX, mouseY = self.cardDisplay:getMouseX(), self.cardDisplay:getMouseY()
    local selected, _ = self:getCardAtXY(mouseX, mouseY)
    local sandbox = SandboxVars.GameNight.DisplayItemNames

    local examine = self.examine
    if examine and ((not selected) or (not examine.index) or (examine.index ~= selected)) then examine:closeAndRemove() end

    if sandbox and selected and selected>0 then
        local card = cardData[selected]
        local flipped = cardFlipStates[selected]

        if (not self.dragging) and (not cardFromOtherWindow) and specialCase and specialCase.examineScale and (not self.examine) then
            self.examine = gameNightExamine.open(self.player, self.deck, false, selected, self)
        end

        local cardName = flipped and (getTextOrNull("IGUI_"..self.deck:getType()) or getItemNameFromFullType("Base."..self.deck:getType())) or deckActionHandler.fetchAltName(card, self.deck, special)
        if cardName then
            local cardNameW = getTextManager():MeasureStringX(UIFont.NewSmall, " "..cardName.." ")
            local cardNameH = getTextManager():getFontHeight(UIFont.NewSmall)
            self.cardDisplay:drawRect(mouseX+(cardNameW/3), mouseY-cardNameH, cardNameW, cardNameH, 0.7, 0, 0, 0)
            self.cardDisplay:drawTextCentre(cardName, mouseX+(cardNameW*0.833), mouseY-cardNameH, 1, 1, 1, 0.7, UIFont.NewSmall)
        end
    end

    if self.dragging then
        local dragX, dragY = self:getMouseX(), self:getMouseY()
        ---@type Texture
        local texture = self.draggingTexture
        if texture then
            local textureW = self.draggingTextureSize and self.draggingTextureSize[1] or texture:getWidth()
            local textureH = self.draggingTextureSize and self.draggingTextureSize[2] or texture:getHeight()

            local tmpTexture = textureW and textureH and Texture.new(texture)
            if tmpTexture then
                tmpTexture:setHeight(textureH * gameNightWindow.scaleSize)
                tmpTexture:setWidth(textureW * gameNightWindow.scaleSize)
            end

            gameNightWindow.DrawTextureAngle(self, tmpTexture, dragX+(textureW/2), dragY+(textureH/2), 0, 1, 1, 1, 0.7)
        end
    end
end





function gameNightDeckSearch:initialise()
    ISPanel.initialise(self)

    local closeText = getText("UI_Close")
    local btnWid = getTextManager():MeasureStringX(UIFont.Small, closeText)+10
    local btnHgt = self.held and 0 or 25
    local pd = self.padding

    self.bounds = {x1=pd, y1=btnHgt+(pd*2), x2=self.width-pd, y2=self.height-pd}

    if not self.held then
        self.closeBtn = ISButton:new(self.width-pd-btnWid, pd, btnWid, btnHgt, closeText, self, gameNightDeckSearch.onClick)
        self.closeBtn.internal = "CLOSE"
        self.closeBtn.borderColor = {r=1, g=1, b=1, a=0.4}
        self.closeBtn:initialise()
        self.closeBtn:instantiate()
        self:addChild(self.closeBtn)

        uiInfo.applyToUI(self, self.closeBtn.x-24, self.closeBtn.y, getText("UI_GameNightSearch"))
    end

    self.cardDisplay = ISPanelJoypad:new(self.bounds.x1, self.bounds.y1, self.bounds.x2-self.padding, self.bounds.y2-(self.held and 0 or self.closeBtn.height)-(self.padding*2))
    self.cardDisplay:initialise()
    self.cardDisplay:instantiate()
    self.cardDisplay.onMouseDown = self.cardOnMouseDown
    self.cardDisplay.onMouseDownOutside = self.cardOnMouseDownOutside
    self.cardDisplay.onMouseUp = self.cardOnMouseUp
    self.cardDisplay.onMouseUpOutside = self.cardOnMouseUpOutside
    self.cardDisplay.onRightMouseUp = self.cardOnRightMouseUp

    self:addChild(self.cardDisplay)
end



function gameNightDeckSearch.open(player, deckItem)

    local instance = gameNightDeckSearch.instances[deckItem]
    if instance then instance:closeAndRemove() end

    local window = gameNightDeckSearch:new(nil, nil, 470, 350, player, deckItem)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)

    return window
end



function gameNightDeckSearch:new(x, y, width, height, player, deckItem, held)
    local o = {}
    x = x or getCore():getScreenWidth()/2 - (width and (width/2) or 0)
    y = y or getCore():getScreenHeight()/2 - (height and (height/2) or 0)
    o = ISPanel:new(x, y, (width or 0), (height or 0))
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.3}

    o.moveWithMouse = true

    o.width = width
    o.height = height
    o.player = player
    o.container = deckItem:getContainer()
    o.worldItem = deckItem:getWorldItem()
    o.deck = deckItem

    local font = getCore():getOptionInventoryFont()
    if font == "Large" then
        o.font = UIFont.Large
    elseif font == "Small" then
        o.font = UIFont.Small
    else
        o.font = UIFont.Medium
    end
    o.fontHgt = getTextManager():getFontHeight(o.font)

    o.scaleSize = 1
    o.held = held
    o.padding = 10

    gameNightDeckSearch.instances[deckItem] = o
    return o
end