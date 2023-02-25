local deckCataloger = {}

deckCataloger.catalogues = {}

function deckCataloger.addDeck(name, cards)
    deckCataloger.catalogues[name] = cards
end

---@param item InventoryItem
function deckCataloger.applyDeck(item)
    local deck = deckCataloger.catalogues[item:getType()]
    if deck then item:getModData()["gameNight_cardDeck"] = copyTable(deck) end
end

return deckCataloger