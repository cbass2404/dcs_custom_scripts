--- Global function initiated to dynamically remove a mission from the set active mission menu if completed
---@param missionCode number
function RemoveMissionFromSetActiveMissionMenu(missionCode)
    local targetKey

    for key, mission in pairs(Missions) do
        if mission.mission_code == missionCode then
            targetKey = key
            break
        end
    end

    if targetKey then
        missionCommands.removeItemForCoalition(coalition.side.BLUE, _G[targetKey])
    else
        env.info("[Error: Tundra Strike]: Key not found for mission code for removal: " .. tostring(missionCode))
    end
end
