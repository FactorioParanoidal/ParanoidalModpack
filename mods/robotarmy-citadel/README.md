# Robot Army: Replicator Citadel

A hostile city of replicator droids for Factorio 2.0, built on the droids of Robot Army Reforged.
At 50 % biter evolution it appears far from the player base, grows by one walled module chunk
every 10 minutes and sends every finished squad against the players.

## Life of the citadel

| Stage | What happens |
|---|---|
| Waiting | Evolution of the `enemy` force on Nauvis is read once a minute. At 45 % the players get a warning. A save already past the threshold gets the citadel 10 minutes after the mod is added. |
| Place | Spawn point + base radius (10 chunks) + distance (50 chunks), random direction; the chunk may have at most 25 % water (paved over) and no player building in the 3x3 chunks around. Up to 8 tries per distance, then 5 chunks farther. |
| Growth | Every growth interval: a ruined module is rebuilt first; otherwise a new module next to the city (compact shapes preferred, toward the base with relay masts). Chunks with water, player buildings or no generation are skipped for 30 minutes. |
| Shields | From 25 modules (with Defence Tower Reforged): a defence tower in every module, shield research for the citadel force, shield modules in the choice. |
| Acceleration | From 100 modules: foundries +10 % speed per hour, no limit. |
| Hive lost | No growth for 60 minutes (foundries keep working). Then the foundry module farthest from the base becomes the new hive; the old hive is rebuilt later as a foundry. |
| Defeat | The hive down and every foundry destroyed: the remaining buildings blow up, the droids are gone. |

## Modules

Every module is one chunk: floor plating, a road cross (tiles 15-16) that continues into the
neighbours, a plaza (12..19) with the hub pylon (supplies the chunk, wired to the neighbour hubs),
four lamps and the place of the shield tower, four quarters for buildings, corner towers. Walls only
on outer edges, gates where the roads leave, inner corners closed. Key buildings decide whether a
module stands: when all of them are destroyed the module is ruined (no bonus, rebuilt first).

| Category | Types (key building) | Effect |
|---|---|---|
| Core | hive | growth; makes riflebots and scouts; muster point |
| Production | light, assault, fire support, sniper, energy weapons, aircraft, terminator foundries | droids of their kinds |
| Power | power plant (2 reactors, 20 MW each) | towers, radars, shields run on the city network |
| Defence | bastion, turret nest, mortar battery (range 40), minefield | towers, mines |
| Support | repair dock, supply depot, wreck recycler | healing, +8 % production each, free droids from losses |
| Recon | radar, jammer, relay mast | knowledge of the base, unchart the city, growth toward the base |
| Upgrade | armour works, weapons laboratory, targeting array, computing centre | armour mark I-III with adaptive focus, +10 % damage, +8 % rate of fire, intelligence |
| Shield | shield amplifier, shield regenerator | shield research levels (from 25 modules) |

## Squads and intelligence

Droids join the squad gathering on the hive plaza; a full squad (8 + 1 per foundry module, at most
40) marches on the base in route segments; at most 6 squads attack at once, at most 400 droids
live. Intelligence levels (one per computing centre, up to 6): 0 nearest target, half squads,
no retreat; 1 full squads and retreat after heavy losses; 2 undefended buildings first; 3 avoids
the chunks where droids died; 4 marches without distraction; 5 pincers (two squads, two targets);
6 strikes poles and generators, damaged squads go to the repair docks.

## Performance

- No unit spawner prototypes and no on_tick: the citadel creates its droids by script.
- One heartbeat every 60 ticks; every task inside it works on a bounded portion: up to 30 foundries,
  one look at each attacking squad every 2 seconds, up to 4 radar chunk looks, every 5 seconds 25
  droids, one repair dock and 4 modules checked.
- The build queue (`on_nth_tick(4)`) is registered only while something is built: 3 buildings per
  step, tiles and clearing in strips of 8 rows.
- One command per squad (a unit group), never per droid; low-priority cached paths.
- Towers, power, lamps, shields and loot are engine work (electric network, turret prototypes,
  loot tables); buildings are simple entities with animations.
- Events: `on_entity_died` filtered by the names of the citadel's droids and buildings; force and
  player changes; setting changes.

## Settings (map)

Enabled, warning and appearance evolution, base radius, distance, growth interval, pause after the
hive falls, acceleration threshold and percent per hour, shield threshold, droid limit, attacking
squads, squad size and maximum, cleared radius, messages.

## Interfaces

Remote interface `robotarmy-citadel`: `status()`, `modules()`, `squads()`, `spawn(x, y)`,
`grow(n, module_type)`, `defeat()`, `configure(overrides)` (keys of the cached settings such as
`growth_ticks`, `stun_ticks`, `base_radius`, `distance`, `squad_base`, `cull_min`; kept in the save,
`configure(nil)` clears them; `grow` forces chunk generation and is meant for tests and admins). Command `/signal` (a neutral name: it is listed in `/help` from the start) prints the phase before the citadel appears and the full state after. Robot Army Reforged gets the kills of its droids
through its remote function `credit_kill`.

## Tests (pure Lua 5.1, run from the mod root; not engine evidence)

`tests/fake_api.lua` is a small fake of the control API used by the control tests (entities in a
spatial index, forces, unit groups that never move; a script placement is blocked by items on the
ground and units in the footprint, as in the engine; event name filters must be single names).

- `tests/layout_test.lua`: plans inside the walls without overlaps, roads and plaza free, key
  buildings in every plan, walls of a lone module and an inner corner, chunk keys, the module choice
  over 120 modules (caps, every category).
- `tests/data_mock_test.lua <raw.lua>`: data.lua, data-updates.lua and data-final-fixes.lua against
  base prototypes taken from a data-raw dump: every new prototype has its fields, sprite files and
  matching animation frames, 195 replicator droids with loot.
- `tests/control_mock_test.lua`: a fake game API runs the whole life: truce and war, warning,
  appearance 60 chunks out, one hour of growth and production, nest clearing, forced growth to the
  shield stage, the hive lost (pause, no growth, new hive), defeat and the blowing up of the city.
