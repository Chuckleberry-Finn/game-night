require "ISUI/ISInventoryPaneContextMenu"
local deckCataloger = require "gameNight - deckCataloger"
local deckActionHandler = require "gameNight - deckActionHandler"

local deckContext = {}

function deckContext.addContext(player, context, items)
    for _, v in ipairs(items) do

        local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end

        local deck = deckActionHandler.getDeck(item)

        if deck then
            if #deck>1 then
                context:addOption(getText("IGUI_drawCard"), item, deckActionHandler.drawCard, player)
                context:addOption(getText("IGUI_drawRandCard"), item, deckActionHandler.drawRandCard, player)
                context:addOption(getText("IGUI_shuffleCards"), item, deckActionHandler.shuffleCards, player)
            end
            context:addOption(getText("IGUI_flipCard"), item, deckActionHandler.flipCard, player)
            break
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(deckContext.addContext)