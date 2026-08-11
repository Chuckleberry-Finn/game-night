local gamePieceHandler = require("gameNight-gamePieceHandler.lua")

if isServer() then
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

        elseif _command == "syncPieceState" then
            sendServerCommand(_module, _command, _data)
        end
    end
    Events.OnClientCommand.Add(onClientCommand)
end

if isClient() then
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

        elseif _command == "syncPieceState" then
            local squareCoords = _data.square
            local square = squareCoords and getCell():getGridSquare(squareCoords.x, squareCoords.y, squareCoords.z)
            local gamePiece = square and gamePieceHandler.findGamePieceOnSquareByItemID(square, _data.itemID)
            if gamePiece then
                gamePieceHandler.applyNetworkSyncedGamePieceState(gamePiece, _data)
            end
        end
    end
    Events.OnServerCommand.Add(onServerCommand)
end
