local alertSystem = require "chuckleberryFinnModdingAlertSystem"
if not alertSystem then return end
alertSystem.addTexture("media/textures/donate/1.png")
alertSystem.addTexture("media/textures/donate/2.png")

local modCountSystem = require "chuckleberryFinnModding_modCountSystem"
if modCountSystem then modCountSystem.pullAndAddModID()
else print("ERROR: MISSING MOD: `ChuckleberryFinnAlertSystem` (Workshop ID: `3077900375`)") end