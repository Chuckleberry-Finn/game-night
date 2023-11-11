--- For anyone looking to make a sub-mod:
--- ! SEE: `gameNight - implementUno` for a simpler example on adding decks.
--- MONOPOLY includes 'alternative' names/icons for cards that will either have the same name or look the same but operate differently.

local applyItemDetails = require "gameNight - applyItemDetails"

--- MONOPOLY DEED DECK
local MonopolyDeedDeck = {}

MonopolyDeedDeck.cards = {"Electric Works","Water Works"}

MonopolyDeedDeck.set = {}
MonopolyDeedDeck.set.Brown = {"Mediterranean Avenue","Baltic Avenue"}
MonopolyDeedDeck.set.Blue = {"Oriental Avenue","Vermont Avenue","Connecticut Avenue"}
MonopolyDeedDeck.set.Pink = {"St. Charles Place","States Avenue","Virginia Avenue"}
MonopolyDeedDeck.set.Orange = {"St. James Place","Tennessee Avenue","New York Avenue"}
MonopolyDeedDeck.set.Red = {"Kentucky Avenue","Indiana Avenue","Illinois Avenue"}
MonopolyDeedDeck.set.Yellow = {"Atlantic Avenue","Ventnor Avenue","Marvin Gardens"}
MonopolyDeedDeck.set.Green = {"Pacific Avenue","North Carolina Avenue","Pennsylvania Avenue"}
MonopolyDeedDeck.set.Purple = {"Park Place","Boardwalk"}

MonopolyDeedDeck.set.RailRoad = {"Reading Railroad","Pennsylvania Railroad","B & D Railroad", "Short Line"}

MonopolyDeedDeck.altIcons = {}

for set,cards in pairs(MonopolyDeedDeck.set) do
    for _,card in pairs(cards) do
        MonopolyDeedDeck.altIcons[card] = set.."Deed"
        table.insert(MonopolyDeedDeck.cards, card)
    end
end

applyItemDetails.addDeck("MonopolyDeed", MonopolyDeedDeck.cards, nil, MonopolyDeedDeck.altIcons)


---Money
--40 $1,$5,$10
--50 $20
--30 $50
--20 $100,$500

---Chance
local MonopolyChanceDeck = {}
MonopolyChanceDeck.cards = {}
MonopolyChanceDeck.altIcons = {}
MonopolyChanceDeck.altNames = {}

for n=1, 25 do
    local cardID = "Chance"..n
    local fetchCard = getTextOrNull("Tooltip_"..cardID)
    if fetchCard then
        table.insert(MonopolyChanceDeck.cards, cardID)
        MonopolyChanceDeck.altNames[cardID] = "Base.MonopolyChance"
        MonopolyChanceDeck.altIcons[cardID] = "ChanceCard"
    end
end

applyItemDetails.addDeck("MonopolyChance", MonopolyChanceDeck.cards, MonopolyChanceDeck.altNames, MonopolyChanceDeck.altIcons)


---Community Chest
local MonopolyCommunityChestDeck = {}
MonopolyCommunityChestDeck.cards = {}
MonopolyCommunityChestDeck.altIcons = {}
MonopolyCommunityChestDeck.altNames = {}

for n=1, 25 do
    local cardID = "CommunityChest"..n
    local fetchCard = getTextOrNull("Tooltip_"..cardID)
    if fetchCard then
        table.insert(MonopolyCommunityChestDeck.cards, cardID)
        MonopolyCommunityChestDeck.altNames[cardID] = "Base.MonopolyCommunityChest"
        MonopolyCommunityChestDeck.altIcons[cardID] = "CommunityChest"
    end
end

applyItemDetails.addDeck("MonopolyCommunityChest", MonopolyCommunityChestDeck.cards, MonopolyCommunityChestDeck.altNames, MonopolyCommunityChestDeck.altIcons)


---REGISTER GAME PIECES AND BOARD -- SEE CATAN IMPLEMENTATION FOR MORE INFO
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
gamePieceAndBoardHandler.registerTypes({
    "Base.MonopolyBoard", "Base.MonopolyBoat", "Base.MonopolyBoot", "Base.MonopolyCar", "Base.MonopolyDog",
    "Base.MonopolyHat", "Base.MonopolyIron", "Base.MonopolyThimble", "Base.MonopolyWheelbarrow",
    "Base.MonopolyHouse","Base.MonopolyHotel"
})


gamePieceAndBoardHandler.registerSpecial("Base.MonopolyBoard", { category = "GameBoard", textureSize = {266,266} })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney1", { canStack = 40 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney5", { canStack = 40 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney10", { canStack = 40 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney20", { canStack = 50 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney50", { canStack = 30 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney100", { canStack = 20 })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney500", { canStack = 20 })