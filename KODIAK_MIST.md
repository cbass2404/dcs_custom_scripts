# Operation Kodiak Mist

## Situation

Insurgents emboldened by foreign trainers have been causing havok around the Torne River region. Your team has been sent in to contain the problem.

## Communication

| Callsign       | Type | Frequency | Comments |
| -------------- | ---- | --------- | -------- |
| AWACS          |      | 251 mhz   |          |
| JTAC           |      | 127.5 mhz |          |
| Farp London    |      | 150 mhz   |          |
| Farp Paris     |      | 134 mhz   |          |
| HMS Invincible |      | 141 mhz   |          |

## Navigation

### Objectives

| Waypoint        | Frequency | Name | Audio         | Comments                   |
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

| Waypoint                  | Frequency | Name | Audio          | Comments |
| ------------------------- | --------- | ---- | -------------- | -------- |
| Farp London Capture Force | 41.5 mhz  | LCF  | .-.. -.-. ..-. |          |
| Crashed Helo Survicors    | 32.25 mhz | SUR  | ... ..- .-.    |          |

## Available Missions

| Obective            | Description                                                                                                                                       | Commments                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Capture Enemy Farp  | Destory the enemy units at the enemy farp and capture a new spawn point.                                                                          |                                                                                     |
| Capture Kemi Tornio | Capture the nearby airbase.<br>This can work as a Rearm/Refuel point for friendlies.                                                              |                                                                                     |
| CSAR                | Rescue the downed chopper pilot from pursuing enemy scouts and<br>bring him safely to Kemi Tornio.                                                | TODO: Setup trigger to spawn helo survivor and start broadcasting home on band code |
| Dam Defense         | Evict enemy forces from the nearby Dam before they destroy it!                                                                                    |                                                                                     |
| IED Factory         | An IED factory has been reported in this area.<br>We don't know where exactly it is but it's in this area.<br>Search and destory.                 |                                                                                     |
| River Raid          | Run up the river and sanitize it of the light enemy forces occupying it.                                                                          |                                                                                     |
| Silkworm Site       | Destroy the enemy Silkworm Site.<br> Restore civilian and military supply shipping to the area.                                                   |                                                                                     |
| Town Liberation     | Liberate the town from enemy forces,<br>but watch your collateral damage.<br>It's not a liberation if all you leave is rubble.                    |                                                                                     |
| Training Camp       | The enemy has set up an intensive training camp to bolster local<br>insurgents. Wipe it out.                                                      |                                                                                     |
| Trainyard           | Hostiles have taken control of an important trainyard and are robbing<br>the trains that come in.<br>Take them down, just don't blast the trains. |                                                                                     |

### Mission Complete Requirements

| Mission         | Complete Trigger     | Requirements                                                 | Comments                 |
| --------------- | -------------------- | ------------------------------------------------------------ | ------------------------ |
| Farp London     | FARP_LONDON_COMPLETE | FARP London Red Forces <br> Farp London Infantry in Zone     | Operation Paris Guard    |
| Silkworm        | SILKWORM_COMPLETE    | Silkworm Site 1 <br> Silkworm Site 2 <br> Silkworm Defenders | Operation Sea Spray      |
| Town Liberation | TOWN_COMPLETE        | Town Hostiles A1-7 <br> Town Hostiles B1-3                   | Operation Quiet Citadel  |
| Dam Defense     | DAM_COMPLETE         | Dam Defenders                                                | Operation Hydro Lock     |
| Trainyard       | TRAINYARD_COMPLETE   | Trainyard Defenders                                          | Operation Steel Junction |
| Farp Paris      | FARP_PARIS_COMPLETE  | Farp Paris Defenders                                         | Operation Paris Guard    |
| IED Factory     | IED_COMPLETE         | IED Factory A-B                                              | Operation Wire Cutter    |
| Training Camp   | TRAINING_COMPLETE    | Training Camp Defenders <br> Training Camp Bunker            | Operation Citadel Sweep  |
| CSAR            | CRASHED_COMPLETE     | Crashed Helo Ambushers A-D                                   | Operation Steel Canopy   |
| Return to Ship  | RTS_COMPLETE         | All Missions Complete, landed at HMS Invincible              |                          |

FARP_LONDON_COMPLETE
SILKWORM_COMPLETE
TOWN_COMPLETE
TRAINYARD_COMPLETE
FARP_PARIS_COMPLETE
IED_COMPLETE
TRAINING_COMPLETE
CRASHED_COMPLETE
DAM_COMPLETE
RTS_COMPLETE

## Dynamic Reaper FAC

Frequency: 255 mhz<br>Laser Code: 1775

| Mission          | Waypoint | Comments |
| ---------------- | -------- | -------- |
| Farp London      | 1        |          |
| Silkworm         | 2        |          |
| Town Liberation  | 3        |          |
| Dam Defense      | 4        |          |
| Trainyard        | 5        |          |
| Farp Paris       | 6        |          |
| IED Factory      | 7        |          |
| Training Camp    | 8        |          |
| CSAR             | 9        |          |
| Mission Complete | 10       |          |

## TODOS

- morse code translation kneeboard
- generate audio for script
- add kneeboard dividers for different missions
- add graphics in game with mission names
- fleet needs to move up into patrol loop after silkworm is down

- Town Liberation
  - if mission success first but then destruction trigger is met then no revolt

## Pre-Release TODOS

- remove dofile links to local files when ready to deploy
