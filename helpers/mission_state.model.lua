--- Writes a flag to the mission's save file (prod only). Mission editor flag actions don't go through trigger.action.setUserFlag, so the editor calls this from a DO SCRIPT after them. Without a value it saves the flag's current value.
--- @alias saveFlag fun(flag: string|number, value: number|boolean|nil): nil

--- Deletes the mission's save file so the next mission start begins fresh (prod only). Saving stops for the rest of the session so later flag changes don't recreate it.
--- @alias deleteSaveFile fun(): nil
