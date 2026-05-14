local gamePieceHandler = require("gameNight-gamePieceHandler.lua")

---@param _player IsoGameCharacter|IsoPlayer
local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "gameNightAction" then return end

    if _command == "pickupAndPlaceGamePiece" then
        local itemID = _data.itemID
        local coolDown = gamePieceHandler.coolDownArray[itemID]
        local allowed = (not coolDown) or coolDown < GameTime.getServerTimeMills()

        local newCoolDown
        if allowed then
            newCoolDown = GameTime.getServerTimeMills() + gamePieceHandler.coolDown
            gamePieceHandler.coolDownArray[itemID] = newCoolDown
        end

        sendServerCommand(_module, _command, {
            username = _player:getUsername(),
            itemID = itemID,
            allowed = allowed,
            newCoolDown = newCoolDown,
        })
    end
end
Events.OnClientCommand.Add(onClientCommand)

local function onServerCommand(_module, _command, _data)
    if _module ~= "gameNightAction" then return end

    if _command == "pickupAndPlaceGamePiece" then
        local itemID = _data.itemID
        local allowed = _data.allowed
        local newCoolDown = _data.newCoolDown
        local username = _data.username

        if username and username == getPlayer():getUsername() then
            gamePieceHandler.processMoveFromBuffer(getPlayer(), itemID, allowed, newCoolDown)
        else
            gamePieceHandler.coolDownArray[itemID] = newCoolDown
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)
