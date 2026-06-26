-- initialize flags
trigger.action.setUserFlag(ActiveMissionFlag, 0)
for _, mission in pairs(Missions) do
    trigger.action.setUserFlag(mission.completedFlag, 0)
end

--  Mission Menu Hierarchy
--
-- - Other
--      - Missions
--          - Get Active Missions
--          - Current Mission
--          - Change Mission
--                - ...active_missions
--          - Go to Standby

-- Setup Mission Menu

-- Initialize Mission Menu
local missionsMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Missions")

-- Initialize Mission Commands

-- Get Active Missions Command
local function getActiveMissions()
    for _, mission in pairs(Missions) do
        local completed = trigger.misc.getUserFlag(mission.completedFlag)

        if completed == 0 then
            local message = mission.name .. "\n" .. mission.description

            trigger.action.outTextForCoalition(coalition.side.BLUE, message, 20)
        end
    end
end

missionCommands.addCommandForCoalition(coalition.side.BLUE, "Get Active Missions", missionsMenu, getActiveMissions)

-- Get Current Mission Command
local function getCurrentMission()
    local currentMissionCode = trigger.misc.getUserFlag(ActiveMissionFlag)

    if currentMissionCode > 0 then
        for _, mission in pairs(Missions) do
            if mission.mission_code == currentMissionCode then
                trigger.action.outTextForCoalition(coalition.side.BLUE,
                    "Current Mission: " .. mission.name .. "\n" .. mission.description, 20)
                break
            end
        end
    else
        -- currentMission is 0 or invalid
        trigger.action.outTextForCoalition(coalition.side.BLUE, "No active mission.", 20)
    end
end

missionCommands.addCommandForCoalition(coalition.side.BLUE, "Current Mission", missionsMenu, getCurrentMission)

-- Go to Standby Command
local function setActiveToStandby()
    trigger.action.setUserFlag(ActiveMissionFlag, 1)
    trigger.action.outTextForCoalition(coalition.side.BLUE, "Mission set to Standby.", 20)
end

missionCommands.addCommandForCoalition(coalition.side.BLUE, "Go to Standby", missionsMenu, setActiveToStandby)

-- Change Mission Sub Menu
local setActiveMissionMenu = missionCommands.addSubMenuForCoalition(coalition.side.BLUE, "Set Active Mission",
    missionsMenu)
for key, mission in pairs(Missions) do
    _G[key] = missionCommands.addCommandForCoalition(coalition.side.BLUE, mission.name, setActiveMissionMenu, function()
        trigger.action.setUserFlag(ActiveMissionFlag, mission.mission_code)
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Active mission set to: " .. mission.name, 20)
    end)
end
