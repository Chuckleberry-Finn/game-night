gameNightTimedAction = ISBaseTimedAction:derive("gameNightTimedAction")


function gameNightTimedAction:isValid()
    return true
end


--function teleportingSystem.action:waitToStart() end
--function teleportingSystem.action:start() end
--function teleportingSystem.action:update() end


function gameNightTimedAction:stop()
    ISBaseTimedAction.stop(self)
end


function gameNightTimedAction:perform()
    ISBaseTimedAction.perform(self)
end


function gameNightTimedAction:new(playerObj)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = playerObj

    o.stopOnWalk = true
    o.stopOnRun = true
    o.stopOnAim = true

    o.maxTime = 50

    return o
end

