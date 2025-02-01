local applyItemDetails = {}

applyItemDetails.deckActionHandler = require "gameNight - deckActionHandler"
applyItemDetails.gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"


function applyItemDetails.applyCardsFromDeck(item, deck)

    item:getModData()["gameNight_cardDeck"] = item:getModData()["gameNight_cardDeck"] or copyTable(deck)

    --oops, clear this
    item:getModData()["gameNight_cardAltNames"] = nil
    item:getModData()["gameNight_cardAltIcons"] = nil
    
    local flippedStates = item:getModData()["gameNight_cardFlipped"]
    if not flippedStates then
        item:getModData()["gameNight_cardFlipped"] = {}
        for i=1, #deck do item:getModData()["gameNight_cardFlipped"][i] = true end
    end
end


applyItemDetails.parsedItems = {}
---@param item InventoryItem
function applyItemDetails.applyGameNightToItem(item, stackInit)
    if not item then return end

    local gamePiece, deck

    if (not applyItemDetails.parsedItems[item]) then

        applyItemDetails.parsedItems[item] = true

        if not applyItemDetails.gamePieceAndBoardHandler._itemTypes then applyItemDetails.gamePieceAndBoardHandler.generate_itemTypes() end

        gamePiece = applyItemDetails.gamePieceAndBoardHandler.isGamePiece(item)
        if gamePiece then applyItemDetails.gamePieceAndBoardHandler.handleDetails(item, stackInit) end

        local itemType = item:getType()
        local fullType = item:getFullType()

        if item:getDisplayCategory() == "GameBox" then
            local specialCase = applyItemDetails.gamePieceAndBoardHandler.specials[fullType]
            if specialCase and specialCase.nonGamePieceOnApplyDetails then
                local func = applyItemDetails[specialCase.nonGamePieceOnApplyDetails]
                if func then func(item) end
            end
        end

        deck = applyItemDetails.deckActionHandler.deckCatalogues[itemType]
        if deck and applyItemDetails.gamePieceAndBoardHandler.specials then
            local specialCase = applyItemDetails.gamePieceAndBoardHandler.specials[fullType]
            if specialCase and specialCase.applyCards then
                applyItemDetails[specialCase.applyCards](item, deck)
            else
                applyItemDetails.applyCardsFromDeck(item, deck)
            end

            applyItemDetails.deckActionHandler.handleDetails(item)
        end
    end
end


applyItemDetails.runExplore = {}

function applyItemDetails.scanRunExplore()
    if #applyItemDetails.runExplore <= 0 then return end
    for i=#applyItemDetails.runExplore, 0, -1 do
        local item = applyItemDetails.runExplore[i]
        if item then
            local container = item:getInventory()
            container:setExplored(true)
            gameNightOnCreateGameBox(item)

            local items = container:getItems()
            for iteration=0, items:size()-1 do
                ---@type InventoryItem
                local ii = items:get(iteration)
                applyItemDetails.applyGameNightToItem(ii, true)
            end
        end
        applyItemDetails.runExplore[i] = nil
    end
end

---@param ItemContainer ItemContainer
function applyItemDetails.applyGameNightToInventory(ItemContainer, stackInit)
    if not ItemContainer then return end

    local applyStacks = false
    local containingItem = ItemContainer:getContainingItem()
    if containingItem and (containingItem:getDisplayCategory() == "GameBox" or containingItem:getModData().gameNight_boxEnough) and (not containingItem:getModData().gameNight_gameBoxFill) then

        containingItem:getModData().gameNight_gameBoxFill = true

        if not ItemContainer:isExplored() then
            table.insert(applyItemDetails.runExplore, containingItem)
            return
        end

        gameNightOnCreateGameBox(containingItem)
        applyStacks = true
    end

    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)
        applyItemDetails.applyGameNightToItem(item, (applyStacks or stackInit))
    end
end


function applyItemDetails.applyToInventory(ISInventoryPage, step)
    if step == "end" then
        applyItemDetails.applyGameNightToInventory(ISInventoryPage.inventory)
    end
end

function applyItemDetails.applyToFillContainer(contName, contType, container, info)

    print("contName: ", contName, "|  contType:",contType, "|  container:",container, "|  info: ",info)

    applyItemDetails.applyGameNightToInventory(container, true)
end

return applyItemDetails