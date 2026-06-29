---@type config
local config = {}

--- @type "dev"|"prod"
-- config.env = "dev"
config.env = "prod"

local devFlags = {
    ACTIVE_MISSION = 0,

    -- ACTIVE MISSION 1: Capture Farp London
    FARP_LONDON_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE MISSION 2: Silkworm
    SILKWORM_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE_MISSION 3: Town Liberation
    -- Note: This mission has collateral damage conditions
    -- IF TOWN_COMPLETE IS SET TO 1, THE MISSION IS CONSIDERED SUCCESSFUL REGARDLESS OF THE COLLATERAL DAMAGE FLAG. HOWEVER, IF TOWN_COMPLETE IS SET TO 2 AND THE COLLATERAL DAMAGE FLAG (TOWN_UPRISING) IS SET TO 1, THEN THE MISSION IS CONSIDERED A FAILURE DUE TO EXCESSIVE COLLATERAL DAMAGE.
    TOWN_COMPLETE = 0,
    TOWN_UPRISING = 0,

    -- ACTIVE MISSION 4: Dam Defense
    -- Note: This mission has collateral damage conditions
    -- IF DAM_COMPLETE IS SET TO 1, THE MISSION IS CONSIDERED SUCCESSFUL REGARDLESS OF THE COLLATERAL DAMAGE FLAG. HOWEVER, IF DAM_COMPLETE IS SET TO 2 AND THE COLLATERAL DAMAGE FLAG (DAM_UPRISING) IS SET TO 1, THEN THE MISSION IS CONSIDERED A FAILURE DUE TO EXCESSIVE COLLATERAL DAMAGE.
    DAM_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully, 2 = failed due to collateral damage
    DAM_ALIVE = 1, -- 1 = dam is still alive, 0 = dam has been destroyed
    DAM_UPRISING = 0, -- 0 = collateral damage threshold not exceeded, 1 = collateral damage threshold exceeded (mission failure)

    -- ACTIVE MISSION 5: Trainyard
    TRAINYARD_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully, 2 = failed due to collateral damage
    TRAIN_YARD_UPRISING = 0, -- 0 = collateral damage threshold not exceeded, 1 = collateral damage threshold exceeded (mission failure)

    -- ACTIVE MISSION 6: Capture Farp Paris
    FARP_PARIS_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE MISSION 7: IED Factory
    IED_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE MISSION 8: Training Camp
    TRAINING_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE MISSION 9: CSAR
    CRASHED_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE MISSION 10: Return to Ship
    RTS_COMPLETE = 0 -- 0 = not completed, 1 = completed successfully
}

if config.env == "dev" then
    for flag, value in pairs(devFlags) do
        trigger.action.setUserFlag(flag, value)
    end
end

--- @type string
config.activeMissionFlag = "ACTIVE_MISSION"

config.partialSuccessPercent = 70

---@type table<number, mission>
config.missions = {
    [1] = {
        name = "Capture Farp London",
        completedFlag = "FARP_LONDON_COMPLETE",
        operationTitle = "Operation Iron Anchor"
    },

    [2] = {
        name = "Silkworm",
        completedFlag = "SILKWORM_COMPLETE",
        operationTitle = "Operation Sea Spray"
    },

    [3] = {
        name = "Town Liberation",
        completedFlag = "TOWN_COMPLETE",
        operationTitle = "Operation Quiet Citadel",
        collateralThreshold = 30,
        collateralThresholdZoneName = "TOWN_COLLATERAL_ZONE",
        collateralDamageFlag = "TOWN_UPRISING"
    },

    [4] = {
        name = "Dam Defense",
        completedFlag = "DAM_COMPLETE",
        operationTitle = "Operation Hydro Lock",
        collateralThreshold = 1,
        collateralThresholdZoneName = "DAM_COLLATERAL_ZONE",
        collateralDamageFlag = "DAM_UPRISING"
    },

    [5] = {
        name = "Trainyard",
        completedFlag = "TRAINYARD_COMPLETE",
        operationTitle = "Operation Steel Junction",
        collateralThreshold = 20,
        collateralThresholdZoneName = "TRAIN_YARD_COLLATERAL_ZONE",
        collateralDamageFlag = "TRAIN_YARD_UPRISING"
    },

    [6] = {
        name = "Capture Farp Paris",
        completedFlag = "FARP_PARIS_COMPLETE",
        operationTitle = "Operation Paris Guard"
    },

    [7] = {
        name = "IED Factory",
        completedFlag = "IED_COMPLETE",
        operationTitle = "Operation Wire Cutter"
    },

    [8] = {
        name = "Training Camp",
        completedFlag = "TRAINING_COMPLETE",
        operationTitle = "Operation Citadel Sweep"
    },

    [9] = {
        name = "CSAR",
        completedFlag = "CRASHED_COMPLETE",
        operationTitle = "Operation Steel Canopy"
    },

    [10] = {
        name = "Return to Ship",
        completedFlag = "RTS_COMPLETE",
        operationTitle = ""
    }
}

MagnusDCSScripting.config = config
