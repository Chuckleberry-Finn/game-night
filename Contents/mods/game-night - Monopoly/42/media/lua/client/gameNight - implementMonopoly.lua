--- For anyone looking to make a sub-mod:
--- ! SEE: `gameNight - implementUno` for a simpler example on adding decks.
--- MONOPOLY includes 'alternative' names/icons for cards that will either have the same name or look the same but operate differently.

local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

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

deckActionHandler.addDeck("MonopolyDeed", MonopolyDeedDeck.cards, nil, MonopolyDeedDeck.altIcons)


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
        MonopolyChanceDeck.altNames[cardID] = "MonopolyChance"
        MonopolyChanceDeck.altIcons[cardID] = "ChanceCard"
    end
end

deckActionHandler.addDeck("MonopolyChance", MonopolyChanceDeck.cards, MonopolyChanceDeck.altNames, MonopolyChanceDeck.altIcons)


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
        MonopolyCommunityChestDeck.altNames[cardID] = "MonopolyCommunityChest"
        MonopolyCommunityChestDeck.altIcons[cardID] = "CommunityChest"
    end
end

deckActionHandler.addDeck("MonopolyCommunityChest", MonopolyCommunityChestDeck.cards, MonopolyCommunityChestDeck.altNames, MonopolyCommunityChestDeck.altIcons)


---REGISTER GAME PIECES AND BOARD -- SEE CATAN IMPLEMENTATION FOR MORE INFO
gamePieceAndBoardHandler.registerTypes({
    "Base.MonopolyBoard", "Base.MonopolyBoat", "Base.MonopolyBoot", "Base.MonopolyCar", "Base.MonopolyDog",
    "Base.MonopolyHat", "Base.MonopolyIron", "Base.MonopolyThimble", "Base.MonopolyWheelbarrow",
    "Base.MonopolyHouse","Base.MonopolyHotel",

    "Base.MonopolyMoney1", "Base.MonopolyMoney5", "Base.MonopolyMoney10", "Base.MonopolyMoney20",
    "Base.MonopolyMoney50", "Base.MonopolyMoney100", "Base.MonopolyMoney500"
})

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyBoat", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyBoot", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyCar", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyDog", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyHat", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyIron", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyThimble", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyWheelbarrow", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyHouse", { noRotate=true, })
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyHotel", { noRotate=true, })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyBoard", {
    category = "GameBoard", textureSize = {532,532}, actions = { lock=true },
    tooltips = {--used coords in photoshop which treats top-left as 0x0
        { x = 208, y = 228, w = 20, h = 33, text = "Mediterranean Avenue" },
        { x = 166, y = 228, w = 20, h = 33, text = "Baltic Avenue" },
        { x = 145, y = 228, w = 20, h = 33, text = "Income Tax" },
        { x = 124, y = 228, w = 20, h = 33, text = "Reading Railroad" },

        { x = 103, y = 228, w = 20, h = 33, text = "Oriental Avenue" },
        { x = 61, y = 228, w = 20, h = 33, text = "Vermont Avenue" },
        { x = 39, y = 228, w = 20, h = 33, text = "Connecticut Avenue" },

        { x = 5, y = 206, w = 33, h = 21, text = "St. Charles Place" },
        { x = 5, y = 185, w = 33, h = 21, text = "Electric Company" },
        { x = 5, y = 164, w = 33, h = 20, text = "States Avenue" },
        { x = 5, y = 143, w = 33, h = 20, text = "Virginia Avenue" },
        { x = 5, y = 122, w = 33, h = 20, text = "Pennsylvania Railroad" },

        { x = 5, y = 101, w = 33, h = 20, text = "St. James Place" },
        { x = 5, y = 59, w = 33, h = 20, text = "Tennessee Avenue" },
        { x = 5, y = 38, w = 33, h = 20, text = "New York Avenue" },

        { x = 39, y = 5, w = 21, h = 32, text = "Kentucky Avenue" },
        { x = 82, y = 5, w = 20, h = 32, text = "Indiana Avenue" },
        { x = 103, y = 5, w = 20, h = 32, text = "Illinois Avenue" },
        { x = 124, y = 5, w = 20, h = 32, text = "B & O Railroad" },

        { x = 145, y = 5, w = 20, h = 32, text = "Atlantic Avenue" },
        { x = 166, y = 5, w = 20, h = 32, text = "Ventnor Avenue" },
        { x = 208, y = 5, w = 20, h = 32, text = "Marvin Avenue" },

        { x = 229, y = 39, w = 32, h = 20, text = "Pacific Avenue" },
        { x = 229, y = 59, w = 32, h = 20, text = "North Carolina Avenue" },
        { x = 229, y = 101, w = 32, h = 20, text = "Pennsylvania Gardens" },

        { x = 229, y = 122, w = 32, h = 20, text = "Short Line" },
        { x = 229, y = 164, w = 32, h = 20, text = "Park Place" },
        { x = 229, y = 185, w = 32, h = 20, text = "Luxury Tax" },
        { x = 229, y = 206, w = 32, h = 20, text = "Boardwalk" },
    }
})
gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney1", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.882, 0.882, 0.882} }, weight = 0.003, canStack = 40, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney5", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.882, 0.741, 0.796} }, weight = 0.003, canStack = 40, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney10", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.882, 0.882, 0.388} }, weight = 0.003, canStack = 40, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney20", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.510, 0.769, 0.678} }, weight = 0.003, canStack = 50, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney50", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.498, 0.749, 0.784} }, weight = 0.003, canStack = 30, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney100", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.827, 0.714, 0.357} }, weight = 0.003, canStack = 20, moveSound = "cardFlip" })

gamePieceAndBoardHandler.registerSpecial("Base.MonopolyMoney500", {
    alternateStackRendering = {func="DrawTextureCardFace", rgb = {0.847, 0.627, 0.098} }, weight = 0.003, canStack = 20, moveSound = "cardFlip" })
