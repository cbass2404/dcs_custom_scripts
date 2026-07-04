local unit = Group.getByName("Strike Group Alpha"):getUnit(1)
if unit and unit:isExist() then
    trigger.action.radioTransmission("l10n/DEFAULT/inv-morse-code.ogg", unit:getPoint(), 0, true, 1050000, 1000,
        "SGA_NDB")
end
