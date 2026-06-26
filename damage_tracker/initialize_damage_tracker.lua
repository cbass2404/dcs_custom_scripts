--- Instantiates Global Variables for Tracking
---@param zoneName string The exact name of the Trigger Zone created in the Mission Editor.
---@param damageThreshold number The total number of unique hits allowed before failure.
---@param eventTriggerFlag string The flag that flips to 1 when damageThreshold is reached.
local function initializeDamageTracker(zoneName, damageThreshold, eventTriggerFlag)
    local trackerKey = "DamageTracker_" .. zoneName
    CustomClasses.activeDamageTrackers[trackerKey] = CustomClasses.damageTracker:new(zoneName, damageThreshold,
        eventTriggerFlag)
end

CustomClasses.initializeDamageTracker = initializeDamageTracker
