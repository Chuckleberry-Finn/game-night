local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
require "gameNight - window"

local deckActionHandler = {}

deckActionHandler.staticDeckActions = {dealCard=true}

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


function deckActionHandler.fetchAltName(cardName, deckItem)
    local altName = deckItem:getModData()["gameNight_cardAltNames"] and deckItem:getModData()["gameNight_cardAltNames"][cardName]
    return ((altName and getItemNameFromFullType(altName)) or cardName)
end

function deckActionHandler.fetchAltIcon(cardName, deckItem)
    return (deckItem:getModData()["gameNight_cardAltIcons"] and deckItem:getModData()["gameNight_cardAltIcons"][cardName] or cardName)
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

        local tooltip = getTextOrNull("Tooltip_"..deckStates[#deckStates])
        if tooltip then deckItem:setTooltip(tooltip) end

        local cardName = deckStates[#deckStates]

        local nameOfCard = deckActionHandler.fetchAltName(cardName, deckItem)
        deckItem:setName(nameOfCard..name_suffix)

        local textureToUse = deckActionHandler.fetchAltIcon(cardName, deckItem)
        texture = getTexture("media/textures/Item_"..itemType.."/"..textureToUse..".png")

        deckItem:getModData()["gameNight_textureInPlay"] = texture

    else
        local textureID = #deckStates>1 and "deck" or "card"

        local tooltip = getTextOrNull("Tooltip_"..itemType)
        if tooltip then deckItem:setTooltip(tooltip) end

        deckItem:setName(getItemNameFromFullType(deckItem:getFullType())..name_suffix)
        texture = getTexture("media/textures/Item_"..itemType.."/"..textureID..".png")
        deckItem:getModData()["gameNight_textureInPlay"] = getTexture("media/textures/Item_"..itemType.."/FlippedInPlay.png")
    end

    if texture then deckItem:setTexture(texture) end

end


---@param drawnCard string
---@param deckItem InventoryItem
function deckActionHandler.generateCard(drawnCard, deckItem, flipped, locations)
    --sq=sq, offsets={x=wiX,y=wiY,z=wiZ}, container=container
    local newCard = InventoryItemFactory.CreateItem(deckItem:getType())
    if newCard then
        newCard:getModData()["gameNight_cardDeck"] = {drawnCard}
        newCard:getModData()["gameNight_cardFlipped"] = {flipped}

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or deckItem:getWorldItem()

        local wiX = (locations and locations.offsets and locations.offsets.x) or (worldItem and (worldItem:getWorldPosX()-worldItem:getX())) or 0
        local wiY = (locations and locations.offsets and locations.offsets.y) or (worldItem and (worldItem:getWorldPosY()-worldItem:getY())) or 0
        local wiZ = (locations and locations.offsets and locations.offsets.z) or (worldItem and (worldItem:getWorldPosZ()-worldItem:getZ())) or 0

        ---@type IsoGridSquare
        local sq = (locations and locations.sq) or (worldItem and worldItem:getSquare())
        if sq then
            sq:AddWorldInventoryItem(newCard, wiX, wiY, wiZ)
        else
            ---@type ItemContainer
            local container = (locations and locations.container) or deckItem:getContainer()
            if container then container:AddItem(newCard) end
        end

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
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._flipSpecificCard, deckItem, index}, deckActionHandler.handleDetails)
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
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._flipCard, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end




function deckActionHandler._mergeDecks(deckItemA, deckItemB, index, player)
    local deckB, flippedB = deckActionHandler.getDeckStates(deckItemB)
    if not deckB then return end

    local deckA, flippedA = deckActionHandler.getDeckStates(deckItemA)
    if not deckA then return end

    index = index and math.max(index,1) or 1

    for i=1, #deckA do
        table.insert(deckB, index, deckA[i])
        table.insert(flippedB, index, flippedA[i])
    end

    gamePieceAndBoardHandler.safelyRemoveGamePiece(deckItemA)
end
---@param deckItemA InventoryItem
---@param deckItemB InventoryItem
function deckActionHandler.mergeDecks(deckItemA, deckItemB, player, index)
    gamePieceAndBoardHandler.pickupGamePiece(player, deckItemA, true)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItemB, {deckActionHandler._mergeDecks, deckItemA, deckItemB, index, player}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItemB, player)
end


function deckActionHandler._drawCards(num, deckItem, player, locations)
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

    local newCards = {}
    for n,card in pairs(drawnCards) do
        gamePieceAndBoardHandler.playSound(deckItem, player)
        local newCard = deckActionHandler.generateCard(card, deckItem, drawnFlippedStates[n], locations)
        table.insert(newCards, newCard)
    end

    return newCards
end


---@param deckItem InventoryItem
function deckActionHandler.drawCards(num, deckItem, player, locations)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._drawCards, num, deckItem, player, locations}, deckActionHandler.handleDetails)
end


function deckActionHandler.drawCard(deckItem, player) deckActionHandler.drawCards(1, deckItem, player) end


function deckActionHandler.dealCard(deckItem, player, x, y)

    local worldItem, container = deckItem:getWorldItem(), deckItem:getContainer()
    x = x or worldItem and (worldItem:getWorldPosX()-worldItem:getX()) or 0
    y = y or worldItem and (worldItem:getWorldPosY()-worldItem:getY()) or 0
    local z = worldItem and (worldItem:getWorldPosZ()-worldItem:getZ()) or 0
    ---@type IsoGridSquare
    local sq = (worldItem and worldItem:getSquare()) or (gameNightWindow and gameNightWindow.instance and gameNightWindow.instance.square)

    deckActionHandler.drawCards(1, deckItem, player, { sq=sq, offsets={x=x,y=y,z=z}, container=container })
end

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
    return newCard
end
---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem, player)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._drawCardIndex, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end

---@param deckItem InventoryItem
function deckActionHandler.drawSpecificCard(deckItem, player, index)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._drawCardIndex, deckItem, index}, deckActionHandler.handleDetails)
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
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._shuffleCards, deckItem}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


require "gameNight - deckSearchUI"
function deckActionHandler._searchDeck(deckItem, player)
   -- local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
   -- if not deckStates then return end
    if deckActionHandler.isDeckItem(deckItem) then gameNightDeckSearch.open(player, deckItem) end
end
function deckActionHandler.searchDeck(deckItem, player)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._searchDeck, deckItem, player}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


return deckActionHandler
