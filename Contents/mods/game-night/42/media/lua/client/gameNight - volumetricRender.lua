local volumetricRender = {}

volumetricRender.loadedTextures = {}

function volumetricRender.loadTexture(texture)
    if not texture then return end
    if volumetricRender.loadedTextures[texture] == nil then
        volumetricRender.loadedTextures[texture] = getTexture("media/textures/modelTextures/"..texture..".png") or false
    end
    return volumetricRender.loadedTextures[texture]
end

--- POKER CHIP STACKS
function volumetricRender.DrawTexturePokerChip(UI, texture, sideTexture, centerX, centerY, rotation, height, segments, r, g, b, a)
    if UI.javaObject == nil or not UI:isVisible() then return end
    local halfTextureWidth = texture:getWidth() / 2
    local halfTextureHeight = texture:getHeight() / 2
    local rotatedAngle = math.rad(180.0 + rotation)
    local cosRotatedAngle = math.cos(rotatedAngle)
    local sinRotatedAngle = math.sin(rotatedAngle)
    local xOffset1 = cosRotatedAngle * halfTextureWidth
    local yOffset1 = sinRotatedAngle * halfTextureWidth
    local xOffset2 = cosRotatedAngle * halfTextureHeight
    local yOffset2 = sinRotatedAngle * halfTextureHeight
    local javaObjCenterX = UI.javaObject:getAbsoluteX() + centerX
    local javaObjCenterY = UI.javaObject:getAbsoluteY() + centerY
    local x1 = (xOffset1 - yOffset2) + javaObjCenterX
    local y1 = (xOffset2 + yOffset1) + javaObjCenterY
    local x2 = (-xOffset1 - yOffset2) + javaObjCenterX
    local y2 = (xOffset2 - yOffset1) + javaObjCenterY
    local x3 = (-xOffset1 + yOffset2) + javaObjCenterX
    local y3 = (-xOffset2 - yOffset1) + javaObjCenterY
    local x4 = (xOffset1 + yOffset2) + javaObjCenterX
    local y4 = (-xOffset2 + yOffset1) + javaObjCenterY

    local stackTexture = sideTexture and volumetricRender.loadTexture(sideTexture) or volumetricRender.roundStackTexture
    local segmentAngle = 360 / (segments*2)

    local function adjustFacePoints(segment, h)

        local adjustedPoints = {}

        local angle = math.rad((segment) * segmentAngle)
        local radius = halfTextureWidth
        adjustedPoints[1] = javaObjCenterX + radius * math.cos(angle - math.rad(90))  -- x1
        adjustedPoints[2] = javaObjCenterY - radius * math.sin(angle - math.rad(90))  -- y1
        angle = angle + math.rad(segmentAngle)
        adjustedPoints[3] = javaObjCenterX + radius * math.cos(angle - math.rad(90))  -- x2
        adjustedPoints[4] = javaObjCenterY - radius * math.sin(angle - math.rad(90))  -- y2

        local bottomRadius = radius * math.cos(math.rad(segmentAngle / 2))
        adjustedPoints[5] = javaObjCenterX + bottomRadius * math.cos(angle - math.rad(90))  -- x3
        adjustedPoints[6] = javaObjCenterY - bottomRadius * math.sin(angle - math.rad(90)) + h  -- y3
        angle = angle - math.rad(segmentAngle)
        adjustedPoints[7] = javaObjCenterX + bottomRadius * math.cos(angle - math.rad(90))  -- x4
        adjustedPoints[8] = javaObjCenterY - bottomRadius * math.sin(angle - math.rad(90)) + h  -- y4

        return adjustedPoints
    end

    local quarter = segments/2
    local side = 0
    for i = -quarter, quarter-1 do
        side=side+1
        local adjustedFacePoints = adjustFacePoints(i, height)
        volumetricRender.DrawTextureSide(stackTexture, -(height+1), adjustedFacePoints, (side % 2 == 0) and 0.9 or r, (side % 2 == 0) and 0.9 or g, (side % 2 == 0) and 0.9 or b, 1)
    end

    getRenderer():render(texture, x1, y1-height, x2, y2-height, x3, y3-height, x4, y4-height, 1, 1, 1, 1, nil)
end


