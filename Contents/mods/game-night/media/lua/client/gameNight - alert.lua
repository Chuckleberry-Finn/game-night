if getActivatedMods():contains("ChuckleberryFinnAlertSystem") then
    local modCountSystem = require "chuckleberryFinnModding_modCountSystem"
    if modCountSystem then modCountSystem.pullAndAddModID() end
else print("WARNING: Highly recommended to install `ChuckleberryFinnAlertSystem` (Workshop ID: `3077900375`) for latest news and updates.") end

local alertSystem = require "chuckleberryFinnModdingAlertSystem"
if alertSystem then
    alertSystem.addTexture("media/textures/donate/1.png")
    alertSystem.addTexture("media/textures/donate/2.png")
    --alertSystem:receiveAlert("Brand new scaling feature! Play-Game UI can now scale to 1x, 1.5x, and 2x.")
end