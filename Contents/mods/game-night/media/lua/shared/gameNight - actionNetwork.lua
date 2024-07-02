local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

---@param _player IsoGameCharacter|IsoPlayer
local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "gameNightAction" then return end

    if _command == "setCoolDown" then
        local itemID = _data.itemID
        gamePieceAndBoardHandler.coolDownArray[itemID] = getTimestampMs()+gamePieceAndBoardHandler.coolDown
    end

    if _command == "pickupAndPlaceGamePiece" then

        local itemID = _data.itemID
        local coolDown = gamePieceAndBoardHandler.coolDownArray[itemID]
        local allowed = (not coolDown) or coolDown<getTimestampMs()

        local newCoolDown
        if allowed then
            newCoolDown = getTimestampMs()+gamePieceAndBoardHandler.coolDown
            gamePieceAndBoardHandler.coolDownArray[itemID] = newCoolDown
        end

        local username = _player:getUsername()
        sendServerCommand(_module, _command, {username=username, itemID=itemID, allowed=allowed, newCoolDown=newCoolDown})
    end
end
Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client


local function onServerCommand(_module, _command, _data)
    if _module ~= "gameNightAction" then return end
    if _command == "pickupAndPlaceGamePiece" then

        local itemID = _data.itemID
        local allowed = _data.allowed
        local newCoolDown = _data.newCoolDown
        local username = _data.username

        if username and username == getPlayer():getUsername() then
            gamePieceAndBoardHandler.processMoveFromBuffer(getPlayer(), itemID, allowed, newCoolDown)
        else
            gamePieceAndBoardHandler.coolDownArray[itemID] = newCoolDown
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
