local gnTags = require("gameNight-tags.lua")
local gamePieceHandler = {}

gamePieceHandler.itemTypes = {}
gamePieceHandler.specials = {}

function gamePieceHandler.registerType(itemFullType)
    gamePieceHandler._itemTypes = gamePieceHandler._itemTypes or {}
    if not gamePieceHandler._itemTypes[itemFullType] then
        table.insert(gamePieceHandler.itemTypes, itemFullType)
        gamePieceHandler._itemTypes[itemFullType] = true
    end
end


function gamePieceHandler.registerTypes(args)
    for _,itemFullType in pairs(args) do
        gamePieceHandler.registerType(itemFullType)
    end
end


function gamePieceHandler.registerSpecial(itemFullType, special)
    if (not getScriptManager():getItem(itemFullType)) then print("ERROR: GameNight: addSpecial: "..itemFullType.." is invalid.") return end
    if (not special) or (type(special)~="table") then print("ERROR: GameNight: addSpecial: special is not table.") return end
    gamePieceHandler.registerType(itemFullType)
    gamePieceHandler.specials[itemFullType] = special
end


gamePieceHandler._itemTypes = nil
function gamePieceHandler.generate_itemTypes()
    gamePieceHandler._itemTypes = gamePieceHandler._itemTypes or {}
    for _,itemType in pairs(gamePieceHandler.itemTypes) do gamePieceHandler._itemTypes[itemType] = true end
end

gamePieceHandler.registerSpecial("Base.Dice", { category = "Die", modelOverride = "gn_Dice", actions = { examine=true, rollDie=6 }, shiftAction = "rollDie", noRotate=true, solid=true, mass=1, })
gamePieceHandler.registerSpecial("Base.DiceWhite", { category = "Die", actions = { examine=true, rollDie=6 }, shiftAction = "rollDie", noRotate=true, solid=true, mass=1, })
gamePieceHandler.registerSpecial("Base.Dice_Wood", { category = "Die", modelOverride = "gn_Dice", actions = { examine=true, rollDie=6 }, shiftAction = "rollDie", noRotate=true, solid=true, mass=1, })
gamePieceHandler.registerSpecial("Base.Dice_Bone", { category = "Die", modelOverride = "gn_Dice", actions = { examine=true, rollDie=6 }, shiftAction = "rollDie", noRotate=true, solid=true, mass=1, })
gamePieceHandler.registerSpecial("Base.Dice_00", { category = "Die", modelOverride = "gn_Dice", actions = { examine=true, rollDie=10 }, shiftAction = "rollDie", noRotate=true, solid=true, mass=1, })
gamePieceHandler.registerSpecial("Base.StellaOcta", { actions = { rollDie=1, examine=true }, shiftAction = "rollDie", solid=true, mass=1, })

gamePieceHandler.registerSpecial("Base.CardDeck", { modelOverride = "gn_CardDeck" })

gamePieceHandler.registerSpecial("Base.GamePieceWhite", { modelOverride = "gn_GamePiecesWhite_Ground", solid=true, mass=1.2, })
gamePieceHandler.registerSpecial("Base.GamePieceRed", { modelOverride = "gn_GamePiecesRed_Ground", weight = 0.01, actions = { flipPiece=true }, altState="GamePieceRedFlipped", shiftAction = "flipPiece", noRotate=true, solid=true, mass=1.2, })
gamePieceHandler.registerSpecial("Base.GamePieceBlack", { modelOverride = "gn_GamePiecesBlack_Ground", weight = 0.01, actions = { flipPiece=true }, altState="GamePieceBlackFlipped", shiftAction = "flipPiece", noRotate=true, solid=true, mass=1.2, })
gamePieceHandler.registerSpecial("Base.GamePieceBlackBackgammon", { modelOverride = "GamePieceBlackBackgammon_Ground", solid=true, mass=1.2, })

gamePieceHandler.registerSpecial("Base.ChessWhite", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=1.0, })
gamePieceHandler.registerSpecial("Base.ChessBlack", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=1.0, })

gamePieceHandler.registerSpecial("Base.ChessWhiteKing", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=2.5, })
gamePieceHandler.registerSpecial("Base.ChessBlackKing", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=2.5, })
gamePieceHandler.registerSpecial("Base.ChessWhiteQueen", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=2.2, })
gamePieceHandler.registerSpecial("Base.ChessBlackQueen", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=2.2, })
gamePieceHandler.registerSpecial("Base.ChessWhiteRook", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=2.0, })
gamePieceHandler.registerSpecial("Base.ChessBlackRook", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=2.0, })
gamePieceHandler.registerSpecial("Base.ChessWhiteKnight", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=1.6, })
gamePieceHandler.registerSpecial("Base.ChessBlackKnight", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=1.6, })
gamePieceHandler.registerSpecial("Base.ChessWhiteBishop", { modelOverride = "gn_WhiteChessPieces", weight = 0.01, solid=true, mass=1.4, })
gamePieceHandler.registerSpecial("Base.ChessBlackBishop", { modelOverride = "gn_BlackChessPieces", weight = 0.01, solid=true, mass=1.4, })

gamePieceHandler.registerSpecial("Base.BackgammonBoard", { modelOverride = "gn_BackgammonBoard_Ground", actions = { lock=true }, category = "GameBoard", textureSize = {532,540} })
gamePieceHandler.registerSpecial("Base.CheckerBoard", { modelOverride = "gn_CheckerBoard_Ground", actions = { lock=true }, category = "GameBoard", textureSize = {532,540} })
gamePieceHandler.registerSpecial("Base.ChessBoard", { actions = { lock=true }, category = "GameBoard", textureSize = {532,540} })

gamePieceHandler.registerSpecial("Base.PokerChips", { modelOverride = "gn_PokerChips_Ground", weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.8, 0.42, 0.41}, sides=7} })
gamePieceHandler.registerSpecial("Base.PokerChipsBlue", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.41, 0.52, 0.82}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsYellow", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.79, 0.75, 0.38}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsWhite", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.94, 0.92, 0.88}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsBlack", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.45, 0.43, 0.4}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsOrange", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.82, 0.65, 0.36}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsPurple", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.71, 0.4, 0.73}, sides=7 } })
gamePieceHandler.registerSpecial("Base.PokerChipsGreen", { weight = 0.003, shiftAction = "takeOneOffStack", canStack = 50, noRotate=true, solid=true, mass=0.6, alternateStackRendering = {depth = 4, func="DrawTexturePokerChip", rgb = {0.44, 0.62, 0.37}, sides=7 } })

---Because I hate copy pasted code - this iterates through the side values and registers their special actions.
local dice_sides = {4,6,8,10,12,20}
for _,side in pairs(dice_sides) do
    gamePieceHandler.registerSpecial("Base.Dice_"..side, {
        addTextureDir = "dice/", noRotate=true, actions = { examine=true, rollDie=side, placeDieOnSide=true }, shiftAction = "rollDie", solid=true, mass=1,
    })
