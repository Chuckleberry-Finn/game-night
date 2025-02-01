require "Items/SuburbsDistributions"

local gameNightDistro = {}

gameNightDistro.gameNightBoxes = {

    CheckersBox = {
        GamePieceRed = 12,
        GamePieceBlack = 12,
        CheckerBoard = 1,
    },

    ChessBox = {
        ChessWhiteKing = 1, ChessWhiteQueen = 1,
        ChessWhiteBishop = 1, ChessWhiteBishop = 1,
        ChessWhiteKnight = 1, ChessWhiteKnight = 1,
        ChessWhiteRook = 1, ChessWhiteRook = 1,

        ChessBlackKing = 1, ChessBlackQueen = 1,
        ChessBlackBishop = 1, ChessBlackBishop = 1,
        ChessBlackKnight = 1, ChessBlackKnight = 1,
        ChessBlackRook = 1, ChessBlackRook = 1,

        ChessWhite = 8, ChessBlack = 8,

        ChessBoard = 1,
    },

    BackgammonBox = {
            DiceWhite = 2,
            GamePieceBlackBackgammon = 15,
            GamePieceWhite = 15,
            BackgammonBoard = 1,
    },

    PokerBox = {
            PokerChips = 1, PokerChipsBlue = 1,
            PokerChipsYellow = 1, PokerChipsWhite = 1,
            PokerChipsBlack = 1, PokerChipsOrange = 1,
            PokerChipsPurple = 1, PokerChipsGreen = 1,

            CardDeck = 2,
            Dice = 2,
    },

}

gameNightDistro.emptyLoot =  { rolls = 1, items = {} }
function gameNightDistro.addToDistributions() for contID,content in pairs(gameNightDistro.gameNightBoxes) do SuburbsDistributions[contID] = gameNightDistro.emptyLoot end end


require "Items/ProceduralDistributions"

gameNightDistro.proceduralDistOverWrite = {}
gameNightDistro.proceduralDistOverWrite.lists = {
    "BarCounterMisc",
    "BookstoreHobbies",
    "CrateRandomJunk",
    "CrateToys",
    "Gifts",
    "GiftStoreToys",
    "GigamartToys",
    "HolidayStuff",
    "Hobbies",
    "LivingRoomWardrobe",
    "OfficeDeskHome",
    "OfficeDesk",
    "PoliceDesk",
    "RecRoomShelf",
    "WardrobeChild",
}

gameNightDistro.proceduralDistOverWrite.itemToReplacement = {
    ["BackgammonBoard"] = "BackgammonBox",
    ["GamePieceWhite"] = "BackgammonBox",

    ["ChessWhite"] = "ChessBox",
    ["ChessBlack"] = "ChessBox",

    ["GamePieceRed"] = "CheckersBox",
    ["GamePieceBlack"] = "CheckersBox",
    ["CheckerBoard"] = "CheckersBox",

    ["PokerChips"] = "PokerBox",

    ["CardDeck"] = {"CardDeck","PlayingCards1","PlayingCards2","PlayingCards3"}
}


function gameNightDistro.overrideProceduralDist()
    for _,contID in pairs(gameNightDistro.proceduralDistOverWrite.lists) do
        for i=1, #ProceduralDistributions.list[contID].items, 2 do
            local itemType = ProceduralDistributions.list[contID].items[i]
            local replacement = gameNightDistro.proceduralDistOverWrite.itemToReplacement[itemType]
            if replacement then

                local chance = ProceduralDistributions.list[contID].items[i+1] * (SandboxVars.GameNight.LootMultiplier)

                if type(replacement)=="table" then

                    chance = chance/#replacement

                    ProceduralDistributions.list[contID].items[i] = replacement[1]
                    ProceduralDistributions.list[contID].items[i+1] = chance
                    for ii=2, #replacement do
                        table.insert(ProceduralDistributions.list[contID].items, replacement[ii])
                        table.insert(ProceduralDistributions.list[contID].items, chance)
                    end
                else
                    ProceduralDistributions.list[contID].items[i] = replacement
                    ProceduralDistributions.list[contID].items[i+1] = chance
                end
            end
        end
    end
end



gameNightDistro.proceduralDistGameNight = {}
gameNightDistro.proceduralDistGameNight.itemsToAdd = {
    ["BackgammonBox"] = {},
    ["ChessBox"] = {},
    ["CheckersBox"] = {},
    ["PokerBox"] = {}, }

gameNightDistro.proceduralDistGameNight.listsToInsert = {

    ["ClassroomDesk"] = { generalChance = 0.05, },
    ["BedroomDresser"] = { generalChance = 0.2, },
    ["ClassroomMisc"] = { generalChance = 0.1, },
    ["SchoolLockers"] = { generalChance = 0.075, },
    ["SchoolLockersBad"] = { generalChance = 0.035, },
    ["OfficeDeskHome"] = { generalChance = 0.025, },
    ["LivingRoomShelf"] = { generalChance = 0.025, },
    ["LivingRoomShelfClassy"] = { generalChance = 0.035, },
    ["LivingRoomWardrobe"] = { generalChance = 0.025, },
    ["RecRoomShelf"] = { generalChance = 0.055, },
    ["BarCounterMisc"] = { generalChance = 6, },
    ["Hobbies"] = { generalChance = 8, },

    ["Gifts"] = { generalChance = 8, },
    ["BookstoreHobbies"] = { generalChance = 8, },
    ["GigamartToys"] = { generalChance = 8, },
    ["GiftStoreToys"] = { generalChance = 8, },
    ["HolidayStuff"] = { generalChance = 8, },
    ["CrateToys"] = { generalChance = 6, },

    ---these are already in the distro so no need to double them up
    ["WardrobeChild"] = { generalChance = 2, chanceOverride = {["BackgammonBox"] = 0, ["ChessBox"] = 0, ["CheckersBox"] = 0, ["PokerBox"] = 0,} },
    ["CrateRandomJunk"] = { generalChance = 1, chanceOverride = {["BackgammonBox"] = 0, ["ChessBox"] = 0, ["CheckersBox"] = 0, ["PokerBox"] = 0,} },
}


function gameNightDistro.fillProceduralDist()
    local gNDpDGN = gameNightDistro.proceduralDistGameNight
    for distID,distData in pairs(gNDpDGN.listsToInsert) do

        if ProceduralDistributions.list[distID] then
            for item,itemData in pairs(gNDpDGN.itemsToAdd) do
                local gnRoll = itemData.rolls or 1

                local distChance = (distData.chanceOverride and distData.chanceOverride[item]) or distData.generalChance
                local itemChance = (itemData.chanceFactor or 1) * (itemData.perDistFactor and itemData.perDistFactor[distID] or 1)

                local chance = distChance * itemChance * (SandboxVars.GameNight.LootMultiplier)
                if chance > 0 then
                    for i=1, gnRoll do
                        table.insert(ProceduralDistributions.list[distID].items, item)
                        table.insert(ProceduralDistributions.list[distID].items, chance)
                    end
                end
            end
        else
            print("ERROR: gameNightDistro.fillProceduralDist: ProceduralDistributions.list.", distID, " not found")
        end
    end
end


return gameNightDistro