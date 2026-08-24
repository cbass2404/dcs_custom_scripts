-- HMD Enforcer Script (NVG Safe Version)
-- Event driven: hooks S_EVENT_TAKEOFF the way Foothold's own handlers in zoneCommander.lua do,
-- reads the helmet draw argument once per takeoff, and only then starts caring about that player.
-- An idle server costs nothing; the old fixed-interval sweep walked every player unit on both
-- coalitions forever, whether or not anybody had moved.
--
-- A player who gets airborne in a restricted airframe with an HMD fitted is warned and given
-- HMD_GRACE_PERIOD to put the aircraft back on the ground. Landing closes the case; running out
-- the clock sends them to Spectator. NVGs are legal and are never touched.
local HMD_GRACE_PERIOD = 300
-- Countdown reminder cadence, and the tick that checks whether the player is still in the jet
local HMD_WARNING_INTERVAL = 60
-- A slot move can be refused while the client is mid state change, so don't let one false
-- return hand an offender the rest of the sortie
local HMD_REMOVAL_RETRIES = 3
local HMD_REMOVAL_RETRY_DELAY = 10

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

-- Foothold's Era global is a bare token, so map it to something a player reads cleanly.
-- Only the eras this script arms in need an entry; anything else falls through to the raw
-- value rather than being dropped from the message.
local ERA_DISPLAY_NAMES = {
    Coldwar = "Cold War",
    Gulfwar = "Gulf War"
}

local MISSION_ERA = ERA_DISPLAY_NAMES[Era] or tostring(Era)

-- Player name -> open case. One entry per offender, cleared on landing, on leaving the jet,
-- or on removal, so the table tracks live violations only and cannot grow across a session.
local openCases = {}

-- Legal only on an exact match, so the configured value must be one the module actually
-- reports. Every other reading counts as an HMD.
local function IsHmdValue(helmet, validHelmetValue)
    return helmet ~= validHelmetValue
end

-- Player units expose the pilot name, not the network id. Only needed at removal time now,
-- so this resolves one name instead of building a table of every connected player per sweep.
local function GetPlayerIdByName(playerName)
    for _, playerId in ipairs(net.get_player_list()) do
        if playerId >= 0 then
            local playerInfo = net.get_player_info(playerId)

            if playerInfo and playerInfo.name == playerName then
                return playerId
            end
        end
    end
end

-- Returns the next scheduler time, or nil to end the case's timer
local function RemoveToSpectator(case, time)
    local playerId = GetPlayerIdByName(case.playerName)

    if playerId and net.force_player_slot(playerId, 0, "") then
        trigger.action.outText(string.format(
            "SYSTEM: %s was returned to Spectator. Reason: the %s HMD is not permitted in this %s mission. NVGs remain legal.",
            case.playerName, case.typeName, MISSION_ERA), 20)

        env.info(string.format("[HMD Enforcer]: moved '%s' to spectator for HMD use in %s.",
            case.playerName, case.typeName))

        openCases[case.playerName] = nil
        return nil
    end

    case.attempts = case.attempts + 1

    if case.attempts >= HMD_REMOVAL_RETRIES then
        env.warning(string.format("[HMD Enforcer]: gave up moving '%s' out of %s after %d attempts.",
            case.playerName, case.typeName, case.attempts))

        openCases[case.playerName] = nil
        return nil
    end

    return time + HMD_REMOVAL_RETRY_DELAY
end

-- Fires once a minute while a case is open: reminds the player, then removes them when the
-- grace period runs out. Also the only liveness check a case gets, which is why it re-reads
-- the unit every tick rather than trusting the reference captured at takeoff.
local function GraceTick(playerName, time)
    local case = openCases[playerName]

    if not case then
        return nil
    end

    local unit = Unit.getByName(case.unitName)

    -- Out of the jet on their own: landed and re-slotted, ejected, died, or disconnected.
    -- They already lost the airframe, so there is nothing left to take.
    if not unit or not unit:isExist() or unit:getPlayerName() ~= playerName then
        openCases[playerName] = nil
        return nil
    end

    case.elapsed = case.elapsed + HMD_WARNING_INTERVAL
    local remaining = HMD_GRACE_PERIOD - case.elapsed

    if remaining <= 0 then
        return RemoveToSpectator(case, time)
    end

    if case.groupId then
        trigger.action.outTextForGroup(case.groupId, string.format(
            "SYSTEM: %s HMD detected. Land within %d minute(s) or you will be returned to Spectator.",
            case.typeName, math.ceil(remaining / 60)), HMD_WARNING_INTERVAL)
    end

    return time + HMD_WARNING_INTERVAL