end


function gamePieceHandler.parseTopOfStack(stack)
    if instanceof(stack, "InventoryItem") then return stack, false end
    if #stack.items==2 then return stack.items[2], false end
    return stack.items[1], stack
end

function gamePieceHandler.bypassForStacks(stack, player, func, args, source)
    if instanceof(stack, "InventoryItem") then return end
    for i=2, #stack.items do
        local item = stack.items[i]
        source[func](item, player, args)
    end
end

gamePieceHandler.specialContextIcons = {}
---@param context ISContextMenu
function gamePieceHandler.generateContextMenuFromSpecialActions(context, player, item, altSource)
    altSource = altSource or gamePieceHandler
    local gamePiece, pieceStack = gamePieceHandler.parseTopOfStack(item)
    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceHandler.specials[fullType]
    if specialCase and specialCase.actions then
        for func,args in pairs(specialCase.actions) do
            if altSource[func] then
                local validTest = altSource[func.."_isValid"]
                local valid = (validTest and validTest(gamePiece, player, args)) or (not validTest and true)
                if valid then
                    local option = context:getOptionFromName(getText("IGUI_"..func)) or context:getOptionFromName(getText("IGUI_"..func)..getText("IGUI_SpecialActionAll"))
                    if not option then
                        if not pieceStack then
                            option = context:addOptionOnTop(getText("IGUI_"..func), gamePiece, altSource[func], player, args)
                        else
                            option = context:addOptionOnTop(getText("IGUI_"..func)..getText("IGUI_SpecialActionAll"), pieceStack, gamePieceHandler.bypassForStacks, player, func, args, altSource)
                        end
                        if option then
                            local childOptionsFunc = altSource["_contextChildrenFor_"..func]
                            if childOptionsFunc then childOptionsFunc(option, context, player, gamePiece, args) end

                            local ico = gamePieceHandler.specialContextIcons[func]
                            if not ico then
                                ico = getTexture("media/textures/actionIcons/"..func..".png")
                                gamePieceHandler.specialContextIcons[func] = ico
                            end
                            if ico then option.iconTexture = ico end
                        end
                    end
                end
            end
        end
    end
end

---@param inventoryItem InventoryItem
function gamePieceHandler.safelyRemoveGamePiece(inventoryItem, player)
    local worldItem = inventoryItem:getWorldItem()
    if worldItem then
        ---@type IsoGridSquare
        local sq = worldItem:getSquare()
        if sq then
            sq:transmitRemoveItemFromSquare(worldItem)
            worldItem:removeFromWorld()
            worldItem:removeFromSquare()
            inventoryItem:setWorldItem(nil)
        end
    end

    ---@type ItemContainer
    local container = inventoryItem:getContainer()
    if container then
        container:setDrawDirty(true)
        inventoryItem:setJobDelta(0.0)
        
        local playerInventory = player:getInventory()
        local isInPlayer = playerInventory and container==playerInventory
        if isInPlayer then
            player:removeAttachedItem(inventoryItem)
            if player:getPrimaryHandItem() == inventoryItem then player:setPrimaryHandItem(nil) end
            if player:getSecondaryHandItem() == inventoryItem then player:setSecondaryHandItem(nil) end
            triggerEvent("OnClothingUpdated", player)
        end

        if isClient() then
            local outerMost = inventoryItem:getOutermostContainer()
            if outerMost and (not instanceof(outerMost:getParent(), "IsoPlayer")) and container:getType()~="floor" then
                container:removeItemOnServer(inventoryItem)
            end
        end
        container:DoRemoveItem(inventoryItem)
        inventoryItem:setContainer(nil)
    end

    inventoryItem:setContainer(nil)
    inventoryItem:setWorldItem(nil)
end

function gamePieceHandler.isGamePiece(gamePiece) return gamePieceHandler._itemTypes[gamePiece:getFullType()] end

function gamePieceHandler.canStackPiece(gamePiece)
    local special = gamePieceHandler.specials[gamePiece:getFullType()]
    return special and special.canStack
end

function gamePieceHandler.canUnstackPiece(gamePiece)
    local stacked = gamePiece:getModData()["gameNight_stacked"]
    return gamePieceHandler.canStackPiece(gamePiece) and stacked and stacked > 1
end

function gamePieceHandler._unstack(gamePiece, player, numberOf, locations)
    --sq=sq, offsets={x=wiX,y=wiY,z=wiZ}, container=container

    local newPiece = instanceItem(gamePiece:getType())
    if newPiece then

        numberOf = numberOf or 1
        newPiece:getModData()["gameNight_stacked"] = numberOf
        gamePiece:getModData()["gameNight_stacked"] = gamePiece:getModData()["gameNight_stacked"]-numberOf

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or gamePiece:getWorldItem()

        local x, y = gamePieceHandler.shiftPieceSlightly(gamePiece)

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

        gamePieceHandler.handleDetails(gamePiece)
        gamePieceHandler.handleDetails(newPiece)

        return gamePiece
    end
end

function gamePieceHandler.unstack(gamePiece, player, numberOf, locations)
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler._unstack, gamePiece, player, numberOf, locations}, nil)
end

function gamePieceHandler.testCanStack(gamePieceA, gamePieceB)
    if not gamePieceHandler.canStackPiece(gamePieceA) or not gamePieceHandler.canStackPiece(gamePieceB) then return false end
    local gpaStack, gpbStack = (gamePieceA:getModData()["gameNight_stacked"] or 1), (gamePieceB:getModData()["gameNight_stacked"] or 1)
    if (gpaStack <= 200) and (gpbStack <= 200) and (gpaStack + gpbStack <= 200) then return true end
    return false
end

function gamePieceHandler._tryStack(gamePieceA, gamePieceB, player)
    local aStack = (gamePieceA:getModData()["gameNight_stacked"] or 1)
    gamePieceB:getModData()["gameNight_stacked"] = (gamePieceB:getModData()["gameNight_stacked"] or 1) + aStack
    gamePieceHandler.safelyRemoveGamePiece(gamePieceA, player)
end

---@param gamePieceA InventoryItem
---@param gamePieceB InventoryItem
function gamePieceHandler.tryStack(gamePieceA, gamePieceB, player, x, y, z)
    if gamePieceA:getFullType() ~= gamePieceB:getFullType() then return end
    if not gamePieceHandler.testCanStack(gamePieceA, gamePieceB) then return end
    gamePieceHandler.pickupGamePiece(player, gamePieceA)
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePieceB, {gamePieceHandler._tryStack, gamePieceA, gamePieceB, player}, nil, x, y, z)
    gamePieceHandler.playSound(gamePieceB, player)
