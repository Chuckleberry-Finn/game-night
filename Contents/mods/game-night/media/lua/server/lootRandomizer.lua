--[[
require "Items/Distributions"
require "Items/SuburbsDistributions"

local function deepPrintTBL(_dist, tab) if type(_dist) == "table" then for k,v in pairs(_dist) do print(tab .. " " .. tostring(k)) deepPrintTBL(v, tab.."  ") end else print(tab .. tostring(_dist)) end end

local function scramble()

    local origRoomLoot = {}
    local foundRoomLoot = {}

    for roomID,data in pairs(SuburbsDistributions) do
        for containerID,contData in pairs(data) do
            if type(contData)=="table" then
                ---if room's container's data has an items list OR if it has a junk list with items
                if (contData.items and #contData.items>0) or (contData.junk and contData.junk.items and #contData.junk.items>0) then
                    ---Add extra exceptions here if needed
                    table.insert(origRoomLoot, roomID)
                    table.insert(foundRoomLoot, roomID)
                end
            end
        end
    end

    print("#foundRoomLoot: "..#foundRoomLoot)

    ---shuffle found list
    for origIndex = #foundRoomLoot, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        foundRoomLoot[origIndex], foundRoomLoot[shuffledIndex] = foundRoomLoot[shuffledIndex], foundRoomLoot[origIndex]
    end

    ---using the original order found replace the entries with the shuffled version
    for index,roomID in pairs(origRoomLoot) do
        SuburbsDistributions[roomID] = copyTable(foundRoomLoot[roomID])
        ---Make changes to distro here as well if needed
    end

    --deepPrintTBL(SuburbsDistributions, "")
end


Events.OnPostDistributionMerge.Add(scramble)
--]]