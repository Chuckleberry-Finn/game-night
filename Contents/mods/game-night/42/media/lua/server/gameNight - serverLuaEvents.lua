local gameNightDistro = require "gameNight - Distributions"
print("TESTING GAME NIGHT DIST CHANGES")
Events.OnDistributionMerge.Add(gameNightDistro.addToSuburbsDist())
Events.OnPostDistributionMerge.Add(gameNightDistro.overrideProceduralDist())
Events.OnPostDistributionMerge.Add(gameNightDistro.fillProceduralDist())