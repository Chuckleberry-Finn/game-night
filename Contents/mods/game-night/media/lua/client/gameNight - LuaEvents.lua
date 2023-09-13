local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
Events.OnGameBoot.Add(gamePieceAndBoardHandler.applyScriptChanges)

local applyItemDetails = require "gameNight - applyItemDetails"
Events.OnRefreshInventoryWindowContainers.Add(applyItemDetails.applyToInventory)
Events.OnFillContainer.Add(applyItemDetails.applyToFillContainer)