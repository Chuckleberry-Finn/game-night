require "ISUI/ISInventoryPaneContextMenu"
local applyItemDetails = require("gameNight-applyItemDetails.lua")
local deckActionHandler = applyItemDetails.deckActionHandler
local gnTags = require("gameNight-tags.lua")
local gamePieceHandler = applyItemDetails.gamePieceHandler
-- require("gameNight-window.lua")
local boxHandler = require("gameNight-boxHandler.lua")

local gamePieceContext = {}

gamePieceContext.gameNightContextMenuIcon = {
    play=getTexture("media/textures/actionIcons/gamenight_icon.png"),
    deal=getTexture("media/textures/actionIcons/dealCard.png"),
    draw=getTexture("media/textures/actionIcons/drawCard.png"),
    drawRand=getTexture("media/textures/actionIcons/drawRandCard.png"),
    search=getTexture("media/textures/actionIcons/searchCards.png"),
    flip=getTexture("media/textures/actionIcons/flipCard.png"),
}

---@param context ISContextMenu
function gamePieceContext.addInventoryItemContext(playerID, context, items)
    local playerObj = getSpecificPlayer(playerID)

    for _, v in ipairs(items) do

        ---@type InventoryItem
        local item = v
        local stack
        if not instanceof(v, "InventoryItem") then
            stack = v
            item = v.items[1]
        end

        local isGamePiece = gamePieceHandler.isGamePiece(item)
        if isGamePiece then
            gamePieceHandler.generateContextMenuForStacking(context, playerObj, item)
            gamePieceHandler.generateContextMenuFromSpecialActions(context, playerObj, (stack or item))
        end

        local deckStates, flippedStates = deckActionHandler.getDeckStates(item)
        if deckStates then

            gamePieceHandler.generateContextMenuFromSpecialActions(context, playerObj, (stack or item), deckActionHandler)

            local flip = context:addOptionOnTop(getText("IGUI_flipCard"), item, deckActionHandler.flipCard, playerObj)
            flip.iconTexture = gamePieceContext.gameNightContextMenuIcon.flip

            if #deckStates>1 then

                local shuffle = context:addOptionOnTop(getText("IGUI_shuffleCards"), item, deckActionHandler.shuffleCards, playerObj)

                local pPrimaryItem = playerObj:getPrimaryHandItem()
                if (not pPrimaryItem) or (pPrimaryItem and pPrimaryItem ~= item) then
                    local drawOption = context:addOptionOnTop(getText("IGUI_draw"), item, nil)
                    local subDrawMenu = ISContextMenu:getNew(context)
                    context:addSubMenu(drawOption, subDrawMenu)

                    --local drawRand = subDrawMenu:addOptionOnTop(getText("IGUI_drawRandCard"), item, deckActionHandler.drawRandCard, playerObj)
                    --drawRand.iconTexture = gamePieceContext.gameNightContextMenuIcon.drawRand

                    local draw = subDrawMenu:addOptionOnTop(getText("IGUI_drawCard"), item, deckActionHandler.drawCard, playerObj)
                    draw.iconTexture = gamePieceContext.gameNightContextMenuIcon.draw

                    local drawMultipleSubMenu = subDrawMenu:getNew(subDrawMenu)
                    local cardCount = {1,3,5,7}
                    for _,n in pairs(cardCount) do
                        if #deckStates >= n then
                            drawMultipleSubMenu:addOption(getText("IGUI_drawCards", n), item, deckActionHandler.drawCards, playerObj, n)
                        end
                    end
                    if #deckStates > cardCount[#cardCount]*2 then
                        local n = math.floor(#deckStates/2)
                        if n > cardCount[#cardCount] then
                            drawMultipleSubMenu:addOption(getText("IGUI_splitCards", n), item, deckActionHandler.drawCards, playerObj, n)
                        end
                    end
                    subDrawMenu:addSubMenu(draw, drawMultipleSubMenu)

                    local drawToHand = subDrawMenu:addOptionOnTop(getText("IGUI_drawToHand"), item, deckActionHandler.drawToHandItem, playerObj, 1)
                    drawToHand.iconTexture = gamePieceContext.gameNightContextMenuIcon.draw

                    local drawToHandMultiSubMenu = subDrawMenu:getNew(subDrawMenu)
                    for _,n in pairs(cardCount) do
                        if #deckStates >= n then
                            drawToHandMultiSubMenu:addOption(getText("IGUI_drawCards", n), item, deckActionHandler.drawToHandItem, playerObj, n)
                        end
                    end
                    if #deckStates > cardCount[#cardCount]*2 then
                        local n = math.floor(#deckStates/2)
                        if n > cardCount[#cardCount] then
                            drawToHandMultiSubMenu:addOption(getText("IGUI_splitCards", n), item, deckActionHandler.drawToHandItem, playerObj, n)
                        end
                    end
                    subDrawMenu:addSubMenu(drawToHand, drawToHandMultiSubMenu)
                end

                local worldItem = item:getWorldItem()
                local gnWindow = gameNightWindow and gameNightWindow.instance

                local playSq = gnWindow and gnWindow.square
                if worldItem or playSq then

                    local x, y
                    if worldItem and gnWindow then x, y = gnWindow:getMouseX(), gnWindow:getMouseY() end

                    local deal = context:addOptionOnTop(getText("IGUI_deal"), item, deckActionHandler.dealCard, playerObj, x, y)
                    deal.iconTexture = gamePieceContext.gameNightContextMenuIcon.deal

                    local dealMultipleSubMenu = context:getNew(context)
                    local cardCount = {1,3,5,7}
                    for _,n in pairs(cardCount) do
                        if #deckStates > n then
                            dealMultipleSubMenu:addOption(getText("IGUI_dealCards", n), item, deckActionHandler.dealCards, playerObj, n)
                        end
                    end

                    if #deckStates > cardCount[#cardCount]*2 then
                        local n = math.floor(#deckStates/2)
                        if n > cardCount[#cardCount] then
                            dealMultipleSubMenu:addOption(getText("IGUI_splitCards", n), item, deckActionHandler.dealCards, playerObj, n)
                        end
                    end

                    context:addSubMenu(deal, dealMultipleSubMenu)
                end


                local search = context:addOptionOnTop(getText("IGUI_searchDeck"), item, deckActionHandler.searchDeck, playerObj)
                search.iconTexture = gamePieceContext.gameNightContextMenuIcon.search
            end
        end
        break
    end
end

Events.OnPreFillInventoryObjectContextMenu.Add(gamePieceContext.addInventoryItemContext)


 require("gameNight-window.lua")
function gamePieceContext.addWorldContext(playerID, context, worldObjects, test)
    ---@type IsoObject|IsoGameCharacter|IsoPlayer
    local playerObj = getSpecificPlayer(playerID)
    local square

    for _,v in ipairs(worldObjects) do square = v:getSquare() end
    if not square then return false end

    if square and ( square:DistToProper(playerObj) <= 1.5 ) then

        local validObjectCount = 0

        for i=0,square:getObjects():size()-1 do
            ---@type IsoObject|IsoWorldInventoryObject
            local object = square:getObjects():get(i)
            if object and instanceof(object, "IsoWorldInventoryObject") then
                local item = object:getItem()
                applyItemDetails.applyGameNightToItem(item)
                local box = item and boxHandler.isGameBox(item)
                if item and (item:hasTag(gnTags.GAME_NIGHT) or box) then
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