require "TimedActions/ISDropWorldItemAction"

local ISDropWorldItemAction_perform = ISDropWorldItemAction.perform

function ISDropWorldItemAction:perform()
    self.item:getModData()["gameNight_rotation"] = (self.rotation or 0)
    ISDropWorldItemAction_perform(self)
end