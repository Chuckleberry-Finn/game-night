if getActivatedMods():contains("ChuckleberryFinnAlertSystem") then
    local alertSystem = require "chuckleberryFinnModdingAlertSystem"
    if alertSystem then
        alertSystem.addTexture("media/textures/donate/1.png")
        alertSystem.addTexture("media/textures/donate/2.png")
        --alertSystem:receiveAlert("Brand new scaling feature! Play-Game UI can now scale to 1x, 1.5x, and 2x.")
    end
end