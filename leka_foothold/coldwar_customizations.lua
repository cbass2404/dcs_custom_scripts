-- Recurring check for unauthorized use of the HMD on aircraft that should not have it in Cold War Era
-- HMD Enforcer Script (NVG Safe Version)
-- Loops on HMD_CHECK_INTERVAL, checks A-10C_2, F-16C_50, and FA-18C_hornet.
-- Sends player to spectator ONLY if HMD is detected. NVGs are allowed.
-- Kept deliberately slow: a sweep costs the server, and the worst case is an offender
-- sitting equipped for one interval, still short of a taxi and takeoff.
local HMD_CHECK_INTERVAL = 30
-- Suppresses repeat chat if a slot move does not take effect before the next sweep
local HMD_REMOVAL_COOLDOWN = 30
-- Temporary diagnostic switch. Set false once the A-10C_2 reading is confirmed on the server.
-- Optional: set HMD_DEBUG_PLAYER to your in-game name to keep the readout off everyone
-- else's screen. Left nil, each player only ever sees their own aircraft's reading.
local HMD_DEBUG = true

-- Restricted airframes and the external model animation argument carrying helmet state.
--   slot              : draw argument holding the helmet configuration
--   validHelmetValue  : inclusive range of argument values that are legal for the era. The
--                       bare helmet, and the NVG-only state on the modules that have one,
--                       must fall inside it. The range gives the reported value room to
--                       drift rather than demanding an exact match.
-- Anything outside the range counts as an HMD, so this fails closed: an argument the server
-- never updates reads as a violation and removes everyone in that airframe.
-- Argument ids and values are per-module. Confirm each in the Model Viewer before
-- trusting it on a live server, then tune the entry rather than the shared check below.
local restricted_types = {
    ["A-10C_2"] = {
        slot = 509,
        validHelmetValue = {0.4, 0.6}
    },
    ["F-16C_50"] = {
        slot = 509,
        validHelmetValue = {0.8, 1.1}
    },
    ["FA-18C_hornet"] = {
        slot = 509,
        validHelmetValue = {0.8, 1.1}
    }
}

-- Player name -> model time of their last removal
local recentlyRemoved = {}

-- Legal when the value sits on either bound or anywhere between them. Read order-independently
-- so a config entry written high-then-low cannot silently invert the check.
local function IsHmdValue(helmet, acceptableRange)
    local low = math.min(acceptableRange[1], acceptableRange[2])
    local high = math.max(acceptableRange[1], acceptableRange[2])

    return helmet < low or helmet > high
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

-- Temporary: announces each stage of a sweep so a failure on a hosted server, where the
-- log is unreadable, can be located from in game. Remove with the rest of the debug code.
local function DebugTrace(text)
    if HMD_DEBUG then
        trigger.action.outText("[HMD Enforcer] debug: " .. text, 20)
    end
end

local function EnforceHMDRestrictions()
    DebugTrace("sweep start")

    local idsByName = GetPlayerIdsByName()
    local now = timer.getTime()

    DebugTrace("player id lookup returned")

    -- getPlayers returns only player-occupied units, so AI never reaches the draw argument check
    for _, side in ipairs({coalition.side.RED, coalition.side.BLUE}) do
        local players = coalition.getPlayers(side)

        DebugTrace(string.format("side=%s units=%s", tostring(side), players and tostring(#players) or "nil"))

        for _, unit in ipairs(players) do
            if unit:isExist() then
                local typeName = unit:getTypeName()
                local playerName = unit:getPlayerName()

                DebugTrace(string.format("player='%s' type='%s'", tostring(playerName), typeName))

                local config = restricted_types[typeName]
                local helmet = config and unit:getDrawArgumentValue(config.slot)

                DebugTrace(string.format("player='%s' type='%s' arg=%s", tostring(playerName), typeName,
                    tostring(helmet)))

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

    DebugTrace("sweep complete")

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
        local errorText = "[HMD Enforcer]: " .. tostring(err)

        env.error(errorText)

        -- env.error only reaches the host's log, so a hosted server swallows the failure
        -- entirely. Broadcast it while debugging or the loop fails silently forever.
        if HMD_DEBUG then
            trigger.action.outText(errorText, 30)
        end
    end

    return time + HMD_CHECK_INTERVAL
end

-- Hold the first sweep one interval past mission launch so framework assets initialize cleanly
if Era == "Coldwar" then
    timer.scheduleFunction(EnforcementTick, nil, timer.getTime() + HMD_CHECK_INTERVAL)
end
