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
    if (not special) or (not type(special)~="table") then print("ERROR: GameNight: addSpecial: special is not table.") return end
    gamePieceAndBoardHandler.specials[itemFullType] = special
end

gamePieceAndBoardHandler._itemTypes = nil
function gamePieceAndBoardHandler.generate_itemTypes()
    gamePieceAndBoardHandler._itemTypes = {}
    for _,itemType in pairs(gamePieceAndBoardHandler.itemTypes) do gamePieceAndBoardHandler._itemTypes[itemType] = true end
end

gamePieceAndBoardHandler.specials = {
    ["Base.Dice"]={ category = "Die", sides = 6 },
    ["Base.DiceWhite"]={ category = "Die", sides = 6 },
    ["Base.GamePieceRed"]={ flipTexture = true },
    ["Base.GamePieceBlack"]={ flipTexture = true },
    ["Base.BackgammonBoard"]={ category = "GameBoard" },
    ["Base.CheckerBoard"]={ category = "GameBoard" },
    ["Base.ChessBoard"]={ category = "GameBoard" },
}

function gamePieceAndBoardHandler.getGamePiece(gamePiece)
    return gamePieceAndBoardHandler._itemTypes[gamePiece:getFullType()]
end

---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.handleDetails(gamePiece)

    local fullType = gamePiece:getFullType()
    if not gamePieceAndBoardHandler._itemTypes then gamePieceAndBoardHandler.generate_itemTypes() end
    if not gamePieceAndBoardHandler._itemTypes[fullType] then return end

    gamePiece:getTags():add("gameNight")
    gamePiece:setWeight(0.01)

    gamePiece:getModData()["gameNight_sound"] = "pieceMove"

    local special = gamePieceAndBoardHandler.specials[fullType]

    local newCategory = special and special.category or "GamePiece"
    if newCategory then gamePiece:setDisplayCategory(newCategory) end

    local sides = special and special.sides
    if sides then gamePiece:getModData()["gameNight_dieSides"] = sides end

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

    ---@type ItemContainer
    local container = gamePiece:getContainer()
    if container then container:setDrawDirty(true) end
end


---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.playSound(gamePiece, player, sound)
    if not player then return end
    sound = sound or gamePiece:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end
end


---@param player IsoPlayer|IsoGameCharacter
---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.takeAction(player, gamePiece, onComplete, detailsFunc)

    local pBD = player:getBodyDamage()
    pBD:setBoredomLevel(math.max(0,pBD:getBoredomLevel()-0.5))

    --[[if luautils.haveToBeTransfered(player, gamePiece, true) then
        local pickUpAction = ISInventoryTransferAction:new(player, gamePiece, gamePiece:getContainer(), player:getInventory(), 0)
        if onComplete and type(onComplete)=="table" then pickUpAction:setOnComplete(unpack(onComplete)) end
        ISTimedActionQueue.add(pickUpAction)

        local xPos, yPos, zPos, square = 0, 0, 0, nil

        ---@type IsoWorldInventoryObject|IsoObject
        local worldItem = gamePiece:getWorldItem()
        if worldItem then
            square = worldItem:getSquare()
            xPos, yPos, zPos = worldItem:getWorldPosX()-worldItem:getX(), worldItem:getWorldPosY()-worldItem:getY(), worldItem:getWorldPosZ()-worldItem:getZ()
        end
        if square then
            local dropAction = ISDropWorldItemAction:new(player, gamePiece, square, xPos, yPos, zPos, 0, false)
            dropAction.maxTime = 0
            ISTimedActionQueue.add(dropAction)
        end
    else--]]

        if onComplete and type(onComplete)=="table" then
            local onCompleteFuncArgs = onComplete
            local func = onCompleteFuncArgs[1]
            local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 = onCompleteFuncArgs[2], onCompleteFuncArgs[3], onCompleteFuncArgs[4], onCompleteFuncArgs[5], onCompleteFuncArgs[6], onCompleteFuncArgs[7], onCompleteFuncArgs[8], onCompleteFuncArgs[9]
            func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        end
    --end
    detailsFunc = detailsFunc or gamePieceAndBoardHandler.handleDetails
    detailsFunc(gamePiece)

    if isClient() then
        local worldItem = gamePiece:getWorldItem()
        if worldItem then worldItem:transmitModData() end
    end

    ---@type ItemContainer
    local container = gamePiece:getContainer()
    if container then container:setDrawDirty(true) end

end


function gamePieceAndBoardHandler.setModDataValue(gamePiece, key, value) gamePiece:getModData()[key] = value end


function gamePieceAndBoardHandler.rollDie(gamePiece, player)
    local sides = gamePiece:getModData()["gameNight_dieSides"]
    if not sides then return end

    local result = ZombRand(sides)+1
    result = result>1 and result or ""

    gamePieceAndBoardHandler.takeAction(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
    gamePieceAndBoardHandler.playSound(gamePiece, player, "dieRoll")
end



function gamePieceAndBoardHandler.flipPiece(gamePiece, player)
    local special = gamePieceAndBoardHandler.specials[gamePiece:getFullType()]
    if not special or not special.flipTexture then return end

    local current = gamePiece:getModData()["gameNight_altState"]
    local result = "Flipped"
    if current then result = nil end

    gamePieceAndBoardHandler.playSound(gamePiece, player)
    gamePieceAndBoardHandler.takeAction(player, gamePiece, {gamePieceAndBoardHandler.setModDataValue, gamePiece, "gameNight_altState", result})
end

return gamePieceAndBoardHandler