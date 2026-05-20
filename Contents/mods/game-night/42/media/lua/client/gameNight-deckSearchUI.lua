require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
 require("gameNight-window.lua")

local applyItemDetails = require("gameNight-applyItemDetails.lua")
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceHandler = applyItemDetails.gamePieceHandler

local uiInfo = require("gameNight-uiInfo.lua")

---@class gameNightDeckSearch : ISPanel
gameNightDeckSearch = ISPanel:derive("gameNightDeckSearch")
gameNightDeckSearch.instances = {}


function gameNightDeckSearch:closeAndRemove()
    local examine = self.examine
    if examine then examine:closeAndRemove() end

    local pos = self.savedPos
    if pos then
        local gw = gameNightWindow and gameNightWindow.instance
        local deck = self.deck
        if gw and gw.square == pos.square and deck then
            deck:getModData()["gameNight_rotation"] = pos.rotation
            gamePieceHandler.coolDownArray[deck:getID()] = nil
            gamePieceHandler.pickupAndPlaceGamePiece(
                self.player, deck, nil,
                deckActionHandler.handleDetails,
                pos.scaledX, pos.scaledY, 0, gw.square)
        end
        self.savedPos = nil
    end

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
    self.draggingFromSelection = false
end


function gameNightDeckSearch:clearSelection()
    self.selection = {}
    self.selectionAnchor = nil
    self.selectionOrder = {}
end


function gameNightDeckSearch:getSelection()
    local indices = {}
    for idx in pairs(self.selection or {}) do table.insert(indices, idx) end
    table.sort(indices, function(a, b) return a > b end)
    return #indices, indices
end


function gameNightDeckSearch:getSelectionOrder()
    return #(self.selectionOrder or {}), self.selectionOrder or {}
end


local function batchExtractCards(searchWindow, clickOrderIndices)
    local deckItem = searchWindow.deck
    local deckStates, flipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates or #deckStates == 0 then return nil end

    local clickPos = {}
    for i, idx in ipairs(clickOrderIndices) do clickPos[idx] = i end

    local sortedDesc = {}
    for _, idx in ipairs(clickOrderIndices) do table.insert(sortedDesc, idx) end
    table.sort(sortedDesc, function(a, b) return a > b end)

    local extracted = {}
    for _, idx in ipairs(sortedDesc) do
        if idx >= 1 and idx <= #deckStates then
            local cp = clickPos[idx]
            extracted[cp] = {
                card = table.remove(deckStates, idx),
                flip = table.remove(flipStates,  idx),
            }
        end
    end

    local drawnCards, drawnFlips = {}, {}
    for i = #clickOrderIndices, 1, -1 do
        if extracted[i] then
            table.insert(drawnCards, extracted[i].card)
            table.insert(drawnFlips, extracted[i].flip)
        end
    end

    if #drawnCards == 0 then return nil end

    local resultItem
    if #deckStates == 0 then
        deckItem:getModData()["gameNight_cardDeck"]    = drawnCards
        deckItem:getModData()["gameNight_cardFlipped"] = drawnFlips
        deckActionHandler.handleDetails(deckItem)
        resultItem = deckItem
    else
        resultItem = deckActionHandler.generateCard(drawnCards, deckItem, drawnFlips, nil)
        deckActionHandler.handleDetails(deckItem)
    end

    gamePieceHandler.playSound(deckItem, searchWindow.player)
    return resultItem
end


local function batchDrawToInventory(searchWindow, sortedIndices)
    local newCard = batchExtractCards(searchWindow, sortedIndices)
    if newCard then deckActionHandler.processCardToHand(newCard, searchWindow.player) end
end


local function batchFlipInPlace(searchWindow, indices)
    local deckItem = searchWindow.deck
    local _, flipStates = deckActionHandler.getDeckStates(deckItem)
    if not flipStates then return end
    for _, idx in ipairs(indices) do
        if flipStates[idx] ~= nil then
            flipStates[idx] = not flipStates[idx]
        end
    end
    deckActionHandler.handleDetails(deckItem)
    gamePieceHandler.playSound(deckItem, searchWindow.player)
end


