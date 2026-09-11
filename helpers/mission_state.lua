local originalSetUserFlag = trigger.action.setUserFlag;

--- Root-level contents of the save file. Kept in memory since this script is the only writer.
local saveState = {}

--- Resolves the save file path and ensures the Saves directory exists. Returns nil if saving isn't possible.
local function getSaveFilePath()
    if not io or not lfs then
        env.error("mission_state: io/lfs are sanitized, cannot use save file")
        return nil
    end

    local config = MagnusDCSScripting.config
    if not config or not config.missionName then
        env.error("mission_state: MagnusDCSScripting.config.missionName is not set, cannot use save file")
        return nil
    end

    -- Relative paths resolve against DCS's working directory (the install's bin folder), not this script,
    -- so anchor to the Saved Games write directory instead. Same folder Foothold writes its saves to.
    local saveDir = lfs.writedir() .. "Missions/Saves"
    lfs.mkdir(saveDir)

    return saveDir .. "/" .. config.missionName .. "_save.json"
end

--- Loads an existing save into saveState so later writes keep its contents, and restores each saved flag.
local function loadSaveFile(saveFilePath)
    local file, err = io.open(saveFilePath, "r")
    if not file then
        env.error("mission_state: failed to read save file " .. saveFilePath .. ": " .. tostring(err))
        return
    end
    local contents = file:read("*a")
    file:close()

    local ok, decoded = pcall(net.json2lua, contents)
    if not ok or type(decoded) ~= "table" then
        -- Leave saveFilePath unset so a corrupt save is never overwritten.
        env.error("mission_state: save file " .. saveFilePath .. " is not a valid JSON object, saving disabled")
        return
    end

    for key, value in pairs(decoded) do
        saveState[tostring(key)] = value
        originalSetUserFlag(key, value)
    end

    MagnusDCSScripting.saveFilePath = saveFilePath
    env.info("mission_state: loaded existing save file " .. saveFilePath)
end

local function createSaveFile(saveFilePath)
    local file, err = io.open(saveFilePath, "w")
    if not file then
        env.error("mission_state: failed to create save file " .. saveFilePath .. ": " .. tostring(err))
        return
    end
    file:write("{}")
    file:close()

    MagnusDCSScripting.saveFilePath = saveFilePath
    env.info("mission_state: created save file " .. saveFilePath)
end

local function encodeJsonString(str)
    local escaped = str:gsub('[%c"\\]', function(char)
        if char == '"' then return '\\"' end
        if char == "\\" then return "\\\\" end
        return string.format("\\u%04x", char:byte())
    end)
    return '"' .. escaped .. '"'
end

--- Mission editor flag actions don't go through trigger.action.setUserFlag, so the editor calls this from a DO SCRIPT
--- after them. Without a value it saves the flag's current value, which covers INCREASE/DECREASE/RANDOM.
local function saveFlag(flag, value)
    if not MagnusDCSScripting.saveFilePath then
        return
    end

    if value == nil then
        value = trigger.misc.getUserFlag(flag)
    end
    saveState[tostring(flag)] = value

    local entries = {}
    for key, val in pairs(saveState) do
        local encodedValue = type(val) == "string" and encodeJsonString(val) or tostring(val)
        table.insert(entries, encodeJsonString(key) .. ":" .. encodedValue)
    end

    local file, err = io.open(MagnusDCSScripting.saveFilePath, "w")
    if not file then
        env.error("mission_state: failed to write save file " .. MagnusDCSScripting.saveFilePath .. ": " .. tostring(err))
        return
    end
    file:write("{" .. table.concat(entries, ",") .. "}")
    file:close()
end

--- Deletes the save file so the next mission start begins fresh. Saving stops for the rest of this session,
--- otherwise the next flag change would recreate the file with partial state.
local function deleteSaveFile()
    local saveFilePath = MagnusDCSScripting.saveFilePath
    if not saveFilePath then
        return
    end

    MagnusDCSScripting.saveFilePath = nil
    saveState = {}

    if os and os.remove then
        local ok, err = os.remove(saveFilePath)
        if ok then
            env.info("mission_state: deleted save file " .. saveFilePath)
            return
        end
        env.error("mission_state: failed to delete save file " .. saveFilePath .. ": " .. tostring(err))
    end

    -- os is sanitized or the delete failed, so empty the file instead. Loading "{}" is the same as a fresh start.
    local file, err = io.open(saveFilePath, "w")
    if not file then
        env.error("mission_state: failed to clear save file " .. saveFilePath .. ": " .. tostring(err))
        return
    end
    file:write("{}")
    file:close()
    env.info("mission_state: cleared save file " .. saveFilePath)
end


local isProd = MagnusDCSScripting.config.env == "prod"

if isProd then
    local saveFilePath = getSaveFilePath()
    if saveFilePath then
        if lfs.attributes(saveFilePath, "mode") == "file" then
            loadSaveFile(saveFilePath)
        else
            createSaveFile(saveFilePath)
        end
    end
end


trigger.action.setUserFlag = function(flag, value)
    if isProd then
        saveFlag(flag, value)
    end
    originalSetUserFlag(flag, value);
end;

MagnusDCSScripting.saveFlag = saveFlag
MagnusDCSScripting.deleteSaveFile = deleteSaveFile

