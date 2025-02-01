local gameNightDistro = require("gameNight - Distributions")

Events.OnPreDistributionMerge.Add(gameNightDistro.addToDistributions)
Events.OnPostDistributionMerge.Add(gameNightDistro.overrideProceduralDist)
Events.OnPostDistributionMerge.Add(gameNightDistro.fillProceduralDist)