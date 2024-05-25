require "Items/SuburbsDistributions"

local gameNightDistro = {}

gameNightDistro.gameNightBoxes = {

    CheckersBox = { rolls = 1,
        items = {
            "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999,
            "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999,
            "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999, "GamePieceRed", 9999,
            "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999,
            "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999,
            "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999, "GamePieceBlack", 9999,
            "CheckerBoard", 9999,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    ChessBox = { rolls = 1,
        items = {
            "ChessWhiteKing", 9999, "ChessWhiteQueen", 9999,
            "ChessWhiteBishop", 9999, "ChessWhiteBishop", 9999,
            "ChessWhiteKnight", 9999, "ChessWhiteKnight", 9999,
            "ChessWhiteRook", 9999, "ChessWhiteRook", 9999,

            "ChessBlackKing", 9999, "ChessBlackQueen", 9999,
            "ChessBlackBishop", 9999, "ChessBlackBishop", 9999,
            "ChessBlackKnight", 9999, "ChessBlackKnight", 9999,
            "ChessBlackRook", 9999, "ChessBlackRook", 9999,

            "ChessWhite", 9999, "ChessWhite", 9999, "ChessWhite", 9999, "ChessWhite", 9999,
            "ChessWhite", 9999, "ChessWhite", 9999, "ChessWhite", 9999, "ChessWhite", 9999,

            "ChessBlack", 9999, "ChessBlack", 9999, "ChessBlack", 9999, "ChessBlack", 9999,
            "ChessBlack", 9999, "ChessBlack", 9999, "ChessBlack", 9999, "ChessBlack", 9999,

            "ChessBoard", 9999,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    BackgammonBox = { rolls = 1,
        items = {
            "DiceWhite", 9999,
            "DiceWhite", 9999,
            "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999,
            "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999,
            "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999,
            "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999,
            "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999, "GamePieceBlackBackgammon", 9999,
            "GamePieceWhite", 9999, "GamePieceWhite", 9999, "GamePieceWhite", 9999,
            "GamePieceWhite", 9999, "GamePieceWhite", 9999, "GamePieceWhite", 9999,
            "GamePieceWhite", 9999, "GamePieceWhite", 9999, "GamePieceWhite", 9999,
            "GamePieceWhite", 9999, "GamePieceWhite", 9999, "GamePieceWhite", 9999,
            "GamePieceWhite", 9999, "GamePieceWhite", 9999, "GamePieceWhite", 9999,
            "BackgammonBoard", 9999,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

    PokerBox = { rolls = 1,
        items = {

            "PokerChips", 9999, "PokerChipsBlue", 9999,
            "PokerChipsYellow", 9999, "PokerChipsWhite", 9999,
            "PokerChipsBlack", 9999, "PokerChipsOrange", 9999,
            "PokerChipsPurple", 9999, "PokerChipsGreen", 9999,

            "CardDeck", 9999, "CardDeck", 9999,
            "Dice", 9999, "Dice", 9999,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },

}

function gameNightDistro.addToSuburbsDist()
    for contID,content in pairs(gameNightDistro.gameNightBoxes) do SuburbsDistributions[contID] = content end
end



require "Items/ProceduralDistributions"

gameNightDistro.proceduralDistOverWrite = {}
gameNightDistro.proceduralDistOverWrite.lists = {"WardrobeChild", "CrateRandomJunk",

                                                 "CrateToys","BarCounterMisc","PoliceDesk","OfficeDeskHome",
                                                 "OfficeDesk","HolidayStuff","Hobbies","GigamartToys","Gifts"}

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

                if type(replacement)=="table" then
                    local chance = ProceduralDistributions.list[contID].items[i+1]
                    chance = chance/#replacement

                    ProceduralDistributions.list[contID].items[i] = replacement[1]
                    ProceduralDistributions.list[contID].items[i+1] = chance
                    for ii=2, #replacement do
                        table.insert(ProceduralDistributions.list[contID].items, replacement[ii])
                        table.insert(ProceduralDistributions.list[contID].items, chance)
                    end
                else
                    ProceduralDistributions.list[contID].items[i] = replacement
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
    ["OfficeDeskHome"] = { generalChance = 0.025, },

    ["BarCounterMisc"] = { generalChance = 6, },
    ["Gifts"] = { generalChance = 8, sealed = true },
    ["GigamartToys"] = { generalChance = 8, sealed = true },
    ["Hobbies"] = { generalChance = 8, },
    ["HolidayStuff"] = { generalChance = 8, sealed = true },

    ---these are already in the distro so no need to double them up
    ["WardrobeChild"] = { generalChance = 2, chanceOverride = {["BackgammonBox"] = 0, ["ChessBox"] = 0, ["CheckersBox"] = 0, ["PokerBox"] = 0,} },
    ["CrateRandomJunk"] = { generalChance = 1, chanceOverride = {["BackgammonBox"] = 0, ["ChessBox"] = 0, ["CheckersBox"] = 0, ["PokerBox"] = 0,} },
}


function gameNightDistro.fillProceduralDist()
    local gNDpDGN = gameNightDistro.proceduralDistGameNight
    for distID,distData in pairs(gNDpDGN.listsToInsert) do
        for item,itemData in pairs(gNDpDGN.itemsToAdd) do
            local gnRoll = itemData.rolls or 1

            local sealed = gNDpDGN.listsToInsert[distID].sealed and getScriptManager():getItem("Base."..item.."_sealed") and "_sealed" or ""

            local distChance = (distData.chanceOverride and distData.chanceOverride[item]) or distData.generalChance
            local itemChance = (itemData.chanceFactor or 1) * (itemData.perDistFactor and itemData.perDistFactor[distID] or 1)

            local chance = distChance * itemChance
            if chance > 0 then
                for i=1, gnRoll do
                    table.insert(ProceduralDistributions.list[distID].items, item..sealed)
                    table.insert(ProceduralDistributions.list[distID].items, chance)
                end
            end
        end
    end
end


return gameNightDistro