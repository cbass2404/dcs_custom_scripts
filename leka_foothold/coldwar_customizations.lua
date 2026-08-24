-- Recurring check for unauthorized use of the HMD on aircraft that should not have it in Cold War Era
-- HMD Enforcer Script (NVG Safe Version)
-- Loops on HMD_CHECK_INTERVAL, checks F-16C_50 and FA-18C_hornet.
-- Sends player to spectator ONLY if HMD is detected. NVGs are allowed.
-- Kept deliberately slow: a sweep costs the server, and the worst case is an offender
-- sitting equipped for one interval, still short of a taxi and takeoff.
local HMD_CHECK_INTERVAL = 30
-- Suppresses repeat chat if a slot move does not take effect before the next sweep
local HMD_REMOVAL_COOLDOWN = 30

-- Restricted airframes and the external model animation argument carrying helmet state.
--   slot              : draw argument holding the helmet configuration
--   validHelmetValue  : the only argument value that is legal for the era. Both modules
--                       offer NVGs or an HMD and nothing else, so this is the NVG state.
-- Every other reading counts as an HMD, so this fails closed: an argument the server never
-- updates reads as a violation and removes everyone in that airframe.
-- Argument ids and values are per-module. Confirm each in the Model Viewer before
-- trusting it on a live server, then tune the entry rather than the shared check below.
local restricted_types = {
    ["F-16C_50"] = {
        slot = 509,
        validHelmetValue = 1
    },
    ["FA-18C_hornet"] = {
        slot = 509,
        validHelmetValue = 1
    }
}

-- Player name -> model time of their last removal
local recentlyRemoved = {}

-- Legal only on an exact match, so the configured value must be one the module actually
-- reports. Every other reading counts as an HMD.
local function IsHmdValue(helmet, validHelmetValue)
    return helmet ~= validHelmetValue
end

-- Player units expose the pilot name, not the network id, so build the reverse lookup per sweep
local function GetPlayerIdsByName()
    local idsByName = {}

    for _, playerId in ipairs(net.get_player_list()) do
        if playerId >= 0 then
            local playerInfo = net.get_player_info(playerId)

            if playerInfo and playerInfo.name then
                idsByName[playerInfo.name] = playerId
            end
        end
    end

    return idsByName
end

local function RemoveToSpectator(playerId, playerName, typeName)
    trigger.action.outText(string.format(
        "SYSTEM: %s was returned to Spectator. Reason: the %s HMD is not permitted in this Cold War mission. NVGs remain legal.",
        playerName, typeName), 20)

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
                local playerName = unit:getPlayerName()
                local config = restricted_types[typeName]
                local helmet = config and unit:getDrawArgumentValue(config.slot)

                if config and helmet and IsHmdValue(helmet, config.validHelmetValue) then
                    local playerId = playerName and idsByName[playerName]
                    local lastRemoval = playerName and recentlyRemoved[playerName]

                    if playerId and not (lastRemoval and now - lastRemoval < HMD_REMOVAL_COOLDOWN) then
                        RemoveToSpectator(playerId, playerName, typeName)
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

-- Hold the first sweep one interval past mission launch so framework assets initialize cleanly
if Era == "Coldwar" then
    timer.scheduleFunction(EnforcementTick, nil, timer.getTime() + HMD_CHECK_INTERVAL)
end
