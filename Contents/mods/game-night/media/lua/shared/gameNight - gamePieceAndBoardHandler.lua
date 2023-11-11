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
        shiftAction = "flipPiece",
    },
    ["Base.GamePieceBlack"]={
        actions = { flipPiece=true },
        shiftAction = "flipPiece",
    },

    ["Base.BackgammonBoard"]={ category = "GameBoard", textureSize = {266,270} },
    ["Base.CheckerBoard"]={ category = "GameBoard", textureSize = {266,270} },
    ["Base.ChessBoard"]={ category = "GameBoard", textureSize = {266,270} },

    ["Base.PokerChips"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsBlue"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsYellow"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsWhite"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsBlack"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsOrange"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsPurple"]={ weight = 0.003, canStack=50 },
    ["Base.PokerChipsGreen"]={ weight = 0.003, canStack=50 },
}


function gamePieceAndBoardHandler.generateContextMenuFromSpecialActions(context, player, gamePiece)
    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceAndBoardHandler.specials[fullType]
    if specialCase and specialCase.actions then
        for func,args in pairs(specialCase.actions) do
            if gamePieceAndBoardHandler[func] then context:addOptionOnTop(getText("IGUI_"..func), gamePiece, gamePieceAndBoardHandler[func], player, args) end
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


function gamePieceAndBoardHandler.unstack(gamePiece, numberOf, locations)
    --sq=sq, offsets={x=wiX,y=wiY,z=wiZ}, container=container

    local newPiece = InventoryItemFactory.CreateItem(gamePiece:getType())
    if newPiece then

        numberOf = numberOf or 1
        newPiece:getModData()["gameNight_stacked"] = numberOf
        gamePiece:getModData()["gameNight_stacked"] = gamePiece:getModData()["gameNight_stacked"]-numberOf

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or gamePiece:getWorldItem()

        local wiX = (locations and locations.offsets and locations.offsets.x) or (worldItem and (worldItem:getWorldPosX()-worldItem:getX())) or 0
        local wiY = (locations and locations.offsets and locations.offsets.y) or (worldItem and (worldItem:getWorldPosY()-worldItem:getY())) or 0
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

    local unStack = context:addOptionOnTop(getText("IGUI_take"), gamePiece, gamePieceAndBoardHandler.unstack, 1)

    local subDrawMenu = ISContextMenu:getNew(context)
    context:addSubMenu(unStack, subDrawMenu)

    for i=1, 25, 5 do
        if stack >= i then
            local option = subDrawMenu:addOption(getText("IGUI_takeMore", i), gamePiece, gamePieceAndBoardHandler.unstack, i)
        end
    end
end


function gamePieceAndBoardHandler.applyScriptChanges()

    local scriptManager = getScriptManager()

    for _,scriptType in pairs(gamePieceAndBoardHandler.itemTypes) do
        local special = gamePieceAndBoardHandler.specials[scriptType]
        local script = scriptManager:getItem(scriptType)
        if script then
            local newCategory = special and special.category or "GamePiece"
            if newCategory then script:DoParam("DisplayCategory = "..newCategory) end

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

    gamePiece:getModData()["gameNight_sound"] = "pieceMove"

    local canStack = gamePieceAndBoardHandler.canStackPiece(gamePiece)
    if canStack and not gamePiece:getModData()["gameNight_stacked"] then
        if type(canStack)~="number" then canStack = 1 end
        gamePiece:getModData()["gameNight_stacked"] = stackInit and canStack or 1
    end

    local stack = gamePiece:getModData()["gameNight_stacked"]
    local name_suffix = stack and stack>1 and " ["..stack.."]" or ""
    gamePiece:setName(gamePiece:getScriptItem():getDisplayName()..name_suffix)
    gamePiece:setActualWeight(gamePiece:getScriptItem():getActualWeight()*(stack or 1))

    local altState = gamePiece:getModData()["gameNight_altState"] or ""

    local texturePath = "Item_InPlayTextures/"..gamePiece:getType()..altState..".png"
    local texture = Texture.trygetTexture(texturePath)
    if texture then gamePiece:getModData()["gameNight_textureInPlay"] = texture end

    local iconPath = "Item_OutOfPlayTextures/"..gamePiece:getType()..altState..".png"
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
    playerInv:setDrawDirty(true)
    playerInv:AddItem(item)

    local playerNum = player:getPlayerNum()
    local pdata = getPlayerData(playerNum)
    if pdata ~= nil then ISInventoryPage.renderDirty = true end

    return true, zPos, xOffset, yOffset
end


---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
---@param xOffset number
---@param yOffset number
function gamePieceAndBoardHandler.placeGamePiece(player, item, worldItemSq, xOffset, yOffset, zPos)
    ---@type IsoWorldInventoryObject|IsoObject
    local placedItem = IsoWorldInventoryObject.new(item, worldItemSq, xOffset, yOffset, zPos)
    if placedItem then

        local itemCont = player:getInventory()

        itemCont:setDrawDirty(true)

        placedItem:setName(item:getName())
        placedItem:setKeyId(item:getKeyId())

        worldItemSq:getObjects():add(placedItem)
        worldItemSq:getWorldObjects():add(placedItem)
        worldItemSq:getChunk():recalcHashCodeObjects()

        item:setWorldItem(placedItem)
        item:setWorldZRotation(0)

        placedItem:addToWorld()
        placedItem:setIgnoreRemoveSandbox(true)
        placedItem:transmitCompleteItemToServer()
        placedItem:getModData().gameNightCoolDown = getTimestampMs()+750
        placedItem:transmitModData()

        itemCont:Remove(item)

        ISInventoryPage.renderDirty = true

        local playerNum = player:getPlayerNum()
        local inventory = getPlayerInventory(playerNum)
        if inventory then inventory:refreshBackpacks() end
        local loot = getPlayerLoot(playerNum)
        if loot then loot:refreshBackpacks() end
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

    local pickedUp, x, y, z = gamePieceAndBoardHandler.pickupGamePiece(player, item, onPickUp)

    zPos = zPos or x or 0
    xOffset = xOffset or y or 0
    yOffset = yOffset or z or 0

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
    result = result>1 and result or ""
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
    gamePieceAndBoardHandler.playSound(gamePiece, player, "dieRoll")
end


function gamePieceAndBoardHandler.flipPiece(gamePiece, player)
    local current = gamePiece:getModData()["gameNight_altState"]
    local result = "Flipped"
    if current then result = nil end
    gamePieceAndBoardHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
end

return gamePieceAndBoardHandler