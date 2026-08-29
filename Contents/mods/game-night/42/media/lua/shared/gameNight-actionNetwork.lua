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

            if allowed then
                local item = gamePieceHandler.resolveGamePieceByItemID(_player, itemID, _data.sourceSquare)
                if item then
                    local onPickUp = _data.modKey and {gamePieceHandler.setModDataValue, item, _data.modKey, _data.modValue} or nil
                    local destSquare = _data.destSquare and getCell():getGridSquare(_data.destSquare.x, _data.destSquare.y, _data.destSquare.z)

                    gamePieceHandler.pickupAndPlaceGamePiece(_player, item, onPickUp, nil,
                        _data.xOffset, _data.yOffset, _data.zPos, destSquare, _data.angleChange, true)

                    local finalWorldItem = item:getWorldItem()
                    local finalSquare = destSquare or (finalWorldItem and finalWorldItem:getSquare())
                    if finalSquare then
                        local snapshot = gamePieceHandler.buildNetworkSyncableGamePieceState(item, finalSquare)
                        if snapshot then
                            sendServerCommand(_module, "syncPieceState", snapshot)
                        end
                    end
                end
            end

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
