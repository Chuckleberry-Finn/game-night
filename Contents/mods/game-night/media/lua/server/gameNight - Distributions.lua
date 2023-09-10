require "Items/SuburbsDistributions"

local gameNightBoxes = {

    CheckersBox = { rolls = 1,
        items = {
            "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100,
            "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100,
            "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100, "GamePieceRed", 100,
            "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100,
            "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100,
            "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100, "GamePieceBlack", 100,
            "CheckerBoard", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    ChessBox = { rolls = 1,
        items = {
            "ChessWhiteKing", 100, "ChessWhiteQueen", 100,
            "ChessWhiteBishop", 100, "ChessWhiteBishop", 100,
            "ChessWhiteKnight", 100, "ChessWhiteKnight", 100,
            "ChessWhiteRook", 100, "ChessWhiteRook", 100,

            "ChessBlackKing", 100, "ChessBlackQueen", 100,
            "ChessBlackBishop", 100, "ChessBlackBishop", 100,
            "ChessBlackKnight", 100, "ChessBlackKnight", 100,
            "ChessBlackRook", 100, "ChessBlackRook", 100,

            "ChessWhite", 100, "ChessWhite", 100, "ChessWhite", 100, "ChessWhite", 100,
            "ChessWhite", 100, "ChessWhite", 100, "ChessWhite", 100, "ChessWhite", 100,

            "ChessBlack", 100, "ChessBlack", 100, "ChessBlack", 100, "ChessBlack", 100,
            "ChessBlack", 100, "ChessBlack", 100, "ChessBlack", 100, "ChessBlack", 100,

            "ChessBoard", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    BackgammonBox = { rolls = 1,
        items = {
            "DiceWhite", 100,
            "DiceWhite", 100,
            "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100,
            "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100,
            "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100,
            "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100,
            "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100, "GamePieceBlackBackgammon", 100,
            "GamePieceWhite", 100, "GamePieceWhite", 100, "GamePieceWhite", 100,
            "GamePieceWhite", 100, "GamePieceWhite", 100, "GamePieceWhite", 100,
            "GamePieceWhite", 100, "GamePieceWhite", 100, "GamePieceWhite", 100,
            "GamePieceWhite", 100, "GamePieceWhite", 100, "GamePieceWhite", 100,
            "GamePieceWhite", 100, "GamePieceWhite", 100, "GamePieceWhite", 100,
            "BackgammonBoard", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    PokerBox = { rolls = 1,
        items = {

            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,
            "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100, "PokerChips", 100,

            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,
            "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100, "PokerChipsBlue", 100,

            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,
            "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100, "PokerChipsYellow", 100,

            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,
            "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100, "PokerChipsWhite", 100,

            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,
            "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100, "PokerChipsBlack", 100,

            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,
            "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100, "PokerChipsOrange", 100,

            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,
            "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100, "PokerChipsPurple", 100,

            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,
            "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100, "PokerChipsGreen", 100,

            "CardDeck", 100, "CardDeck", 100,
            "Dice", 100, "Dice", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },


}

for _,box in pairs(gameNightBoxes) do table.insert(SuburbsDistributions, box) end



require "Items/ProceduralDistributions"

local proceduralDistOverWrite = {}
proceduralDistOverWrite.lists = {"WardrobeChild", "CrateRandomJunk"}
proceduralDistOverWrite.itemToReplacement = {
    ["BackgammonBoard"] = "BackgammonBox",
    ["GamePieceWhite"] = "BackgammonBox",

    ["ChessWhite"] = "ChessBox",
    ["ChessBlack"] = "ChessBox",

    ["GamePieceRed"] = "CheckersBox",
    ["GamePieceBlack"] = "CheckersBox",
    ["CheckerBoard"] = "CheckersBox",

    ["PokerChips"] = "PokerBox",
}

for _,list in pairs(proceduralDistOverWrite.lists) do

    for i=1, #list.items, 2 do
        local itemType = list.items[i]
        local replacement = proceduralDistOverWrite.itemToReplacement[itemType]
        if replacement then
            list.items[i] = replacement
        end
    end
end


local proceduralDistGameNight = {}

proceduralDistGameNight.itemsToAdd = {
    "BackgammonBox",
    "ChessBox",
    "CheckersBox",
    "PokerBox",
}

proceduralDistGameNight.listsToInsert = {
    ["BarCounterMisc"]={
        generalChance = 6,
    },
    ["Gifts"]={
        generalChance = 8,
    },
    ["GigamartToys"]={
        generalChance = 8,
    },
    ["Hobbies"]={
        generalChance = 8,
    },
    ["HolidayStuff"]={
        generalChance = 8,
    },
--[[
    ["WardrobeChild"]={
        generalChance = 2,
    },

    ["CrateRandomJunk"]={
        generalChance = 1,
    },
--]]
}

for distID,distData in pairs(proceduralDistGameNight.listsToInsert) do
    for _,item in pairs(proceduralDistGameNight.itemsToAdd) do
        table.insert(ProceduralDistributions.list[distID].items, item)
        table.insert(ProceduralDistributions.list[distID].items, distData.generalChance)
    end
end