end

function gamePieceHandler.takeOneOffStack(gamePiece, player, x, y, z)
    local gpaStack = gamePiece:getModData()["gameNight_stacked"]
    if not gpaStack or gpaStack <= 1 then
        gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, nil, nil, x, y, z)
        return
    end

    local locations = {}
    local worldItem = gamePiece:getWorldItem()
    local sq = worldItem and worldItem:getSquare()
    if sq then
        locations.sq = sq
        locations.offsets = {x=x,y=y,z=z}
    end
    gamePieceHandler.unstack(gamePiece, player, 1, locations)
end

function gamePieceHandler.generateContextMenuForStacking(context, player, gamePiece)
    if not gamePieceHandler.canUnstackPiece(gamePiece) then return end

    local stack = gamePiece:getModData()["gameNight_stacked"] and gamePiece:getModData()["gameNight_stacked"]>1 and gamePiece:getModData()["gameNight_stacked"]
    if not stack then return end

    local locations = {}--
    local worldItem = gamePiece:getWorldItem()
    local sq = worldItem and worldItem:getSquare()
    if sq then locations[sq] = sq end

    local unStack = context:addOptionOnTop(getText("IGUI_take"), gamePiece, gamePieceHandler._unstack, player, 1, locations)

    local subDrawMenu = ISContextMenu:getNew(context)
    context:addSubMenu(unStack, subDrawMenu)

    for i=1, 25, 5 do if stack >= i then
        local option = subDrawMenu:addOption(getText("IGUI_takeMore", i), gamePiece, gamePieceHandler._unstack, player, i, locations)
    end end
end

function gamePieceHandler.applyScriptChanges()

    local scriptManager = getScriptManager()

    for _,scriptType in pairs(gamePieceHandler.itemTypes) do

        local special = gamePieceHandler.specials[scriptType]
        local script = scriptManager:getItem(scriptType)
        if script then

            if special then
                local newCategory = special.category
                if special.ignoreCategory then newCategory = nil end
                if newCategory then script:DoParam("DisplayCategory = "..newCategory) end

                local modelOverride = special.modelOverride
                if modelOverride then script:DoParam("WorldStaticModel = "..modelOverride) end
            end

            local iconPath = "OutOfPlayTextures/"..script:getName()..".png"
            local icon = Texture.trygetTexture("Item_"..iconPath)
            if icon then script:DoParam("Icon = "..iconPath) end

            local tags = script:getTags()
            if not tags:contains(gnTags.GAME_NIGHT) then tags:add(gnTags.GAME_NIGHT) end

            local special_weight = special and special.weight
            if special_weight then script:DoParam("Weight = "..special_weight) end

        end
    end

end

---@param gamePiece InventoryItem
function gamePieceHandler.fetchIconState(gamePiece, mainDir,additionalTextureDir,altState)
    local iconState = altState or gamePiece:getType()
    local texturePath = mainDir.."/"..additionalTextureDir..iconState..".png"
    local texture = Texture.trygetTexture(texturePath)

    if not texture then
        local scriptIcon = gamePiece:getScriptItem():getIcon()
        texturePath = scriptIcon--mainDir.."/"..additionalTextureDir..scriptIcon..".png"
        texture = Texture.trygetTexture(texturePath)
    end

    if texture then return texture end
end

---@param gamePiece InventoryItem
function gamePieceHandler.handleDetails(gamePiece, stackInit)

    local fullType = gamePiece:getFullType()

    if not gamePieceHandler._itemTypes then return end
    if not gamePieceHandler._itemTypes[fullType] then return end

    local tags = gamePiece:getTags()
    if not tags:contains(gnTags.GAME_NIGHT) then tags:add(gnTags.GAME_NIGHT) end

    local special = gamePieceHandler.specials[fullType]
    local md = gamePiece:getModData()

    if special then
        local deckData = md["gameNight_cardDeck"]
        local defaultCategory
        if deckData then
            defaultCategory = type(deckData)=="table" and #deckData > 1 and "Deck" or "Card"
        elseif gamePiece:IsInventoryContainer() then
            defaultCategory = "GameBox"
        else
            defaultCategory = "GamePiece"
        end
        local newCategory = special.category or defaultCategory
        if special.ignoreCategory then newCategory = nil end
        if newCategory then gamePiece:setDisplayCategory(newCategory) end
    end

    md["gameNight_sound"] = special and special.moveSound or "pieceMove"

    local canStack = gamePieceHandler.canStackPiece(gamePiece)
    if canStack and not md["gameNight_stacked"] then
        if type(canStack)~="number" then canStack = 1 end
        md["gameNight_stacked"] = stackInit and canStack or 1
    end

    local script = gamePiece:getScriptItem()

    local displayCount = gamePieceHandler.getDisplayCount(gamePiece)
    local name_suffix = displayCount and " ["..displayCount.."]" or ""
    gamePiece:setName(script:getDisplayName()..name_suffix)

    local stack = md["gameNight_stacked"]
    local special_weight = special and special.weight or script:getActualWeight()
    gamePiece:setActualWeight(special_weight*(stack or 1))

    local iconState = md["gameNight_altState"]
    local additionalTextureDir = special and special.addTextureDir or ""

    local texture = gamePieceHandler.fetchIconState(gamePiece, "Item_InPlayTextures", additionalTextureDir, iconState)
    if texture then md["gameNight_textureInPlay"] = texture end

    local icon = gamePieceHandler.fetchIconState(gamePiece, "Item_OutOfPlayTextures", additionalTextureDir, iconState)
    if icon then gamePiece:setTexture(icon) end

    local cont = gamePiece:getContainer()
    local parent = cont and cont:getParent()
    if parent and instanceof(parent, "IsoPlayer") then
        gamePieceHandler.refreshInventory(parent)
    end
end

---@param gamePiece InventoryItem
function gamePieceHandler.playSound(gamePiece, player, sound)
    if not player then return end
    sound = sound or gamePiece:getModData()["gameNight_sound"]
    if sound then player:getEmitter():playSound(sound) end
end

function gamePieceHandler.setModDataValue(gamePiece, key, value)
    gamePiece:getModData()[key] = value
end

gamePieceHandler.coolDownArray = {}

function gamePieceHandler.itemIsBusy(item)
    if not item then return true end
    local coolDown = gamePieceHandler.coolDownArray[item:getID()]
    local busy = coolDown and (coolDown>GameTime.getServerTimeMills())
    return busy
end

function gamePieceHandler.itemCoolDown(item)
    if not item then return true end
    local coolDown = gamePieceHandler.coolDownArray[item:getID()]
    return coolDown
end

function gamePieceHandler.onPickUp(onPickUp)
    if onPickUp and type(onPickUp)=="table" then
        local func = onPickUp[1]
        func(unpack(onPickUp, 2))
    end