function gameNightDeckSearch:cardOnRightMouseUp(x, y)
    local searchWindow = self.parent
    local selected, _ = searchWindow:getCardAtXY(x, y)

    local count, indices = searchWindow:getSelection()

    if count >= 1 and selected and selected > 0 and searchWindow.selection[selected] then
        local context = ISContextMenu.get(searchWindow.player:getPlayerNum(), getMouseX(), getMouseY())

        local label = " (" .. count .. ")"

        local pPrimaryItem = searchWindow.player:getPrimaryHandItem()
        if (not pPrimaryItem) or (pPrimaryItem ~= searchWindow.deck) then
            context:addOption(getText("IGUI_draw") .. label, searchWindow, function(sw)
                local _, idx = sw:getSelectionOrder()
                batchDrawToInventory(sw, idx)
                sw:clearSelection()
            end, searchWindow)
        end

        context:addOption(getText("IGUI_flipCard") .. label, searchWindow, function(sw)
            local _, idx = sw:getSelection()
            batchFlipInPlace(sw, idx)
            sw:clearSelection()
        end, searchWindow)

        searchWindow:clearDragging()
        ISPanelJoypad.onRightMouseUp(self, x, y)
        return
    end

    if selected and selected > 0 then
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
            if searchWindow.draggingFromSelection then
                local _, orderIndices = searchWindow:getSelectionOrder()
                local extracted = batchExtractCards(searchWindow, orderIndices)
                if extracted then gameNightWin:calculateItemDrop(gameNightWin:getMouseX(), gameNightWin:getMouseY(), {extracted}) end
                searchWindow:clearSelection()
            else
                local cardDrawn = deckActionHandler._drawCardIndex(deckItem, nil, cardBeingDragged, nil, true)
                if cardDrawn then gameNightWin:calculateItemDrop(gameNightWin:getMouseX(), gameNightWin:getMouseY(), {cardDrawn}) end
            end
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
            local dropPos, inBetween = sisWindow:getCardAtXY(overX, overY)

            if dropPos then
                if searchWindow.draggingFromSelection then
                    local _, orderIndices = searchWindow:getSelectionOrder()
                    local extracted = batchExtractCards(searchWindow, orderIndices)
                    if extracted then deckActionHandler.mergeDecks(extracted, sisDeck, searchWindow.player, dropPos+(inBetween and 0 or 1)) end
                    searchWindow:clearSelection()
                else
                    local cardDrawn = deckActionHandler._drawCardIndex(deckItem, nil, cardBeingDragged, nil, true)
                    if cardDrawn then deckActionHandler.mergeDecks(cardDrawn, sisDeck, searchWindow.player, dropPos+(inBetween and 0 or 1)) end
                end
            end
        end
    end

    searchWindow:clearDragging()
    ISPanelJoypad.onMouseUpOutside(self, x, y)
end


