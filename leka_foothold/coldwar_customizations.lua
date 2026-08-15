-- Enable LogisticCommander for A-10C_2
LogisticCommander.allowedTypes['A-10C_2'] = true

-- Recurring check for unauthorized use of the HMD on aircraft that should not have it in Cold War Era
-- HMD Enforcer Script (NVG Safe Version)
-- Loops every 10 seconds, checks A-10C_2, F-16C_50, and FA-18C_hornet.
-- Sends player to spectator ONLY if HMD is detected. NVGs are allowed.

local HMD_CHECK_INTERVAL = 10
-- Suppresses repeat chat if a slot move does not take effect before the next sweep
local HMD_REMOVAL_COOLDOWN = 30

-- Restricted airframes and the external model animation argument carrying helmet state.
--   arg    : draw argument holding the helmet configuration
--   hmdMin : values at or above this are an HMD/JHMCS. The NVG band sits below it and is legal.
-- Argument ids and value bands are per-module. Confirm each in the Model Viewer before
-- trusting it on a live server, then tune the entry rather than the shared check below.
local restricted_types = {
    ["A-10C_2"] = {
        arg = 509,
        hmdMin = 0.6
    },
    ["F-16C_50"] = {
        arg = 509,
        hmdMin = 0.6
    },
    ["FA-18C_hornet"] = {
        arg = 509,
        hmdMin = 0.6
    }
}

-- Player name -> model time of their last removal
local recentlyRemoved = {}

-- Player units expose the pilot name, not the network id, so build the reverse lookup per sweep
local function GetPlayerIdsByName()
    local idsByName = {}

    for _, playerId in ipairs(net.get_player_list()) do
        -- Skip the host/server identity slot
        if playerId ~= 1 then
            local playerInfo = net.get_player_info(playerId)

            if playerInfo and playerInfo.name then
                idsByName[playerInfo.name] = playerId
            end
        end
    end

    trigger.action.outText(
        string.format("[HMD Enforcer]: updating player ID lookup. %s", table.concat(idsByName, ", ")), 5)
    return idsByName
end

local function RemoveToSpectator(playerId, playerName, typeName)
    net.send_chat_to(string.format(
        "SYSTEM: %s, you were returned to Spectator. Reason: the %s HMD is not permitted in this Cold War mission. Disable the HMD in Special Options, then re-slot. NVGs remain legal.",
        playerName, typeName), playerId)

    -- Side 0 with an empty slot id is the spectator pool
    if not net.force_player_slot(playerId, 0, "") then
        env.warning(string.format("[HMD Enforcer]: failed to move '%s' out of %s.", playerName, typeName))
        trigger.action
            .outText(string.format("[HMD Enforcer]: failed to move '%s' out of %s.", playerName, typeName), 10)
        return
    end

    recentlyRemoved[playerName] = timer.getTime()
    env.info(string.format("[HMD Enforcer]: moved '%s' to spectator for HMD use in %s.", playerName, typeName))
end

local function EnforceHMDRestrictions()
    local idsByName = GetPlayerIdsByName()
    local now = timer.getTime()
    trigger.action.outText("[HMD Enforcer]: beginning HMD enforcement sweep.", 5)

    -- getPlayers returns only player-occupied units, so AI never reaches the draw argument check
    for _, side in ipairs({coalition.side.RED, coalition.side.BLUE}) do
        for _, unit in ipairs(coalition.getPlayers(side)) do
            if unit:isExist() then
                local typeName = unit:getTypeName()
                local config = restricted_types[typeName]
                trigger.action.outText(string.format("[HMD Enforcer]: checking unit '%s' of type '%s'.",
                unit:getPlayerName(), typeName), 5)

                if config then
                    local helmet = unit:getDrawArgumentValue(config.arg)
                    trigger.action.outText(string.format(
                        "[HMD Enforcer]: detected HMD use in '%s'. Helmet: %s, Type: %s, Config: %s",
                        unit:getPlayerName(), helmet, typeName, config or "unknown"), 5)

                    if helmet and helmet >= config.hmdMin then
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

