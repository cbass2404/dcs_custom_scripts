---@type table<string, damageTracker>
local activeDamageTrackers = {}
CustomClasses.activeDamageTrackers = activeDamageTrackers

--- damageHandler Class
--- This class is responsible for handling DCS World events related to damage tracking and delegating them to the appropriate damageTracker instances based on the location of the hit.
--- @class damageHandler
local damageHandler = {}

--- damageHandler:onEvent
--- Called when an event occurs that may affect damage tracking.
---@param event any
---@return nil
function damageHandler:onEvent(event)
    -- Fail silently for unhandled frames to protect CPU performance
    if not event or not event.id or not event.target then
        return
    end

    local isDamageEvent = event.id == world.event.S_EVENT_HIT or event.id == world.event.S_EVENT_DEAD
    if not isDamageEvent then
        return
    end

    local unit = event.target
    if not unit or not unit:isExist() then
        return
    end

    local isBuilding = Object.getCategory(unit) == Object.Category.SCENERY
    if not isBuilding then
        return
    end

    for _, tracker in pairs(CustomClasses.activeDamageTrackers) do
        local inZone, uniqueId = damageHandler:targetInZone(unit, tracker.zoneName)

        if not uniqueId then
            env.info("[Magnus Damage Tracker]: ERROR - Missing unique ID for unit in zone " .. tracker.zoneName)
            return
        end

        if inZone then
            tracker:onBuildingHit(uniqueId)
            return -- Exit tracking loop immediately once target zone is handled
        end
    end
end

--- damageHandler:targetInZone
--- Checks if the scenery object is within the specified zone.
---@param object Object The hit structural asset
---@param zoneName string Target trigger zone boundary name
---@return boolean, string|nil Returns evaluation status and absolute coordinate string identity
function damageHandler:targetInZone(object, zoneName)
    if not object or not zoneName then
        env.info("[Magnus Damage Tracker]: ERROR - Missing unit or zone data for inZone()")
        return false, nil
    end

    local triggerZone = trigger.misc.getZone(zoneName)
    if not triggerZone then
        env.info("[Magnus Damage Tracker]: ERROR - Missing trigger zone: " .. tostring(zoneName))
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

CustomClasses.damageHandler = damageHandler

world.addEventHandler(damageHandler)
