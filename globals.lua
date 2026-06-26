ActiveMissionFlag = "ACTIVE_MISSION"

-- Mission Definitions
---@class Mission
---@field name string
---@field mission_code number
---@field description string
---@field completedFlag string|nil

---@type table<string, Mission>
Missions = {
    ["capture_farp_london"] = {
        name = "Capture Farp London",
        mission_code = 1,
        description = "Destroy the enemy units at the enemy farp and capture it! Bring ground forces to hold the farp!",
        completedFlag = "FARP_LONDON_COMPLETE"
    },
    ["capture_farp_paris"] = {
        name = "Capture Farp Paris",
        mission_code = 6,
        description = "Destroy the enemy units at the enemy farp and capture it! Bring ground forces to hold the farp!",
        completedFlag = "FARP_PARIS_COMPLETE"
    },
    ["csar"] = {
        name = "CSAR",
        mission_code = 10,
        description = "Rescue the downed chopper pilot from pursuing enemy scouts and bring him safely to Kemi Tornio.",
        completedFlag = "CRASHED_COMPLETE"
    },
    ["dam_defense"] = {
        name = "Dam Defense",
        mission_code = 4,
        description = "Evict enemy forces from the nearby Dam before they destroy it!",
        completedFlag = "DAM_COMPLETE"
    },
    ["ied_factory"] = {
        name = "IED Factory",
        mission_code = 7,
        description = "An IED factory has been reported in this area. We don't know where exactly it is but it's in this area. Search and destory.",
        completedFlag = "IED_COMPLETE"
    },
    ["river_raid"] = {
        name = "River Raid",
        mission_code = 9,
        description = "Run up the river and sanitize it of the light enemy forces occupying it.",
        completedFlag = "RIVER_COMPLETE"
    },
    ["silkworm"] = {
        name = "Silkworm",
        mission_code = 2,
        description = "Destroy the enemy Silkworm Site. Restore civilian and military supply shipping to the area.",
        completedFlag = "SILKWORM_COMPLETE"
    },
    ["town_liberation"] = {
        name = "Town Liberation",
        mission_code = 3,
        description = "Liberate the town from enemy forces, but watch your collateral damage. It's not a liberation if all you leave is rubble.",
        completedFlag = "TOWN_COMPLETE"
    },
    ["training_camp"] = {
        name = "Training Camp",
        mission_code = 8,
        description = "The enemy has set up an intensive training camp to bolster local insurgents. Wipe it out.",
        completedFlag = "TRAINING_COMPLETE"
    },
    ["trainyard"] = {
        name = "Trainyard",
        mission_code = 5,
        description = "	Hostiles have taken control of an important trainyard and are robbing the trains that come in. Take them down, just don't blast the trains.",
        completedFlag = "TRAINYARD_COMPLETE"
    }
}

--- @type Mission
Standby = {
    name = "Standby",
    mission_code = 0,
    description = "No active missions. Stand by for further instructions."
}

