local gamePieceAndBoardHandler = {}

gamePieceAndBoardHandler.itemTypes = {
    "Base.Dice", "Base.GamePieceWhite", "Base.GamePieceRed",
    "Base.GamePieceBlack", "Base.BackgammonBoard", "Base.CheckerBoard",
    "Base.ChessWhite","Base.ChessBlack","Base.PokerChips",

    --added
    "Base.DiceWhite",

    "Base.PokerChipsBlue","Base.PokerChipsYellow","Base.PokerChipsWhite","Base.PokerChipsBlack",
    "Base.PokerChipsOrange","Base.PokerChipsPurple","Base.PokerChipsGreen",

    "Base.GamePieceBlackBackgammon","Base.ChessBoard",
    "Base.ChessWhiteKing","Base.ChessBlackKing","Base.ChessWhiteBishop","Base.ChessBlackBishop",
    "Base.ChessWhiteQueen", "Base.ChessBlackQueen", "Base.ChessWhiteRook","Base.ChessBlackRook",
    "Base.ChessWhiteKnight", "Base.ChessBlackKnight",

    "Base.StellaOcta","Base.Dice4", "Base.Dice6", "Base.Dice8", "Base.Dice10", "Base.Dice12", "Base.Dice20",
}


function gamePieceAndBoardHandler.registerTypes(args)
    for _,t in pairs(args) do table.insert(gamePieceAndBoardHandler.itemTypes, t) end
    gamePieceAndBoardHandler.generate_itemTypes()
end

function gamePieceAndBoardHandler.registerSpecial(itemFullType, special)
    if (not getScriptManager():getItem(itemFullType)) then print("ERROR: GameNight: addSpecial: "..itemFullType.." is invalid.") return end
    if (not special) or (type(special)~="table") then print("ERROR: GameNight: addSpecial: special is not table.") return end
    gamePieceAndBoardHandler.specials[itemFullType] = special
end

gamePieceAndBoardHandler._itemTypes = nil
function gamePieceAndBoardHandler.generate_itemTypes()
    gamePieceAndBoardHandler._itemTypes = {}
    for _,itemType in pairs(gamePieceAndBoardHandler.itemTypes) do gamePieceAndBoardHandler._itemTypes[itemType] = true end
end

