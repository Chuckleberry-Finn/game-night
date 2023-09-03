--- For anyone looking to make a sub-mod:
--TERMS: CARDS AND GAME PIECES/BOARDS

---First require this file so that the cataloger module can be called on.
local applyItemDetails = require "gameNight - applyItemDetails"

--- Examples of defining a table
-- this example is overly complicated as it pieces together a table for the sake of typing up a large list
-- technically you just need a table of strings corresponding to textures/names for items


--- CATAN RESOURCES
local CatanResourceDeck = {}
CatanResourceDeck.types = {"Brick","Stone","Wood","Wheat","Sheep"}
CatanResourceDeck.cards = {}
for _,s in pairs(CatanResourceDeck.types) do for i=1, 19 do table.insert(CatanResourceDeck.cards, s) end end
applyItemDetails.addDeck("CatanResourceDeck", CatanResourceDeck.cards)


--- CATAN DEVELOPMENTS
local CatanDevelopmentDeck = {}
--Fourteen (14) Knight Cards.
--Six (6) Progress Cards (2 x Monopoly, 2 x Road Building, 2 x Year of Plenty).
CatanDevelopmentDeck.types = {"Knight","Monopoly","Road Building","Year of Plenty"}
CatanDevelopmentDeck.count = {14,2,2,2}
--Five (5) Victory Point Cards (Chapel, Library, Market, Palace, University).
CatanDevelopmentDeck.cards = {"Chapel", "Library", "Market", "Palace", "University"}

for i,s in pairs(CatanDevelopmentDeck.types) do
    for ii=1, i do
        table.insert(CatanDevelopmentDeck.cards, s)
    end
end
applyItemDetails.addDeck("CatanDevelopmentDeck", CatanDevelopmentDeck.cards)



---Identify game pieces by type
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

gamePieceAndBoardHandler.addTypes({ "Base.CatanRobber", "Base.LongestRoad", "Base.LargestArmy", "Base.CatanBoard",
                                    "Base.PlayerCostsWhite", "Base.PlayerCostsRed", "Base.PlayerCostsOrange", "Base.PlayerCostsBlue"})
---Add special cases
gamePieceAndBoardHandler.addSpecial("Base.CatanBoard", { category = "GameBoard" })
