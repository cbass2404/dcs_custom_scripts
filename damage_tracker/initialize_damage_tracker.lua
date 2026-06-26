--- @type initializeDamageTracker
local function initializeDamageTracker(zoneName, damageThreshold, eventTriggerFlag)

    local trackerKey = "DamageTracker_" .. zoneName
    MagnusDCSScripting.activeDamageTrackers[trackerKey] = MagnusDCSScripting.damageTracker:new(zoneName,
        damageThreshold, eventTriggerFlag)
end

MagnusDCSScripting.initializeDamageTracker = initializeDamageTracker
