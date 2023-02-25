local deckCataloger = {}

deckCataloger.catalogues = {}

function deckCataloger.addDeck(name, cards)
    deckCataloger.catalogues[name] = cards
end

return deckCataloger