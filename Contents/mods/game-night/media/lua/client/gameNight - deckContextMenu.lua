require "ISUI/ISInventoryPaneContextMenu"
local deckCataloger = require "gameNight - deckCataloger"
local deckActionHandler = require "gameNight - deckActionHandler"

local deckContext = {}

function deckContext.addContext(player, context, items)
    for _, v in ipairs(items) do

        local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end

        deckCataloger.applyDeckToItem(item)
        local deck, flippedStates = deckActionHandler.getDeck(item)

        if deck then
            if #deck>1 then
                context:addOption(getText("IGUI_drawCard"), item, deckActionHandler.drawCard)
                context:addOption(getText("IGUI_drawRandCard"), item, deckActionHandler.drawRandCard)
                context:addOption(getText("IGUI_shuffleCards"), item, deckActionHandler.shuffleCards)
            end
            context:addOption(getText("IGUI_flipCard"), item, deckActionHandler.flipCard)
            break
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(deckContext.addContext)