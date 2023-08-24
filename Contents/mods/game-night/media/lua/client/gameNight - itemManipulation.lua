local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

local itemManipulation = {}

itemManipulation.deckCatalogues = {}

function itemManipulation.addDeck(name, cards) itemManipulation.deckCatalogues[name] = cards end


itemManipulation.parsedItems = {}
function itemManipulation.applyGameNightToItem(item)
    if not item then return end

    local gamePiece, deck

    if (not itemManipulation.parsedItems[item]) then

        if not gamePieceAndBoardHandler._itemTypes then gamePieceAndBoardHandler.generate_itemTypes() end

        print("APPLYING TO: "..item:getFullType())

        gamePiece = gamePieceAndBoardHandler.getGamePiece(item)
        if gamePiece then gamePieceAndBoardHandler.handleDetails(item) end

        deck = itemManipulation.deckCatalogues[item:getType()]
        if deck then
            itemManipulation.parsedItems[item] = true
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

    return gamePiece, deck
end


---@param ItemContainer ItemContainer
function itemManipulation.applyGameNightToInventory(ItemContainer)

    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)
        itemManipulation.applyGameNightToItem(item)
    end
end


function itemManipulation.applyToInventory(ISInventoryPage, step) if step == "begin" then itemManipulation.applyGameNightToInventory(ISInventoryPage.inventory) end end
Events.OnRefreshInventoryWindowContainers.Add(itemManipulation.applyToInventory)

function itemManipulation.applyToFillContainer(contName, contType, container) itemManipulation.applyGameNightToInventory(container) end
Events.OnFillContainer.Add(itemManipulation.applyToFillContainer)


return itemManipulation