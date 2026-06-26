--- @class damageTracker
--- @field collateralDamage table<string, boolean>
--- @field damageThreshold number
--- @field eventTriggerFlag string
--- @field totalDamage number
--- @field zoneName string
local damageTracker = {
    collateralDamage = {},
    damageThreshold = 0,
    eventTriggerFlag = "",
    totalDamage = 0,
    zoneName = ""
}

---@param zoneName string The exact name of the Trigger Zone created in the Mission Editor.
---@param damageThreshold number The total number of unique hits allowed before failure.
---@param eventTriggerFlag string The flag that flips to 1 when damageThreshold is reached.
---@return damageTracker|nil
function damageTracker:new(zoneName, damageThreshold, eventTriggerFlag)
    if not zoneName or not damageThreshold or not eventTriggerFlag then
        env.info("[Magnus Damage Tracker]: ERROR - Missing required parameters for DamageTracker constructor.")
        return nil
    end

    local instance = {}
    setmetatable(instance, self)
    self.__index = self

    trigger.action.setUserFlag(eventTriggerFlag, 0)

    instance.collateralDamage = {}
    instance.damageThreshold = tonumber(damageThreshold) or 5
    instance.eventTriggerFlag = tostring(eventTriggerFlag)
    instance.totalDamage = 0
    instance.zoneName = zoneName

    return instance
end

--- Called when a building is hit within the specified zone.
---@param id string The unique spatial ID coordinate string of the building.
---@return nil
function damageTracker:onBuildingHit(id)
    if self.collateralDamage[id] then
        return
    end

    -- Safe execution sequence: update database records BEFORE evaluating failure state
    self.collateralDamage[id] = true
    self.totalDamage = self.totalDamage + 1

    env.info("[Magnus Damage Tracker]: " .. self.zoneName .. " logged unique impact at " .. id .. ". Current score: " ..
                 self.totalDamage .. "/" .. self.damageThreshold)

    if self.totalDamage >= self.damageThreshold then
        self:onThresholdExceeded()
    end
end

--- Called when the damage threshold is exceeded within the specified zone.
function damageTracker:onThresholdExceeded()
    trigger.action.setUserFlag(self.eventTriggerFlag, 1)
    env.info("[Magnus Damage Tracker]: CRITICAL ALERT - Damage threshold exceeded in zone: " .. self.zoneName)
    CustomClasses.activeDamageTrackers["DamageTracker_" .. self.zoneName] = nil
end

CustomClasses.damageTracker = damageTracker
