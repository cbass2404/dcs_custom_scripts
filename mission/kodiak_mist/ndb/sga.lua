--- @type transmitSgaNdb
local function transmitSgaNdb()
    local group = Group.getByName("Strike Group Alpha")
    local unit = group and group:getUnit(1)
    if unit and unit:isExist() then
        trigger.action.radioTransmission("l10n/DEFAULT/inv-morse-code.ogg", unit:getPoint(), 0, false, 1050000, 1000,
            "SGA_NDB")
    else
        env.error("[MagnusDCSScripting NDB]: Strike Group Alpha not found, SGA NDB not started")
    end
end

MagnusDCSScripting.transmitSgaNdb = transmitSgaNdb
