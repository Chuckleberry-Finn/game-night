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
--Advance to "Go". (Collect $200)
--Advance to Illinois Ave. If you pass Go, collect $200.
--Advance to St. Charles Place. If you pass Go, collect $200.
--Advance to the nearest Utility. If unowned, you may buy it from the Bank. If owned, throw dice and pay owner a total 10 (ten) times the amount thrown.
--Advance to the nearest Railroad. If unowned, you may buy it from the Bank. If owned, pay owner twice the rent to which they are otherwise entitled.
--Bank pays you dividend of $50.
--Get out of Jail Free. This card may be kept until needed, or traded/sold.
--Go Back Three Spaces.
--Go directly to Jail. Do not pass GO, do not collect $200.
--Make general repairs on all your property: For each house pay $25, For each hotel pay $100.
--Take a trip to Reading Railroad. If you pass Go, collect $200.
--Pay Poor Tax of $15
--Take a walk on the Boardwalk. Advance to Boardwalk.
--You have been elected Chairman of the Board. Pay each player $50.
--Your building loan matures. Collect $150 from the bank.
local MonopolyChanceDeck = {}
MonopolyChanceDeck.cards = {}
applyItemDetails.addDeck("MonopolyDeedDeck", MonopolyChanceDeck.cards)

---Community Chest
--Advance to "Go". Collect $200.
--Bank error in your favor. Collect $200.
--Doctor's fees. {fee} Pay $50.
--From sale of stock you get $50. {$45.}
--Get Out of Jail Free. {Get out of Jail, Free. in previous US editions} – This card may be kept until needed or sold/traded.
--Go to Jail. Go directly to jail. Do not pass Go, Do not collect $200.
--Grand Opera Opening Night. Collect $50 from every player for opening night seats.
--Christmas Fund Matures. Collect $100.
--Income tax refund. Collect $20.
--It's your birthday. Collect $10 from every player.
--Life insurance matures – Collect $100
--Hospital Fees. Pay $50. {Pay hospital fees of $100.} {Pay hospital $100.}
--School fees. Pay $50. {Pay school fees {tax} of $150}
--Receive $25 consultancy fee. {Receive for services $25.}
--You are assessed for street repairs: Pay $40 per house and $115 per hotel you own.
--You have won second prize in a beauty contest. Collect $10.
--You inherit $100.
local MonopolyCommunityChestDeck = {}
MonopolyCommunityChestDeck.cards = {}
applyItemDetails.addDeck("MonopolyDeedDeck", MonopolyCommunityChestDeck.cards)



local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
gamePieceAndBoardHandler.registerTypes({
    "Base.MonopolyBoard", "Base.MonopolyBoat", "Base.MonopolyBoot", "Base.MonopolyCar", "Base.MonopolyDog",
    "Base.MonopolyHat", "Base.MonopolyIron", "Base.MonopolyThimble", "Base.MonopolyWheelbarrow"
})

