require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

gameNightDistro.proceduralDistGameNight.itemsToAdd["MonopolyBox"] = {}

gameNightDistro.gameNightBoxes["MonopolyBox"] = {
    rolls = 1,
    items = {
        "Dice", 9999, "Dice", 9999, "MonopolyBoard", 9999, "MonopolyDeed", 9999,
        "MonopolyChance", 9999, "MonopolyCommunityChest", 9999,
        "MonopolyBoat", 9999, "MonopolyBoot", 9999, "MonopolyCar", 9999, "MonopolyDog", 9999,
        "MonopolyHat", 9999, "MonopolyIron", 9999, "MonopolyThimble", 9999, "MonopolyWheelbarrow", 9999,

        "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999,
        "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999,
        "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999, "MonopolyHotel", 9999,

        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,
        "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999, "MonopolyHouse", 9999,

        "MonopolyMoney1", 9999, "MonopolyMoney5", 9999, "MonopolyMoney10", 9999, "MonopolyMoney20", 9999,
        "MonopolyMoney50", 9999, "MonopolyMoney100", 9999, "MonopolyMoney500", 9999,
    },
    junk = { rolls = 1, items = {} }, fillRand = 0,
}
