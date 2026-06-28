---@type damageTracker
local damageTracker = {}

function damageTracker:new(zoneName, damageThreshold, eventTriggerFlag)
    if not zoneName or not damageThreshold or not eventTriggerFlag then
        env.info(
            "[MagnusDCSScripting Damage Tracker]: ERROR - Missing required parameters for DamageTracker constructor.")
        return nil
    end

    local instance = setmetatable({}, {
        __index = self
    })

    trigger.action.setUserFlag(eventTriggerFlag, 0)

    instance.collateralDamage = {}
    instance.damageThreshold = tonumber(damageThreshold) or 5
    instance.eventTriggerFlag = tostring(eventTriggerFlag)
    instance.totalDamage = 0
    instance.zoneName = zoneName

    return instance
end

-- HIGH-PERFORMANCE OPTIMIZATION: Early exit for non-damage events and non-building targets to minimize processing overhead
function damageTracker:onBuildingHit(id)
    if self.collateralDamage[id] then
        return
    end

    -- Safe execution sequence: update database records BEFORE evaluating failure state
    self.collateralDamage[id] = true
    self.totalDamage = self.totalDamage + 1

    env.info("[MagnusDCSScripting Damage Tracker]: " .. self.zoneName .. " logged unique impact at " .. id ..
                 ". Current score: " .. self.totalDamage .. "/" .. self.damageThreshold)

    trigger.action.outTextForCoalition(coalition.side.BLUE, "[Damage Tracker]:" .. " | id: " .. id ..
    " | totalCollateral: " .. self.totalDamage, 10)

    if self.totalDamage >= self.damageThreshold then
        self:onThresholdExceeded()
    end
end

-- HIGH-PERFORMANCE OPTIMIZATION: Early exit for non-damage events and non-building targets to minimize processing overhead
function damageTracker:onThresholdExceeded()
    trigger.action.setUserFlag(self.eventTriggerFlag, 1)
    env.info("[MagnusDCSScripting Damage Tracker]: CRITICAL ALERT - Damage threshold exceeded in zone: " ..
                 self.zoneName)
    MagnusDCSScripting.activeDamageTrackers["DamageTracker_" .. self.zoneName] = nil
end

MagnusDCSScripting.damageTracker = damageTracker
