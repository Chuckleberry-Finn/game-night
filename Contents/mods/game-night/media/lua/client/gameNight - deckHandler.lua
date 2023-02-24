--local card = {}--["name"] = value
--local deck = {}--["ID"]=card(?)


local deckHandler = {}


function deckHandler.getAndOrSetDeck(deckItem)
    local deckData = deckItem:getModData()["cardDeck"]

    if not deckData then
        ---initiate deck
    end

    return deckData
end


---@param deckItem InventoryItem
function deckHandler.addCard(deckItem)
    local deck = deckHandler.getAndOrSetDeck(deckItem)
    if not deck then return end

end


function deckHandler.shuffle(deckItem)

    local deck = deckHandler.getAndOrSetDeck(deckItem)

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end

