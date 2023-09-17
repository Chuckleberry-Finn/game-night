local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

local deckActionHandler = {}

function deckActionHandler.isDeckItem(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if deckData then return true end
    return false
end


---@param deckItem InventoryItem
function deckActionHandler.getDeckStates(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if not deckData then return end

    local cardFlipStates = deckItem:getModData()["gameNight_cardFlipped"]

    return deckData, cardFlipStates
end


deckActionHandler.cardWeight = 0.003
---@param deckItem InventoryItem
function deckActionHandler.handleDetails(deckItem)
    local deckStates, flippedStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates or not flippedStates then return end

    if #deckStates <= 0 then return end
    local itemType = deckItem:getType()

    deckItem:setActualWeight(deckActionHandler.cardWeight*#deckStates)
    deckItem:getTags():add("gameNight")

    ---@type Texture
    local texture

    local category = #deckStates>1 and "Deck" or "Card"
    deckItem:setDisplayCategory(category)

    deckItem:getModData()["gameNight_sound"] = "cardFlip"

    local name_suffix = #deckStates>1 and " ["..#deckStates.."]" or ""

    if flippedStates[#deckStates] ~= true then
        deckItem:setName(deckStates[#deckStates]..name_suffix)
        texture = getTexture("media/textures/Item_"..itemType.."/"..deckStates[#deckStates]..".png")
        deckItem:getModData()["gameNight_textureInPlay"] = nil

    else
        local textureID = #deckStates>1 and "deck" or "card"
        deckItem:setName(getText("IGUI_"..itemType)..name_suffix)
        texture = getTexture("media/textures/Item_"..itemType.."/"..textureID..".png")
        deckItem:getModData()["gameNight_textureInPlay"] = getTexture("media/textures/Item_"..itemType.."/FlippedInPlay.png")
    end

    if texture then deckItem:setTexture(texture) end

    --[[
    if isClient() then
        local worldItem = deckItem:getWorldItem()
        if worldItem then worldItem:transmitModData() end
    end
    --]]
end


---@param drawnCard string
---@param deckItem InventoryItem
function deckActionHandler.generateCard(drawnCard, deckItem, flipped)
    local newCard = InventoryItemFactory.CreateItem(deckItem:getType())
    if newCard then
        newCard:getModData()["gameNight_cardDeck"] = {drawnCard}
        newCard:getModData()["gameNight_cardFlipped"] = {flipped}

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = deckItem:getWorldItem()
        if worldItem then

            local wiX = (worldItem:getWorldPosX()-worldItem:getX())+ZombRandFloat(-0.1,0.1)
            local wiY = (worldItem:getWorldPosY()-worldItem:getY())+ZombRandFloat(-0.1,0.1)
            local wiZ = (worldItem:getWorldPosZ()-worldItem:getZ())

            ---@type IsoGridSquare
            local sq = worldItem:getSquare()
            if sq then sq:AddWorldInventoryItem(newCard, wiX, wiY, wiZ) end
        end

        ---@type ItemContainer
        local container = deckItem:getContainer()
        if container then container:AddItem(newCard) end

        deckActionHandler.handleDetails(deckItem)
        deckActionHandler.handleDetails(newCard)
        return newCard
    end
end


function deckActionHandler._flipSpecificCard(deckItem, flipIndex)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end
    deckItem:getModData()["gameNight_cardFlipped"][flipIndex] = not currentFlipStates[flipIndex]
end
function deckActionHandler.flipSpecificCard(deckItem, player, index)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._flipSpecificCard, deckItem, index}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


function deckActionHandler._flipCard(deckItem)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end

    local handleFlippedDeck = {}
    local handleFlippedStates = {}

    for n=#deckStates, 1, -1 do
        table.insert(handleFlippedDeck, deckStates[n])
        table.insert(handleFlippedStates, (not currentFlipStates[n]))
    end

    deckItem:getModData()["gameNight_cardDeck"] = handleFlippedDeck
    deckItem:getModData()["gameNight_cardFlipped"] = handleFlippedStates
end
function deckActionHandler.flipCard(deckItem, player)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._flipCard, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
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


function deckActionHandler._mergeDecks(deckItemA, deckItemB)
    local deckB, flippedB = deckActionHandler.getDeckStates(deckItemB)
    if not deckB then return end

    local deckA, flippedA = deckActionHandler.getDeckStates(deckItemA)
    if not deckA then return end

    for _,card in pairs(deckA) do table.insert(deckB, card) end
    for _,flip in pairs(flippedA) do table.insert(flippedB, flip) end
    deckActionHandler.safelyRemoveCard(deckItemA)
end
---@param deckItemA InventoryItem
---@param deckItemB InventoryItem
function deckActionHandler.mergeDecks(deckItemA, deckItemB, player)
    gamePieceAndBoardHandler.takeAction(player, deckItemA, nil)
    gamePieceAndBoardHandler.takeAction(player, deckItemB, {deckActionHandler._mergeDecks, deckItemA, deckItemB}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItemB, player)
end


function deckActionHandler._drawCards(num, deckItem, player)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end

    local drawnCards = {}
    local drawnFlippedStates = {}
    local draw = #deckStates

    for i=1, num do
        local drawnCard, drawnFlip = deckStates[draw], currentFlipStates[draw]
        deckStates[draw] = nil
        if currentFlipStates then currentFlipStates[draw] = nil end
        table.insert(drawnCards, drawnCard)
        table.insert(drawnFlippedStates, drawnFlip)
    end

    for n,card in pairs(drawnCards) do
        gamePieceAndBoardHandler.playSound(deckItem, player)
        local newCard = deckActionHandler.generateCard(card, deckItem, drawnFlippedStates[n])
    end

    return drawnCards, drawnFlippedStates
end
---@param deckItem InventoryItem
function deckActionHandler.drawCards(num, deckItem, player)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._drawCards, num, deckItem, player}, deckActionHandler.handleDetails)
end
function deckActionHandler.drawCard(deckItem, player) deckActionHandler.drawCards(1, deckItem, player) end


function deckActionHandler._drawCardIndex(deckItem, drawIndex)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end

    local deckCount = #deckStates
    drawIndex = drawIndex or ZombRand(deckCount)+1
    local drawnCard, drawnFlipped

    for i=1,deckCount do
        if i==drawIndex then
            drawnCard = deckStates[i]
            drawnFlipped = currentFlipStates[i]
            deckStates[i] = nil
            currentFlipStates[i] = nil
        end

        if i>drawIndex then
            if deckStates[i-1] == nil then
                deckStates[i-1] = deckStates[i]
                currentFlipStates[i-1] = currentFlipStates[i]
                deckStates[i] = nil
                currentFlipStates[i] = nil
            end
        end
    end

    local newCard = deckActionHandler.generateCard(drawnCard, deckItem, drawnFlipped)
end
---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem, player)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._drawCardIndex, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end

---@param deckItem InventoryItem
function deckActionHandler.drawSpecificCard(deckItem, player, index)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._drawCardIndex, deckItem, index}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end

function deckActionHandler._shuffleCards(deckItem)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end

    for origIndex = #deckStates, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        currentFlipStates[origIndex], currentFlipStates[shuffledIndex] = currentFlipStates[shuffledIndex], currentFlipStates[origIndex]
        deckStates[origIndex], deckStates[shuffledIndex] = deckStates[shuffledIndex], deckStates[origIndex]
    end
end
function deckActionHandler.shuffleCards(deckItem, player)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._shuffleCards, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


require "gameNight - deckSearchUI"
function deckActionHandler._searchDeck(deckItem, player)
   -- local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
   -- if not deckStates then return end
    if deckActionHandler.isDeckItem(deckItem) then gameNightDeckSearch.open(player, deckItem) end
end
function deckActionHandler.searchDeck(deckItem, player)
    gamePieceAndBoardHandler.takeAction(player, deckItem, {deckActionHandler._searchDeck, deckItem, player}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


return deckActionHandler
