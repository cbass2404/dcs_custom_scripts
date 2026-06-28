--- @type initializeDamageTracker
local function initializeDamageTracker()
    local missions = MagnusDCSScripting.config.missions

    for _, mission in pairs(missions) do
        if mission and mission.collateralThresholdZoneName and mission.collateralThreshold and
            mission.collateralDamageFlag then
            local trackerKey = "DamageTracker_" .. mission.collateralThresholdZoneName

            MagnusDCSScripting.activeDamageTrackers[trackerKey] =
                MagnusDCSScripting.damageTracker:new(mission.collateralThresholdZoneName, mission.collateralThreshold,
                    mission.collateralDamageFlag)

            env.info("[MagnusDCSScripting Damage Tracker]: Initialized damage tracker for zone: " ..
                         mission.collateralThresholdZoneName .. " with threshold: " .. mission.collateralThreshold ..
                         " and event trigger flag: " .. mission.collateralDamageFlag)
        end
    end
end

MagnusDCSScripting.initializeDamageTracker = initializeDamageTracker
