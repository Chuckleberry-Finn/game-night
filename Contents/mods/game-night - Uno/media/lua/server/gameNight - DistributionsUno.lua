require "Items/SuburbsDistributions"

local gameNightBoxes = {
    UnoBox = { rolls = 1,
        items = {
            "UnoCards", 9999,
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
    table.insert(ProceduralDistributions.list[distID].items, "UnoBox")
    table.insert(ProceduralDistributions.list[distID].items, chance)
end