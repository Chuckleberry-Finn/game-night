local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
--require "gameNight - deckSearchUI"
--require "gameNight - window"

local deckActionHandler = {}

deckActionHandler.deckCatalogues = {}
deckActionHandler.altDetails = {} --altNames, altIcons

function deckActionHandler.addDeck(itemType, cardIcons, altNames, altIcons)
    deckActionHandler.deckCatalogues[itemType] = cardIcons

    if altNames or altIcons then
        deckActionHandler.altDetails[itemType] = {}
        if altNames then deckActionHandler.altDetails[itemType].altNames = altNames end
        if altIcons then deckActionHandler.altDetails[itemType].altIcons = altIcons end
    end
end


function deckActionHandler.fetchAltName(card, deckItem)
    local itemType = deckItem:getType()
    if not deckActionHandler.altDetails[itemType] then return card end
    local altNames = deckActionHandler.altDetails[itemType].altNames

    local altName = altNames and altNames[card]
    return ((altName and (getTextOrNull("IGUI_"..altName) or altName)) or card)
end


function deckActionHandler.fetchAltIcon(card, deckItem)
    local itemType = deckItem:getType()
    if not deckActionHandler.altDetails[itemType] then return card end
    local altIcons = deckActionHandler.altDetails[itemType].altIcons

    local altIcon = altIcons and altIcons[card] or card
    return altIcon
end


