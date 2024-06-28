local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "gameNightAction" then return end
    if _command == "pickupAndPlaceGamePiece" then
        --local moveID = _data.moveID

        local item = _data.item
        local blockUse = (not gamePieceAndBoardHandler.itemIsBusy(item))

        print(" ~ receiving request - processing response")

        sendServerCommand(_player, _module, _command, {item=item, allowed=blockUse})
    end
end
Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client


local function onServerCommand(_module, _command, _data)
    if _module ~= "gameNightAction" then return end
    if _command == "pickupAndPlaceGamePiece" then
        --local moveID = _data.moveID
        local item = _data.item
        local allowed = _data.allowed
        print(" ~~ received response! move buffer buffering!")

        gamePieceAndBoardHandler.processMoveFromBuffer(getPlayer(), item, allowed)
    end
end
Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
