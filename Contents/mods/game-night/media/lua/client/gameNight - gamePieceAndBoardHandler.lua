local gamePieceAndBoardHandler = {}

gamePieceAndBoardHandler.itemTypes = {
    "Base.Dice", "Base.PokerChips", "Base.GamePieceWhite", "Base.GamePieceRed",
    "Base.GamePieceBlack", "Base.BackgammonBoard", "Base.CheckerBoard",
    "Base.ChessWhite","Base.ChessBlack",
    --added
    "Base.GamePieceBlackBackgammon","Base.ChessBoard",
    --[["Base.ChessWhiteKing","Base.ChessBlackKing","Base.ChessWhiteBishop","Base.ChessBlackBishop",
    "Base.ChessWhiteQueen", "Base.ChessBlackQueen", "Base.ChessWhiteRook","Base.ChessBlackRook",
    "Base.ChessWhiteKnight", "Base.ChessBlackKnight",--]]
}

gamePieceAndBoardHandler._itemTypes = nil
function gamePieceAndBoardHandler.generate_itemTypes()
    gamePieceAndBoardHandler._itemTypes = {}
    for _,itemType in pairs(gamePieceAndBoardHandler.itemTypes) do gamePieceAndBoardHandler._itemTypes[itemType] = true end
end

gamePieceAndBoardHandler.specials = {
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

    local newCategory = gamePieceAndBoardHandler.specials[fullType] and gamePieceAndBoardHandler.specials[fullType].category or "GamePiece"
    if newCategory then gamePiece:setDisplayCategory(newCategory) end

    local flippedState = gamePiece:getModData()["gameNight_pieceFlipped"]==true and "Flipped" or ""

    local texturePath = "inPlayTextures/"..gamePiece:getType()..flippedState..".png"
    local texture = Texture.trygetTexture(texturePath)
    if texture then gamePiece:getModData()["gameNight_textureInPlay"] = texture end

    local iconPath = "outOfPlayTextures/"..gamePiece:getType()..flippedState..".png"
    local icon = Texture.trygetTexture(iconPath)
    if icon then gamePiece:setTexture(icon) end

end


function gamePieceAndBoardHandler.flipPiece(gamePiece)

    local special = gamePieceAndBoardHandler.specials[gamePiece:getFullType()]
    if not special or not special.flipTexture then return end

    local current = gamePiece:getModData()["gameNight_pieceFlipped"] or false
    gamePiece:getModData()["gameNight_pieceFlipped"] = (not current)

    gamePieceAndBoardHandler.handleDetails(gamePiece)
end

return gamePieceAndBoardHandler