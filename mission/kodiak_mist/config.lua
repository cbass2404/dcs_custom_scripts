---@type config
local config = {}

--- @type "dev"|"prod"
-- config.env = "dev"
config.env = "prod"

local devFlags = {
    ACTIVE_MISSION = 0,

    -- ACTIVE MISSION 1: Capture Farp London
    FARP_LONDON_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully
    FARP_LONDON_OCCUPIED = 0, -- 0 = not occupied, 1 = occupied by blue coalition, prevents repetitive ATC inbound calls for multiple players

    -- ACTIVE MISSION 2: Silkworm
    SILKWORM_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully

    -- ACTIVE_MISSION 3: Town Liberation
    -- Note: This mission has collateral damage conditions
    -- IF TOWN_COMPLETE IS SET TO 1, THE MISSION IS CONSIDERED SUCCESSFUL REGARDLESS OF THE COLLATERAL DAMAGE FLAG. HOWEVER, IF TOWN_COMPLETE IS SET TO 2 AND THE COLLATERAL DAMAGE FLAG (TOWN_UPRISING) IS SET TO 1, THEN THE MISSION IS CONSIDERED A FAILURE DUE TO EXCESSIVE COLLATERAL DAMAGE.
    TOWN_COMPLETE = 0,
    TOWN_UPRISING = 0,
    KEMI_TORNIO_OCCUPIED = 0, -- 0 = not occupied, 1 = occupied by blue coalition, prevents repetitive ATC inbound calls for multiple players

    -- ACTIVE MISSION 4: Dam Defense
    -- Note: This mission has collateral damage conditions
    -- IF DAM_COMPLETE IS SET TO 1, THE MISSION IS CONSIDERED SUCCESSFUL REGARDLESS OF THE COLLATERAL DAMAGE FLAG. HOWEVER, IF DAM_COMPLETE IS SET TO 2 AND THE COLLATERAL DAMAGE FLAG (DAM_UPRISING) IS SET TO 1, THEN THE MISSION IS CONSIDERED A FAILURE DUE TO EXCESSIVE COLLATERAL DAMAGE.
    DAM_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully, 2 = failed due to collateral damage
    DAM_UPRISING = 0, -- 0 = collateral damage threshold not exceeded, 1 = collateral damage threshold exceeded (mission failure)

    -- ACTIVE MISSION 5: Trainyard
    TRAINYARD_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully, 2 = failed due to collateral damage
    TRAIN_YARD_UPRISING = 0, -- 0 = collateral damage threshold not exceeded, 1 = collateral damage threshold exceeded (mission failure)

    -- ACTIVE MISSION 6: Capture Farp Paris
    FARP_PARIS_COMPLETE = 0, -- 0 = not completed, 1 = completed successfully
    FARP_PARIS_OCCUPIED = 0, -- 0 = not occupied, 1 = occupied by blue coalition, prevents repetitive ATC inbound calls for multiple players

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
        operationTitle = "Operation Iron Anchor",
        missionStartZone = "Strike Group Alpha",
        missionEndZone = "Farp London",
        instructions = "\n- Tune ADF to 950 khz FLN\n- Approach with caution and eliminate the enemy\n- Tune FM to 41.5 mhz LCF\n- Pickup the special forces team and deliver them to FARP London\n- Hold the FARP until reinforcements arrive"
    },

    [2] = {
        name = "Silkworm",
        completedFlag = "SILKWORM_COMPLETE",
        operationTitle = "Operation Sea Spray",
        missionStartZone = "Farp London",
        missionEndZone = "Farp London",
        instructions = "\n- ADF to 575 khz SWT\n- From beacon 180 for 8.5\n- Eliminate targets"
    },

    [3] = {
        name = "Town Liberation",
        completedFlag = "TOWN_COMPLETE",
        operationTitle = "Operation Quiet Citadel",
        collateralThreshold = 50,
        collateralThresholdZoneName = "TOWN_COLLATERAL_ZONE",
        collateralDamageFlag = "TOWN_UPRISING",
        missionStartZone = "Farp London",
        missionEndZone = "Kemi Tornio",
        instructions = "\n- Tune ADF to 550 khz TLT\n- Destroy the enemy forces\n- Be careful of collateral damage"
    },

    [4] = {
        name = "Dam Defense",
        completedFlag = "DAM_COMPLETE",
        operationTitle = "Operation Hydro Lock",
        missionStartZone = "Kemi Tornio",
        missionEndZone = "Kemi Tornio",
        instructions = "\n- Precision air to ground ordinance\n- Tune ADF to 675 khz DDT\n- DO NOT DESTROY THE DAM"
    },

    [5] = {
        name = "Trainyard",
        completedFlag = "TRAINYARD_COMPLETE",
        operationTitle = "Operation Steel Junction",
        collateralThreshold = 25,
        collateralThresholdZoneName = "TRAIN_YARD_COLLATERAL_ZONE",
        collateralDamageFlag = "TRAIN_YARD_UPRISING",
        missionStartZone = "Kemi Tornio",
        missionEndZone = "Kemi Tornio",
        instructions = "\n- Tune ADF to 775 khz TYT\n- Ingress to the city of Tornio\n- Eliminate the enemy forces occupying the rail yard\n- DO NOT DESTROY INFRASTRUCTURE"
    },

    [6] = {
        name = "Capture Farp Paris",
        completedFlag = "FARP_PARIS_COMPLETE",
        operationTitle = "Operation Paris Guard",
        missionStartZone = "Kemi Tornio",
        missionEndZone = "Farp Paris",
        instructions = "\n- Load up with an A2A payload, hostile helicopters expected\n- Pickup Team Anvil at the North end of the Tarmac\n- Tune ADF to 515 khz FPR\n- Ingress on Farp Paris, deploy Team Anvil for capture"
    },

    [7] = {
        name = "IED Factory",
        completedFlag = "IED_COMPLETE",
        operationTitle = "Operation Wire Cutter",
        missionStartZone = "Farp Paris",
        missionEndZone = "Farp Paris",
        instructions = "\n- Heavy ordinance to level a building\n- Check kneeboard maps for navigation\n- WEAPONS HOLD unless fired upon"
    },

    [8] = {
        name = "Training Camp",
        completedFlag = "TRAINING_COMPLETE",
        operationTitle = "Operation Citadel Sweep",
        missionStartZone = "Farp Paris",
        missionEndZone = "Farp Paris",
        instructions = "\n- Equip air to ground ordinance for light armor\n- Egress NW to the Factory\n- Eliminate the targets\n- Sling load a cargo box and return it to Farp Paris"
    },

    [9] = {
        name = "CSAR",
        completedFlag = "CRASHED_COMPLETE",
        operationTitle = "Operation Steel Canopy",
        missionStartZone = "Farp Paris",
        missionEndZone = "Kemi Tornio",
        instructions = "\n- Light air to ground weapons, potential light armor expected\n- Egress at 1-0-2 for 30 klicks\n- Catch up with Heavy 1-1 and provide overwatch while they pick up the troops\n- Need capacity for four troops on one of your birds"
    },

    [10] = {
        name = "Return to Ship",
        completedFlag = "RTS_COMPLETE",
        operationTitle = "Return to Ship",
        missionStartZone = "Kemi Tornio",
        missionEndZone = "Strike Group Alpha",
        instructions = "\n- tune ADF to 1050 khz INV\n- Egress from Kemi Tornio to the south\n- Land on one of the ships for Mission Complete"
    }
}

MagnusDCSScripting.config = config
