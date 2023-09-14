require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

table.insert(gameNightDistro.proceduralDistGameNight.itemsToAdd,"CatanBox")

gameNightDistro.gameNightBoxes["CatanBox"] = {
    rolls = 1,
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
}
