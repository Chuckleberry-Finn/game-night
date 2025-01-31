require "Items/SuburbsDistributions"

local gameNightDistro = require "gameNight - Distributions"

gameNightDistro.proceduralDistGameNight.itemsToAdd["MonopolyBox"] = {}

gameNightDistro.gameNightBoxes.MonopolyBox = {

    Dice = 2, MonopolyBoard = 1, MonopolyDeed = 1,
    MonopolyChance = 1, MonopolyCommunityChest = 1,
    MonopolyBoat = 1, MonopolyBoot = 1, MonopolyCar = 1, MonopolyDog = 1,
    MonopolyHat = 1, MonopolyIron = 1, MonopolyThimble = 1, MonopolyWheelbarrow = 1,

    MonopolyHotel = 12,
    MonopolyHouse = 32,

    MonopolyMoney1 = 1, MonopolyMoney5 = 1, MonopolyMoney10 = 1, MonopolyMoney20 = 1,
    MonopolyMoney50 = 1, MonopolyMoney100 = 1, MonopolyMoney500 = 1,
}
