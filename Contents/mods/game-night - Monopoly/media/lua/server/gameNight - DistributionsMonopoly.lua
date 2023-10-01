require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

table.insert(gameNightDistro.proceduralDistGameNight.itemsToAdd,"MonopolyBox")

gameNightDistro.gameNightBoxes["MonopolyBox"] = {
    rolls = 1,
    items = {
        "Dice", 9999, "Dice", 9999,
        "MonopolyBoard", 9999, "MonopolyDeed", 9999,
    },
    junk = { rolls = 1, items = {} }, fillRand = 0,
}
