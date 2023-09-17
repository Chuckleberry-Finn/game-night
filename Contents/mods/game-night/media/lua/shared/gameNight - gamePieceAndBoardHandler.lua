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
    ["Base.Dice"]={ category = "Die", actions = { rollDie=6 }, },
    ["Base.DiceWhite"]={ category = "Die", actions = { rollDie=6 }, },

    ["Base.GamePieceRed"]={ actions = { flipPiece=true } },
    ["Base.GamePieceBlack"]={ actions = { flipPiece=true } },

    ["Base.BackgammonBoard"]={ category = "GameBoard" },
    ["Base.CheckerBoard"]={ category = "GameBoard" },
    ["Base.ChessBoard"]={ category = "GameBoard" },

    ["Base.PokerChips"]={ weight = 0.003 },
    ["Base.PokerChipsBlue"]={ weight = 0.003 },
    ["Base.PokerChipsYellow"]={ weight = 0.003 },
    ["Base.PokerChipsWhite"]={ weight = 0.003 },
    ["Base.PokerChipsBlack"]={ weight = 0.003 },
    ["Base.PokerChipsOrange"]={ weight = 0.003 },
    ["Base.PokerChipsPurple"]={ weight = 0.003 },
    ["Base.PokerChipsGreen"]={ weight = 0.003 },
}
--Weight

function gamePieceAndBoardHandler.generateContextMenuFromSpecialActions(context, player, gamePiece)
    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceAndBoardHandler.specials[fullType]
    if specialCase and specialCase.actions then
        for func,args in pairs(specialCase.actions) do
            if gamePieceAndBoardHandler[func] then context:addOptionOnTop(getText("IGUI_"..func), gamePiece, gamePieceAndBoardHandler[func], player, args) end
        end
    end
end


function gamePieceAndBoardHandler.isGamePiece(gamePiece)
    return gamePieceAndBoardHandler._itemTypes[gamePiece:getFullType()]
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
function gamePieceAndBoardHandler.handleDetails(gamePiece)

    local fullType = gamePiece:getFullType()
    if not gamePieceAndBoardHandler._itemTypes then gamePieceAndBoardHandler.generate_itemTypes() end
    if not gamePieceAndBoardHandler._itemTypes[fullType] then return end

    gamePiece:getModData()["gameNight_sound"] = "pieceMove"

    local altState = gamePiece:getModData()["gameNight_altState"] or ""

    local texturePath = "Item_InPlayTextures/"..gamePiece:getType()..altState..".png"
    local texture = Texture.trygetTexture(texturePath)
    if texture then gamePiece:getModData()["gameNight_textureInPlay"] = texture end

    local iconPath = "Item_OutOfPlayTextures/"..gamePiece:getType()..altState..".png"
    local icon = Texture.trygetTexture(iconPath)
    if icon then gamePiece:setTexture(icon) end

    if isClient() then
        local worldItem = gamePiece:getWorldItem()
        if worldItem then worldItem:transmitModData() end
    end
end


---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.playSound(gamePiece, player, sound)
    if not player then return end
    sound = sound or gamePiece:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end
end



function gamePieceAndBoardHandler.pickupAndPlaceGamePiece(item, square, player, xOffset, yOffset)
--[[
    local oldZ = 0
    ---@type IsoObject|IsoWorldInventoryObject
    local worldItemObj = item:getWorldItem()
    if worldItemObj then
        oldZ = worldItemObj:getWorldPosZ()-worldItemObj:getZ()
        --square:transmitRemoveItemFromSquare(worldItemObj)
    end

    local transferAction = ISInventoryTransferAction:new(player, item, item:getContainer(), player:getInventory(), 1)
    transferAction.putSoundTime = getTimestamp() + 100
    ISTimedActionQueue.add(transferAction)

    local sound = item:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end

    --return square:AddWorldInventoryItem(item, xOffset, yOffset, oldZ)

    local dropAction = ISDropWorldItemAction:new(player, item, square, xOffset, yOffset, oldZ, 0, false)
    dropAction.maxTime = 1
    ISTimedActionQueue.addAfter(transferAction, dropAction)
--]]

    ---@type IsoObject|IsoWorldInventoryObject
    local worldItemObj = item:getWorldItem()

    local oldZ = 0
    if worldItemObj then
        oldZ = worldItemObj:getWorldPosZ()-worldItemObj:getZ()
        square:transmitRemoveItemFromSquare(worldItemObj)
        square:removeWorldObject(worldItemObj)
        item:setWorldItem(nil)
        worldItemObj = nil
    end

    ---@type InventoryItem
    local invItemToWorld = square:AddWorldInventoryItem(item, xOffset, yOffset, oldZ, false)
    if (not worldItemObj) and invItemToWorld then
        invItemToWorld:setWorldZRotation(0)
        invItemToWorld:getWorldItem():setIgnoreRemoveSandbox(true)
        invItemToWorld:getWorldItem():transmitCompleteItemToServer()
    end


    local playerNum = player:getPlayerNum()
    local inventory = getPlayerInventory(playerNum)
    if inventory then inventory:refreshBackpacks() end
    local loot = getPlayerLoot(playerNum)
    if loot then loot:refreshBackpacks() end
end


---@param player IsoPlayer|IsoGameCharacter
---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.takeAction(player, gamePiece, onComplete, detailsFunc)

    local pBD = player:getBodyDamage()
    pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-0.5))

    if onComplete and type(onComplete)=="table" then
        local onCompleteFuncArgs = onComplete
        local func = onCompleteFuncArgs[1]
        local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = onCompleteFuncArgs[2], onCompleteFuncArgs[3], onCompleteFuncArgs[4], onCompleteFuncArgs[5], onCompleteFuncArgs[6], onCompleteFuncArgs[7], onCompleteFuncArgs[8], onCompleteFuncArgs[9]
        func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    end

    detailsFunc = detailsFunc or gamePieceAndBoardHandler.handleDetails
    detailsFunc(gamePiece)
end


function gamePieceAndBoardHandler.setModDataValue(gamePiece, key, value) gamePiece:getModData()[key] = value end


function gamePieceAndBoardHandler.rollDie(gamePiece, player, sides)
    sides = sides or 6
    local result = ZombRand(sides)+1
    result = result>1 and result or ""

    gamePieceAndBoardHandler.takeAction(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
    gamePieceAndBoardHandler.playSound(gamePiece, player, "dieRoll")
end



function gamePieceAndBoardHandler.flipPiece(gamePiece, player)
    local current = gamePiece:getModData()["gameNight_altState"]
    local result = "Flipped"
    if current then result = nil end
    gamePieceAndBoardHandler.playSound(gamePiece, player)
    gamePieceAndBoardHandler.takeAction(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
end

return gamePieceAndBoardHandler