end

---@param item InventoryItem
function gamePieceHandler.pickupGamePiece(player, item, onPickUp, detailsFunc, angleChange)
    if not item then return end

    local blockUse = gamePieceHandler.itemIsBusy(item)
    if blockUse then return end

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

    if itemContainer and itemContainer ~= playerInv then
        if isClient() and not itemContainer:isInCharacterInventory(player) and itemContainer:getType()~="floor" then itemContainer:removeItemOnServer(item) end
        itemContainer:DoRemoveItem(item)
        itemContainer:setDrawDirty(true)
        playerInv:setDrawDirty(true)
        playerInv:AddItem(item)
        gamePieceHandler.onPickUp(onPickUp)
        pickedUp = true
    end

    if item then
        if angleChange then gamePieceHandler.rotatePiece(item, angleChange, player) end
        detailsFunc = detailsFunc or gamePieceHandler.handleDetails
        detailsFunc(item)
    end

    gamePieceHandler.refreshInventory(player)

    return pickedUp, xOffset, yOffset, zPos
end

function gamePieceHandler.refreshInventory(player)
    ISInventoryPage.renderDirty = true
    local playerNum = player:getPlayerNum()
    local inventory = getPlayerInventory(playerNum)
    if inventory then inventory:refreshBackpacks() end
    local loot = getPlayerLoot(playerNum)
    if loot then loot:refreshBackpacks() end
end

function gamePieceHandler.shiftPieceSlightly(gamePiece, offset)
    local worldItem = gamePiece:getWorldItem()
    if not worldItem then return 0, 0 end
    local xOffset = worldItem and worldItem:getWorldPosX()-worldItem:getX() or 0
    local yOffset = worldItem and worldItem:getWorldPosY()-worldItem:getY() or 0

    offset = offset or 0.02

    xOffset = xOffset+ZombRandFloat(0-offset,offset)
    yOffset = yOffset+ZombRandFloat(0-offset,offset)

    return xOffset, yOffset
end

gamePieceHandler.coolDown = (isClient() or isServer()) and 1001 or 3

---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
---@param xOffset number
---@param yOffset number
---@param worldItemSq IsoGridSquare
function gamePieceHandler.placeGamePiece(player, item, worldItemSq, xOffset, yOffset, zPos)

    if (not item) or (not worldItemSq) then return end

    local itemCont = item:getContainer()
    local playerInventory = player:getInventory()

    local isInPlayer = itemCont and playerInventory and itemCont==playerInventory
    if not isInPlayer then return end

    local rotation = item:getModData()["gameNight_rotation"] or 0
    item:setWorldZRotation(rotation)

    itemCont:setDrawDirty(true)
    item:setJobDelta(0.0)
    player:removeAttachedItem(item)
    if player:getPrimaryHandItem() == item then player:setPrimaryHandItem(nil) end
    itemCont:Remove(item)
    triggerEvent("OnClothingUpdated", player)

    ---@type InventoryItem
    local placedItem = worldItemSq:AddWorldInventoryItem(item, xOffset, yOffset, zPos)
    if placedItem then
        placedItem:setName(item:getName())
        placedItem:setKeyId(item:getKeyId())

        local worldObject = placedItem:getWorldItem()
        if worldObject then
            worldObject:setIgnoreRemoveSandbox(true)
        end
    end

    gamePieceHandler.refreshInventory(player)
end


gamePieceHandler.moveBuffer = {}
---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
function gamePieceHandler.processMoveFromBuffer(player, itemID, allowed, newCoolDown)

    local buffer = gamePieceHandler.moveBuffer[player]

    local move = buffer and buffer["i"..itemID]
    if not move then return end

    local moveItem = move.item

    if allowed and moveItem and (not gamePieceHandler.itemIsBusy(moveItem)) then
        local onPickUp, detailsFunc, xOffset, yOffset, zPos, square, angleChange = move.onPickUp, move.detailsFunc, move.xOffset, move.yOffset, move.zPos, move.square, move.angleChange
        gamePieceHandler.pickupAndPlaceGamePiece(player, moveItem, onPickUp, detailsFunc, xOffset, yOffset, zPos, square, angleChange, true)
    end

    if newCoolDown then gamePieceHandler.coolDownArray[itemID] = newCoolDown end

    buffer["i"..itemID] = nil
end


---@param player IsoPlayer|IsoGameCharacter|IsoMovingObject|IsoObject
---@param item InventoryItem
---@param xOffset number
---@param yOffset number
function gamePieceHandler.pickupAndPlaceGamePiece(player, item, onPickUp, detailsFunc, xOffset, yOffset, zPos, square, angleChange, byPassClient)

    local blockUse = gamePieceHandler.itemIsBusy(item)
    if blockUse then return end

    if xOffset == true then xOffset, yOffset, zPos = nil, nil, nil end

    if isClient() and (not byPassClient) then
        gamePieceHandler.moveBuffer[player] = gamePieceHandler.moveBuffer[player] or {}

        local itemID = item:getID()

        gamePieceHandler.moveBuffer[player]["i"..itemID] = { item=item, onPickUp = onPickUp , detailsFunc = detailsFunc,
                                                                           xOffset = xOffset, yOffset = yOffset, zPos = zPos, square = square, angleChange = angleChange }
        sendClientCommand(player, "gameNightAction", "pickupAndPlaceGamePiece", {itemID=itemID})
        return
    end

    ---@type IsoWorldInventoryObject|IsoObject
    local worldItem = item:getWorldItem()
    ---@type IsoGridSquare
    local worldItemSq = square or worldItem and worldItem:getSquare()

    local pickedUp, x, y, z = gamePieceHandler.pickupGamePiece(player, item, onPickUp, detailsFunc, angleChange)

    local playerInv = player:getInventory()
    local itemContainer = item:getContainer()
    if not pickedUp and itemContainer and itemContainer == playerInv then
        gamePieceHandler.onPickUp(onPickUp)
    end

    xOffset = xOffset or x or 0
    yOffset = yOffset or y or 0
    zPos = zPos or z or 0

    if item and worldItemSq then
        local stats = player:getStats()
        if stats then
            stats:set(CharacterStat.BOREDOM, math.max(0, stats:get(CharacterStat.BOREDOM) - 1))
            stats:set(CharacterStat.UNHAPPINESS, math.max(0, stats:get(CharacterStat.UNHAPPINESS) - 1))
        end

        local sound = item:getModData()["gameNight_sound"]
        if sound then player:getEmitter():playSound(sound) end

        gamePieceHandler.placeGamePiece(player, item, worldItemSq, xOffset, yOffset, zPos)
    end

    gamePieceHandler.refreshInventory(player)
end


