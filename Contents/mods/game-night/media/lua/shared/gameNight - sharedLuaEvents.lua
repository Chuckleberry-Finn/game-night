local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
Events.OnLoad.Add(gamePieceAndBoardHandler.applyScriptChanges)
if isServer() then Events.OnGameBoot.Add(gamePieceAndBoardHandler.applyScriptChanges) end