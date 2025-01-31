local gameNightDistro = require "gameNight - Distributions"

Events.OnDistributionMerge.Add(gameNightDistro.addToSuburbsDist)
Events.OnPostDistributionMerge.Add(gameNightDistro.overrideProceduralDist)
Events.OnPostDistributionMerge.Add(gameNightDistro.fillProceduralDist)