gamePieceAndBoardHandler.specials = {
    ["Base.Dice"]={
        category = "Die",
        actions = { rollDie=6 },
        shiftAction = "rollDie",
    },
    ["Base.DiceWhite"]={
        category = "Die",
        actions = { rollDie=6 },
        shiftAction = "rollDie",
    },

    ["Base.GamePieceRed"]={
        actions = { flipPiece=true },
        altState="GamePieceRedFlipped",
        shiftAction = "flipPiece",
    },
    ["Base.GamePieceBlack"]={
        actions = { flipPiece=true },
        altState="GamePieceBlackFlipped",
        shiftAction = "flipPiece",
    },

    ["Base.BackgammonBoard"]={ category = "GameBoard", textureSize = {532,540} },
    ["Base.CheckerBoard"]={ category = "GameBoard", textureSize = {532,540} },
    ["Base.ChessBoard"]={ category = "GameBoard", textureSize = {532,540} },

    ["Base.PokerChips"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsBlue"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsYellow"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsWhite"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsBlack"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsOrange"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsPurple"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsGreen"]={ weight = 0.003, canStack=50 },
}


---Because I hate copy pasted code - this iterates through the side values and registers their special actions.
local sides = {4,6,8,10,12,20}
for _,side in pairs(sides) do
    gamePieceAndBoardHandler.registerSpecial("Base.Dice"..side, { addTextureDir = "dice/", actions = { rollDie=side }, shiftAction = "rollDie", })
end

gamePieceAndBoardHandler.registerSpecial("Base.StellaOcta", { actions = { rollDie=1 }, shiftAction = "rollDie", })



function gamePieceAndBoardHandler.parseTopOfStack(stack)
    if instanceof(stack, "InventoryItem") then return stack, false end
    if #stack.items==2 then return stack.items[2], false end
    return stack.items[1], stack
end


function gamePieceAndBoardHandler.bypassForStacks(stack, player, func, args, source)
    if instanceof(stack, "InventoryItem") then return end
    for i=2, #stack.items do
        local item = stack.items[i]
        source[func](item, player, args)
    end
end


gamePieceAndBoardHandler.specialContextIcons = {}
function gamePieceAndBoardHandler.generateContextMenuFromSpecialActions(context, player, item, altSource)
    altSource = altSource or gamePieceAndBoardHandler
    local gamePiece, pieceStack = gamePieceAndBoardHandler.parseTopOfStack(item)
    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceAndBoardHandler.specials[fullType]
    if specialCase and specialCase.actions then
        for func,args in pairs(specialCase.actions) do
            if altSource[func] then
                local option
                if not pieceStack then
                    option = context:addOptionOnTop(getText("IGUI_"..func), gamePiece, altSource[func], player, args)

                else
                    option = context:addOptionOnTop(getText("IGUI_"..func)..getText("IGUI_SpecialActionAll"), pieceStack, gamePieceAndBoardHandler.bypassForStacks, player, func, args, altSource)
                end
                if option then
                    local ico = gamePieceAndBoardHandler.specialContextIcons[func]
                    if not ico then
                        ico = getTexture("media/textures/actionIcons/"..func..".png")
                        gamePieceAndBoardHandler.specialContextIcons[func] = ico
                    end
                    if ico then option.iconTexture = ico end
                end
            end
        end
    end
end


---@param inventoryItem InventoryItem
function gamePieceAndBoardHandler.safelyRemoveGamePiece(inventoryItem)
    local worldItem = inventoryItem:getWorldItem()
    if worldItem then
        ---@type IsoGridSquare
        local sq = worldItem:getSquare()
        if sq then
            sq:transmitRemoveItemFromSquare(worldItem)
            sq:removeWorldObject(worldItem)
            inventoryItem:setWorldItem(nil)
        end
    end
    ---@type ItemContainer
    local container = inventoryItem:getContainer()
    if container then container:DoRemoveItem(inventoryItem) end
end


function gamePieceAndBoardHandler.isGamePiece(gamePiece) return gamePieceAndBoardHandler._itemTypes[gamePiece:getFullType()] end


function gamePieceAndBoardHandler.canStackPiece(gamePiece)
    return (gamePieceAndBoardHandler.specials[gamePiece:getFullType()] and gamePieceAndBoardHandler.specials[gamePiece:getFullType()].canStack)
end


function gamePieceAndBoardHandler.canUnstackPiece(gamePiece)
    return (gamePieceAndBoardHandler.canStackPiece(gamePiece) and gamePiece:getModData()["gameNight_stacked"] and gamePiece:getModData()["gameNight_stacked"] > 1)
end


function gamePieceAndBoardHandler.unstack(gamePiece, numberOf, player, locations)
    --sq=sq, offsets={x=wiX,y=wiY,z=wiZ}, container=container

    local newPiece = InventoryItemFactory.CreateItem(gamePiece:getType())
    if newPiece then

        numberOf = numberOf or 1
        newPiece:getModData()["gameNight_stacked"] = numberOf
        gamePiece:getModData()["gameNight_stacked"] = gamePiece:getModData()["gameNight_stacked"]-numberOf

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or gamePiece:getWorldItem()

        local x, y = gamePieceAndBoardHandler.shiftPieceSlightly(gamePiece)

        local wiX = (locations and locations.offsets and locations.offsets.x) or (x) or 0
        local wiY = (locations and locations.offsets and locations.offsets.y) or (y) or 0
        local wiZ = (locations and locations.offsets and locations.offsets.z) or (worldItem and (worldItem:getWorldPosZ()-worldItem:getZ())) or 0

        ---@type IsoGridSquare
        local sq = (locations and locations.sq) or (worldItem and worldItem:getSquare())
        if sq then
            sq:AddWorldInventoryItem(newPiece, wiX, wiY, wiZ)
        else
            ---@type ItemContainer
            local container = (locations and locations.container) or gamePiece:getContainer()
            if container then container:AddItem(newPiece) end
        end

        gamePieceAndBoardHandler.handleDetails(gamePiece)
        gamePieceAndBoardHandler.handleDetails(newPiece)
        gamePieceAndBoardHandler.refreshInventory(player)

        return gamePiece
    end
end


function gamePieceAndBoardHandler._tryStack(gamePieceA, gamePieceB)
    if not gamePieceAndBoardHandler.canStackPiece(gamePieceA) or not gamePieceAndBoardHandler.canStackPiece(gamePieceB) then return end
    local aStack = (gamePieceA:getModData()["gameNight_stacked"] or 1)
    gamePieceB:getModData()["gameNight_stacked"] = (gamePieceB:getModData()["gameNight_stacked"] or 1) + aStack
    gamePieceAndBoardHandler.safelyRemoveGamePiece(gamePieceA)
end
---@param gamePieceA InventoryItem
---@param gamePieceB InventoryItem
function gamePieceAndBoardHandler.tryStack(gamePieceA, gamePieceB, player)
    if gamePieceA:getFullType() ~= gamePieceB:getFullType() then return end
    gamePieceAndBoardHandler.pickupGamePiece(player, gamePieceA, true)
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePieceB, {gamePieceAndBoardHandler._tryStack, gamePieceA, gamePieceB})
    gamePieceAndBoardHandler.playSound(gamePieceB, player)
