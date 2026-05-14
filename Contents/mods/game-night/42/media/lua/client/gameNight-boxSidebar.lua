require "ISUI/ISPanel"

local applyItemDetails = require("gameNight-applyItemDetails.lua")
local gamePieceHandler = applyItemDetails.gamePieceHandler
local deckActionHandler = applyItemDetails.deckActionHandler
local boxHandler = require("gameNight-boxHandler.lua")

---@class gameNightBoxSidebar : ISPanel
gameNightBoxSidebar = ISPanel:derive("gameNightBoxSidebar")

local function tableHasEntries(t)
    for _ in pairs(t) do return true end
    return false
end

local COLS = 6
local ROWS = 4
local ICON_SIZE = 16
local ICON_GAP = 2
local EDGE_PAD = 3
local HEADER_H = 18
local HEADER_PAD = 2
local CELL_W = ICON_SIZE + ICON_GAP
local PANEL_W = EDGE_PAD + COLS * ICON_SIZE + (COLS - 1) * ICON_GAP + EDGE_PAD -- 112

gameNightBoxSidebar.instance = nil



local GameNightTransfer = ISBaseTimedAction:derive("GameNightTransfer")

function GameNightTransfer:new(player, item, fromInv, toInv, sidebar)
    local o = ISBaseTimedAction.new(self, player)
    setmetatable(o, self)
    self.__index = self
    o.item = item
    o.fromInv = fromInv
    o.toInv = toInv
    o.sidebar = sidebar
    o.maxTime = 50
    o.jobDelta = 0
    return o
end

function GameNightTransfer:isValid() return self.fromInv:contains(self.item) end

function GameNightTransfer:start()
    self.sidebar.activeTransfers[self.item:getID()] = self
end

function GameNightTransfer:perform()
    if self.fromInv:contains(self.item) then
        self.fromInv:Remove(self.item)
        self.toInv:AddItem(self.item)
        self.sidebar.gameWindow.elementsDirty = true
        gamePieceHandler.refreshInventory(self.sidebar.player)
    end
    self.sidebar.activeTransfers[self.item:getID()] = nil
    ISBaseTimedAction.perform(self)
end

function GameNightTransfer:update()
    self.jobDelta = self.jobDelta + 1
    if self.jobDelta >= self.maxTime then self:perform() end
end

function GameNightTransfer:stop()
    self.sidebar.activeTransfers[self.item:getID()] = nil
    ISBaseTimedAction.stop(self)
end


local GameNightPickup = ISBaseTimedAction:derive("GameNightPickup")

function GameNightPickup:new(player, item, sidebar, sectionKey)
    local o = ISBaseTimedAction.new(self, player)
    setmetatable(o, self)
    self.__index = self
    o.item = item
    o.sidebar = sidebar
    o.sectionKey = sectionKey or "inventory"
    o.maxTime = 30
    o.jobDelta = 0
    return o
end

function GameNightPickup:isValid() return self.item:getWorldItem() ~= nil end

function GameNightPickup:start()
    self.sidebar.activeTransfers[self.item:getID()] = self
end

function GameNightPickup:perform()
    self.sidebar.activeTransfers[self.item:getID()] = nil
    gamePieceHandler.pickupGamePiece(self.character, self.item)
    self.sidebar.gameWindow.elementsDirty = true
    ISBaseTimedAction.perform(self)
end

function GameNightPickup:update()
    self.jobDelta = self.jobDelta + 1
    if self.jobDelta >= self.maxTime then self:perform() end
end

function GameNightPickup:stop()
    self.sidebar.activeTransfers[self.item:getID()] = nil
    ISBaseTimedAction.stop(self)
end




function gameNightBoxSidebar:new(player, gameWindow)
    local gw = gameWindow
    local o = ISPanel:new(gw:getX() + gw:getWidth() + 4, gw:getY(), PANEL_W, gw:getHeight())
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.gameWindow = gameWindow
    o.sections = {}
    o.collapsed = {}
    o.scroll = {}
    o.activeTransfers = {}
    o.moveWithMouse = true
    o.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.9}
    o.borderColor = {r=0.45, g=0.45, b=0.45, a=0.9}
    o.sidebarSelected = {}
    o.sidebarDragGroup = nil
    o.selectionAnchor = nil
    return o