function gamePieceHandler.examine(gamePiece, player, indexIfCard)
    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceHandler.specials[fullType]
    local examineScale = specialCase and specialCase.examineScale
    local examineAction = specialCase and specialCase.actions and specialCase.actions.examine
    if examineScale or examineAction then gameNightExamine.open(player, gamePiece, true, indexIfCard) end
end


function gamePieceHandler.rollDie_direct(gamePiece, player, sides, x, y, z)
    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceHandler.specials[fullType]
    sides = sides or (specialCase and specialCase.actions and specialCase.actions.rollDie)

    local result = ZombRand(sides)+1
    result = result>1 and gamePiece:getType()..result or nil

    local xShift, yShift = gamePieceHandler.shiftPieceSlightly(gamePiece)
    x = (x or 0)+xShift
    y = (y or 0)+yShift

    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler.setModDataValue, gamePiece, "gameNight_altState", result}, nil, x, y, z)
    gamePieceHandler.playSound(gamePiece, player, "dieRoll")
end


function gamePieceHandler.rollDie(gamePiece, player, sides, x, y, z)
    if gameNightWindow and gameNightWindow.instance and gameNightWindow.instance:isVisible() then
        gameNightWindow.instance:animateAndRollDie(gamePiece, player, x, y, z)
        return
    end
    gamePieceHandler.rollDie_direct(gamePiece, player, sides, x, y, z)
end


function gamePieceHandler._contextChildrenFor_placeDieOnSide(option, context, player, gamePiece, args)
    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceHandler.specials[fullType]

    local sides = (specialCase and specialCase.actions and specialCase.actions.rollDie)
    if not sides then return end

    local currentAltState = gamePiece:getModData()["gameNight_altState"]
    local casGsub = currentAltState and currentAltState:gsub("%D", "")
    local currentValue = casGsub and tonumber(casGsub) or 1

    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(option, subMenu)

    local multi = (args and type(args)=="number" and args) or 1

    for n=1, sides do
        if n ~= currentValue then
            subMenu:addOption(getText("IGUI_PlaceDieOnSide", n*multi), gamePiece, gamePieceHandler.placeDieOnSide, player, n)
        end
    end
end


function gamePieceHandler.placeDieOnSide(gamePiece, player, side)
    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceHandler.specials[fullType]

    local sides = (specialCase and specialCase.actions and specialCase.actions.rollDie)
    if not sides then return end

    local result = side
    result = result>1 and gamePiece:getType()..result or nil
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler.setModDataValue, gamePiece, "gameNight_altState", result})
end


function gamePieceHandler.rotatePiece(gamePiece, angleChange, player)
    local current = gamePiece:getModData()["gameNight_rotation"] or 0
    local fullType = gamePiece:getFullType()
    local specialCase = fullType and gamePieceHandler.specials[fullType]
    local noRotate = specialCase and specialCase.noRotate

    local state = noRotate and 0 or (current + angleChange)

    if state < 0 then
        state = 360 + state
    elseif state >= 360 then
        state = state - 360
    end

    gamePieceHandler.setModDataValue(gamePiece, "gameNight_rotation", state)
end


function gamePieceHandler.coinFlip(gamePiece, player, x, y, z, square)
    local heads = ZombRand(2) == 0

    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceHandler.specials[fullType]
    local altState = specialCase and specialCase.altState
    if not altState then return end

    if not heads then altState = nil end

    gamePieceHandler.playSound(gamePiece, player, "coinFlip")
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler.setModDataValue, gamePiece, "gameNight_altState", altState}, nil, x, y, z, square)
end


function gamePieceHandler.flipPiece(gamePiece, player, x, y, z, square)

    local fullType = gamePiece:getFullType()
    local specialCase = gamePieceHandler.specials[fullType]
    local result = specialCase and specialCase.altState

    if gamePiece:getModData()["gameNight_altState"] then result = nil end
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler.setModDataValue, gamePiece, "gameNight_altState", result}, nil, x, y, z, square)
end


function gamePieceHandler.lock(gamePiece, player, x, y, z, square)
    local result = true
    if gamePiece:getModData()["gameNight_locked"] then result = nil end
    gamePieceHandler.pickupAndPlaceGamePiece(player, gamePiece, {gamePieceHandler.setModDataValue, gamePiece, "gameNight_locked", result}, nil, x, y, z, square)
end


---Batch action, each key must match an action name that appears in specials[item].actions.
---
--- fn(item, window) per-item call- omit to use handler[actionID](item, window.player)
--- filter(item) -> bool which items qualify- omit to check specials[item].actions[actionID]
--- label(count) -> string context menu text- omit for a generic fallback
---
---Add-ons that register new actions can call gamePieceHandler.registerBatchMeta(id, meta).
gamePieceHandler.batchMeta = {

    rollDie = {
        fn = function(item, window, x, y)
            gamePieceHandler.rollDie(item, window.player, nil, x, y, 0)
        end,
    },

    flipPiece = {
        filter = function(item)
            local c = gamePieceHandler.card
            return (c and c.isDeckItem(item)) or gamePieceHandler.isGamePiece(item)
        end,
        fn = function(item, window, x, y)
            local c = gamePieceHandler.card
            if c and c.isDeckItem(item) then
                c.flipCard(item, window.player, x, y, 0, window.square)
            else
                gamePieceHandler.flipPiece(item, window.player, x, y, 0, window.square)
            end
        end,
    },

    lock = {},
    coinFlip = {},

}


---Register batch metadata for a new action. Intended for add-ons that add actions via
---registerSpecial and want them to appear in the batch context menu automatically.
---@param actionID string must match a key in specials[item].actions
---@param meta table { fn, filter, label } all fields optional- see batchMeta docs above
function gamePieceHandler.registerBatchMeta(actionID, meta)
    gamePieceHandler.batchMeta[actionID] = meta
end


---Group behavior metadata, auto-wired by the window into registerGroupBehavior.
---Each key becomes a named group behavior checked in order before "default".
---
--- match(item) -> bool which items belong to this group- required
--- clusterRadius (number) scatter radius when releasing a shaken group- default 6
--- onRelease(item,window,x,y) called per-item on release- defaults to pickupAndPlaceGamePiece
---
---Add-ons can call gamePieceHandler.registerGroupMeta(name, meta).
gamePieceHandler.groupMeta = {

    die = {
        match = function(item)
            local sp = gamePieceHandler.specials[item:getFullType()]
            return sp and sp.actions and sp.actions.rollDie
        end,
        clusterRadius = 8,
        -- onRelease defaults to pickupAndPlaceGamePiece
    },

}


---Register group behavior metadata for a new item category. Intended for add-ons.
---@param name string
---@param meta table { match, clusterRadius, onRelease } — see groupMeta docs above
function gamePieceHandler.registerGroupMeta(name, meta)
    gamePieceHandler.groupMeta[name] = meta
