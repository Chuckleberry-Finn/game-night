local boxHandler = {}

function boxHandler.isGameBox(item)
    if not item then return false end
    return (item:getDisplayCategory() == "GameBox" and item:IsInventoryContainer())
end

function boxHandler.findAllNearbyBoxes(square)
    if not square then return {} end
    local cell = getCell()
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local found = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            local sq = cell:getGridSquare(x+dx, y+dy, z)
            if sq then
                local objects = sq:getObjects()
                for i = 0, objects:size()-1 do
                    local obj = objects:get(i)
                    if obj and instanceof(obj, "IsoWorldInventoryObject") then
                        local it = obj:getItem()
                        if it and boxHandler.isGameBox(it) then
                            table.insert(found, obj)
                        end
                    end
                end
            end
        end
    end
    return found
end

function boxHandler.findNearbyBox(square)
    if not square then return nil end
    local cell = getCell()
    local x, y, z = square:getX(), square:getY(), square:getZ()
    for dx = -1, 1 do
        for dy = -1, 1 do
            local sq = cell:getGridSquare(x+dx, y+dy, z)
            if sq then
                local objects = sq:getObjects()
                for i = 0, objects:size()-1 do
                    local obj = objects:get(i)
                    if obj and instanceof(obj, "IsoWorldInventoryObject") then
                        local it = obj:getItem()
                        if it and boxHandler.isGameBox(it) then
                            return obj
                        end
                    end
                end
            end
        end
    end
end

return boxHandler
