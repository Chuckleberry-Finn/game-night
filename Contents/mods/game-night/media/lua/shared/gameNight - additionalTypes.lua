---TODO: Look into this down the line, this would avoid repetitive item scripts from being needed at all
--[[
local additionalTypes = {}

additionalTypes.items = {
    ["Base.ChessWhite"]={ "King","Queen","Bishop","Knight","Rook" },
    ["Base.ChessBlack"]={ "King","Queen","Bishop","Knight","Rook" },
    ["Base.PokerChips"]={ "White","Black","Green","Blue","Yellow","Purple","Orange"},
}

function additionalTypes.process()

    local scriptManager = getScriptManager()

    for itemType,variants in pairs(additionalTypes.items) do
        if variants then

            local script = scriptManager:getItem(itemType)

            local scriptItemType = script:getName()
            local scriptType = tostring(script:getType())
            local scriptWeight = script:getActualWeight()
            local scriptCategory = script:getDisplayCategory()
            local scriptDisplayName = script:getDisplayName()
            local scriptIcon = script:getIcon()
            local scriptWorldStaticModel

            local numClassFields = getNumClassFields(script)
            for i = 0, numClassFields - 1 do
                ---@type Field
                local javaField = getClassField(script, i)
                if javaField and tostring(javaField) == "public float zombie.scripting.objects.Item.worldStaticModel" then
                    scriptWorldStaticModel = getClassFieldVal(script, javaField)
                end
            end

            for _,variant in pairs(variants) do

                local additionalScript = "module Base { item "..scriptItemType..variant..
                        " { ".."DisplayCategory = "..scriptCategory..
                        ", Weight = "..scriptWeight..", Type = "..scriptType..
                        ",DisplayName	= "..scriptDisplayName..
                        ",Icon = "..scriptIcon

                if scriptWorldStaticModel then additionalScript = additionalScript.. ", WorldStaticModel = "..scriptWorldStaticModel end

                additionalScript = additionalScript..", } }"
                scriptManager:ParseScript(additionalScript)
            end
        end
    end
end

Events.OnResetLua.Add(additionalTypes.process)

return additionalTypes
--]]