end


function gamePieceHandler.getKind(item, specials)
    if item:getModData()["gameNight_cardDeck"] then return "card" end
    if specials then
        local sp = specials[item:getFullType()]
        if sp and sp.actions and sp.actions.rollDie then return "die" end
    end
    return "piece"
end

function gamePieceHandler.isCard(item)
    return item:getModData()["gameNight_cardDeck"] ~= nil
end


function gamePieceHandler.getCount(item)
    local md = item:getModData()
    local deckData = md["gameNight_cardDeck"]
    if deckData ~= nil then
        return type(deckData) == "table" and #deckData or 0
    end
    return md["gameNight_stacked"]
end


function gamePieceHandler.getDisplayCount(item)
    local md = item:getModData()
    local deckData = md["gameNight_cardDeck"]
    if deckData ~= nil then
        local n = type(deckData) == "table" and #deckData or 0
        return n > 0 and n or nil
    end
    local stacked = md["gameNight_stacked"]
    return (stacked and stacked > 1) and stacked or nil
end


function gamePieceHandler.getDepthAndFunc(item, specialCase)
    local md = item:getModData()
    local altRend = specialCase and specialCase.alternateStackRendering
    local deckData = md["gameNight_cardDeck"]
    local stack = md["gameNight_stacked"]

    if not altRend and not deckData and not stack then return nil, nil end

    local depthFactor = (altRend and altRend.depth) or (deckData and 0.33) or 1
    local cardCount = deckData and type(deckData) == "table" and #deckData or nil
    local depth = (cardCount and cardCount * depthFactor) or stack or depthFactor
    local drawFunc = (altRend and altRend.func) or (deckData and "DrawTextureCardFace") or "DrawTextureRoundFace"

    return depth, drawFunc
end


