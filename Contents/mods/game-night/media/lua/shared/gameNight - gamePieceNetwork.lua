local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

if isServer() then
    local function onClientCommand(_module, _command, _player, _data)
        if _module ~= "gameNightGamePiece" then return end
        if _command == "updateGamePiece" then sendServerCommand(_module, _command, _data) end
    end
    Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client
end

if isClient() then
    local function onServerCommand(_module, _command, _data)
        if _module ~= "gameNightGamePiece" then return end
        if _command == "updateGamePiece" then
            ---@type ComboItem|InventoryItem

            print("PIECE HERE: ",_data.username)

            local item, username = _data.item, _data.username
            item:getModData().gameNightInUse = username
        end
    end
    Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
end