end


function gamePieceAndBoardHandler.generateContextMenuForStacking(context, player, gamePiece)
    if not gamePieceAndBoardHandler.canUnstackPiece(gamePiece) then return end

    local stack = gamePiece:getModData()["gameNight_stacked"] and gamePiece:getModData()["gameNight_stacked"]>1 and gamePiece:getModData()["gameNight_stacked"]
    if not stack then return end

    local unStack = context:addOptionOnTop(getText("IGUI_take"), gamePiece, gamePieceAndBoardHandler.unstack, 1, player)

    local subDrawMenu = ISContextMenu:getNew(context)
    context:addSubMenu(unStack, subDrawMenu)

    for i=1, 25, 5 do if stack >= i then
        local option = subDrawMenu:addOption(getText("IGUI_takeMore", i), gamePiece, gamePieceAndBoardHandler.unstack, i, player)
    end end
end


function gamePieceAndBoardHandler.applyScriptChanges()

    local scriptManager = getScriptManager()

    for _,scriptType in pairs(gamePieceAndBoardHandler.itemTypes) do

        local special = gamePieceAndBoardHandler.specials[scriptType]
        local script = scriptManager:getItem(scriptType)
        if script then

            local newCategory = special and special.category or "GamePiece"
            if newCategory then
                script:DoParam("DisplayCategory = "..newCategory)
            end

            local iconPath = "OutOfPlayTextures/"..script:getName()..".png"
            local icon = Texture.trygetTexture("Item_"..iconPath)
            if icon then script:DoParam("Icon = "..iconPath) end

            local tags = script:getTags()
            if not tags:contains("gameNight") then tags:add("gameNight") end

            local weight = special and special.weight or 0.01
            script:DoParam("Weight = "..weight)
        end
    end

end


---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.handleDetails(gamePiece, stackInit)

    local fullType = gamePiece:getFullType()

    if not gamePieceAndBoardHandler._itemTypes then gamePieceAndBoardHandler.generate_itemTypes() end
    if not gamePieceAndBoardHandler._itemTypes[fullType] then return end

    local special = gamePieceAndBoardHandler.specials[fullType]
    local newCategory = special and special.category or "GamePiece"
    if newCategory then gamePiece:setDisplayCategory(newCategory) end

    gamePiece:getModData()["gameNight_sound"] = special and special.moveSound or "pieceMove"

    local canStack = gamePieceAndBoardHandler.canStackPiece(gamePiece)
    if canStack and not gamePiece:getModData()["gameNight_stacked"] then
        if type(canStack)~="number" then canStack = 1 end
        gamePiece:getModData()["gameNight_stacked"] = stackInit and canStack or 1
    end

    local stack = gamePiece:getModData()["gameNight_stacked"]
    local name_suffix = stack and stack>1 and " ["..stack.."]" or ""
    gamePiece:setName(gamePiece:getScriptItem():getDisplayName()..name_suffix)
    gamePiece:setActualWeight(gamePiece:getScriptItem():getActualWeight()*(stack or 1))

    local iconState = gamePiece:getModData()["gameNight_altState"] or gamePiece:getType()

    local additionalTextureDir = special and special.addTextureDir or ""

    local texturePath = "Item_InPlayTextures/"..additionalTextureDir..iconState..".png"
    local texture = Texture.trygetTexture(texturePath)
    if texture then gamePiece:getModData()["gameNight_textureInPlay"] = texture end

    local iconPath = "Item_OutOfPlayTextures/"..additionalTextureDir..iconState..".png"
    local icon = Texture.trygetTexture(iconPath)
    if icon then gamePiece:setTexture(icon) end

