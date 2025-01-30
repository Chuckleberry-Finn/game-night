local deckActionHandler = require "gameNight - deckActionHandler"
local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"

require "ISUI/ISInventoryPane"
--[[
local ISInventoryPane_doContextualDblClick = ISInventoryPane.doContextualDblClick
function ISInventoryPane:doContextualDblClick(item)
    ISInventoryPane_doContextualDblClick(self, item)
    local deckStates, flippedStates = deckActionHandler.getDeckStates(item)
    if deckStates then
        if #deckStates>1 then
            deckActionHandler.drawCard(item)
        else
            deckActionHandler.flipCard(item)
        end
    end
end
--]]

local ISInventoryPane_onMouseUp = ISInventoryPane.onMouseUp
function ISInventoryPane:onMouseUp(x, y)
    if not self:getIsVisible() then return end

    local draggingOld = ISMouseDrag.dragging
    local draggingFocusOld = ISMouseDrag.draggingFocus
    local selectedOld = self.selected
    local busy = false
    self.previousMouseUp = self.mouseOverOption

    local noSpecialKeys = (not isShiftKeyDown() and not isCtrlKeyDown())
    if (noSpecialKeys and x >= self.column2 and  x == self.downX and y == self.downY) and self.mouseOverOption ~= 0 and self.items[self.mouseOverOption] ~= nil then busy = true end

    local result = ISInventoryPane_onMouseUp(self, x, y)
    if not result then return end
    if busy or (not noSpecialKeys) then return end

    self.selected = selectedOld

    if (draggingOld ~= nil) and (draggingFocusOld == self) and (draggingFocusOld ~= nil) then

        if self.player ~= 0 then return end
        local playerObj = getSpecificPlayer(self.player)
        local itemFound = {}

        local doWalk = true
        local dragging = ISInventoryPane.getActualItems(draggingOld)
        for i,v in ipairs(dragging) do
            if deckActionHandler.isDeckItem(v) or gamePieceAndBoardHandler.canStackPiece(v) then
                local transfer = v:getContainer() and not self.inventory:isInside(v)
                if v:isFavorite() and not self.inventory:isInCharacterInventory(playerObj) then transfer = false end
                if transfer then
                    if doWalk then if not luautils.walkToContainer(self.inventory, self.player) then break end doWalk = false end
                    table.insert(itemFound, v)
                end
            end
        end

        if #itemFound <= 0 then
            ISMouseDrag.dragging = draggingOld
            ISMouseDrag.draggingFocus = draggingFocusOld
            self.selected = selectedOld
            return true
        end

        self.selected = {}
        getPlayerLoot(self.player).inventoryPane.selected = {}
        getPlayerInventory(self.player).inventoryPane.selected = {}

        local pushTo = self.items[self.mouseOverOption]
        if not pushTo then return end

        local pushToActual
        if instanceof(pushTo, "InventoryItem") then pushToActual = pushTo else pushToActual = pushTo.items[1] end

        for _,item in pairs(itemFound) do if item==pushToActual then return end end

        if pushToActual then
            if deckActionHandler.isDeckItem(pushToActual) then
                for _,deck in pairs(itemFound) do
                    deckActionHandler.mergeDecks(deck, pushToActual, playerObj)
                end

            elseif gamePieceAndBoardHandler.canStackPiece(pushToActual) then

                for _,gamePiece in pairs(itemFound) do
                    gamePieceAndBoardHandler.tryStack(gamePiece, pushToActual, playerObj)
                end
            end
        end
    end
end