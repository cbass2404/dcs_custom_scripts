-- Recurring check for unauthorized use of the HMD on aircraft that should not have it in Cold War Era
-- HMD Enforcer Script (NVG Safe Version)
-- Loops every 10 seconds, checks A-10C_2, F-16C_50, and FA-18C_hornet.
-- Sends player to spectator ONLY if HMD is detected. NVGs are allowed.
local HMD_CHECK_INTERVAL = 10
-- Suppresses repeat chat if a slot move does not take effect before the next sweep
local HMD_REMOVAL_COOLDOWN = 30

-- Restricted airframes and the external model animation argument carrying helmet state.
--   arg : draw argument holding the helmet configuration
--   hmd : the argument values that mean an HMD/JHMCS is fitted. Any value not listed here
--         is treated as legal, so the bare helmet and NVG values must stay out of the list.
-- Argument ids and values are per-module. Confirm each in the Model Viewer before
-- trusting it on a live server, then tune the entry rather than the shared check below.
local restricted_types = {
    ["A-10C_2"] = {
        arg = 509,
        hmd = {0, 1}
    },
    ["F-16C_50"] = {
        arg = 509,
        hmd = {0}
    },
    ["FA-18C_hornet"] = {
        arg = 509,
        hmd = {0}
    }
}

-- Player name -> model time of their last removal
local recentlyRemoved = {}

-- Matched exactly, so each configured value must be one the model actually reports
local function IsHmdValue(helmet, hmdValues)
    for _, hmdValue in ipairs(hmdValues) do
        if helmet == hmdValue then
            return true
        end
    end

    return false
end

-- Player units expose the pilot name, not the network id, so build the reverse lookup per sweep
local function GetPlayerIdsByName()
    local idsByName = {}

    for _, playerId in ipairs(net.get_player_list()) do
        if playerId ~= 1 then
            local playerInfo = net.get_player_info(playerId)

            if playerInfo and playerInfo.name then
                idsByName[playerInfo.name] = playerId
            end
        end
    end

    return idsByName
end

local function RemoveToSpectator(playerId, playerName, typeName)
    if typeName ~= "A-10C_2" then
        trigger.action.outText(string.format(
            "SYSTEM: %s was returned to Spectator. Reason: the %s HMD is not permitted in this Cold War mission. NVGs remain legal.",
            playerName, typeName), 20)
    else
        trigger.action.outText(string.format(
            "SYSTEM: %s was returned to Spectator. Reason: the %s HMD is not permitted in this Cold War mission.",
            playerName, typeName), 20)
    end

    if not net.force_player_slot(playerId, 0, "") then
        env.warning(string.format("[HMD Enforcer]: failed to move '%s' out of %s.", playerName, typeName))
        return
    end

    recentlyRemoved[playerName] = timer.getTime()
    env.info(string.format("[HMD Enforcer]: moved '%s' to spectator for HMD use in %s.", playerName, typeName))
end

local function EnforceHMDRestrictions()
    local idsByName = GetPlayerIdsByName()
    local now = timer.getTime()

    -- getPlayers returns only player-occupied units, so AI never reaches the draw argument check
    for _, side in ipairs({coalition.side.RED, coalition.side.BLUE}) do
        for _, unit in ipairs(coalition.getPlayers(side)) do
            if unit:isExist() then
                local typeName = unit:getTypeName()
                local config = restricted_types[typeName]

                if config then
                    local helmet = unit:getDrawArgumentValue(config.arg)

                    if helmet and IsHmdValue(helmet, config.hmd) then
                        local playerName = unit:getPlayerName()
                        local playerId = playerName and idsByName[playerName]
                        local lastRemoval = playerName and recentlyRemoved[playerName]

                        if playerId and not (lastRemoval and now - lastRemoval < HMD_REMOVAL_COOLDOWN) then
                            RemoveToSpectator(playerId, playerName, typeName)
                        end
                    end
                end
            end
        end
    end

    -- Age out cooldown entries so the table cannot grow across a long server session
    for playerName, removedAt in pairs(recentlyRemoved) do
        if now - removedAt >= HMD_REMOVAL_COOLDOWN then
            recentlyRemoved[playerName] = nil
        end
    end
end

-- Timer entry point. A single bad sweep is contained so the loop survives it.
local function EnforcementTick(_, time)
    local ok, err = pcall(EnforceHMDRestrictions)

    if not ok then
        env.error("[HMD Enforcer]: " .. tostring(err))
    end

    return time + HMD_CHECK_INTERVAL
