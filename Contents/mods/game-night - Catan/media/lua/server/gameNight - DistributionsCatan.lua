require "Items/SuburbsDistributions"

local gameNightBoxes = {
    CatanBox = { rolls = 1,
        items = {
            "CatanLargestArmy", 100,
            "CatanLongestRoad", 100,
            "PlayerCostsBlue", 100,
            "PlayerCostsOrange", 100,
            "PlayerCostsRed", 100,
            "PlayerCostsWhite", 100,
            "CatanRobber", 100,
            "CatanDevelopmentDeck", 100,
            "CatanResourceDeck", 100,
            "CatanBoard", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },
}

for _,box in pairs(gameNightBoxes) do table.insert(SuburbsDistributions, box) end