end


---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.playSound(gamePiece, player, sound)
    if not player then return end
    sound = sound or gamePiece:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end
end


function gamePieceAndBoardHandler.setModDataValue(gamePiece, key, value)
    gamePiece:getModData()[key] = value
end

---@param item InventoryItem
function gamePieceAndBoardHandler.pickupGamePiece(player, item)

    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = item:getWorldItem()
    ---@type IsoGridSquare
    local worldItemSq = worldItem and worldItem:getSquare()

   -- if worldItem == nil or worldItemSq == nil then return end

    ---@type IsoGridSquare
    local playerSq = player:getSquare()

    if worldItemSq and playerSq and worldItemSq:isBlockedTo(playerSq) then return end

    local zPos = worldItem and worldItem:getWorldPosZ()-worldItem:getZ() or 0
    local xOffset = worldItem and worldItem:getWorldPosX()-worldItem:getX() or 0
    local yOffset = worldItem and worldItem:getWorldPosY()-worldItem:getY() or 0

    if worldItem and worldItemSq and worldItemSq:getWorldObjects():contains(worldItem) then
        worldItemSq:transmitRemoveItemFromSquare(worldItem)
        worldItem:removeFromWorld()
        worldItem:removeFromSquare()
        worldItem:setSquare(nil)
        item:setWorldItem(nil)
    end

    ---@type ItemContainer
    local playerInv = player:getInventory()
    local itemContainer = item:getContainer()
    local pickedUp = false

    if (not worldItem) and itemContainer ~= playerInv then

        if isClient() and not itemContainer:isInCharacterInventory(player) and itemContainer:getType()~="floor" then itemContainer:removeItemOnServer(item) end
        itemContainer:DoRemoveItem(item)
        itemContainer:setDrawDirty(true)

        playerInv:setDrawDirty(true)
        playerInv:AddItem(item)
        pickedUp = true

        local playerNum = player:getPlayerNum()
        local pdata = getPlayerData(playerNum)
        if pdata ~= nil then ISInventoryPage.renderDirty = true end
    end

    return pickedUp, xOffset, yOffset, zPos
end


function gamePieceAndBoardHandler.refreshInventory(player)
    ISInventoryPage.renderDirty = true
    local playerNum = player:getPlayerNum()
    local inventory = getPlayerInventory(playerNum)
    if inventory then inventory:refreshBackpacks() end
    local loot = getPlayerLoot(playerNum)
    if loot then loot:refreshBackpacks() end
end


function gamePieceAndBoardHandler.shiftPieceSlightly(gamePiece, offset)
    local worldItem = gamePiece:getWorldItem()
    if not worldItem then return 0, 0 end
    local xOffset = worldItem and worldItem:getWorldPosX()-worldItem:getX() or 0
    local yOffset = worldItem and worldItem:getWorldPosY()-worldItem:getY() or 0

    offset = offset or 0.02

    xOffset = xOffset+ZombRandFloat(0-offset,offset)
    yOffset = yOffset+ZombRandFloat(0-offset,offset)

    return xOffset, yOffset
end

gamePieceAndBoardHandler.coolDown = (isClient() or isServer()) and 750 or 5