function gamePieceHandler.getCurrent(item)
    local md = item:getModData()
    local deckData = md["gameNight_cardDeck"]
    if deckData and type(deckData) == "table" and #deckData > 0 then
        return deckData[#deckData]
    end
    return md["gameNight_altState"]
end


function gamePieceHandler.isFlipped(item)
    local md = item:getModData()
    local deckData = md["gameNight_cardDeck"]
    if deckData then
        local flipped = md["gameNight_cardFlipped"]
        if flipped and #flipped > 0 then return flipped[#flipped] == true end
        return false
    end
    -- For pieces, a non-nil altState means something has been flipped/changed.
    return md["gameNight_altState"] ~= nil
end


function gamePieceHandler.getRotation(item)
    return item:getModData()["gameNight_rotation"] or 0
end


function gamePieceHandler.isLocked(item)
    return item:getModData()["gameNight_locked"] == true
end


local card = {}
gamePieceHandler.card = card

card.deckCatalogues = {}
card.altDetails = {}

function card.addDeck(itemType, cardIcons, altNames, altIcons)
    card.deckCatalogues[itemType] = cardIcons

    if altNames or altIcons then
        card.altDetails[itemType] = {}
        if altNames then card.altDetails[itemType].altNames = altNames end
        if altIcons then card.altDetails[itemType].altIcons = altIcons end
    end
end


function card.fetchAltName(cardName, deckItem)
    local itemType = deckItem:getType()
    if not card.altDetails[itemType] then return cardName end
    local altNames = card.altDetails[itemType].altNames

    local altName = altNames and altNames[cardName]
    return ((altName and (getTextOrNull("IGUI_"..altName) or altName)) or cardName)
end


function card.fetchAltIcon(cardName, deckItem)
    local itemType = deckItem:getType()
    if not card.altDetails[itemType] then return cardName end
    local altIcons = card.altDetails[itemType].altIcons

    local altIcon = altIcons and altIcons[cardName] or cardName
    return altIcon
end


function card.isDeckItem(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if deckData and #deckData>0 then return true end
    return false
end


---@param deckItem InventoryItem
function card.getDeckStates(deckItem)
    local deckData = deckItem:getModData()["gameNight_cardDeck"]
    if not deckData then return end

    local cardFlipStates = deckItem:getModData()["gameNight_cardFlipped"]

    return deckData, cardFlipStates
end


card.cardWeight = 0.003
---@param deckItem InventoryItem
function card.handleDetails(deckItem)
    local deckStates, flippedStates = card.getDeckStates(deckItem)
    if not deckStates or not flippedStates then return end

    if #deckStates <= 0 then return end
    local itemType = deckItem:getType()
    local fullType = deckItem:getFullType()

    deckItem:setActualWeight(card.cardWeight*#deckStates)

    local tags = deckItem:getTags()
    if not tags:contains(gnTags.GAME_NIGHT) then tags:add(gnTags.GAME_NIGHT) end

    ---@type Texture
    local texture

    local special = gamePieceHandler.specials[fullType]
    local category = special and special.category or (#deckStates>1 and "Deck" or "Card")
    deckItem:setDisplayCategory(category)

    deckItem:getModData()["gameNight_sound"] = special and special.moveSound or "cardFlip"

    local name_suffix = #deckStates>1 and " ["..#deckStates.."]" or ""

    if flippedStates[#deckStates] ~= true then

        local tooltip = getTextOrNull("Tooltip_"..deckStates[#deckStates])
        if tooltip then deckItem:setTooltip(tooltip) end

        local cardName = deckStates[#deckStates]

        local nameOfCard = card.fetchAltName(cardName, deckItem)
        deckItem:setName(nameOfCard..name_suffix)

        local cardFaceType = special and special.cardFaceType or itemType

        local textureToUse = card.fetchAltIcon(cardName, deckItem)
        texture = getTexture("media/textures/Item_"..cardFaceType.."/"..textureToUse..".png")

        deckItem:getModData()["gameNight_textureInPlay"] = texture

    else
        local textureID = #deckStates>1 and "deck" or "card"

        local tooltip = getTextOrNull("Tooltip_"..itemType)
        if tooltip then deckItem:setTooltip(tooltip) end

        local itemName = #deckStates<=1 and getTextOrNull("IGUI_"..deckItem:getType()) or getItemNameFromFullType(deckItem:getFullType())
        deckItem:setName(itemName..name_suffix)

        texture = getTexture("media/textures/Item_"..itemType.."/"..textureID..".png")
        deckItem:getModData()["gameNight_textureInPlay"] = getTexture("media/textures/Item_"..itemType.."/FlippedInPlay.png")
    end

    if texture then deckItem:setTexture(texture) end

    local cont = deckItem:getContainer()
    local parent = cont and cont:getParent()
    if parent and instanceof(parent, "IsoPlayer") then
        gamePieceHandler.refreshInventory(parent)
    end
end


---@param drawnCard string
---@param deckItem InventoryItem
function card.generateCard(drawnCard, deckItem, flipped, locations)
    --sq=sq, offsets={x=wiX,y=wiY,z=wiZ}, container=container
    local newCard = instanceItem(deckItem:getType())
    if newCard then

        if type(drawnCard)~="table" then drawnCard = {drawnCard} end
        if type(flipped)~="table" then flipped = {flipped} end

        newCard:getModData()["gameNight_cardDeck"] = drawnCard
        newCard:getModData()["gameNight_cardFlipped"] = flipped

        if deckItem then card.handleDetails(deckItem) end
        card.handleDetails(newCard)

        ---@type IsoObject|IsoWorldInventoryObject
        local worldItem = locations and locations.worldItem or (deckItem and deckItem:getWorldItem())
        local wiX = (locations and locations.offsets and locations.offsets.x) or (worldItem and (worldItem:getWorldPosX()-worldItem:getX())) or 0
        local wiY = (locations and locations.offsets and locations.offsets.y) or (worldItem and (worldItem:getWorldPosY()-worldItem:getY())) or 0
        local wiZ = (locations and locations.offsets and locations.offsets.z) or (worldItem and (worldItem:getWorldPosZ()-worldItem:getZ())) or 0

        ---@type IsoGridSquare
        local sq = (locations and locations.sq) or (worldItem and worldItem:getSquare())
        if sq then
            sq:AddWorldInventoryItem(newCard, wiX, wiY, wiZ)
        else
            ---@type ItemContainer
            local container = (locations and locations.container) or (deckItem and deckItem:getContainer())
            if container then container:AddItem(newCard) end
        end

        return newCard
    end
end


function card._flipSpecificCard(deckItem, flipIndex)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if not deckStates then return end
    deckItem:getModData()["gameNight_cardFlipped"][flipIndex] = not currentFlipStates[flipIndex]
    card.handleDetails(deckItem)
end


function card.flipSpecificCard(deckItem, player, index, x, y, z)
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._flipSpecificCard, deckItem, index}, card.handleDetails, x, y, z)
    gamePieceHandler.playSound(deckItem, player)
end


function card._flipCard(deckItem)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if not deckStates then return end

    local handleFlippedDeck = {}
    local handleFlippedStates = {}

    for n=#deckStates, 1, -1 do
        table.insert(handleFlippedDeck, deckStates[n])
        table.insert(handleFlippedStates, (not currentFlipStates[n]))
    end

    deckItem:getModData()["gameNight_cardDeck"] = handleFlippedDeck
    deckItem:getModData()["gameNight_cardFlipped"] = handleFlippedStates
    card.handleDetails(deckItem)
end


function card.flipCard(deckItem, player, x, y, z, square)
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._flipCard, deckItem}, card.handleDetails, x, y, z, square)
    gamePieceHandler.playSound(deckItem, player)
end


function card.canMergeDecks(deckItemA, deckItemB)
    if (deckItemA:getType() ~= deckItemB:getType()) or (deckItemA == deckItemB) then return false end

    local deckB, flippedB = card.getDeckStates(deckItemB)
    if not deckB then return false end

    local deckA, flippedA = card.getDeckStates(deckItemA)
    if not deckA then return false end

    if (#deckA <= 300) and (#deckB <= 300) and (#deckA + #deckB <= 300) then return deckA, deckB, flippedA, flippedB end

    return false
end


function card._mergeDecks(player, deckItemA, deckA, deckItemB, deckB, flippedA, flippedB, index)
    index = index and math.min(#deckB+1,math.max(index,1)) or #deckB+1
    for i=#deckA, 1, -1 do
        table.insert(deckB, index, deckA[i])
        table.insert(flippedB, index, flippedA[i])
    end
    card.handleDetails(deckItemB)
    gamePieceHandler.safelyRemoveGamePiece(deckItemA, player)
    gamePieceHandler.refreshInventory(player)
end


---@param deckItemA InventoryItem
---@param deckItemB InventoryItem
function card.mergeDecks(deckItemA, deckItemB, player, index)

    local deckA, deckB, flippedA, flippedB = card.canMergeDecks(deckItemA, deckItemB)
    if not deckA or not deckB then return end

    gamePieceHandler.pickupGamePiece(player, deckItemA)
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItemB, {card._mergeDecks, player, deckItemA, deckA, deckItemB, deckB, flippedA, flippedB, index}, card.handleDetails)
    gamePieceHandler.playSound(deckItemB, player)
end


---@param player IsoPlayer|IsoGameCharacter
function card._drawCards(num, deckItem, player, locations, faceUp, ignoreProcess)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if not deckStates then return end

    local draw = #deckStates
    num = math.min(num, draw)

    local drawnCards = {}
    local drawnFlippedStates = {}

    local newCard

    if num < draw then
        for i=num, 1, -1 do
            local topCard = #deckStates
            local drawnCard, drawnFlip = deckStates[topCard], currentFlipStates[topCard]
            deckStates[topCard] = nil
            if currentFlipStates then currentFlipStates[topCard] = nil end
            table.insert(drawnCards, drawnCard)
            local flipState = drawnFlip
            if faceUp then flipState = false end
            table.insert(drawnFlippedStates, flipState)
        end
        newCard = card.generateCard(drawnCards, deckItem, drawnFlippedStates, locations)
    else
        newCard = deckItem
        if faceUp then
            local flipStates = {}
            for i=1, #currentFlipStates do flipStates[i] = false end
            deckItem:getModData()["gameNight_cardFlipped"] = flipStates
        end
    end

    if newCard then
        gamePieceHandler.playSound(newCard, player)
        card.processOnDraw(deckItem)
        if (not ignoreProcess) then card.processCardToHand(newCard, player) end
    end

    return newCard
end


function card.processOnDraw(deckItem)
    local fullType = deckItem:getFullType()
    local special = gamePieceHandler.specials[fullType]
    local onDraw = special and special.onDraw
    if onDraw and card[onDraw] then card[onDraw](deckItem) end
end


function card.processCardToHand(deckItem, player)
    if not player then return end

    local inHand = player and player:getPrimaryHandItem()
    local heldCards = inHand and card.isDeckItem(inHand)

    if player and deckItem:getContainer() then
        if not inHand then player:setPrimaryHandItem(deckItem) end
        if heldCards then
            local deckA, deckB, flippedA, flippedB = card.canMergeDecks(deckItem, inHand)
            if not deckA or not deckB then return end
            card._mergeDecks(player, deckItem, deckA, inHand, deckB, flippedA, flippedB)
        end
    end
end


function card.drawCards_isValid(deckItem, player, num)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if deckStates and #deckStates >= num then return true end
    return false
end


---@param deckItem InventoryItem
function card.drawCards(deckItem, player, num)
    local locations = {container=player:getInventory()}
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    local func = (num >= #deckStates) and "pickupGamePiece" or "pickupAndPlaceGamePiece"
    gamePieceHandler[func](player, deckItem, {card._drawCards, num, deckItem, player, locations, true}, card.handleDetails)
end


function card.drawCard(deckItem, player) card.drawCards(deckItem, player, 1) end
---@param num number
---@param deckItem InventoryItem
---@param player IsoPlayer|IsoGameCharacter
function card._drawToHandItem(num, deckItem, player)
    local deckStates, deckFlipped = card.getDeckStates(deckItem)
    if not deckStates or #deckStates == 0 then return end
    num = math.min(num, #deckStates)

    local primary = player:getPrimaryHandItem()
    local primaryStates, primaryFlipped = primary and card.getDeckStates(primary)

    if primaryStates and primaryFlipped then
        for _ = 1, num do
            if #deckStates == 0 then break end
            table.insert(primaryStates, 1, table.remove(deckStates))
            table.insert(primaryFlipped, 1, table.remove(deckFlipped) or false)
        end
        card.handleDetails(deckItem)
        card.handleDetails(primary)
    else
        local drawnCards, drawnFlipped = {}, {}
        for _ = 1, num do
            if #deckStates == 0 then break end
            table.insert(drawnCards, 1, table.remove(deckStates))
            table.insert(drawnFlipped, 1, table.remove(deckFlipped) or false)
        end
        if #drawnCards == 0 then return end

        local playerInv = player:getInventory()
        local newCard
        if #deckStates == 0 then
            -- All cards drawn — reuse the deck item itself rather than generating a new one.
            deckItem:getModData()["gameNight_cardDeck"] = drawnCards
            deckItem:getModData()["gameNight_cardFlipped"] = drawnFlipped
            newCard = deckItem
        else
            newCard = card.generateCard(drawnCards, deckItem, drawnFlipped, {container = playerInv})
        end

        card.handleDetails(deckItem)
        if newCard then
            card.handleDetails(newCard)
            if not playerInv:contains(newCard) then playerInv:AddItem(newCard) end
            player:setPrimaryHandItem(newCard)
        end
    end

    gamePieceHandler.playSound(deckItem, player)
    gamePieceHandler.refreshInventory(player)
end


---@param deckItem InventoryItem
---@param player IsoPlayer|IsoGameCharacter
---@param num number
function card.drawToHandItem(deckItem, player, num)
    local deckStates = card.getDeckStates(deckItem)
    if not deckStates or #deckStates == 0 then return end
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem,
        {card._drawToHandItem, math.min(num or 1, #deckStates), deckItem, player}, card.handleDetails)
end

function card._dealCards(deckItem, player, n, x, y)
    local worldItem = deckItem:getWorldItem()
    x = x or worldItem and (worldItem:getWorldPosX()-worldItem:getX()) or ZombRandFloat(0.48,0.52)
    y = y or worldItem and (worldItem:getWorldPosY()-worldItem:getY()) or ZombRandFloat(0.48,0.52)
    local z = worldItem and (worldItem:getWorldPosZ()-worldItem:getZ()) or 0
    ---@type IsoGridSquare
    local sq = (worldItem and worldItem:getSquare()) or (gameNightWindow and gameNightWindow.instance and gameNightWindow.instance.square)
    card._drawCards(n, deckItem, player, { sq=sq, offsets={x=x,y=y,z=z} }, nil, true)
end


function card.dealCards(deckItem, player, n, x, y, z)
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._dealCards, deckItem, player, n, x, y}, card.handleDetails)
end


function card.dealCard(deckItem, player, x, y, z)
    card.dealCards(deckItem, player, 1, x, y, z)
end


function card._drawCardIndex(deckItem, player, drawIndex, locations, ignoreProcess)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if not deckStates then return deckItem end

    local deckCount = #deckStates
    if deckCount <= 1 then
        card.processOnDraw(deckItem)
        if player and (not ignoreProcess) then card.processCardToHand(deckItem, player) end
        return deckItem
    end

    drawIndex = drawIndex or ZombRand(deckCount)+1

    local drawnCard = deckStates[drawIndex]
    local drawnFlipped = currentFlipStates[drawIndex]
    table.remove(deckStates, drawIndex)
    table.remove(currentFlipStates, drawIndex)

    local newCard = card.generateCard(drawnCard, deckItem, drawnFlipped, locations)
    card.processOnDraw(newCard)
    if player and (not ignoreProcess) then card.processCardToHand(newCard, player) end
    return newCard
end


---@param deckItem InventoryItem
function card.drawRandCard(deckItem, player, x, y, z)
    local locations = {container=player:getInventory()}
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._drawCardIndex, deckItem, player, nil, locations}, card.handleDetails, x, y, z)
    gamePieceHandler.playSound(deckItem, player)
end


---@param deckItem InventoryItem
function card.drawSpecificCard(deckItem, player, index, x, y, z)
    local locations = {container=player:getInventory()}
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._drawCardIndex, deckItem, player, index, locations}, card.handleDetails, x, y, z)
    gamePieceHandler.playSound(deckItem, player)
end


function card._shuffleCards(deckItem)
    local deckStates, currentFlipStates = card.getDeckStates(deckItem)
    if not deckStates then return end

    for origIndex = #deckStates, 2, -1 do
        local shuffledIndex = ZombRand(origIndex)+1
        currentFlipStates[origIndex], currentFlipStates[shuffledIndex] = currentFlipStates[shuffledIndex], currentFlipStates[origIndex]
        deckStates[origIndex], deckStates[shuffledIndex] = deckStates[shuffledIndex], deckStates[origIndex]
    end
end


function card.shuffleCards(deckItem, player, x, y, z)
    gamePieceHandler.pickupAndPlaceGamePiece(player, deckItem, {card._shuffleCards, deckItem}, card.handleDetails, x, y, z)
    gamePieceHandler.playSound(deckItem, player, "cardShuffle")
end


function card._searchDeck(deckItem, player)
    if card.isDeckItem(deckItem) then gameNightDeckSearch.open(player, deckItem) end
end


function card.searchDeck(deckItem, player)
    local onPickUp = card._searchDeck
    local pickedUp, x, y, z = gamePieceHandler.pickupGamePiece(player, deckItem, {onPickUp, deckItem, player}, card.handleDetails)
    local playerInv = player:getInventory()
    local itemContainer = deckItem:getContainer()
    gamePieceHandler.playSound(deckItem, player)
    if not pickedUp and itemContainer and itemContainer == playerInv then
        card._searchDeck(deckItem, player)
    end
end


function card.examine(gamePiece, player, indexIfCard)
    gamePieceHandler.examine(gamePiece, player, indexIfCard)
end


return gamePieceHandler
