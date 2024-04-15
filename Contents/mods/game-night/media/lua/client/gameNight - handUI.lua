require "ISUI/ISPanel"
require "ISUI/ISPanelJoypad"
require "gameNight - window"

--local applyItemDetails = require "gameNight - applyItemDetails"
--local deckActionHandler = applyItemDetails.deckActionHandler
--local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

---@class gameNightHand : ISPanel
gameNightHand = gameNightDeckSearch:derive("gameNightHand")

function gameNightHand:update() gameNightDeckSearch.update(self) end
function gameNightHand:onMouseWheel(del) gameNightDeckSearch.onMouseWheel(self, del) end
function gameNightHand:getCardAtXY(x, y) gameNightDeckSearch.getCardAtXY(self, x, y) end
function gameNightHand:clearDragging() gameNightDeckSearch.clearDragging(self) end
function gameNightHand:cardOnRightMouseUp(x, y) gameNightDeckSearch.cardOnRightMouseUp(self, x, y) end
function gameNightHand:onMouseMove(dx, dy) gameNightDeckSearch.onMouseMove(self, dx, dy) end
function gameNightHand:cardOnMouseUpOutside(x, y) gameNightDeckSearch.cardOnMouseUpOutside(self, x, y) end
function gameNightHand:cardOnMouseUp(x, y) gameNightDeckSearch.cardOnMouseUp(self, x, y) end
function gameNightHand:cardOnMouseDownOutside(x, y) gameNightDeckSearch.cardOnMouseDownOutside(self, x, y) end
function gameNightHand:cardOnMouseDown(x, y) gameNightDeckSearch.cardOnMouseDown(self, x, y) end
function gameNightHand:prerender() gameNightDeckSearch.prerender(self) end
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