# Arctic Razor

## Script Load Order

### Production

```lua
-- MUST BE FIRST
-- ONCE > TIME MORE (1) > DO SCRIPT FILE
-- dcs_scripts/main.lua

-- ONCE > TIME MORE (2) > DO SCRIPT FILE
-- dcs_scripts/mission/arctic_razor/config.lua

-- Order does not matter in second trigger, they populate the GLOBAL generated in main.lua
-- ONCE > TIME MORE (3) > DO SCRIPT FILE
-- dcs_scripts/damage_tracker/damage_tracker_handler.lua
-- dcs_scripts/damage_tracker/damage_tracker.lua
-- dcs_scripts/damage_tracker/initialize_damage_tracker.lua

-- MUST BE LAST
-- ONCE > TIME MORE (4) > DO SCRIPT FILE
-- dcs_scripts/event_handler.lua
```

### Dev Mode

```lua
-- ONCE > TIME MORE (1) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\main.lua")

-- ONCE > TIME MORE (2) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\missions\\arctic_razor\\config.lua")

-- ONCE > TIME MORE (3) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\damage_tracker.lua")

dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\damage_tracker_handler.lua")

dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\initialize_damage_tracker.lua")

-- ONCE > TIME MORE (4) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\event_handler.lua")
```
