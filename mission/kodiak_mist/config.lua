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
        operationTitle = "Operation London",
        introText = "",
        outroText = ""
    },

    [2] = {
        name = "Silkworm",
        completedFlag = "SILKWORM_COMPLETE",
        operationTitle = "Operation Silkworm",
        introText = "",
        outroText = ""
    },

    [3] = {
        name = "Town Liberation",
        completedFlag = "TOWN_COMPLETE",
        operationTitle = "Operation Town Liberation",
        introText = "",
        outroText = ""
    },

    [4] = {
        name = "Dam Defense",
        completedFlag = "DAM_COMPLETE",
        operationTitle = "Operation Dam Defense",
        introText = "",
        outroText = ""
    },

    [5] = {
        name = "Trainyard",
        completedFlag = "TRAINYARD_COMPLETE",
        operationTitle = "Operation Trainyard",
        introText = "",
        outroText = ""
    },

    [6] = {
        name = "Capture Farp Paris",
        completedFlag = "FARP_PARIS_COMPLETE",
        operationTitle = "Operation Paris",
        introText = "",
        outroText = ""
    },

    [7] = {
        name = "IED Factory",
        completedFlag = "IED_COMPLETE",
        operationTitle = "Operation IED Factory",
        introText = "",
        outroText = ""
    },

    [8] = {
        name = "Training Camp",
        completedFlag = "TRAINING_COMPLETE",
        operationTitle = "Operation Training Camp",
        introText = "",
        outroText = ""
    },

    [9] = {
        name = "CSAR",
        completedFlag = "CRASHED_COMPLETE",
        operationTitle = "Operation CSAR",
        introText = "",
        outroText = ""
    },

    [10] = {
        name = "River Raid",
        completedFlag = "RIVER_COMPLETE",
        operationTitle = "Operation River Raid",
        introText = "",
        outroText = ""
    }
}

MagnusDCSScripting.config = config