function deckActionHandler.isDeckItem(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if deckData and #deckData>0 then return true end
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
    local fullType = deckItem:getFullType()

    deckItem:setActualWeight(deckActionHandler.cardWeight*#deckStates)
    deckItem:getTags():add("gameNight")

    ---@type Texture
    local texture

    local special = gamePieceAndBoardHandler.specials[fullType]
    local category = special and special.category or (#deckStates>1 and "Deck" or "Card")
    deckItem:setDisplayCategory(category)

    deckItem:getModData()["gameNight_sound"] = special and special.moveSound or "cardFlip"

    local name_suffix = #deckStates>1 and " ["..#deckStates.."]" or ""

    if flippedStates[#deckStates] ~= true then

        local tooltip = getTextOrNull("Tooltip_"..deckStates[#deckStates])
        if tooltip then deckItem:setTooltip(tooltip) end

        local cardName = deckStates[#deckStates]

        local nameOfCard = deckActionHandler.fetchAltName(cardName, deckItem)
        deckItem:setName(nameOfCard..name_suffix)

        local cardFaceType = special and special.cardFaceType or itemType

        local textureToUse = deckActionHandler.fetchAltIcon(cardName, deckItem)
        texture = getTexture("media/textures/Item_"..cardFaceType.."/"..textureToUse..".png")

        deckItem:getModData()["gameNight_textureInPlay"] = texture

    else
        local textureID = #deckStates>1 and "deck" or "card"

        local tooltip = getTextOrNull("Tooltip_"..itemType)
        if tooltip then deckItem:setTooltip(tooltip) end

        local itemName = #deckStates<=1 and getTextOrNull("IGUI_"..deckItem:getType()) or getItemNameFromFullType(deckItem:getFullType())
        deckItem:setName(itemName..name_suffix)

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

        if type(drawnCard)~="table" then drawnCard = {drawnCard} end
        if type(flipped)~="table" then flipped = {flipped} end

        newCard:getModData()["gameNight_cardDeck"] = drawnCard
        newCard:getModData()["gameNight_cardFlipped"] = flipped

        if deckItem then deckActionHandler.handleDetails(deckItem) end
        deckActionHandler.handleDetails(newCard)

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or (deckItem and deckItem:getWorldItem())
        local wiX = (locations and locations.offsets and locations.offsets.x) or (worldItem and (worldItem:getWorldPosX()-worldItem:getX())) or 0
        local wiY = (locations and locations.offsets and locations.offsets.y) or (worldItem and (worldItem:getWorldPosY()-worldItem:getY())) or 0
        local wiZ = (locations and locations.offsets and locations.offsets.z) or (worldItem and (worldItem:getWorldPosZ()-worldItem:getZ())) or 0

        ---@type IsoGridSquare
        local sq = (locations and locations.sq) or (worldItem and worldItem:getSquare())
        if sq then
            if isClient() then sendClientCommand(getPlayer(), "gameNightAction", "setCoolDown", {itemID=deckItem:getID()}) end
            sq:AddWorldInventoryItem(newCard, wiX, wiY, wiZ)
        else
            ---@type ItemContainer
            local container = (locations and locations.container) or (deckItem and deckItem:getContainer())
            if container then container:AddItem(newCard) end
        end

        return newCard
    end
end


function deckActionHandler._flipSpecificCard(deckItem, flipIndex)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end
    deckItem:getModData()["gameNight_cardFlipped"][flipIndex] = not currentFlipStates[flipIndex]
end
function deckActionHandler.flipSpecificCard(deckItem, player, index, x, y, z)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._flipSpecificCard, deckItem, index}, deckActionHandler.handleDetails, x, y, z)
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
function deckActionHandler.flipCard(deckItem, player, x, y, z)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._flipCard, deckItem}, deckActionHandler.handleDetails, x, y, z)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


function deckActionHandler.canMergeDecks(deckItemA, deckItemB)
    if (deckItemA:getType() ~= deckItemB:getType()) or (deckItemA == deckItemB) then return false end

    local deckB, flippedB = deckActionHandler.getDeckStates(deckItemB)
    if not deckB then return false end

    local deckA, flippedA = deckActionHandler.getDeckStates(deckItemA)
    if not deckA then return false end

    if (#deckB <= 300) and (#deckB <= 300) and (#deckB + #deckB <= 300) then return deckA, deckB, flippedA, flippedB end

    return false
end

function deckActionHandler._mergeDecks(player, deckItemA, deckA, deckItemB, deckB, flippedA, flippedB, index)
    index = index and math.min(#deckB+1,math.max(index,1)) or #deckB+1
    for i=#deckA, 1, -1 do
        table.insert(deckB, index, deckA[i])
        table.insert(flippedB, index, flippedA[i])
    end
    deckActionHandler.handleDetails(deckItemB)
    gamePieceAndBoardHandler.safelyRemoveGamePiece(deckItemA, player)
    gamePieceAndBoardHandler.refreshInventory(player)
end

---@param deckItemA InventoryItem
---@param deckItemB InventoryItem
function deckActionHandler.mergeDecks(deckItemA, deckItemB, player, index)

    local deckA, deckB, flippedA, flippedB = deckActionHandler.canMergeDecks(deckItemA, deckItemB)
    if not deckA or not deckB then return end

    gamePieceAndBoardHandler.pickupGamePiece(player, deckItemA)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItemB, {deckActionHandler._mergeDecks, player, deckItemA, deckA, deckItemB, deckB, flippedA, flippedB, index}, deckActionHandler.handleDetails)
    gamePieceAndBoardHandler.playSound(deckItemB, player)
end


---@param player IsoPlayer|IsoGameCharacter
function deckActionHandler._drawCards(num, deckItem, player, locations, faceUp, ignoreProcess)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return end

    local draw = #deckStates
    num = math.min(num, draw)

    local drawnCards = {}
    local drawnFlippedStates = {}

    local newCard

    if num < draw then
        for i=num, 1, -1 do
            local topCard = #deckStates
            local drawnCard, drawnFlip = deckStates[topCard], currentFlipStates[topCard]
            deckStates[topCard] = nil
            if currentFlipStates then currentFlipStates[topCard] = nil end
            table.insert(drawnCards, drawnCard)
            local flipState = drawnFlip
            if faceUp then flipState = false end
            table.insert(drawnFlippedStates, flipState)
        end
        newCard = deckActionHandler.generateCard(drawnCards, deckItem, drawnFlippedStates, locations)
    else
        newCard = deckItem
        if faceUp then
            local flipStates = {}
            for i=1, #currentFlipStates do flipStates[i] = false end
            deckItem:getModData()["gameNight_cardFlipped"] = flipStates
        end
    end

    if newCard then
        gamePieceAndBoardHandler.playSound(newCard, player)
        deckActionHandler.processOnDraw(deckItem)
        if (not ignoreProcess) then deckActionHandler.processCardToHand(newCard, player) end
    end

    return newCard
end


function deckActionHandler.processOnDraw(deckItem)
    local fullType = deckItem:getFullType()
    local special = gamePieceAndBoardHandler.specials[fullType]
    local onDraw = special and special.onDraw
    if onDraw and deckActionHandler[onDraw] then deckActionHandler[onDraw](deckItem) end
end


function deckActionHandler.processCardToHand(deckItem, player)
    if not player then return end

    local inHand = player and player:getPrimaryHandItem()
    local heldCards = inHand and deckActionHandler.isDeckItem(inHand)

    if player and deckItem:getContainer() then
        if not inHand then player:setPrimaryHandItem(deckItem) end
        if heldCards then
            local deckA, deckB, flippedA, flippedB = deckActionHandler.canMergeDecks(deckItem, inHand)
            if not deckA or not deckB then return end
            deckActionHandler._mergeDecks(player, deckItem, deckA, inHand, deckB, flippedA, flippedB)
        end
    end
end


function deckActionHandler.drawCards_isValid(deckItem, player, num)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if deckStates and #deckStates >= num then return true end
    return false
end

---@param deckItem InventoryItem
function deckActionHandler.drawCards(deckItem, player, num)
    local locations = {container=player:getInventory()}
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    local func = (num >= #deckStates) and "pickupGamePiece" or "pickupAndPlaceGamePiece"
    gamePieceAndBoardHandler[func](player, deckItem, {deckActionHandler._drawCards, num, deckItem, player, locations, true}, deckActionHandler.handleDetails)
end

function deckActionHandler.drawCard(deckItem, player) deckActionHandler.drawCards(deckItem, player, 1) end


function deckActionHandler._dealCards(deckItem, player, n, x, y)
    local worldItem = deckItem:getWorldItem()
    x = x or worldItem and (worldItem:getWorldPosX()-worldItem:getX()) or ZombRandFloat(0.48,0.52)
    y = y or worldItem and (worldItem:getWorldPosY()-worldItem:getY()) or ZombRandFloat(0.48,0.52)
    local z = worldItem and (worldItem:getWorldPosZ()-worldItem:getZ()) or 0
    ---@type IsoGridSquare
    local sq = (worldItem and worldItem:getSquare()) or (gameNightWindow and gameNightWindow.instance and gameNightWindow.instance.square)
    deckActionHandler._drawCards(n, deckItem, player, { sq=sq, offsets={x=x,y=y,z=z} }, nil, true)
end

function deckActionHandler.dealCards(deckItem, player, n, x, y, z)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._dealCards, deckItem, player, n, x, y}, deckActionHandler.handleDetails)
end

function deckActionHandler.dealCard(deckItem, player, x, y, z) deckActionHandler.dealCards(deckItem, player, 1, x, y, z) end



function deckActionHandler._drawCardIndex(deckItem, player, drawIndex, locations, ignoreProcess)
    local deckStates, currentFlipStates = deckActionHandler.getDeckStates(deckItem)
    if not deckStates then return deckItem end

    local deckCount = #deckStates
    if deckCount <= 1 then
        deckActionHandler.processOnDraw(deckItem)
        if player and (not ignoreProcess) then deckActionHandler.processCardToHand(deckItem, player) end
        return deckItem
    end

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

    local newCard = deckActionHandler.generateCard(drawnCard, deckItem, drawnFlipped, locations)
    deckActionHandler.processOnDraw(newCard)
    if player and (not ignoreProcess) then deckActionHandler.processCardToHand(newCard, player) end
    return newCard
end


---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem, player, x, y, z)
    local locations = {container=player:getInventory()}
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._drawCardIndex, deckItem, player, nil, locations}, deckActionHandler.handleDetails, x, y, z)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