end

function gameNightBoxSidebar:initialise()
    ISPanel.initialise(self)
end

function gameNightBoxSidebar:update()
    local gw = self.gameWindow
    if not gw or not gw:isVisible() then self:close() return end
    self:setX(gw:getX() + gw:getWidth() + 4)
    self:setY(gw:getY())
    self:setHeight(gw:getHeight())
    self:buildSections()
end

function gameNightBoxSidebar:clearSelection()
    self.sidebarSelected = {}
    self.selectionAnchor = nil
end




function gameNightBoxSidebar:collectItems(javaInv)
    local result = {}
    if not javaInv then return result end
    local list = javaInv:getItems()
    for i = 0, list:size() - 1 do
        local item = list:get(i)
        if item then
            local sp = gamePieceHandler.specials[item:getFullType()]
            local isDie = sp and sp.category == "Die"
            local hideUI = sp and sp.hideUI
            if (gamePieceHandler.isGamePiece(item) or deckActionHandler.isDeckItem(item)) and not isDie and not hideUI then
                table.insert(result, item)
            end
        end
    end
    return result
end

function gameNightBoxSidebar:buildSections()
    local gw = self.gameWindow
    local sections = {}
    local curY = HEADER_PAD

    local function layoutItems(items, fromBox, scrollOff)
        scrollOff = scrollOff or 0
        local startIdx = scrollOff * COLS + 1
        local entries = {}
        local col, row = 0, 0
        for i = startIdx, #items do
            if row >= ROWS then break end
            table.insert(entries, {
                item = items[i],
                tex = items[i]:getTexture(),
                col = col,
                iy = curY + HEADER_PAD + row * CELL_W,
                fromBox = fromBox,
            })
            col = col + 1
            if col >= COLS then
                col = 0
                row = row + 1
            end
        end
        local totalRows = math.ceil(#items / COLS)
        local visibleRows = math.min(math.max(totalRows - scrollOff, 0), ROWS)
        curY = curY + visibleRows * CELL_W + HEADER_PAD
        return entries, totalRows
    end

    for _, boxWorldItem in ipairs(boxHandler.findAllNearbyBoxes(gw.square)) do
        local boxItem = boxWorldItem:getItem()
        local label = boxItem and (boxItem:getDisplayName() or boxItem:getName()) or "Box"
        local key = "box_" .. tostring(boxWorldItem)
        local items = self:collectItems(boxItem and boxItem:getInventory())
        local headerY = curY
        local scrollOff = math.min(self.scroll[key] or 0, math.max(0, math.ceil(#items/COLS)-ROWS))
        self.scroll[key] = scrollOff
        curY = curY + HEADER_H + HEADER_PAD
        local entries, totalRows
        if not self.collapsed[key] then
            entries, totalRows = layoutItems(items, boxWorldItem, scrollOff)
        else
            entries = {}
            totalRows = math.ceil(#items / COLS)
        end
        table.insert(sections, {
            key=key, label=label, items=items, fromBox=boxWorldItem,
            headerY=headerY, entries=entries, totalRows=totalRows, scrollOffset=scrollOff,
        })
    end

    local handItem = self.player:getPrimaryHandItem()
    local invPieces = {}
    for _, item in ipairs(self:collectItems(self.player:getInventory())) do
        if item ~= handItem then table.insert(invPieces, item) end
    end

    local key = "inventory"
    local headerY = curY
    local scrollOff = math.min(self.scroll[key] or 0, math.max(0, math.ceil(#invPieces/COLS)-ROWS))
    self.scroll[key] = scrollOff
    curY = curY + HEADER_H + HEADER_PAD
    local entries, totalRows
    if not self.collapsed[key] then
        entries, totalRows = layoutItems(invPieces, nil, scrollOff)
    else
        entries = {}
        totalRows = math.ceil(#invPieces / COLS)
    end
    table.insert(sections, {
        key="inventory", label="Inventory", items=invPieces, fromBox=nil,
        headerY=headerY, entries=entries, totalRows=totalRows, scrollOffset=scrollOff,
    })

    self.sections = sections
end

function gameNightBoxSidebar:getSectionAtLocalY(y)
    local result = nil
    for _, section in ipairs(self.sections) do
        if section.headerY <= y then result = section end
    end
    return result
end




function gameNightBoxSidebar:prerender()
    ISPanel.prerender(self)
    local sections = self.sections
    if not sections or #sections == 0 then return end

    local w = self:getWidth()
    local font = UIFont.NewSmall
    local fh = getTextManager():getFontHeight(font)
    local mx = self:getMouseX()
    local my = self:getMouseY()
    local gw = self.gameWindow

    local isDragging = gw and gw.movingPiece ~= nil
    local targetSection = (isDragging and mx >= 0 and mx < w) and self:getSectionAtLocalY(my) or nil

    self:drawRect(0, 0, w, self:getHeight(), 0.25, 0.1, 0.1, 0.1)
    self:drawRectBorder(0, 0, w, self:getHeight(), 0.4, 0.6, 0.6, 0.6)

    self.sidebarSelected = self.sidebarSelected or {}

    local hoveredItem = nil
    local hasSelection = tableHasEntries(self.sidebarSelected)

    for _, section in ipairs(sections) do
        local hy = section.headerY
        local collapsed = self.collapsed[section.key]
        local totalRows = section.totalRows or 0
        local scrollOff = section.scrollOffset or 0
        local isTarget = (section == targetSection)
        local hHovered = mx >= 0 and mx < w and my >= hy and my < hy + HEADER_H

        local hBg = isTarget and 0.45 or (hHovered and 0.35 or 0.2)
        self:drawRect(0, hy, w, HEADER_H, 0.9, hBg, hBg, isTarget and hBg * 1.6 or hBg)
        if isTarget then
            self:drawRectBorder(0, hy, w, HEADER_H, 0.9, 0.3, 0.55, 1.0)
        end

        local fillSum, fillCount = 0, 0
        for _, sItem in ipairs(section.items) do
            local act = self.activeTransfers[sItem:getID()]
            if act then
                fillSum = fillSum + math.min(1, (act.jobDelta or 0) / math.max(1, act.maxTime or 50))
                fillCount = fillCount + 1
            end
        end
        for _, act in pairs(self.activeTransfers) do
            if act.sectionKey == section.key then
                fillSum = fillSum + math.min(1, (act.jobDelta or 0) / math.max(1, act.maxTime or 30))
                fillCount = fillCount + 1
            end
        end
        if fillCount > 0 then
            local fill = fillSum / fillCount
            self:drawRect(0, hy, math.max(1, math.floor(w * fill)), HEADER_H, 0.35, 0.1, 0.5, 0.25)
        end

        self:drawText(collapsed and ">" or "v", w - 12, hy + (HEADER_H - fh) / 2, 1, 1, 1, 0.7, font)
        local label = section.label
        while #label > 1 and getTextManager():MeasureStringX(font, label) > (w - 18) do
            label = label:sub(1, -2)
        end
        self:drawText(label, 4, hy + (HEADER_H - fh) / 2, 1, 1, 1, 0.85, font)

        if not collapsed and #section.entries > 0 then
            local gridY = hy + HEADER_H + HEADER_PAD
            self:setStencilRect(0, gridY, w, ROWS * CELL_W)
            for _, entry in ipairs(section.entries) do
                if entry.tex then
                    local ix = EDGE_PAD + entry.col * CELL_W
                    local iy = entry.iy
                    local hov = mx >= ix and mx < ix + ICON_SIZE and my >= iy and my < iy + ICON_SIZE
                    local selected = self.sidebarSelected[entry.item] ~= nil

                    if selected then
                        self:drawRect(ix-1, iy-1, ICON_SIZE+2, ICON_SIZE+2, 0.45, 0.15, 0.45, 0.85)
                        self:drawRectBorder(ix-1, iy-1, ICON_SIZE+2, ICON_SIZE+2, 1, 0.3, 0.6, 1.0)
                    elseif hov then
                        self:drawRect(ix-1, iy-1, ICON_SIZE+2, ICON_SIZE+2, 0.35, 0.4, 0.6, 0.9)
                    end

                    local alpha = hov and 1.0 or 0.8
                    self:drawTextureScaledAspect(entry.tex, ix, iy, ICON_SIZE, ICON_SIZE, 1, 1, 1, alpha)

                    local act = self.activeTransfers[entry.item:getID()]
                    if act then
                        local prog = math.min(1, (act.jobDelta or 0) / math.max(1, act.maxTime or 50))
                        self:drawRectBorder(ix-1, iy-1, ICON_SIZE+2, ICON_SIZE+2, 0.9, 0.2, 0.85, 0.5)
                        self:drawRect(ix, iy+ICON_SIZE-3, ICON_SIZE, 3, 0.8, 0, 0, 0)
                        self:drawRect(ix, iy+ICON_SIZE-3, math.max(1, math.floor(ICON_SIZE*prog)), 3, 0.9, 0.2, 0.85, 0.3)
                    end

                    if hov then hoveredItem = entry.item end
                end
            end
            self:clearStencilRect()

            if totalRows > ROWS then
                local trackH = ROWS * CELL_W
                local thumbH = math.max(4, math.floor(trackH * ROWS / totalRows))
                local thumbY = gridY + math.floor((trackH - thumbH) * scrollOff / math.max(1, totalRows - ROWS))
                self:drawRect(w - 5, thumbY, 3, thumbH, 0.7, 1, 1, 1)
            end
        end
    end
    
    if hoveredItem then
        local lbl = hoveredItem:getDisplayName() or hoveredItem:getName() or ""
        local count = gamePieceHandler.getDisplayCount(hoveredItem)
        if count then lbl = lbl .. " [" .. count .. "]" end
        local tw = getTextManager():MeasureStringX(font, " " .. lbl .. " ")
        self:drawRect(-tw-4, my-fh, tw, fh, 0.85, 0, 0, 0)
        self:drawText(" " .. lbl .. " ", -tw-4, my-fh, 1, 1, 1, 0.9, font)
    end
end

function gameNightBoxSidebar:render()
    ISPanel.render(self)
end




function gameNightBoxSidebar:onMouseDown(x, y)
    self.sidebarSelected = self.sidebarSelected or {}

    for _, section in ipairs(self.sections) do
        if y >= section.headerY and y < section.headerY + HEADER_H then
            self.collapsed[section.key] = not self.collapsed[section.key]
            return
        end
    end

    local function rangeSelect(section, anchorItem, targetItem)
        local anchorIdx, targetIdx
        for i, it in ipairs(section.items) do
            if it == anchorItem then anchorIdx = i end
            if it == targetItem  then targetIdx = i end
        end
        if not anchorIdx or not targetIdx then return false end
        local lo, hi = math.min(anchorIdx, targetIdx), math.max(anchorIdx, targetIdx)
        for i = lo, hi do
            local it = section.items[i]
            self.sidebarSelected[it] = { item = it, fromBox = section.fromBox }
        end
        return true
    end

    for _, section in ipairs(self.sections) do
        if not self.collapsed[section.key] then
            for _, entry in ipairs(section.entries) do
                local ix = EDGE_PAD + entry.col * CELL_W
                if x >= ix and x < ix + ICON_SIZE and y >= entry.iy and y < entry.iy + ICON_SIZE then

                    if isAltKeyDown() and isShiftKeyDown() then
                        if self.selectionAnchor then
                            if not rangeSelect(section, self.selectionAnchor, entry.item) then
                                self.sidebarSelected[entry.item] = { item = entry.item, fromBox = entry.fromBox }
                            end
                        else
                            self.sidebarSelected[entry.item] = { item = entry.item, fromBox = entry.fromBox }
                            self.selectionAnchor = entry.item
                        end
                        return
                    end

                    if isAltKeyDown() then
                        if self.sidebarSelected[entry.item] then
                            self.sidebarSelected[entry.item] = nil
                        else
                            self.sidebarSelected[entry.item] = { item = entry.item, fromBox = entry.fromBox }
                        end
                        self.selectionAnchor = entry.item
                        return
                    end

                    if isShiftKeyDown() and self.selectionAnchor then
                        if not rangeSelect(section, self.selectionAnchor, entry.item) then
                            self.sidebarSelected[entry.item] = { item = entry.item, fromBox = entry.fromBox }
                        end
                        return
                    end

                    local isInSelection = self.sidebarSelected[entry.item] ~= nil
                    local hasAnySelection = tableHasEntries(self.sidebarSelected)

                    if isInSelection and hasAnySelection then
                        local group = {}
                        for _, sel in pairs(self.sidebarSelected) do
                            if sel.item ~= entry.item then
                                table.insert(group, sel)
                            end
                        end
                        self:clearSelection()
                        self:pickUpItem(entry.item, entry.fromBox, group)
                    else
                        self:clearSelection()
                        self.selectionAnchor = entry.item
                        self:pickUpItem(entry.item, entry.fromBox)
                    end
                    return
                end
            end
        end
    end

end

function gameNightBoxSidebar:onMouseUp(x, y)
    local gw = self.gameWindow
    if gw and gw.movingPiece then
        local item = gw.movingPiece
        local fromBox = gw.movingPieceFromBox
        local dragGroup = self.sidebarDragGroup
        local section = self:getSectionAtLocalY(y)

        if item:getWorldItem() then
            self:receiveItem(item)
            gw.movingPiece = nil
            gw.movingPieceFromBox = nil
            gw.moveWithMouse = false
            self.sidebarDragGroup = nil
            ISPanel.onMouseUp(self, x, y)
            return
        end

        if section then
            local playerInv = self.player:getInventory()

            local function queueOne(it, fBox)
                if section.fromBox then
                    local toInv = section.fromBox:getItem() and section.fromBox:getItem():getInventory()
                    if toInv then
                        if fBox and fBox ~= section.fromBox then
                            local fromInv = fBox:getItem() and fBox:getItem():getInventory()
                            if fromInv then
                                ISTimedActionQueue.add(GameNightTransfer:new(self.player, it, fromInv, toInv, self))
                            end
                        elseif not fBox and playerInv:contains(it) then
                            ISTimedActionQueue.add(GameNightTransfer:new(self.player, it, playerInv, toInv, self))
                        end
                    end
                elseif fBox then
                    local fromInv = fBox:getItem() and fBox:getItem():getInventory()
                    if fromInv then
                        ISTimedActionQueue.add(GameNightTransfer:new(self.player, it, fromInv, playerInv, self))
                    end
                end
            end

            queueOne(item, fromBox)

            if dragGroup then
                for _, sel in ipairs(dragGroup) do
                    queueOne(sel.item, sel.fromBox)
                end
            end

            if gw.selection then
                for _, sel in pairs(gw.selection) do
                    local selItem = sel and sel.item
                    if selItem and selItem ~= item then
                        local selFromBox = nil
                        for _, sec in ipairs(self.sections) do
                            if sec.fromBox then
                                local bInv = sec.fromBox:getItem() and sec.fromBox:getItem():getInventory()
                                if bInv and bInv:contains(selItem) then
                                    selFromBox = sec.fromBox
                                    break
                                end
                            end
                        end
                        queueOne(selItem, selFromBox)
                    end
                end
            end
        end

        gw.movingPiece = nil
        gw.movingPieceFromBox = nil
        gw.moveWithMouse = false
        gw.elementsDirty = true
        self.sidebarDragGroup = nil
    end
    ISPanel.onMouseUp(self, x, y)
end

function gameNightBoxSidebar:onMouseUpOutside(x, y)
    local gw = self.gameWindow
    if gw and gw.movingPiece then
        local dragGroup = self.sidebarDragGroup
        local mx, my = gw:getMouseX(), gw:getMouseY()

        local boundW = gw.width  - (gw.padding or 0) * 2
        local boundH = gw.height - (gw.padding or 0) * 2
        local function fuzzedPos(i)
            if i <= 1 then return mx, my end
            return mx + ZombRandFloat(-0.02, 0.02) * boundW,
                   my + ZombRandFloat(-0.02, 0.02) * boundH
        end

        local fx, fy = fuzzedPos(1)
        gw:processMouseUp(function() end, fx, fy)

        if dragGroup then
            for i, sel in ipairs(dragGroup) do
                gw.movingPiece = sel.item
                gw.movingPieceFromBox = sel.fromBox
                local gx, gy = fuzzedPos(i + 1)
                gw:processMouseUp(function() end, gx, gy)
            end
            gw.movingPiece = nil
            gw.movingPieceFromBox = nil
        end

        self.sidebarDragGroup = nil
    end
    ISPanel.onMouseUpOutside(self, x, y)
end

function gameNightBoxSidebar:onRightMouseDown(x, y)
    for _, section in ipairs(self.sections) do
        if not self.collapsed[section.key] then
            for _, entry in ipairs(section.entries) do
                local ix = EDGE_PAD + entry.col * CELL_W
                if x >= ix and x < ix + ICON_SIZE and y >= entry.iy and y < entry.iy + ICON_SIZE then
                    ISInventoryPaneContextMenu.createMenu(
                        self.player:getPlayerNum(), entry.fromBox == nil, {entry.item}, getMouseX(), getMouseY())
                    return
                end
            end
        end
    end
    ISPanel.onRightMouseDown(self, x, y)
end

function gameNightBoxSidebar:onMouseWheel(del)
    local section = self:getSectionAtLocalY(self:getMouseY())
    if section and not self.collapsed[section.key] then
        local maxScroll = math.max(0, (section.totalRows or 0) - ROWS)
        self.scroll[section.key] = math.max(0, math.min(maxScroll, (self.scroll[section.key] or 0) + del))
    end
    return true
end




function gameNightBoxSidebar:takeFromBox(item, boxWorldItem)
    local boxInv = boxWorldItem:getItem():getInventory()
    if not boxInv then return end
    boxInv:Remove(item)
    self.player:getInventory():AddItem(item)
    gamePieceHandler.refreshInventory(self.player)
end

---@param item InventoryItem
---@param fromBox IsoWorldInventoryObject|nil
---@param group table|nil List of { item, fromBox } for additional selected items
function gameNightBoxSidebar:pickUpItem(item, fromBox, group)
    local gw = self.gameWindow
    if not gw then return end

    self.sidebarDragGroup = (group and #group > 0) and group or nil

    gw.movingPieceFromBox = fromBox
    local mx = getMouseX() - gw:getAbsoluteX()
    local my = getMouseY() - gw:getAbsoluteY()
    gw.elements[item:getID()] = {
        x=mx, y=my, w=ICON_SIZE, h=ICON_SIZE,
        rot=0, priority=0, item=item, locked=false,
        tex=item:getTexture(),
    }
    gw.movingPiece = item
    gw.movingPieceOriginStamp = gamePieceHandler.itemCoolDown(item)
    gw.moveWithMouse = false

    if group then
        for _, sel in ipairs(group) do
            gw.elements[sel.item:getID()] = {
                x=mx, y=my, w=ICON_SIZE, h=ICON_SIZE,
                rot=0, priority=0, item=sel.item, locked=false,
                tex=sel.item:getTexture(),
            }
        end
    end
end


function gameNightBoxSidebar:receiveItem(item)
    local localY = self:getMouseY()
    local section = self:getSectionAtLocalY(localY)
    local gw = self.gameWindow
    local sKey = section and section.key or "inventory"
    local playerInv = self.player:getInventory()

    local function handleOne(it)
        if section and section.fromBox then
            gamePieceHandler.pickupGamePiece(self.player, it)
            local boxInv = section.fromBox:getItem() and section.fromBox:getItem():getInventory()
            if boxInv then
                ISTimedActionQueue.add(GameNightTransfer:new(self.player, it, playerInv, boxInv, self))
            end
        elseif it:getWorldItem() then
            ISTimedActionQueue.add(GameNightPickup:new(self.player, it, self, sKey))
        end
    end

    handleOne(item)
    if gw and gw.selection then
        for _, sel in pairs(gw.selection) do
            local selItem = sel and sel.item
            if selItem and selItem ~= item and selItem:getWorldItem() then
                handleOne(selItem)
            end
        end
    end
    if gw then gw.elementsDirty = true end
end

function gameNightBoxSidebar:containsPoint(absX, absY)
    local ax = self:getAbsoluteX()
    local ay = self:getAbsoluteY()
    return absX >= ax and absX <= ax + self:getWidth()
       and absY >= ay and absY <= ay + self:getHeight()
end




function gameNightBoxSidebar:close()
    gameNightBoxSidebar.instance = nil
    self:setVisible(false)
    self:removeFromUIManager()
end

function gameNightBoxSidebar.open(player, gameWindow)
    local existing = gameNightBoxSidebar.instance
    if existing then existing:close() end
    local o = gameNightBoxSidebar:new(player, gameWindow)
    o:initialise()
    o:addToUIManager()
    o:setVisible(true)
    gameNightBoxSidebar.instance = o
    return o
end