---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
---@param xOffset number
---@param yOffset number
function gamePieceAndBoardHandler.placeGamePiece(player, item, worldItemSq, xOffset, yOffset, zPos)

    local itemCont = item:getContainer()
    local playerInventory = player:getInventory()

    ---@type IsoWorldInventoryObject|IsoObject
    local placedItem = IsoWorldInventoryObject.new(item, worldItemSq, xOffset, yOffset, zPos)
    if placedItem then

        local isInPlayer = itemCont and playerInventory and itemCont==playerInventory

        if isInPlayer then
            itemCont:setDrawDirty(true)
            item:setJobDelta(0.0)
            player:removeAttachedItem(item)
            if player:isEquipped(item) then
                player:removeFromHands(item)
                player:removeWornItem(item, false)
            end
            itemCont:Remove(item)
            triggerEvent("OnClothingUpdated", player)
        end

        placedItem:setName(item:getName())
        placedItem:setKeyId(item:getKeyId())

        worldItemSq:getObjects():add(placedItem)
        worldItemSq:getWorldObjects():add(placedItem)
        worldItemSq:getChunk():recalcHashCodeObjects()

        item:setWorldItem(placedItem)
        local rotation = item:getModData()["gameNight_rotation"] or 0
        item:setWorldZRotation(rotation)

        placedItem:addToWorld()
        placedItem:setIgnoreRemoveSandbox(true)
        placedItem:transmitCompleteItemToServer()
        placedItem:getModData().gameNightCoolDown = getTimestampMs()+gamePieceAndBoardHandler.coolDown
        placedItem:transmitModData()

        gamePieceAndBoardHandler.refreshInventory(player)
    end
end


---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
---@param xOffset number
---@param yOffset number
function gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, item, onPickUp, detailsFunc, xOffset, yOffset, zPos, square)

    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = item:getWorldItem()

    ---@type IsoGridSquare
    local worldItemSq = square or worldItem and worldItem:getSquare()

    if worldItem then
        worldItem:getModData().gameNightCoolDown = getTimestampMs()+gamePieceAndBoardHandler.coolDown
        worldItem:transmitModData()
    end

    local pickedUp, x, y, z = gamePieceAndBoardHandler.pickupGamePiece(player, item, onPickUp)

    xOffset = xOffset or x or 0
    yOffset = yOffset or y or 0
    zPos = zPos or z or 0

    if onPickUp and type(onPickUp)=="table" then
        local onCompleteFuncArgs = onPickUp
        local func = onCompleteFuncArgs[1]
        local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = onCompleteFuncArgs[2], onCompleteFuncArgs[3], onCompleteFuncArgs[4], onCompleteFuncArgs[5], onCompleteFuncArgs[6], onCompleteFuncArgs[7], onCompleteFuncArgs[8], onCompleteFuncArgs[9]
        func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    end

    if item then

        detailsFunc = detailsFunc or gamePieceAndBoardHandler.handleDetails
        detailsFunc(item)

        if worldItemSq then

            local pBD = player:getBodyDamage()
            pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-1))

            local sound = item:getModData()["gameNight_sound"]
            if sound then player:getEmitter():playSound(sound) end

            gamePieceAndBoardHandler.placeGamePiece(player, item, worldItemSq, xOffset, yOffset, zPos)
        end
    end
end


function gamePieceAndBoardHandler.rollDie(gamePiece, player, sides)

    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceAndBoardHandler.specials[fullType]
    sides = sides or (specialCase and specialCase.actions and specialCase.actions.rollDie)

    local result = ZombRand(sides)+1
    result = result>1 and gamePiece:getType()..result or ""

    local x, y = gamePieceAndBoardHandler.shiftPieceSlightly(gamePiece)

    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result}, nil, x, y)
    gamePieceAndBoardHandler.playSound(gamePiece, player, "dieRoll")
end


function gamePieceAndBoardHandler.rotatePiece(gamePiece, angleChange, player)
    local current = gamePiece:getModData()["gameNight_rotation"] or 0
    local state = current + angleChange

    if state < 0 then
        state = 360 + state
    elseif state >= 360 then
        state = state - 360
    end

    gamePieceAndBoardHandler.setModDataValue(gamePiece, "gameNight_rotation", state)
end


function gamePieceAndBoardHandler.flipPiece(gamePiece, player)

    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceAndBoardHandler.specials[fullType]
    local result = specialCase and specialCase.altState

    if gamePiece:getModData()["gameNight_altState"] then result = nil end

    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
end

return gamePieceAndBoardHandler