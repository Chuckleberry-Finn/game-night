local applyItemDetails = require "gameNight - applyItemDetails"
Events.OnRefreshInventoryWindowContainers.Add(applyItemDetails.applyToInventory)
Events.OnFillContainer.Add(applyItemDetails.applyToFillContainer)