--- ROUND STACKS
volumetricRender.roundStackTexture = getTexture("media/textures/modelTextures/roundStack.png")
function volumetricRender.DrawTextureRoundFace(UI, texture, sideTexture, centerX, centerY, rotation, height, segments, r, g, b, a)
    if UI.javaObject == nil or not UI:isVisible() then return end
    local halfTextureWidth = texture:getWidth() / 2
    local halfTextureHeight = texture:getHeight() / 2
    local rotatedAngle = math.rad(180.0 + rotation)
    local cosRotatedAngle = math.cos(rotatedAngle)
    local sinRotatedAngle = math.sin(rotatedAngle)
    local xOffset1 = cosRotatedAngle * halfTextureWidth
    local yOffset1 = sinRotatedAngle * halfTextureWidth
    local xOffset2 = cosRotatedAngle * halfTextureHeight
    local yOffset2 = sinRotatedAngle * halfTextureHeight
    local javaObjCenterX = UI.javaObject:getAbsoluteX() + centerX
    local javaObjCenterY = UI.javaObject:getAbsoluteY() + centerY
    local x1 = (xOffset1 - yOffset2) + javaObjCenterX
    local y1 = (xOffset2 + yOffset1) + javaObjCenterY
    local x2 = (-xOffset1 - yOffset2) + javaObjCenterX
    local y2 = (xOffset2 - yOffset1) + javaObjCenterY
    local x3 = (-xOffset1 + yOffset2) + javaObjCenterX
    local y3 = (-xOffset2 - yOffset1) + javaObjCenterY
    local x4 = (xOffset1 + yOffset2) + javaObjCenterX
    local y4 = (-xOffset2 + yOffset1) + javaObjCenterY

    local stackTexture = sideTexture and volumetricRender.loadTexture(sideTexture) or volumetricRender.roundStackTexture
    local segmentAngle = 360 / (segments*2)

    local function adjustFacePoints(segment, h)

        local adjustedPoints = {}

        local angle = math.rad((segment) * segmentAngle)
        local radius = halfTextureWidth
        adjustedPoints[1] = javaObjCenterX + radius * math.cos(angle - math.rad(90))  -- x1
        adjustedPoints[2] = javaObjCenterY - radius * math.sin(angle - math.rad(90))  -- y1
        angle = angle + math.rad(segmentAngle)
        adjustedPoints[3] = javaObjCenterX + radius * math.cos(angle - math.rad(90))  -- x2
        adjustedPoints[4] = javaObjCenterY - radius * math.sin(angle - math.rad(90))  -- y2

        local bottomRadius = radius * math.cos(math.rad(segmentAngle / 2))
        adjustedPoints[5] = javaObjCenterX + bottomRadius * math.cos(angle - math.rad(90))  -- x3
        adjustedPoints[6] = javaObjCenterY - bottomRadius * math.sin(angle - math.rad(90)) + h  -- y3
        angle = angle - math.rad(segmentAngle)
        adjustedPoints[7] = javaObjCenterX + bottomRadius * math.cos(angle - math.rad(90))  -- x4
        adjustedPoints[8] = javaObjCenterY - bottomRadius * math.sin(angle - math.rad(90)) + h  -- y4

        return adjustedPoints
    end

    local quarter = segments/2
    for i = -quarter, quarter-1 do
        local adjustedFacePoints = adjustFacePoints(i, height)
        volumetricRender.DrawTextureSide(stackTexture, -(height+1), adjustedFacePoints, r, g, b, 1)
    end

    getRenderer():render(texture, x1, y1-height, x2, y2-height, x3, y3-height, x4, y4-height, 1, 1, 1, 1, nil)
end

function volumetricRender.DrawTextureSide(texture, height, facePoints, r, g, b, a)
    local x1, y1, x2, y2, x3, y3, x4, y4 = unpack(facePoints)
    getRenderer():render(texture, x1, y1+height, x2, y2+height, x3, y3+height, x4, y4+height, r, g, b, a, nil)
end




