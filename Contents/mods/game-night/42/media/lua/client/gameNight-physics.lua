local gameNightPhysics = {}

-- Keyed by item:getID(). Cleared when an object comes to rest.
gameNightPhysics.objects = {}

-- Recognised fields:
-- friction (number 0–1) velocity multiplier per tick.
-- restitution (number 0–1) speed kept after a wall bounce.
-- angularFriction (number 0–1) angular-velocity multiplier/tick.
-- minSpeed (number) speed below which the object rests.
-- duration (integer) max ticks before forcing rest.
-- collide (bool) enable elastic circle-collision against other collidable objects.
-- onBounce (function(obj, window)) called on every wall hit (and on object collision when collide=true).
-- onRest (function(obj, window)) called when the object comes to rest.
-- render (function(obj, element, window)) draws the object each frame.
-- If absent, the element texture is drawn at physics position.
gameNightPhysics.types = {}


---@param typeName string
---@param props table
function gameNightPhysics.registerType(typeName, props)
    gameNightPhysics.types[typeName] = props
end


---@param item InventoryItem
---@param typeName string
---@param params table { x, y, vx, vy, rot, angularV, mass, noRotate, data }
function gameNightPhysics.spawn(item, typeName, params)
    local props = gameNightPhysics.types[typeName]
    if not props then return end
    params = params or {}
    gameNightPhysics.objects[item:getID()] = {
        item = item,
        typeName = typeName,
        props = props,
        x = params.x or 0,
        y = params.y or 0,
        vx = params.vx or 0,
        vy = params.vy or 0,
        rot = params.rot or 0,
        angularV = params.angularV or 0,
        ticks = 0,
        maxTicks = props.duration or 90,
        mass = params.mass or 1,
        noRotate = params.noRotate,
        data = params.data or {},
    }
end


---@param item InventoryItem
function gameNightPhysics.remove(item)
    gameNightPhysics.objects[item:getID()] = nil
end


local minKnockSpeed = 2.5

---@param obj table
---@param element table
---@param window gameNightWindow
function gameNightPhysics.resolveCollisions(obj, element, window)
    local r1 = math.min(element.w, element.h) / 2
    local id1 = obj.item:getID()

    for id2, other in pairs(gameNightPhysics.objects) do
        if id2 ~= id1 and other.props.collide then
            local otherEl = window.elements[id2]
            if otherEl then
                local r2 = math.min(otherEl.w, otherEl.h) / 2
                local dx = other.x - obj.x
                local dy = other.y - obj.y
                local distSq = dx * dx + dy * dy
                local minDist = r1 + r2

                if distSq < minDist * minDist and distSq > 0 then
                    local dist = math.sqrt(distSq)
                    local nx = dx / dist
                    local ny = dy / dist

                    local halfOverlap = (minDist - dist) * 0.5
                    obj.x = obj.x - nx * halfOverlap
                    obj.y = obj.y - ny * halfOverlap
                    other.x = other.x + nx * halfOverlap
                    other.y = other.y + ny * halfOverlap

                    local rvx = obj.vx - other.vx
                    local rvy = obj.vy - other.vy
                    local dot = rvx * nx + rvy * ny

                    if dot > 0 then
                        local e = (obj.props.restitution + other.props.restitution) * 0.5
                        local invMassSum = (1 / obj.mass) + (1 / other.mass)
                        local J = -(1 + e) * dot / invMassSum

                        obj.vx = obj.vx + J / obj.mass * nx
                        obj.vy = obj.vy + J / obj.mass * ny
                        other.vx = other.vx - J / other.mass * nx
                        other.vy = other.vy - J / other.mass * ny

                        if obj.props.onBounce then obj.props.onBounce(obj, window) end
                        if other.props.onBounce then other.props.onBounce(other, window) end
                    end
                end
            end
        end
    end

    for id2, el in pairs(window.elements) do
        if id2 ~= id1 and el.solid and not el.locked and not gameNightPhysics.objects[id2] then
            local r2 = math.min(el.w, el.h) / 2
            local dx = el.x - obj.x
            local dy = el.y - obj.y
            local distSq = dx * dx + dy * dy
            local minDist = r1 + r2

            if distSq < minDist * minDist and distSq > 0 then
                local dist = math.sqrt(distSq)
                local nx = dx / dist
                local ny = dy / dist

                obj.x = obj.x - nx * (minDist - dist)
                obj.y = obj.y - ny * (minDist - dist)

                local dot = obj.vx * nx + obj.vy * ny

                if dot > 0 then
                    local m1 = obj.mass
                    local m2 = el.mass or 1
                    local invMassSum = (1 / m1) + (1 / m2)
                    local e = obj.props.restitution or 1
                    local J = -(1 + e) * dot / invMassSum

                    obj.vx = obj.vx + J / m1 * nx
                    obj.vy = obj.vy + J / m1 * ny

                    local kVx = -J / m2 * nx
                    local kVy = -J / m2 * ny
                    local knockSpeed = math.sqrt(kVx * kVx + kVy * kVy)

                    if knockSpeed > minKnockSpeed then
                        gameNightPhysics.spawn(el.item, el.physicsType or "piece", {
                            x = el.x,
                            y = el.y,
                            rot = el.rot,
                            vx = kVx,
                            vy = kVy,
                            angularV = el.noRotate and 0 or ZombRandFloat(-3, 3),
                            mass = m2,
                            noRotate = el.noRotate,
                        })
                    end

                    if obj.props.onBounce then obj.props.onBounce(obj, window) end
                end
            end
        end
    end
