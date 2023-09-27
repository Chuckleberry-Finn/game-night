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
            local item = _data.item
            ---@type IsoWorldInventoryObject|IsoObject
            local itemWorldItem = item and item:getWorldItem()
            if itemWorldItem then
                itemWorldItem:getModData().gameNightInUse = true
            end
        end
    end
    Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
end