function gameNightDeckSearch:cardOnMouseUp(x, y)
    local searchWindow = self.parent

    local target, inBetween = searchWindow:getCardAtXY(x, y)
    local deckItem = searchWindow.deck
    local cardData, flippedStates = deckActionHandler.getDeckStates(deckItem)

    if searchWindow.dragging and target and target >= 1 then

        if searchWindow.draggingFromSelection then
            local _, orderIndices = searchWindow:getSelectionOrder()
            if #orderIndices > 0 then
                local selPos = {}
                for i, idx in ipairs(orderIndices) do selPos[idx] = i end

                local sortedDesc = {}
                for _, idx in ipairs(orderIndices) do table.insert(sortedDesc, idx) end
                table.sort(sortedDesc, function(a, b) return a > b end)

                local extracted = {}
                for _, idx in ipairs(sortedDesc) do
                    extracted[selPos[idx]] = {
                        card = table.remove(cardData, idx),
                        flip = table.remove(flippedStates, idx),
                    }
                end

                local insertPos = target
                for _, idx in ipairs(sortedDesc) do
                    if idx < target then insertPos = insertPos - 1 end
                end
                insertPos = math.max(1, math.min(#cardData + 1, insertPos))
                
                for i = 1, #orderIndices do
                    table.insert(cardData, insertPos + i - 1, extracted[i].card)
                    table.insert(flippedStates, insertPos + i - 1, extracted[i].flip)
                end

                gamePieceHandler.playSound(deckItem, searchWindow.player)
                deckActionHandler.handleDetails(deckItem)
                searchWindow:clearSelection()
            end

        else
            local cardA = cardData[searchWindow.dragging]
            local flippedA = flippedStates[searchWindow.dragging]

            if searchWindow.dragInBetween then
                local selectionDrag = -1
                local dest = target
                if searchWindow.dragging < dest then
                    selectionDrag = 1
                    dest = dest - 1
                end
                for n = searchWindow.dragging, dest, selectionDrag do
                    cardData[n] = cardData[n + selectionDrag]
                    flippedStates[n] = flippedStates[n + selectionDrag]
                end
                cardData[dest] = cardA
                flippedStates[dest] = flippedA
            else
                local cardB = cardData[target]
                local flippedB = flippedStates[target]
                cardData[searchWindow.dragging] = cardB
                flippedStates[searchWindow.dragging] = flippedB
                cardData[target] = cardA
                flippedStates[target] = flippedA
            end

            gamePieceHandler.playSound(deckItem, searchWindow.player)
            deckActionHandler.handleDetails(deckItem)
        end
    end

    local gameWindow = gameNightWindow and gameNightWindow.instance
    local card = gameWindow and gameWindow.movingPiece
    if card then
        if target and target >= 0 then
            if gamePieceHandler.itemIsBusy(card) then gameWindow:clearMovingPiece(x, y) return end
            local notCompatible = card:getType() ~= deckItem:getType()
            if notCompatible then gameWindow:clearMovingPiece() return end
            deckActionHandler.mergeDecks(card, deckItem, searchWindow.player, target + (inBetween and 0 or 1))
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
    local selected, _ = searchWindow:getCardAtXY(x, y)

    if isAltKeyDown() then
        if selected and selected > 0 then
            searchWindow.selection = searchWindow.selection or {}
            searchWindow.selectionOrder = searchWindow.selectionOrder or {}
            if isShiftKeyDown() and searchWindow.selectionAnchor then
                local lo = math.min(searchWindow.selectionAnchor, selected)
                local hi = math.max(searchWindow.selectionAnchor, selected)
                for i = lo, hi do
                    if not searchWindow.selection[i] then
                        searchWindow.selection[i] = true
                        table.insert(searchWindow.selectionOrder, i)
                    end
                end
            else
                if searchWindow.selection[selected] then
                    searchWindow.selection[selected] = nil
                    for i = #searchWindow.selectionOrder, 1, -1 do
                        if searchWindow.selectionOrder[i] == selected then
                            table.remove(searchWindow.selectionOrder, i)
                            break
                        end
                    end
                else
                    searchWindow.selection[selected] = true
                    table.insert(searchWindow.selectionOrder, selected)
                end
                searchWindow.selectionAnchor = selected
            end
        end
        ISPanelJoypad.onMouseDown(self, x, y)
        return
    end

    if isShiftKeyDown() and searchWindow.selectionAnchor and selected and selected > 0 then
        searchWindow.selection = searchWindow.selection or {}
        searchWindow.selectionOrder = searchWindow.selectionOrder or {}
        local lo = math.min(searchWindow.selectionAnchor, selected)
        local hi = math.max(searchWindow.selectionAnchor, selected)
        for i = lo, hi do
            if not searchWindow.selection[i] then
                searchWindow.selection[i] = true
                table.insert(searchWindow.selectionOrder, i)
            end
        end
        ISPanelJoypad.onMouseDown(self, x, y)
        return
    end

    if selected and selected > 0 and searchWindow.selection and searchWindow.selection[selected] then
        searchWindow:clearDragging()
        searchWindow.dragging = selected
        searchWindow.draggingFromSelection = true
        local cardData, flippedStates = deckActionHandler.getDeckStates(searchWindow.deck)
        if cardData and cardData[selected] then
            local itemType = searchWindow.deck:getType()
            local fullType = searchWindow.deck:getFullType()
            local special = gamePieceHandler.specials[fullType]
            local texture
            if flippedStates[selected] ~= true then
                local cardFaceType = special and special.cardFaceType or itemType
                local textureToUse = deckActionHandler.fetchAltIcon(cardData[selected], searchWindow.deck)
                texture = getTexture("media/textures/Item_"..cardFaceType.."/"..textureToUse..".png")
            else
                texture = getTexture("media/textures/Item_"..itemType.."/FlippedInPlay.png")
            end
            searchWindow.draggingTextureSize = special and special.textureSize
            searchWindow.draggingTexture = texture
        end
        ISPanelJoypad.onMouseDown(self, x, y)
        return
    end

    if selected and selected > 0 then
        searchWindow:clearSelection()
        searchWindow:clearDragging()

        searchWindow.dragging = selected

        local cardData, flippedStates = deckActionHandler.getDeckStates(searchWindow.deck)
        if cardData and cardData[selected] then
            local itemType = searchWindow.deck:getType()
            local fullType = searchWindow.deck:getFullType()
            local special = gamePieceHandler.specials[fullType]
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
    else
        searchWindow:clearDragging()
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

            if gamePieceHandler.itemIsBusy(self.deck) then return end

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
    local special = gamePieceHandler.specials[fullType]
    local cardFaceType = special and special.cardFaceType or itemType

    local halfPad = math.floor((self.padding/2)+0.5)
    local xOffset, yOffset = halfPad, halfPad
    local resetXOffset = xOffset

    local specialCase = fullType and gamePieceHandler.specials[fullType]
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

                if self.selection and self.selection[n] then
                    self.cardDisplay:drawRect(xOffset, yOffset-(self.scrollY or 0), self.cardWidth, self.cardHeight, 0.35, 0.15, 0.45, 0.85)
                    self.cardDisplay:drawRectBorder(xOffset, yOffset-(self.scrollY or 0), self.cardWidth, self.cardHeight, 1, 0.3, 0.6, 1.0)
                end

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
    o.selection = {}
    o.selectionOrder = {}
    o.selectionAnchor = nil

    gameNightDeckSearch.instances[deckItem] = o
    return o
end