end

-- Begin execution 10 seconds after mission launch to ensure framework assets initialize cleanly
timer.scheduleFunction(EnforcementTick, nil, timer.getTime() + HMD_CHECK_INTERVAL)

-- ============================================================================
-- A-10C II zone supply gate
-- The Hog is in Foothold's logistics tables so the Logistics menu and the
-- Load/Unload Supplies commands appear, but it may only actually pick supplies
-- up while carrying an MXU-648 travel pod. Foothold builds the radio menu once
-- per slot entry, so the pod check has to run when Load is pressed rather than
-- when the menu is created.
-- ============================================================================
local TRAVEL_POD_CLSID = "MXU-648-TP"

-- Airframes that need a cargo pod before they may carry zone supplies.
local pod_required_types = {
    ["A-10C_2"] = true
}

-- DCS does not expose a live pylon loadout to the mission environment, so this
-- reads the payload the slot was defined with in the mission file. A player who
-- rearms to a different loadout after spawning still reads as their original
-- payload here, so the A-10 slots must be authored with the pod already fitted.
local function GetSlotPayload(unit)
    local unitId = unit:getID()
    local group = unit:getGroup()
    local groupId = group and group:getID()

    if not (unitId and groupId) then
        return nil
    end

    for coalitionName, coalitionData in pairs(env.mission.coalition) do
        if (coalitionName == "red" or coalitionName == "blue") and type(coalitionData) == "table" and
            type(coalitionData.country) == "table" then

            for _, countryData in pairs(coalitionData.country) do
                for objectType, objectData in pairs(countryData) do
                    -- Only flyable categories carry a pylon payload
                    if (objectType == "plane" or objectType == "helicopter") and type(objectData) == "table" and
                        type(objectData.group) == "table" then

                        for _, groupData in pairs(objectData.group) do
                            if groupData.groupId == groupId and type(groupData.units) == "table" then
                                for _, unitData in pairs(groupData.units) do
                                    if unitData.unitId == unitId then
                                        return unitData.payload
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function HasTravelPod(unit)
    local payload = GetSlotPayload(unit)

    if not (payload and type(payload.pylons) == "table") then
        return false
    end

    for _, pylon in pairs(payload.pylons) do
        if pylon.CLSID == TRAVEL_POD_CLSID then
            return true
        end
    end

    return false
end

-- Wrapped rather than replaced so a Foothold update keeps whatever the stock
-- loadSupplies does once the pod check passes. LogisticCommander instances
-- inherit through __index, so patching the class reaches the live commander.
if LogisticCommander and LogisticCommander.loadSupplies then
    -- Foothold resolves AllowedToCarrySupplies once, when zoneCommander.lua loads,
    -- taking the config global if it exists and an internal default table if it
    -- does not. Writing to the live table here is immune to a stale copy of the
    -- config embedded in the .miz and to the config loading after zoneCommander.
    LogisticCommander.AllowedToCarrySupplies = LogisticCommander.AllowedToCarrySupplies or {}
    for typeName in pairs(pod_required_types) do
        LogisticCommander.AllowedToCarrySupplies[typeName] = true
        LogisticCommander.allowedTypes[typeName] = true
    end

    -- The Load/Unload commands are also gated on legacy logistics mode, which is
    -- a separate setting. Log it so a silent menu can be told apart from a
    -- silent config.
    env.info(string.format(
        "[Cold War]: travel pod gate installed. WarehouseLogistics=%s A-10C_2 carry=%s",
        tostring(WarehouseLogistics), tostring(LogisticCommander.AllowedToCarrySupplies["A-10C_2"])))

    local baseLoadSupplies = LogisticCommander.loadSupplies

    function LogisticCommander:loadSupplies(groupName, supplyCount)
        local group = Group.getByName(groupName)
        local unit = group and group:getUnit(1)

        if unit and pod_required_types[unit:getTypeName()] and not HasTravelPod(unit) then
            trigger.action.outTextForGroup(group:getID(),
                "Supplies require an MXU-648 travel pod. Take a loadout with a travel pod fitted to carry cargo.", 10)
            return
        end

        return baseLoadSupplies(self, groupName, supplyCount)
    end
else
    env.error("[Cold War]: LogisticCommander unavailable, A-10C II travel pod gate not installed.")
end