end

local function OpenCase(unit, playerName, typeName)
    -- A touch and go re-fires the takeoff event; keep the original clock rather than
    -- handing out a fresh five minutes on every bounce.
    if openCases[playerName] then
        return
    end

    local group = unit:getGroup()

    local case = {
        playerName = playerName,
        unitName = unit:getName(),
        groupId = group and group:getID(),
        typeName = typeName,
        elapsed = 0,
        attempts = 0
    }

    openCases[playerName] = case

    if case.groupId then
        trigger.action.outTextForGroup(case.groupId, string.format(
            "SYSTEM: %s HMD detected. It is not permitted in this %s mission - NVGs remain legal. Land within %d minutes and change your helmet, or you will be returned to Spectator.",
            typeName, MISSION_ERA, HMD_GRACE_PERIOD / 60), 30)
    end

    case.timerId = timer.scheduleFunction(GraceTick, playerName, timer.getTime() + HMD_WARNING_INTERVAL)

    env.info(string.format("[HMD Enforcer]: '%s' took off in %s with an HMD, %d seconds to land.",
        playerName, typeName, HMD_GRACE_PERIOD))
end

local function OnTakeoff(unit, playerName)
    local typeName = unit:getTypeName()
    local config = restricted_types[typeName]

    if not config then
        return
    end

    local helmet = unit:getDrawArgumentValue(config.slot)

    if helmet and IsHmdValue(helmet, config.validHelmetValue) then
        OpenCase(unit, playerName, typeName)
    end
end

-- Checking the player out: back on the ground inside the window, so the case is closed and
-- the next takeoff gets a fresh read of the draw argument.
local function OnLand(playerName)
    local case = openCases[playerName]

    if not case then
        return
    end

    if case.timerId then
        timer.removeFunction(case.timerId)
    end

    openCases[playerName] = nil

    if case.groupId then
        trigger.action.outTextForGroup(case.groupId,
            "SYSTEM: Landed in time - no action taken. Change your helmet before your next takeoff.", 20)
    end

    env.info(string.format("[HMD Enforcer]: '%s' landed within the grace period, case closed.", playerName))
end

local hmdEnforcer = {}

function hmdEnforcer:onEvent(event)
    if not event or not event.initiator then
        return
    end

    if event.id ~= world.event.S_EVENT_TAKEOFF and event.id ~= world.event.S_EVENT_LAND then
        return
    end

    -- Statics and weapons reach this handler too and have no pilot to look up
    if not event.initiator.getPlayerName then
        return
    end

    -- A single bad event is contained so DCS does not tear the handler down
    local ok, err = pcall(function()
        local playerName = event.initiator:getPlayerName()

        if not playerName then
            return
        end

        if event.id == world.event.S_EVENT_TAKEOFF then
            OnTakeoff(event.initiator, playerName)
        else
            OnLand(playerName)
        end
    end)

    if not ok then
        env.error("[HMD Enforcer]: " .. tostring(err))
    end
end

-- Neither jet carried a JHMCS in either era, and neither jet exists at all in the eras before
-- them, so there is nothing to enforce outside these two. zoneCommander.lua already folds
-- Gulfwar into Coldwar on load; the second test is there in case that normalization moves or
-- this file is ever loaded ahead of it.
if Era == "Coldwar" or Era == "Gulfwar" then
    world.addEventHandler(hmdEnforcer)
    env.info(string.format("[Foothold HMD Enforcer]: armed on takeoff, %d second grace period.", HMD_GRACE_PERIOD))
end