end


---@param obj table physics object
---@param element table board element (has .w, .h)
---@param window gameNightWindow
---@return boolean stillActive
function gameNightPhysics.update(obj, element, window)
    local props = obj.props
    obj.ticks = obj.ticks + 1

    obj.x = obj.x + obj.vx
    obj.y = obj.y + obj.vy

    local friction = props.friction or 0.96
    local angularFriction = props.angularFriction or 0.95
    obj.vx = obj.vx * friction
    obj.vy = obj.vy * friction

    local angSpeed = 0
    if not obj.noRotate then
        obj.rot = obj.rot + obj.angularV
        obj.angularV = obj.angularV * angularFriction
        angSpeed = math.abs(obj.angularV)
    end

    local hw = element.w / 2
    local hh = element.h / 2
    local restitution = props.restitution or 1.0
    local bounced = false
    local b = window.bounds

    if obj.x - hw < b.x1 then
        obj.x = b.x1 + hw
        obj.vx = math.abs(obj.vx) * restitution
        bounced = true
    end
    if obj.x + hw > b.x2 then
        obj.x = b.x2 - hw
        obj.vx = -math.abs(obj.vx) * restitution
        bounced = true
    end
    if obj.y - hh < b.y1 then
        obj.y = b.y1 + hh
        obj.vy = math.abs(obj.vy) * restitution
        bounced = true
    end
    if obj.y + hh > b.y2 then
        obj.y = b.y2 - hh
        obj.vy = -math.abs(obj.vy) * restitution
        bounced = true
    end

    if bounced and props.onBounce then
        props.onBounce(obj, window)
    end

    if props.collide then
        gameNightPhysics.resolveCollisions(obj, element, window)
    end

    local speed = math.sqrt(obj.vx * obj.vx + obj.vy * obj.vy)
    local minSpeed = props.minSpeed or 0.5
    local resting = speed < 0.3
                  or (speed < minSpeed and angSpeed < 0.05)
                  or obj.ticks >= obj.maxTicks

    if resting then
        gameNightPhysics.objects[obj.item:getID()] = nil
        if props.onRest then props.onRest(obj, window) end
        return false
    end

    return true
end


---@param obj table
---@param element table
---@param window gameNightWindow
function gameNightPhysics.draw(obj, element, window)
    local render = obj.props.render
    if render then
        render(obj, element, window)
    else
        local tex = element.tex
        if tex then window:DrawTextureAngle(tex, obj.x, obj.y, obj.rot, 1, 1, 1, 0.9) end
    end
end


---@param obj table
---@param element table
---@param window gameNightWindow
---@return number scaledX
---@return number scaledY
function gameNightPhysics.toWorldCoords(obj, element, window)
    local wW = window.width - window.padding * 2
    local wH = window.height - window.padding * 2
    local sx = math.min(math.max((obj.x - element.w / 2) / wW, 0), 1)
    local sy = math.min(math.max((obj.y - element.h / 2) / wH, 0), 1)
    return sx, sy
end


return gameNightPhysics