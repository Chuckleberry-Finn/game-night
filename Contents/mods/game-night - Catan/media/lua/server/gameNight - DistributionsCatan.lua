require "Items/SuburbsDistributions"

local gameNightBoxes = {
    CatanBox = { rolls = 1,
        items = {
            "CatanLargestArmy", 9999,
            "CatanLongestRoad", 9999,
            "CatanPlayerCostsBlue", 9999,
            "CatanPlayerCostsOrange", 9999,
            "CatanPlayerCostsRed", 9999,
            "CatanPlayerCostsWhite", 9999,
            "CatanRobber", 9999,
            "CatanDevelopmentDeck", 9999,
            "CatanResourceDeck", 9999,
            "CatanBoard", 9999,

            "Dice", 9999, "Dice", 9999,

            "CatanSettlementBlue", 9999, "CatanSettlementBlue", 9999, "CatanSettlementBlue", 9999, "CatanSettlementBlue", 9999, "CatanSettlementBlue", 9999,
            "CatanCityBlue", 9999, "CatanCityBlue", 9999, "CatanCityBlue", 9999, "CatanCityBlue", 9999,
            "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999,
            "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999,
            "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999, "CatanRoadBlue", 9999,

            "CatanSettlementWhite", 9999, "CatanSettlementWhite", 9999, "CatanSettlementWhite", 9999, "CatanSettlementWhite", 9999, "CatanSettlementWhite", 9999,
            "CatanCityWhite", 9999, "CatanCityWhite", 9999, "CatanCityWhite", 9999, "CatanCityWhite", 9999,
            "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999,
            "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999,
            "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999, "CatanRoadWhite", 9999,

            "CatanSettlementRed", 9999, "CatanSettlementRed", 9999, "CatanSettlementRed", 9999, "CatanSettlementRed", 9999, "CatanSettlementRed", 9999,
            "CatanCityRed", 9999, "CatanCityRed", 9999, "CatanCityRed", 9999, "CatanCityRed", 9999,
            "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999,
            "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999,
            "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999, "CatanRoadRed", 9999,

            "CatanSettlementOrange", 9999, "CatanSettlementOrange", 9999, "CatanSettlementOrange", 9999, "CatanSettlementOrange", 9999, "CatanSettlementOrange", 9999,
            "CatanCityOrange", 9999, "CatanCityOrange", 9999, "CatanCityOrange", 9999, "CatanCityOrange", 9999,
            "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999,
            "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999,
            "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999, "CatanRoadOrange", 9999,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },
}

for contID,content in pairs(gameNightBoxes) do SuburbsDistributions[contID] = content end



require "Items/ProceduralDistributions"

local proceduralDistGameNight = {}

proceduralDistGameNight.listsToInsert = {
    ["BarCounterMisc"]=3,
    ["Gifts"]=4,
    ["GigamartToys"]=4,
    ["Hobbies"]=4,
    ["HolidayStuff"]=4,
    ["WardrobeChild"]=1,
    ["CrateRandomJunk"]=1,
}

for distID,chance in pairs(proceduralDistGameNight.listsToInsert) do
    table.insert(ProceduralDistributions.list[distID].items, "CatanBox")
    table.insert(ProceduralDistributions.list[distID].items, chance)
end