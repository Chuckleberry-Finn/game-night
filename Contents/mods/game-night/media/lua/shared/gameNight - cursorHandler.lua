local cursorHandler = {}

cursorHandler.mpColorCodes = {}

---@param player IsoPlayer|IsoGameCharacter
function cursorHandler.sendUpdate(player)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then
        Events.OnPlayerUpdate.Remove(cursorHandler.sendUpdate)
        return
    end

    local sq = window.square
    if not sq then return end
    local dataSqXYZ = sq:getX().."_"..sq:getY().."_"..sq:getZ()
    local mouseXY = window:getMouseX().."_"..window:getMouseY()

    if not cursorHandler.mpColorCodes[player] then
        local mpTextColor = getCore():getMpTextColor()
        cursorHandler.mpColorCodes[player] = mpTextColor:getR().."_"..mpTextColor:getG().."_"..mpTextColor:getB()
    end

    local dataToSend = dataSqXYZ.."_"..player:getUsername().."_"..mouseXY.."_"..cursorHandler.mpColorCodes[player]
    sendClientCommand(player, "gameNightCursor", "update", {dataToSend})
end

--cursorHandler.cursor = nil
--cursorHandler.cursorW = nil
--cursorHandler.cursorH = nil
function cursorHandler.receiveUpdate(data)--sqX, sqY, sqZ, playerUsername, mouseX, mouseY, r, g, b)
    ---@type gameNightWindow
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    local dataPoints = {}
    for str in string.gmatch(data, "([^".."_".."]+)") do table.insert(dataPoints, str) end

    local sqX, sqY, sqZ = tonumber(dataPoints[1]), tonumber(dataPoints[2]), tonumber(dataPoints[3])

    if (window.square:getX() ~= sqX) or (window.square:getY() ~= sqY) or (window.square:getZ() ~= sqZ) then return end

    local playerUsername = dataPoints[4]
    local mouseX, mouseY = tonumber(dataPoints[5]), tonumber(dataPoints[6])
    local r, g, b = tonumber(dataPoints[7]), tonumber(dataPoints[8]), tonumber(dataPoints[9])

    cursorHandler.cursor = cursorHandler.cursor or getTexture("media/textures/gamenight_cursor.png")
    cursorHandler.cursorW = cursorHandler.cursorW or cursorHandler.cursor:getWidth()
    cursorHandler.cursorH = cursorHandler.cursorH or cursorHandler.cursor:getHeight()

    local texture = cursorHandler.cursor
    mouseX = mouseX+cursorHandler.cursorW
    mouseY = mouseY+cursorHandler.cursorH
    window:drawTexture(texture, mouseX, mouseY, 1, r, g, b)
    window:drawText(playerUsername, mouseX, mouseY, r, g, b, 1, UIFont.NewSmall)
end

return cursorHandler