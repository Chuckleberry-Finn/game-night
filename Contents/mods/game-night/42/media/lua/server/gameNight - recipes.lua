require "recipecode"
require "Items/SuburbsDistributions"

Recipe.GameNight = {}

---@param character IsoPlayer
function Recipe.GameNight.Unbox(craftRecipeData, character)

    local result = craftRecipeData:getAllCreatedItems():get(0)
    local itemType = result:getType()
    local itemContainer = result:getInventory()
    local itemContainerDistribution = Distributions[1][itemType]
    
    if not itemContainerDistribution then return end
    if itemContainerDistribution.rolls <= 0 then return end

    for _=1, itemContainerDistribution.rolls do
        for k,item in pairs(itemContainerDistribution.items) do
            if type(item) == "string" then ItemPickerJava.tryAddItemToContainer(itemContainer, item, nil) end
        end
    end
end