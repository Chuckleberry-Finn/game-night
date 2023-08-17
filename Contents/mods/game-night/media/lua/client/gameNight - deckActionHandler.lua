local deckActionHandler = {}
--local deck = {"cardName"}

function deckActionHandler.isDeckItem(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if deckData then return true end
    return false
end


---@param deckItem IsoObject
function deckActionHandler.getDeck(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if not deckData then return end

    local cardFlipStates = deckItem:getModData()["gameNight_cardFlipped"]

    return deckData, cardFlipStates
end


deckActionHandler.cardWeight = 0.003
---@param deckItem InventoryItem
function deckActionHandler.handleDetails(deckItem)
    local deck, flippedStates = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    if #deck <= 0 then return end
    local itemType = deckItem:getType()

    deckItem:setWeight(deckActionHandler.cardWeight*#deck)
    deckItem:getTags():add("gameNight")

    if #deck == 1 then
        ---@type Texture
        local texture

        deckItem:setDisplayCategory("Card")

        if flippedStates and flippedStates[1] ~= true then
            deckItem:setName(deck[1])
            texture = getTexture("media/textures/"..itemType.."/"..deck[1]..".png")
        else
            texture = getTexture("media/textures/"..itemType.."/card"..deckItem:getType()..".png")
            deckItem:setName(getText("IGUI_PlayingCard"))
        end

        if texture then deckItem:setTexture(texture) end

    else
        deckItem:setDisplayCategory("Deck")

        deckItem:setName(getItemNameFromFullType(deckItem:getFullType()).." ["..#deck.."]")
        local texture = getTexture("media/textures/"..itemType.."/deck"..deckItem:getType()..".png")
        deckItem:setTexture(texture)
    end

    ---@type ItemContainer
    local container = deckItem:getOutermostContainer()
    if container then
        local contParent = container:getParent()
        if contParent and instanceof(contParent, "IsoPlayer") then

            local inventory = getPlayerInventory(contParent:getPlayerNum())
            if inventory then inventory:refreshBackpacks() end

            local loot = getPlayerLoot(contParent:getPlayerNum())
            if loot then loot:refreshBackpacks() end
        end
    end
end


---@param drawnCard string
---@param deckItem InventoryItem
function deckActionHandler.generateCard(drawnCard, deckItem, flipped)
    local newCard = InventoryItemFactory.CreateItem(deckItem:getType())
    if newCard then
        newCard:getModData()["gameNight_cardDeck"] = {drawnCard}
        newCard:getModData()["gameNight_cardFlipped"] = {flipped}

        ---@type IsoWorldInventoryObject
        local worldItem = deckItem:getWorldItem()
        if worldItem then
            ---@type IsoGridSquare
            local sq = worldItem:getSquare()
            if sq then
                sq:AddWorldInventoryItem(newCard, 0, 0, 0)
                return
            end
        end

        ---@type ItemContainer
        local container = deckItem:getOutermostContainer()
        if container then container:AddItem(newCard) end

        deckActionHandler.handleDetails(deckItem)
        deckActionHandler.handleDetails(newCard)
        return newCard
    end
end


function deckActionHandler.flipCard(deckItem)
    local deck, currentFlipStates = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    for n,card in pairs(deck) do
        local flipped = currentFlipStates[n]
        if flipped == true then
            currentFlipStates[n] = false
        else
            currentFlipStates[n] = true
        end
    end

    deckActionHandler.handleDetails(deckItem)
end


---@param inventoryItem InventoryItem
function deckActionHandler.safelyRemoveCard(inventoryItem)
    local worldItem = inventoryItem:getWorldItem()
    if worldItem then
        ---@type IsoGridSquare
        local sq = worldItem:getSquare()
        if sq then
            sq:transmitRemoveItemFromSquare(worldItem)
            sq:removeWorldObject(worldItem)
            inventoryItem:setWorldItem(nil)
        end
    end
    ---@type ItemContainer
    local container = inventoryItem:getContainer()
    if container then container:DoRemoveItem(inventoryItem) end
end


---@param deckItemA InventoryItem
---@param deckItemB InventoryItem
function deckActionHandler.mergeDecks(deckItemA, deckItemB)
    local deckB, flippedB = deckActionHandler.getDeck(deckItemB)
    if not deckB then return end

    local deckA, flippedA = deckActionHandler.getDeck(deckItemA)
    if not deckA then return end

    for _,card in pairs(deckA) do table.insert(deckB, card) end
    for _,flip in pairs(flippedA) do table.insert(flippedB, flip) end

    deckActionHandler.handleDetails(deckItemB)
    deckActionHandler.safelyRemoveCard(deckItemA)
end


require "ISUI/ISInventoryPane"

local ISInventoryPane_doContextualDblClick = ISInventoryPane.doContextualDblClick
function ISInventoryPane:doContextualDblClick(item)
    ISInventoryPane_doContextualDblClick(self, item)
    local deck, flippedStates = deckActionHandler.getDeck(item)
    if deck then
        if #deck>1 then
            deckActionHandler.drawCard(item)
        else
            deckActionHandler.flipCard(item)
        end
    end
end


local ISInventoryPane_onMouseUp = ISInventoryPane.onMouseUp
function ISInventoryPane:onMouseUp(x, y)
    if not self:getIsVisible() then return end

    local draggingOld = ISMouseDrag.dragging
    local draggingFocusOld = ISMouseDrag.draggingFocus
    local selectedOld = self.selected
    local busy = false
    self.previousMouseUp = self.mouseOverOption

    local noSpecialKeys = (not isShiftKeyDown() and not isCtrlKeyDown())
    if (noSpecialKeys and x >= self.column2 and  x == self.downX and y == self.downY) and self.mouseOverOption ~= 0 and self.items[self.mouseOverOption] ~= nil then busy = true end

    local result = ISInventoryPane_onMouseUp(self, x, y)
    if not result then return end
    if busy or (not noSpecialKeys) then return end

    self.selected = selectedOld

    if (draggingOld ~= nil) and (draggingFocusOld == self) and (draggingFocusOld ~= nil) then

        if self.player ~= 0 then return end
        local playerObj = getSpecificPlayer(self.player)
        local itemFound = {}

        local doWalk = true
        local dragging = ISInventoryPane.getActualItems(draggingOld)
        for i,v in ipairs(dragging) do
            if deckActionHandler.isDeckItem(v) then
                local transfer = v:getContainer() and not self.inventory:isInside(v)
                if v:isFavorite() and not self.inventory:isInCharacterInventory(playerObj) then transfer = false end
                if transfer then
                    if doWalk then if not luautils.walkToContainer(self.inventory, self.player) then break end doWalk = false end
                    table.insert(itemFound, v)
                end
            end
        end

        if #itemFound <= 0 then
            ISMouseDrag.dragging = draggingOld
            ISMouseDrag.draggingFocus = draggingFocusOld
            self.selected = selectedOld
            return true
        end

        self.selected = {}
        getPlayerLoot(self.player).inventoryPane.selected = {}
        getPlayerInventory(self.player).inventoryPane.selected = {}

        local pushTo = self.items[self.mouseOverOption]
        if not pushTo then return end

        local pushToActual
        if instanceof(pushTo, "InventoryItem") then pushToActual = pushTo else pushToActual = pushTo.items[1] end

        for _,deck in pairs(itemFound) do if deck==pushToActual then return end end

        if pushToActual and deckActionHandler.isDeckItem(pushToActual) then for _,deck in pairs(itemFound) do deckActionHandler.mergeDecks(deck, pushToActual) end end
    end
end


---@param deckItem InventoryItem
function deckActionHandler.drawCards(num, deckItem)
    local deck, currentFlipStates = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    local drawnCards = {}
    local drawnFlippedStates = {}
    local draw = #deck

    for i=1, num do
        local drawnCard, drawnFlip = deck[draw], currentFlipStates[draw]
        deck[draw] = nil
        if currentFlipStates then currentFlipStates[draw] = nil end
        table.insert(drawnCards, drawnCard)
        table.insert(drawnFlippedStates, drawnFlip)
    end

    for n,card in pairs(drawnCards) do
        local newCard = deckActionHandler.generateCard(card, deckItem, not drawnFlippedStates[n])
    end
end

function deckActionHandler.drawCard(deckItem) deckActionHandler.drawCards(1, deckItem) end

---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem)
    local deck, currentFlipStates = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    local deckCount = #deck
    local drawIndex = ZombRand(deckCount)+1
    local drawnCard, drawnFlipped

    for i=1,deckCount do
        if i==drawIndex then
            drawnCard = deck[i]
            drawnFlipped = currentFlipStates[i]
            deck[i] = nil
            currentFlipStates[i] = nil
        end

        if i>drawIndex then
            if deck[i-1] == nil then
                deck[i-1] = deck[i]
                currentFlipStates[i-1] = currentFlipStates[i]
                deck[i] = nil
                currentFlipStates[i] = nil
            end
        end
    end

    local newCard = deckActionHandler.generateCard(drawnCard, deckItem, not drawnFlipped)
end


function deckActionHandler.shuffleCards(deckItem)
    local deck, currentFlipStates = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        currentFlipStates[origIndex], currentFlipStates[shuffledIndex] = currentFlipStates[shuffledIndex], currentFlipStates[origIndex]
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end


return deckActionHandler
