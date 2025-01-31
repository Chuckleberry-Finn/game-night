require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

gameNightDistro.proceduralDistGameNight.itemsToAdd["CatanBox"] = {}

gameNightDistro.gameNightBoxes.CatanBox = {

    CatanLargestArmy = 1,
    CatanLongestRoad = 1,
    CatanRobber = 1,
    CatanDevelopmentDeck = 1,
    CatanResourceDeck = 1,
    CatanBoard = 1,

    Dice = 2,

    CatanPlayerCostsBlue = 1, CatanSettlementBlue = 5, CatanCityBlue = 4, CatanRoadBlue = 15,
    CatanPlayerCostsWhite = 1, CatanSettlementWhite = 5, CatanCityWhite = 4, CatanRoadWhite = 15,
    CatanPlayerCostsRed = 1, CatanSettlementRed = 5, CatanCityRed = 4, CatanRoadRed = 15,
    CatanPlayerCostsOrange = 1, CatanSettlementOrange = 5, CatanCityOrange = 4, CatanRoadOrange = 15,
}
