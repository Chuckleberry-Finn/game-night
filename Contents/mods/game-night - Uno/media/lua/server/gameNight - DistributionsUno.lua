require "Items/SuburbsDistributions"

local gameNightBoxes = {
    UnoBox = { rolls = 1,
        items = {
            "UnoCards", 100,
        },
        junk = { rolls = 1, items = {} }, fillRand = 0,
    },
}

for _,box in pairs(gameNightBoxes) do table.insert(SuburbsDistributions, box) end