---@param deckItem InventoryItem
function deckActionHandler.drawSpecificCard(deckItem, player, index, x, y, z)
    local locations = {container=player:getInventory()}
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._drawCardIndex, deckItem, player, index, locations}, deckActionHandler.handleDetails, x, y, z)
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
function deckActionHandler.shuffleCards(deckItem, player, x, y, z)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, deckItem, {deckActionHandler._shuffleCards, deckItem}, deckActionHandler.handleDetails, x, y, z)
    gamePieceAndBoardHandler.playSound(deckItem, player)
end


function deckActionHandler._searchDeck(deckItem, player)
    if deckActionHandler.isDeckItem(deckItem) then gameNightDeckSearch.open(player, deckItem) end
end
function deckActionHandler.searchDeck(deckItem, player)
    local onPickUp = deckActionHandler._searchDeck
    local pickedUp, x, y, z = gamePieceAndBoardHandler.pickupGamePiece(player, deckItem, {onPickUp, deckItem, player}, deckActionHandler.handleDetails)
    local playerInv = player:getInventory()
    local itemContainer = deckItem:getContainer()
    gamePieceAndBoardHandler.playSound(deckItem, player)
    if not pickedUp and itemContainer and itemContainer == playerInv then
        deckActionHandler._searchDeck(deckItem, player)
    end
end

function deckActionHandler.examine(gamePiece, player, indexIfCard)
    gamePieceAndBoardHandler.examine(gamePiece, player, indexIfCard)
end


return deckActionHandler