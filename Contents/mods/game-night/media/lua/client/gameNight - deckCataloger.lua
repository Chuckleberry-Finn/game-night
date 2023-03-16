local deckActionHandler = require "gameNight - deckActionHandler"

local deckCataloger = {}

deckCataloger.catalogues = {}

function deckCataloger.addDeck(name, cards) deckCataloger.catalogues[name] = cards end


deckCataloger.parsedItems = {}
function deckCataloger.applyDeckToItem(item)
    if (not deckCataloger.parsedItems[item]) then

        local deck = deckCataloger.catalogues[item:getType()]

        if item and deck then
            deckCataloger.parsedItems[item] = true
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
function deckCataloger.applyDecks(ItemContainer)

    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)
        deckCataloger.applyDeckToItem(item)
    end
end


function deckCataloger.applyToInventory(ISInventoryPage, step) if step == "begin" then deckCataloger.applyDecks(ISInventoryPage.inventory) end end
Events.OnRefreshInventoryWindowContainers.Add(deckCataloger.applyToInventory)

function deckCataloger.applyToFillContainer(contName, contType, container) deckCataloger.applyDecks(container) end
Events.OnFillContainer.Add(deckCataloger.applyToFillContainer)


return deckCataloger