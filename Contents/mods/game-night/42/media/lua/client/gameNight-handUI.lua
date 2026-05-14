require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
 require("gameNight-window.lua")

--local applyItemDetails = require("gameNight-applyItemDetails.lua")
--local deckActionHandler = applyItemDetails.deckActionHandler
--local gamePieceHandler = applyItemDetails.gamePieceHandler

---@class gameNightHand : ISPanel
gameNightHand = gameNightDeckSearch:derive("gameNightHand")

function gameNightHand:update() gameNightDeckSearch.update(self) end
function gameNightHand:onMouseWheel(del) gameNightDeckSearch.onMouseWheel(self, del) end
function gameNightHand:getCardAtXY(x, y) gameNightDeckSearch.getCardAtXY(self, x, y) end
function gameNightHand:clearDragging() gameNightDeckSearch.clearDragging(self) end
function gameNightHand:clearSelection() gameNightDeckSearch.clearSelection(self) end
function gameNightHand:getSelection() return gameNightDeckSearch.getSelection(self) end
function gameNightHand:getSelectionOrder() return gameNightDeckSearch.getSelectionOrder(self) end
function gameNightHand:cardOnRightMouseUp(x, y) gameNightDeckSearch.cardOnRightMouseUp(self, x, y) end
function gameNightHand:onMouseMove(dx, dy) gameNightDeckSearch.onMouseMove(self, dx, dy) end
function gameNightHand:cardOnMouseUpOutside(x, y) gameNightDeckSearch.cardOnMouseUpOutside(self, x, y) end
function gameNightHand:cardOnMouseUp(x, y) gameNightDeckSearch.cardOnMouseUp(self, x, y) end
function gameNightHand:cardOnMouseDownOutside(x, y) gameNightDeckSearch.cardOnMouseDownOutside(self, x, y) end
function gameNightHand:cardOnMouseDown(x, y) gameNightDeckSearch.cardOnMouseDown(self, x, y) end
function gameNightHand:prerender()
    gameNightDeckSearch.prerender(self)
    -- "In Hand" label: NewSmall font, centred in the header strip above the card display.
    local font = UIFont.NewSmall
    local fh = getTextManager():getFontHeight(font)
    local lw = getTextManager():MeasureStringX(font, "In Hand")
    local lx = math.floor((self.width - lw) / 2)
    local ly = math.floor((self.bounds.y1 - fh) / 2)
    self:drawText("In Hand", lx, ly, 0.85, 0.85, 0.85, 0.9, font)
end

function gameNightHand:render() gameNightDeckSearch.render(self) end
function gameNightHand:initialise() gameNightDeckSearch.initialise(self) end


function gameNightHand.open(player, deckItem)

    local searchInstance = gameNightDeckSearch.instances[deckItem]
    if searchInstance then searchInstance:closeAndRemove() end

    local instance = gameNightHand.instance
    if instance then instance:closeAndRemove() end

    local gameWindow = gameNightWindow and gameNightWindow.instance
    local x, y, w, h
    if gameWindow then
        h = 160
        x = (gameWindow:getX()+gameWindow:getWidth()+10)
        y = (gameWindow:getY()+gameWindow:getHeight()-h)
        w = gameWindow:getWidth()*0.66
    end

    local window = gameNightHand:new(x, y, w, h, player, deckItem)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)

    return window
end


function gameNightHand:new(x, y, width, height, player, deckItem)
    local o = gameNightDeckSearch:new(x, y, width, height, player, deckItem, true)
    o.scaleSize = 1.25
    return o
end