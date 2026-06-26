---@type config
local config = {}

--- @type string
config.activeMissionFlag = "ACTIVE_MISSION"

config.partialSuccessPercent = 70

---@type table<number, mission>
config.missions = {
    [1] = {
        name = "Capture Farp London",
        completedFlag = "FARP_LONDON_COMPLETE",
        operationTitle = "Operation Iron Anchor",
        introText = "",
        outroText = ""
    },

    [2] = {
        name = "Silkworm",
        completedFlag = "SILKWORM_COMPLETE",
        operationTitle = "Operation Sea Spray",
        introText = "",
        outroText = ""
    },

    [3] = {
        name = "Town Liberation",
        completedFlag = "TOWN_COMPLETE",
        operationTitle = "Operation Quiet Citadel",
        introText = "",
        outroText = ""
    },

    [4] = {
        name = "Dam Defense",
        completedFlag = "DAM_COMPLETE",
        operationTitle = "Operation Hydro Lock",
        introText = "",
        outroText = ""
    },

    [5] = {
        name = "Trainyard",
        completedFlag = "TRAINYARD_COMPLETE",
        operationTitle = "Operation Steel Junction",
        introText = "",
        outroText = ""
    },

    [6] = {
        name = "Capture Farp Paris",
        completedFlag = "FARP_PARIS_COMPLETE",
        operationTitle = "Operation Paris Guard",
        introText = "",
        outroText = ""
    },

    [7] = {
        name = "IED Factory",
        completedFlag = "IED_COMPLETE",
        operationTitle = "Operation Wire Cutter",
        introText = "",
        outroText = ""
    },

    [8] = {
        name = "Training Camp",
        completedFlag = "TRAINING_COMPLETE",
        operationTitle = "Operation Citadel Sweep",
        introText = "",
        outroText = ""
    },

    [9] = {
        name = "CSAR",
        completedFlag = "CRASHED_COMPLETE",
        operationTitle = "Operation Steel Canopy",
        introText = "",
        outroText = ""
    },

    [10] = {
        name = "Return to Ship",
        completedFlag = "RTS_COMPLETE",
        operationTitle = "",
        introText = "",
        outroText = ""
    }
}

MagnusDCSScripting.config = config
