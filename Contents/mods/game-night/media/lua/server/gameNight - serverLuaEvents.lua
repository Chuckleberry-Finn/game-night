local gameNightDistro = require "gameNight - Distributions"

Events.GameBoot.Add(gameNightDistro.addToSuburbsDist())
Events.GameBoot.Add(gameNightDistro.overrideProceduralDist())
Events.GameBoot.Add(gameNightDistro.fillProceduralDist())