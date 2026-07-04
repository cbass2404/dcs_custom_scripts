---@type damageHandler
local damageHandler = {}

function damageHandler:onEvent(event)
    -- Fail silently for unhandled frames to protect CPU performance
    if not event.target or not event.target.isExist or not event.target:isExist() or not event.initiator or
        not event.initiator:getCoalition() == coalition.side.BLUE or not event.weapon:isExist() then
        return
    end

    local isDamageEvent = event.id == world.event.S_EVENT_HIT or event.id == world.event.S_EVENT_DEAD
    if not isDamageEvent then
        return
    end

    local category = event.target:getCategory()
    local desc = event.target:getDesc()

    if not (category == Object.Category.SCENERY) or not desc or not desc.attributes or
        not desc.attributes["Buildings"] or desc.attributes["Bridges"] or desc.attributes["Fortifications"] then
        return
    end

    for _, tracker in pairs(MagnusDCSScripting.activeDamageTrackers) do
        local inZone, uniqueId = damageHandler:targetInZone(event.target, tracker.zoneName)

        if not uniqueId then
            env.info("[MagnusDCSScripting Damage Tracker Handler]: ERROR - Missing unique ID for unit in zone " ..
                         tracker.zoneName)
            return
        end

        if inZone then
            tracker:onBuildingHit(uniqueId)
            return -- Exit tracking loop immediately once target zone is handled
        end
    end
end

function damageHandler:targetInZone(object, zoneName)
    if not object or not zoneName then
        env.info("[MagnusDCSScripting Damage Tracker Handler]: ERROR - Missing unit or zone data for inZone()")
        return false, nil
    end

    local triggerZone = trigger.misc.getZone(zoneName)
    if not triggerZone then
        env.info("[MagnusDCSScripting Damage Tracker Handler]: ERROR - Missing trigger zone: " .. tostring(zoneName))
        return false, nil
    end

    local hitPos = object:getPoint()
    local zonePos = triggerZone.point
    local zoneRadius = triggerZone.radius

    local dx = zonePos.x - hitPos.x
    local dz = zonePos.z - hitPos.z

    -- HIGH-PERFORMANCE OPTIMIZATION: Compare squared bounds to eliminate math.sqrt entirely
    local distanceSquared = (dx * dx) + (dz * dz)
    local radiusSquared = zoneRadius * zoneRadius
    local inZone = distanceSquared <= radiusSquared

    local uniqueId = string.format("%.1f_%.1f", hitPos.x, hitPos.z)

    return inZone, uniqueId

end

MagnusDCSScripting.damageHandler = damageHandler

