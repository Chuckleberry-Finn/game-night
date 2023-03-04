local deckCataloger = {}

deckCataloger.catalogues = {}

function deckCataloger.addDeck(name, cards) deckCataloger.catalogues[name] = cards end

deckCataloger.parsedItems = {}

---@param ItemContainer ItemContainer
function deckCataloger.applyDecks(ItemContainer)

    if not ItemContainer then return end
    local items = ItemContainer:getItems()
    for iteration=0, items:size()-1 do
        ---@type InventoryItem
        local item = items:get(iteration)

        if (not deckCataloger.parsedItems[item]) then

            local deck = deckCataloger.catalogues[item:getType()]
            if item and deck then

                deckCataloger.parsedItems[item] = true

                if deck then
                    item:getModData()["gameNight_cardDeck"] = item:getModData()["gameNight_cardDeck"] or copyTable(deck)
                    item:getModData()["gameNight_bFlipped"] = item:getModData()["gameNight_bFlipped"] or true
                end

            end
        end
    end

end


function deckCataloger.applyToInventory(ISInventoryPage, step) deckCataloger.applyDecks(ISInventoryPage.inventory) end
Events.OnRefreshInventoryWindowContainers.Add(deckCataloger.applyToInventory)

function deckCataloger.applyToFillContainer(contName, contType, container) deckCataloger.applyDecks(container) end
Events.OnFillContainer.Add(deckCataloger.applyToFillContainer)


return deckCataloger