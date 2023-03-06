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
    if not deckData then return print("ERROR: Unable to find modData deck: "..tostring(deckItem)) end
    return deckData
end


---@param deckItem InventoryItem
function deckActionHandler.handleDetails(deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    if #deck <= 0 then return end

    if #deck == 1 then
        deckItem:setName(getText("IGUI_PlayingCard").." ("..deck[1]..")")
        local texture = getTexture("media/textures/card"..deckItem:getType()..".png")
        deckItem:setTexture(texture)
    else
        deckItem:setName(getItemNameFromFullType(deckItem:getFullType()))
        local texture = getTexture("media/textures/deck"..deckItem:getType()..".png")
        deckItem:setTexture(texture)
    end
end


---@param drawnCard string
---@param deckItem InventoryItem
function deckActionHandler.generateCard(drawnCard, deckItem)
    local newCard = InventoryItemFactory.CreateItem(deckItem:getType())
    if newCard then
        newCard:getModData()["gameNight_cardDeck"] = {drawnCard}
        deckActionHandler.handleDetails(deckItem)
        deckActionHandler.handleDetails(newCard)

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

        local container = deckItem:getOutermostContainer()
        if container then container:AddItem(newCard) end

    end
end


function deckActionHandler.flipCard(deckItem)
    local currentState = deckItem:getModData()["gameNight_bFlipped"]

    if currentState == true then
        deckItem:getModData()["gameNight_bFlipped"] = false
    else
        deckItem:getModData()["gameNight_bFlipped"] = true
    end
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
    local deckB = deckActionHandler.getDeck(deckItemB)
    if not deckB then return end

    local deckA = deckActionHandler.getDeck(deckItemA)
    if not deckA then return end

    for _,card in pairs(deckA) do table.insert(deckB, card) end

    deckActionHandler.handleDetails(deckItemB)
    deckActionHandler.safelyRemoveCard(deckItemA)
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
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    local drawn = {}

    for i=1, num do
        local drawnCard = deck[#deck]
        deck[#deck] = nil
        table.insert(drawn, drawnCard)
    end

    for _,card in pairs(drawn) do
        print("drawn: "..card)
        deckActionHandler.generateCard(card, deckItem)
    end
end

function deckActionHandler.drawCard(deckItem) deckActionHandler.drawCards(1, deckItem) end


---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    local deckCount = #deck
    local drawIndex = ZombRand(deckCount)+1

    local drawnCard

    for i=1,deckCount do
        if i==drawIndex then
            drawnCard = deck[i]
            deck[i] = nil
        end

        if i>drawIndex then
            if deck[i-1] == nil then
                deck[i-1] = deck[i]
                deck[i] = nil
            end
        end
    end

    print("drawn: "..drawnCard)
    deckActionHandler.generateCard(drawnCard, deckItem)
end


function deckActionHandler.shuffleCards(deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end


return deckActionHandler
