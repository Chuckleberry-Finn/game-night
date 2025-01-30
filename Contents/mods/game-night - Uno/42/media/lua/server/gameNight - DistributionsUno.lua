require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

gameNightDistro.proceduralDistGameNight.itemsToAdd["UnoBox"] = {}

gameNightDistro.gameNightBoxes["UnoBox"] = {
    rolls = 1,
    items = {
        "UnoCards", 9999,
    },
    junk = { rolls = 1, items = {} }, fillRand = 0,
}

