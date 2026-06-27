# Operation Kodiak Mist

## Situation

Insurgents emboldened by foreign trainers have been causing havok around the Torne River region. Your team has been sent in to contain the problem.

## Script Load Order

### Production

```lua
-- MUST BE FIRST
-- ONCE > TIME MORE (1) > DO SCRIPT FILE
-- dcs_scripts/main.lua

-- ONCE > TIME MORE (2) > DO SCRIPT FILE
-- dcs_scripts/mission/kodiak_mist/config.lua

-- Order does not matter in second trigger, they populate the GLOBAL generated in main.lua
-- ONCE > TIME MORE (3) > DO SCRIPT FILE
-- damage_tracker
-- dcs_scripts/damage_tracker/damage_tracker_handler.lua
-- dcs_scripts/damage_tracker/damage_tracker.lua
-- dcs_scripts/damage_tracker/initialize_damage_tracker.lua
-- dcs_scripts/mission/final_score.lua

-- MUST BE LAST
-- ONCE > TIME MORE (4) > DO SCRIPT FILE
-- dcs_scripts/mission/kodiak_mist/event_handler.lua
```

### Dev Mode

```lua
-- ONCE > TIME MORE (1) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\main.lua")

-- ONCE > TIME MORE (2) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\mission\\kodiak_mist\\config.lua")

-- ONCE > TIME MORE (3) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\damage_tracker.lua")

dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\damage_tracker_handler.lua")

dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\damage_tracker\\initialize_damage_tracker.lua")

dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\mission\\final_score.lua")

-- ONCE > TIME MORE (4) > DO SCRIPT
dofile("C:\\Users\\coryb\\Dev\\dcs_scripts\\mission\\kodiak_mist\\event_handler.lua")

-- ONCE > TIME MORE (20) > DO SCRIPT
MagnusDCSScripting.initializeDamageTracker("TOWN_COLLATERAL_ZONE", 10, "TOWN_UPRISING")

MagnusDCSScripting.initializeDamageTracker("DAM_COLLATERAL_ZONE", 1, "DAM_UPRISING")

MagnusDCSScripting.initializeDamageTracker("TRAIN_YARD_COLLATERAL_ZONE", 5, "TRAIN_YARD_UPRISING")
```

## Communication

| Callsign       | Type    | Frequency | Comments    |
| -------------- | ------- | --------- | ----------- |
| Overlord 1-1   | AWACS   | 124 mhz   |             |
| UZI 1-1        | JTAC    | 127.5 mhz | LASER: 1775 |
| London         | FARP    | 150 mhz   |             |
| Paris          | FARP    | 134 mhz   |             |
| HMS Invincible | CARRIER | 141 mhz   |             |

## Navigation

### Objectives

| NDB             | Frequency | Name | Audio         | Comments                   |
| --------------- | --------- | ---- | ------------- | -------------------------- |
| Dam Defense     | 675 khz   | DDT  | -.. -.. -     |                            |
| Farp London     | 950 khz   | FLN  | ..-. .-.. -.  | TODO: Revist morse code    |
| Farp Paris      | 515 khz   | FPR  | ..-. .--. .-. | TODO: Revist morse code    |
| Kemi Tornio     | 415 khz   | KTA  | -.- - .-      |                            |
| Silkworm        | 575 khz   | SWT  | ... .-- -     | Targets 180 for 8.5 clicks |
| Town Liberation | 550 khz   | TLT  | - .-.. -      |                            |
| Trainyard       | 775 khz   | TYT  | - -.-- -      |                            |

### Non-Directional Beacons

| Waypoint       | Frequency | Name | Audio      | Comments |
| -------------- | --------- | ---- | ---------- | -------- |
| HMS Invincible | 1050 khz  | INV  | .. -. ...- |          |

### Infantry Beacons

| Waypoint                           | Frequency | Name | Audio          | Comments |
| ---------------------------------- | --------- | ---- | -------------- | -------- |
| Nomad (Farp London Capture Force)  | 41.5 mhz  | LCF  | .-.. -.-. ..-. |          |
| Heavy 1-1 (Crashed Helo Survivors) | 32.25 mhz | SUR  | ... ..- .-.    |          |

### Mission

| AM# | WP  | Mission         | Complete Trigger     | Requirements                                             | Comments                 |
| --- | --- | --------------- | -------------------- | -------------------------------------------------------- | ------------------------ |
| 1   | 1   | Farp London     | FARP_LONDON_COMPLETE | FARP London Red Forces <br> Farp London Infantry in Zone | Operation Iron Anchor    |
| 2   | 2   | Silkworm        | SILKWORM_COMPLETE    | Silkworm Site 1 <br> Silkworm Site 2                     | Operation Sea Spray      |
| 3   | 3   | Town Liberation | TOWN_COMPLETE        | Town Hostiles A1-7 <br> Town Hostiles B1-3               | Operation Quiet Citadel  |
|     | 4   | Kemi Tornio     |                      |                                                          |                          |
| 4   | 5   | Dam Defense     | DAM_COMPLETE         | Dam Defenders                                            | Operation Hydro Lock     |
| 5   | 6   | Trainyard       | TRAINYARD_COMPLETE   | Trainyard Defenders                                      | Operation Steel Junction |
| 6   | 7   | Farp Paris      | FARP_PARIS_COMPLETE  | Farp Paris Defenders                                     | Operation Paris Guard    |
| 7   | 8   | IED Factory     | IED_COMPLETE         | IED Factory A-B                                          | Operation Wire Cutter    |
| 8   | 9   | Training Camp   | TRAINING_COMPLETE    | Training Camp Defenders <br> Training Camp Bunker        | Operation Citadel Sweep  |
| 9   | 10  | CSAR            | CRASHED_COMPLETE     | Crashed Helo Ambushers A-D                               | Operation Steel Canopy   |
| 10  | 11  | Return to Ship  | RTS_COMPLETE         | All Missions Complete, landed at HMS Invincible          |                          |
| 11  |     | MISSION END     |                      |                                                          |                          |

Press the Spacebar when your flight is ready to continue and tuned into Overlord.

Note: Only one spacebar press will advance the mission no matter who presses it. Do not continue until everyone is ready.

## TODOS

- morse code translation kneeboard
- generate audio for script
- change script to radio transmission
- update awacs (Overlord) to 124
- add kneeboard dividers for different missions
- add graphics in game with mission names

## Pre-Release TODOS

- remove dofile links to local files when ready to deploy
