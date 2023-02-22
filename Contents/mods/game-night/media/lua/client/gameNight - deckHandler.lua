--local card = {}--["name"] = value
--local deck = {}--["ID"]=card(?)

local deckHandler = {}

---@param deckItem InventoryItem
function deckHandler.addCard(deckItem)
    local deckData = deckItem:hasModData() and deckItem:getModData()["cardDeck"]
    if not deckData then return end

end


