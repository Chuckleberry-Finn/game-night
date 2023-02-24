--local card = {}--["name"] = value
--local deck = {}--["ID"]=card(?)


local deckHandler = {}

---@param deckItem IsoObject
function deckHandler.getDeck(deckItem)
    --deckItem:getModData()["gameNight_cardDeck"] = deckItem:getModData()["gameNight_cardDeck"] or {}
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if not deckData then return print("ERROR: Unable to find modData deck: "..tostring(deckItem)) end
    return deckData
end


---@param deckItem InventoryItem
function deckHandler.addCard(card, deckItem)
    local deck = deckHandler.getDeck(deckItem)
    if not deck then return end
    table.insert(deck, card)
end


---@param deckItem InventoryItem
function deckHandler.drawCards(num, deckItem)
    local deck = deckHandler.getDeck(deckItem)
    if not deck then return end

    local drawn = {}

    for i=1, num do
        local drawnCard = deck[#deck]
        deck[#deck] = nil
        table.insert(drawn, drawnCard)
    end

    return drawn
end

function deckHandler.drawCard(deckItem) deckHandler.drawCards(1, deckItem) end


---@param deckItem InventoryItem
function deckHandler.drawRandCard(deckItem)
    local deck = deckHandler.getDeck(deckItem)
    if not deck then return end

    local deckCount = #deck
    local drawIndex = ZombRand(deckCount)+1

    local drawnCard

    for i=1,deckCount do
        if i==drawIndex then
            drawnCard = deck[i]
            deck[i] = nil
        end

        if i>drawIndex then
            if deck[i-1] == nil then
                deck[i-1] = deck[i]
                deck[i] = nil
            end
        end
    end

    return drawnCard
end


function deckHandler.shuffle(deckItem)
    local deck = deckHandler.getDeck(deckItem)
    if not deck then return end

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end

