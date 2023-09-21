require "ISUI/ISInventoryPaneContextMenu"
local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

local gamePieceContext = {}

gamePieceContext.gameNightContextMenuIcon = {
    play=getTexture("media/textures/gamenight_icon.png"),
    deal=getTexture("media/textures/dealCard.png"),
    draw=getTexture("media/textures/drawCard.png"),
    search=getTexture("media/textures/searchCards.png"),
}


---@param context ISContextMenu
function gamePieceContext.addInventoryItemContext(playerID, context, items)
    local playerObj = getSpecificPlayer(playerID)
    for _, v in ipairs(items) do

        ---@type InventoryItem
        local item = v
        if not instanceof(v, "InventoryItem") then item = v.items[1] end

        local isGamePiece = gamePieceAndBoardHandler.isGamePiece(item)
        if isGamePiece then gamePieceAndBoardHandler.generateContextMenuFromSpecialActions(context, playerObj, item) end

        local deckStates, flippedStates = deckActionHandler.getDeckStates(item)
        if deckStates then

            local flip = context:addOptionOnTop(getText("IGUI_flipCard"), item, deckActionHandler.flipCard, playerObj)

            if #deckStates>1 then

                local shuffle = context:addOptionOnTop(getText("IGUI_shuffleCards"), item, deckActionHandler.shuffleCards, playerObj)

                local drawOption = context:addOptionOnTop(getText("IGUI_draw"), item, nil)
                local subDrawMenu = ISContextMenu:getNew(context)
                context:addSubMenu(drawOption, subDrawMenu)

                local worldItem = item:getWorldItem()
                if worldItem then
                    local deal = subDrawMenu:addOptionOnTop(getText("IGUI_deal"), item, deckActionHandler.dealCard, playerObj)
                    deal.iconTexture = gamePieceContext.gameNightContextMenuIcon.deal
                end

                local drawRand = subDrawMenu:addOptionOnTop(getText("IGUI_drawRandCard"), item, deckActionHandler.drawRandCard, playerObj)
                drawRand.iconTexture = gamePieceContext.gameNightContextMenuIcon.draw

                local draw = subDrawMenu:addOptionOnTop(getText("IGUI_drawCard"), item, deckActionHandler.drawCard, playerObj)
            draw.iconTexture = gamePieceContext.gameNightContextMenuIcon.draw

            local search = context:addOptionOnTop(getText("IGUI_searchDeck"), item, deckActionHandler.searchDeck, playerObj)
            search.iconTexture = gamePieceContext.gameNightContextMenuIcon.searc
                end
            break
        end
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(gamePieceContext.addInventoryItemContext)


require "gameNight - window"
function gamePieceContext.addWorldContext(playerID, context, worldObjects, test)
    if test then return true end
    ---@type IsoObject|IsoGameCharacter|IsoPlayer
    local playerObj = getSpecificPlayer(playerID)
    local square

    for _,v in ipairs(worldObjects) do square = v:getSquare() end
    if not square then return false end

    if square==playerObj:getSquare() or luautils.isSquareAdjacentToSquare(square, playerObj:getSquare()) then

        local validObjectCount = 0

        for i=0,square:getObjects():size()-1 do
            ---@type IsoObject|IsoWorldInventoryObject
            local object = square:getObjects():get(i)
            if object and instanceof(object, "IsoWorldInventoryObject") then
                local item = object:getItem()
                applyItemDetails.applyGameNightToItem(item)
                if item and item:getTags():contains("gameNight") then
                    validObjectCount = validObjectCount+1
                end
            end
        end

        if validObjectCount > 0 then
            local option = context:addOptionOnTop(getText("IGUI_Play_Game"), worldObjects, gameNightWindow.open, playerObj, square)
            option.iconTexture = gamePieceContext.gameNightContextMenuIcon.play
        end
    end
    return false
end
Events.OnFillWorldObjectContextMenu.Add(gamePieceContext.addWorldContext)

return gamePieceContext