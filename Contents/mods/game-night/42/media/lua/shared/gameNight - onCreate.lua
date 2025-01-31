local gameNightDistro = require("gameNight - Distributions")

function gameNightOnCreateGameBox(gameBox)
    if not gameBox then return end

    local gameBoxType = gameBox:getType()
    local gameBoxContainer = gameBox:getInventory()
    local gameBoxContents = gameNightDistro.gameNightBoxes[gameBoxType]
    if not gameBoxContents then return end

    for item,count in pairs(gameBoxContents) do
        for i=1, count do
            local spawnedItem = ItemPickerJava.tryAddItemToContainer(gameBoxContainer, item, nil)
            if not spawnedItem then return end
        end
    end
end