local cursorHandler = {}

cursorHandler.mpColorCodes = {}

---@param player IsoPlayer|IsoGameCharacter
function cursorHandler.sendUpdate(player)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then
        Events.OnPlayerUpdate.Remove(cursorHandler.sendUpdate)
        return
    end

    local x, y = window:getMouseX(), window:getMouseY()
    local outOfBounds = ((x < window.bounds.x1) or (y < window.bounds.y1) or (x > window.bounds.x2) or (y > window.bounds.y2))
    if outOfBounds then return end
    
    local sq = window.square
    if not sq then return end
    local dataSqXYZ = sq:getX().."_"..sq:getY().."_"..sq:getZ()
    local mouseXY = x.."_"..y

    if not cursorHandler.mpColorCodes[player] then
        local mpTextColor = getCore():getMpTextColor()
        cursorHandler.mpColorCodes[player] = mpTextColor:getR().."_"..mpTextColor:getG().."_"..mpTextColor:getB()
    end

    local dataToSend = dataSqXYZ.."_"..player:getUsername().."_"..mouseXY.."_"..cursorHandler.mpColorCodes[player]
    sendClientCommand(player, "gameNightCursor", "update", {dataToSend})
end

function cursorHandler.receiveUpdate(data)--sqX, sqY, sqZ, playerUsername, mouseX, mouseY, r, g, b, pieceTexture)
    ---@type gameNightWindow
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    local dataPoints = {}
    for str in string.gmatch(data, "([^".."_".."]+)") do table.insert(dataPoints, str) end

    local playerUsername = dataPoints[4]
    if playerUsername == window.player:getUsername() then return end

    local sqX, sqY, sqZ = tonumber(dataPoints[1]), tonumber(dataPoints[2]), tonumber(dataPoints[3])

    if (window.square:getX() ~= sqX) or (window.square:getY() ~= sqY) or (window.square:getZ() ~= sqZ) then return end

    local mouseX, mouseY = tonumber(dataPoints[5]), tonumber(dataPoints[6])
    local r, g, b = tonumber(dataPoints[7]), tonumber(dataPoints[8]), tonumber(dataPoints[9])

    window.cursorDraws[playerUsername] = {x=mouseX, y=mouseY, r=r, g=g, b=b, ticks=11}
end

return cursorHandler