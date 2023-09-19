local gameNightDistro = require "gameNight - Distributions"
Events.OnGameBoot.Add(gameNightDistro.addToSuburbsDist())
Events.OnGameBoot.Add(gameNightDistro.overrideProceduralDist())
Events.OnGameBoot.Add(gameNightDistro.fillProceduralDist())

local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
Events.OnLoad.Add(gamePieceAndBoardHandler.applyScriptChanges)
if isServer() then Events.OnGameBoot.Add(gamePieceAndBoardHandler.applyScriptChanges) end