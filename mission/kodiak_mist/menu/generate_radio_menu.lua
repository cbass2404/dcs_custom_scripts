--  Mission Menu Hierarchy
--
-- - Other
--   - Ready To Deploy
--   - Current Operation
-- Ready to Deploy Command
local function readyToDeploy()
    local activeMission = trigger.misc.getUserFlag(MagnusDCSScripting.config.activeMissionFlag)
    if activeMission >= #MagnusDCSScripting.config.missions then
        return
    end

    if (activeMission == 0) then
        trigger.action.setUserFlag(MagnusDCSScripting.config.activeMissionFlag, 1)
    else
        local isComplete = trigger.misc.getUserFlag(MagnusDCSScripting.config.missions[activeMission].completedFlag) > 0
        local allCoalitionInEndZone = MagnusDCSScripting.allOfCoalitionInZone(
            MagnusDCSScripting.config.missions[activeMission].missionEndZone, coalition.side.BLUE,
            Group.Category.HELICOPTER)

        if isComplete and allCoalitionInEndZone then
            trigger.action.setUserFlag(MagnusDCSScripting.config.activeMissionFlag, activeMission + 1)
        end
    end
end

-- Operation Name Command
local function operationName()
    local activeMission = tonumber(trigger.misc.getUserFlag(MagnusDCSScripting.config.activeMissionFlag))

    if not activeMission or activeMission > #MagnusDCSScripting.config.missions then
        return
    end

    if (activeMission == 0) then
        trigger.action.outText("Waiting on Users To Signal Ready Status", 20)
        return
    end

    local currentMission = MagnusDCSScripting.config.missions[activeMission]

    local missionCompleted = trigger.misc.getUserFlag(currentMission.completedFlag) > 0

    if missionCompleted then
        trigger.action.outText("Current Mission: " .. currentMission.operationTitle .. "\nStatus: Completed" ..
                                   "\nReturn to " .. currentMission.missionEndZone ..
                                   " before starting the next mission.", 30)
    else
        trigger.action.outText("Current Mission: " .. currentMission.operationTitle .. "\nStatus: In Progress" ..
                                   "\nProceed to " .. currentMission.missionStartZone .. currentMission.instructions, 30)
    end
end

local function clearMessages()
    trigger.action.outText("", 0, true)
end

local menuOptions = {{
    optionName = "Ready to Deploy",
    functionToTriggerOnSelect = readyToDeploy
}, {
    optionName = "Current Operation",
    functionToTriggerOnSelect = operationName
}, {
    optionName = "Clear Messages",
    functionToTriggerOnSelect = clearMessages
}}

local function generateRadioMenu()
    for _, data in ipairs(menuOptions) do
        if data.optionName and data.functionToTriggerOnSelect then

            missionCommands.addCommand(data.optionName, nil, data.functionToTriggerOnSelect, nil)
        end
    end
end

generateRadioMenu()
