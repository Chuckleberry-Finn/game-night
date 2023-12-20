require "TimedActions/ISDropWorldItemAction"

local ISDropWorldItemAction_perform = ISDropWorldItemAction.perform

function ISDropWorldItemAction:perform()
    ISDropWorldItemAction_perform(self)
    --	o.item = item
    --	o.rotation = rotation
    self.item:getModData()["gameNight_rotation"] = (self.rotation or 0)
end