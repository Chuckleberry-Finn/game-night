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