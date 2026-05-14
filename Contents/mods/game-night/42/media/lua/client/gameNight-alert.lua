if getActivatedMods():contains("ChuckleberryFinnAlertSystem") then
    local alertSystem = require "chuckleberryFinnModdingAlertSystem"
    if alertSystem then
        alertSystem.addTexture("media/textures/donate/1.png")
        alertSystem.addTexture("media/textures/donate/2.png")
    end
end