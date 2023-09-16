--TODO: REFACTOR THIS AWAY
require "ISUI/ISPanelJoypad"
---@class gameNightElement : ISPanelJoypad
gameNightElement = ISPanelJoypad:derive("gameNightElement")
function gameNightElement:initialise() ISPanelJoypad.initialise(self) end

function gameNightElement:onMouseUp(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    window:onMouseUp(window:getMouseX(), window:getMouseY())
end

function gameNightElement:onRightMouseDown(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    window:onRightMouseDown(window:getMouseX(), window:getMouseY())
end

function gameNightElement:onMouseDown(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end
    window:onMouseDown(window:getMouseX(), window:getMouseY())
end


local gamePieceAndBoardHandler = require "gameNight - gamePieceAndBoardHandler"
function gameNightElement:moveElement(x, y)
    local window = gameNightWindow.instance
    if not window or not window:isVisible() then return end

    if not self.moveWithMouse or not window.movingPiece or self~=window.movingPiece then return end
    window.movingPiece = nil

    ---@type IsoObject|InventoryItem
    local item = self.itemObject
    if not item then return end

    local selfW, selfH = self:getWidth(), self:getHeight()

    local offsetX = window.movingPieceOffset and window.movingPieceOffset[1] or 0
    local offsetY = window.movingPieceOffset and window.movingPieceOffset[2] or 0

    local newX = (self:getX()+x)-window.x-(offsetX)
    local newY = (self:getY()+y)-window.y-(offsetY)

    newX = math.min(math.max(newX, window.bounds.x1), window.bounds.x2-selfW)
    newY = math.min(math.max(newY, window.bounds.y1), window.bounds.y2-selfH)

    if newX < window.bounds.x1 or newY < window.bounds.y1 or newX > window.bounds.x2 or newY > window.bounds.y2 then return end

    local boundsDifference = window.padding*2
    local scaledX = (newX/(window.width-boundsDifference))
    local scaledY = (newY/(window.height-boundsDifference))

    self.moveWithMouse = false
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(item, window.square, window.player, scaledX, scaledY)
    self.moveWithMouse = true

    local pBD = window.player:getBodyDamage()
    pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-0.5))
end


function gameNightElement:prerender() ISPanelJoypad.prerender(self) end
function gameNightElement:render() ISPanelJoypad.render(self) end
function gameNightElement:new(x, y, width, height, itemObject)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemObject = itemObject
    o.borderColor = {r=1, g=1, b=1, a=0}
    o.backgroundColor = {r=1, g=1, b=1, a=0}
    o.moveWithMouse = true
    o.selectedItem = nil
    o.pendingRequest = false
    return o
end