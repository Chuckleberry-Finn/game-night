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
    gamePiece:getModData()["gameNight_sound"] = "pieceMove"

    local special = gamePieceAndBoardHandler.specials[fullType]

    local newCategory = special and special.category or "GamePiece"
    if newCategory then gamePiece:setDisplayCategory(newCategory) end

    local sides = special and special.sides
    if sides then gamePiece:getModData()["gameNight_dieSides"] = sides end

    local altState = gamePiece:getModData()["gameNight_altState"] or ""

    local texturePath = "inPlayTextures/"..gamePiece:getType()..altState..".png"
    local texture = Texture.trygetTexture(texturePath)
    if texture then gamePiece:getModData()["gameNight_textureInPlay"] = texture end

    local iconPath = "outOfPlayTextures/"..gamePiece:getType()..altState..".png"
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
function gamePieceAndBoardHandler.playSound(gamePiece, sound, player)
    if not player then return end
    sound = sound or gamePiece:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end
end


---@param gamePiece InventoryItem
function gamePieceAndBoardHandler.pickUp(player, gamePiece)
    local xPos, yPos, zPos, square = 0, 0, 0, nil
    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = gamePiece:getWorldItem()
    if worldItem then
        square = worldItem:getSquare()
        xPos, yPos, zPos = worldItem:getWorldPosX(), worldItem:getWorldPosY(), worldItem:getWorldPosZ()
    end
    ISTimedActionQueue.add(ISInventoryTransferAction:new(player, gamePiece, gamePiece:getContainer(), player:getInventory(), 0))
    return xPos, yPos, zPos, square
end
function gamePieceAndBoardHandler.putDown(player, gamePiece, square, x, y, z)
    local dropAction = ISDropWorldItemAction:new(player, gamePiece, square, x, y, z, 0, false)
    dropAction.maxTime = 1
    ISTimedActionQueue.add(dropAction)
end


function gamePieceAndBoardHandler.rollDie(gamePiece, player)
    local sides = gamePiece:getModData()["gameNight_dieSides"]
    if not sides then return end

    local x, y, z, square = gamePieceAndBoardHandler.pickUp(player, gamePiece)
    local result = ZombRand(sides)+1
    result = result>1 and result or ""
    
    gamePiece:getModData()["gameNight_altState"] = result
    gamePieceAndBoardHandler.handleDetails(gamePiece)
    gamePieceAndBoardHandler.playSound(gamePiece, "dieRoll", player)
    gamePieceAndBoardHandler.putDown(player, gamePiece, square, x, y, z)
end



function gamePieceAndBoardHandler.flipPiece(gamePiece, player)
    local special = gamePieceAndBoardHandler.specials[gamePiece:getFullType()]
    if not special or not special.flipTexture then return end

    local x, y, z, square = gamePieceAndBoardHandler.pickUp(player, gamePiece)
    local current = gamePiece:getModData()["gameNight_altState"]
    if current then
        gamePiece:getModData()["gameNight_altState"] = nil
    else
        gamePiece:getModData()["gameNight_altState"] = "Flipped"
    end

    gamePieceAndBoardHandler.handleDetails(gamePiece)
    gamePieceAndBoardHandler.playSound(gamePiece, player)
    gamePieceAndBoardHandler.putDown(player, gamePiece, square, x, y, z)
end

return gamePieceAndBoardHandler