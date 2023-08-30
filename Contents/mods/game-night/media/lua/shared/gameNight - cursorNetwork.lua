if isServer() then
    local function onClientCommand(_module, _command, _player, _data)
        if _module ~= "gameNightCursor" then return end
        if _command == "update" then sendServerCommand(_module, _command, _data) end
    end
    Events.OnClientCommand.Add(onClientCommand)--what the server gets from the client
end

if isClient() then
    local cursorHandler = require "gameNight - cursorHandler"
    local function onServerCommand(_module, _command, _data)
        if _module ~= "gameNightCursor" then return end
        if _command == "update" then cursorHandler.receiveUpdate(_data[1]) end
    end
    Events.OnServerCommand.Add(onServerCommand)--what clients gets from the server
end