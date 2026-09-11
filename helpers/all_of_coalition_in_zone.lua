--- Function to check if all of a set of unit types are in a specified zone for a given coalition
--- @param zoneName string - The name of the zone to check
--- @param coalitionType number - The coalition to check (e.g., coalition.side.BLUE)
--- @param unitCategory number|nil - the Group.Category of targeted type
--- @return boolean - Returns true if all specified unit types from the coalition are in the zone, false otherwise
local function allOfCoalitionInZone(zoneName, coalitionType, unitCategory)
    -- 1. CHEAPEST CHECK FIRST: Look up the static zone data
    local zone = trigger.misc.getZone(zoneName)
    if not zone then
        return false
    end

    -- 2. DYNAMIC CHECK SECOND: Scan the active mission state for groups
    local groups = coalition.getGroups(coalitionType, unitCategory)
    if not groups or #groups == 0 then
        return false
    end

    -- 3. MATH PREPARATION: Cache the squared radius once
    local zonePos = zone.point
    local zoneRadiusSq = zone.radius * zone.radius

    local totalUnits = 0
    local unitsInZone = 0

    for _, group in ipairs(groups) do
        local units = group:getUnits()
        for _, unit in ipairs(units) do
            if unit:isExist() and unit:getLife() > 1 then
                totalUnits = totalUnits + 1

                -- Calculate 2D distance between unit and zone center
                local unitPos = unit:getPosition().p
                local dx = unitPos.x - zonePos.x
                local dz = unitPos.z - zonePos.z
                local distanceSq = (dx * dx) + (dz * dz)

                if distanceSq <= zoneRadiusSq then
                    unitsInZone = unitsInZone + 1
                end
            end
        end
    end

    -- Returns true only if there is at least 1 unit and all of them are inside
    return totalUnits > 0 and (totalUnits == unitsInZone)
end

MagnusDCSScripting.allOfCoalitionInZone = allOfCoalitionInZone
