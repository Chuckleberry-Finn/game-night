local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

local applyItemDetails = {}

applyItemDetails.deckCatalogues = {}

function applyItemDetails.addDeck(name, cards) applyItemDetails.deckCatalogues[name] = cards end


applyItemDetails.parsedItems = {}
function applyItemDetails.applyGameNightToItem(item)
    if not item then return end

    local gamePiece, deck

    if (not applyItemDetails.parsedItems[item]) then

        if not gamePieceAndBoardHandler._itemTypes then gamePieceAndBoardHandler.generate_itemTypes() end

        gamePiece = gamePieceAndBoardHandler.getGamePiece(item)
        if gamePiece then gamePieceAndBoardHandler.handleDetails(item) end

        deck = applyItemDetails.deckCatalogues[item:getType()]
        if deck then
            applyItemDetails.parsedItems[item] = true
            if deck then
                item:getModData()["gameNight_cardDeck"] = item:getModData()["gameNight_cardDeck"] or copyTable(deck)

                local flippedStates = item:getModData()["gameNight_cardFlipped"]
                if not flippedStates then
                    item:getModData()["gameNight_cardFlipped"] = {}
                    for i=1, #deck do item:getModData()["gameNight_cardFlipped"][i] = true end
                end
                deckActionHandler.handleDetails(item)
            end
        end
    end
end


---@param ItemContainer ItemContainer
function applyItemDetails.applyGameNightToInventory(ItemContainer)

    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)
        applyItemDetails.applyGameNightToItem(item)
    end
end


function applyItemDetails.applyToInventory(ISInventoryPage, step) if step == "begin" then applyItemDetails.applyGameNightToInventory(ISInventoryPage.inventory) end end
Events.OnRefreshInventoryWindowContainers.Add(applyItemDetails.applyToInventory)

function applyItemDetails.applyToFillContainer(contName, contType, container) applyItemDetails.applyGameNightToInventory(container) end
Events.OnFillContainer.Add(applyItemDetails.applyToFillContainer)


return applyItemDetails