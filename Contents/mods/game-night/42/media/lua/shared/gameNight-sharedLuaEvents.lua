local gamePieceHandler = require("gameNight-gamePieceHandler.lua")
Events.OnLoad.Add(gamePieceHandler.applyScriptChanges)
if isServer() then Events.OnGameBoot.Add(gamePieceHandler.applyScriptChanges) end