--- @type getFinalScore
local function getFinalScore()
    local config = MagnusDCSScripting.config

    -- Safely read the percentage target from your global config object
    local partialSuccessPercent = config and config.partialSuccessPercent or 70

    -- Safe-proof the configuration: default to 70% if the value is invalid or zero
    if not config or not config.partialSuccessPercent or type(config.partialSuccessPercent) ~= "number" or
        config.partialSuccessPercent <= 0 or config.partialSuccessPercent > 100 or not config.missions then
        env.info(
            "[Magnus Custom Script - Final Score]: Error: Invalid or missing configuration for finalScore. Ensure config.partialSuccessPercent is a positive number more than 0 up to 100 and config.missions is defined.")
        return
    end

    local missions = config.missions
    local perfectScore = #missions
    local finalScore = 0

    -- 1. Calculate raw player score from flags
    for _, mission in ipairs(missions) do
        local flagValue = trigger.misc.getUserFlag(mission.completedFlag)
        if flagValue == 1 then
            finalScore = finalScore + 1
        end
    end

    local displayMessage = ""
    if finalScore == perfectScore then
        displayMessage = string.format("Mission Success %d/%d", finalScore, perfectScore)
        trigger.action.outTextForCoalition(2, displayMessage, 60)
        return -- Cleanly exits here on perfect runs, skipping all code below
    end

    -- 2. Penalize overflow points (e.g., collateral damage or extra deaths) and determine score
    local minimalScore = math.ceil(perfectScore * (partialSuccessPercent / 100))

    -- 3. Conditional check sequence
    if finalScore >= minimalScore then
        displayMessage = string.format("Partial Success %d/%d", finalScore, perfectScore)
    else
        displayMessage = string.format("Mission Failure %d/%d", finalScore, perfectScore)
    end

    -- 6. Broadcast message to Blue Coalition (2)
    trigger.action.outTextForCoalition(2, displayMessage, 60)
end

MagnusDCSScripting.getFinalScore = getFinalScore