--- CARD STACKS
volumetricRender.cardStackTexture = getTexture("media/textures/modelTextures/cardStack.png")
function volumetricRender.DrawTextureCardFace(UI, texture, sideTexture, centerX, centerY, rotation, height, ignore, r, g, b, a)
    if UI.javaObject == nil or not UI:isVisible() then return end
    local halfTextureWidth, halfTextureHeight = texture:getWidth() / 2, texture:getHeight() / 2
    local rotatedAngle = math.rad(180.0 + rotation)
    local cosRotatedAngle, sinRotatedAngle = math.cos(rotatedAngle), math.sin(rotatedAngle)
    local xOffset1, yOffset1 = cosRotatedAngle * halfTextureWidth, sinRotatedAngle * halfTextureWidth
    local xOffset2, yOffset2 = cosRotatedAngle * halfTextureHeight, sinRotatedAngle * halfTextureHeight
    local javaObjCenterX, javaObjCenterY = UI.javaObject:getAbsoluteX() + centerX, UI.javaObject:getAbsoluteY() + centerY
    local x1, y1 = (xOffset1 - yOffset2) + javaObjCenterX, (xOffset2 + yOffset1) + javaObjCenterY
    local x2, y2 = (-xOffset1 - yOffset2) + javaObjCenterX, (xOffset2 - yOffset1) + javaObjCenterY
    local x3, y3 = (-xOffset1 + yOffset2) + javaObjCenterX, (-xOffset2 - yOffset1) + javaObjCenterY
    local x4, y4 = (xOffset1 + yOffset2) + javaObjCenterX, (-xOffset2 + yOffset1) + javaObjCenterY

    if height > 0 then
        local facePoints = {x1, y1, x2, y2, x3, y3, x4, y4}
        local cardStackTexture = sideTexture and volumetricRender.loadTexture(sideTexture) or volumetricRender.cardStackTexture
        if rotation >= 270 then
            volumetricRender.DrawTextureLeftEdgeSide(cardStackTexture, -height, facePoints, r*0.6, g*0.6, b*0.6, 1)
            if rotation ~= 270 then volumetricRender.DrawTextureBottomEdgeSide(cardStackTexture, -height, facePoints, r, g, b, 1) end

        elseif rotation >= 180 then
            if rotation ~= 180 then volumetricRender.DrawTextureLeftEdgeSide(cardStackTexture, -height, facePoints, r, g, b, 1) end
            volumetricRender.DrawTextureTopEdgeSide(cardStackTexture, -height, facePoints, r*0.6, g*0.6, b*0.6, 1)

        elseif rotation >= 90 then
            volumetricRender.DrawTextureRightEdgeSide(cardStackTexture, -height, facePoints, r*0.6, g*0.6, b*0.6, 1)
            if rotation ~= 90 then volumetricRender.DrawTextureTopEdgeSide(cardStackTexture, -height, facePoints, r, g, b, 1) end

        elseif rotation >= 0 then
            if rotation ~= 0 then volumetricRender.DrawTextureRightEdgeSide(cardStackTexture, -height, facePoints, r, g, b, 1) end
            volumetricRender.DrawTextureBottomEdgeSide(cardStackTexture, -height, facePoints, r*0.6, g*0.6, b*0.6, 1)
        end
    end
    getRenderer():render(texture, x1, y1-height, x2, y2-height, x3, y3-height, x4, y4-height, 1, 1, 1, 1, nil)
end

function volumetricRender.DrawTextureTopEdgeSide(texture, height, facePoints, r, g, b, a)
    local fX1, fY1, fX2, fY2, fX3, fY3, fX4, fY4 = unpack(facePoints)
    local x1, y1, x2, y2, x3, y3, x4, y4 = fX1, fY1+height, fX2, fY2+height, fX2, fY2, fX1, fY1
    getRenderer():render(texture, x1, y1, x2, y2, x3, y3, x4, y4, r, b, g, a, nil)
end

function volumetricRender.DrawTextureBottomEdgeSide(texture, height, facePoints, r, g, b, a)
    local fX1, fY1, fX2, fY2, fX3, fY3, fX4, fY4 = unpack(facePoints)
    local x1, y1, x2, y2, x3, y3, x4, y4 = fX4, fY4, fX3, fY3, fX3, fY3 + height, fX4, fY4 + height
    getRenderer():render(texture, x1, y1, x2, y2, x3, y3, x4, y4, r, b, g, a, nil)
end

function volumetricRender.DrawTextureLeftEdgeSide(texture, height, facePoints, r, g, b, a)
    local fX1, fY1, fX2, fY2, fX3, fY3, fX4, fY4 = unpack(facePoints)
    local x1, y1, x2, y2, x3, y3, x4, y4 = fX1, fY1, fX4, fY4, fX4, fY4 + height, fX1, fY1 + height
    getRenderer():render(texture, x1, y1, x2, y2, x3, y3, x4, y4, r, g, b, a, nil)
end

function volumetricRender.DrawTextureRightEdgeSide(texture, height, facePoints, r, g, b, a)
    local fX1, fY1, fX2, fY2, fX3, fY3, fX4, fY4 = unpack(facePoints)
    local x1, y1, x2, y2, x3, y3, x4, y4 = fX3, fY3, fX2, fY2, fX2, fY2 + height, fX3, fY3 + height
    getRenderer():render(texture, x1, y1, x2, y2, x3, y3, x4, y4, r, g, b, a, nil)
end


return volumetricRender