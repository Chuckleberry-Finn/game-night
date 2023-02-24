--local card = {}--["name"] = value
--local deck = {}--["ID"]=card(?)


local deckHandler = {}

---@param deckItem IsoObject
function deckHandler.getAndOrSetDeck(deckItem)
    deckItem:getModData()["gameNight_cardDeck"] = deckItem:getModData()["gameNight_cardDeck"] or {}
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    return deckData
end


---@param deckItem InventoryItem
function deckHandler.addCard(deckItem, card)
    local deck = deckHandler.getAndOrSetDeck(deckItem)
    if not deck then return print("ERROR: Unable to register deck: "..tostring(deckItem)) end
    table.insert(deck, card)
end


function deckHandler.shuffle(deckItem)

    local deck = deckHandler.getAndOrSetDeck(deckItem)
    if not deck then return print("ERROR: Unable to register deck: "..tostring(deckItem)) end

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end

