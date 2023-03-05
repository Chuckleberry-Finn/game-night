local deckActionHandler = {}
--local deck = {"cardName"}

---@param deckItem IsoObject
function deckActionHandler.getDeck(deckItem)
    --deckItem:getModData()["gameNight_cardDeck"] = deckItem:getModData()["gameNight_cardDeck"] or {}
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if not deckData then return print("ERROR: Unable to find modData deck: "..tostring(deckItem)) end
    return deckData
end


---@param deckItem InventoryItem
function deckActionHandler.generateCard(drawnCard, deckItem)
    local newCard = InventoryItemFactory.CreateItem(deckItem:getType())
    if newCard then
        newCard:getModData()["gameNight_cardDeck"] = {drawnCard}
        newCard:setName(getText("ItemName_PlayingCard"))
        local container = deckItem:getOutermostContainer()
        container:AddItem(newCard)
    end
end


function deckActionHandler.flipCard(deckItem)
    local currentState = deckItem:getModData()["gameNight_bFlipped"]

    if currentState == true then
        deckItem:getModData()["gameNight_bFlipped"] = false
    else
        deckItem:getModData()["gameNight_bFlipped"] = true
    end
end


---@param deckItem InventoryItem
function deckActionHandler.addCard(card, deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end
    table.insert(deck, card)
end


---@param deckItem InventoryItem
function deckActionHandler.drawCards(num, deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    local drawn = {}

    for i=1, num do
        local drawnCard = deck[#deck]
        deck[#deck] = nil
        table.insert(drawn, drawnCard)
    end

    for _,card in pairs(drawn) do
        print("drawn: "..card)
        deckActionHandler.generateCard(card, deckItem)
    end
end

function deckActionHandler.drawCard(deckItem) deckActionHandler.drawCards(1, deckItem) end


---@param deckItem InventoryItem
function deckActionHandler.drawRandCard(deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
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

    print("drawn: "..drawnCard)
    deckActionHandler.generateCard(drawnCard, deckItem)
end


function deckActionHandler.shuffleCards(deckItem)
    local deck = deckActionHandler.getDeck(deckItem)
    if not deck then return end

    for origIndex = #deck, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        deck[origIndex], deck[shuffledIndex] = deck[shuffledIndex], deck[origIndex]
    end
end


return deckActionHandler
