local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

gamePieceAndBoardHandler.coolDownArray = {}

local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "gameNightAction" then return end

    if _command == "setCoolDown" then
        local item = _data.item
        gamePieceAndBoardHandler.coolDownArray[item] = getTimestampMs()+gamePieceAndBoardHandler.coolDown
    end

    if _command == "pickupAndPlaceGamePiece" then
        --local moveID = _data.moveID

        local item = _data.item
        local coolDown = gamePieceAndBoardHandler.coolDownArray[item]
        local allowed = (not coolDown) or coolDown<getTimestampMs()

        print(" ~ receiving request - processing response")

        if allowed then gamePieceAndBoardHandler.coolDownArray[item] = getTimestampMs()+gamePieceAndBoardHandler.coolDown end

        sendServerCommand(_player, _module, _command, {item=item, allowed=allowed, coolDown=gamePieceAndBoardHandler.coolDownArray[item]})
    end
end
Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client


local function onServerCommand(_module, _command, _data)
    if _module ~= "gameNightAction" then return end
    if _command == "pickupAndPlaceGamePiece" then
        --local moveID = _data.moveID
        local item = _data.item
        local allowed = _data.allowed
        local coolDown = _data.coolDown
        print(" ~~ received response! move buffer buffering!")

        gamePieceAndBoardHandler.processMoveFromBuffer(getPlayer(), item, allowed, coolDown)
    end
end
Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
