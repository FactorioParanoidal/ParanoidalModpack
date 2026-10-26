# PARANOIDAL: Start with BnL

Local project mod (until 2.0.0 `zzzparanoidal-shipwreck`): the whole start of Paranoidal. Balance of
the start crash supplies is in `shipwreck-config.lua`, everything new in `bnl-config.lua`.

## Start crash supplies (from 1.0.0)

- Data stage: AAI wreck prototypes and the salvaged assembling machine, lab and generator
  (`data.lua`, lab inputs copied from the vanilla lab); in `data-final-fixes.lua` (after
  ic-more-qualities) every wreck and the ship get mining time 1.5 s (the ship 6 s, big wrecks 3 s), the medium loot of the config
  and an invisible pickaxe target, the ship 80 slots, the generator its values and quality tooltip.
- Control: on a new map the freeplay item lists are emptied (the player starts empty, respawn items
  stay), the AAI scene is created and, when freeplay has created the crash site, the ship and its
  debris are filled. Start wrecks get their mining loot from the config with the start level and
  quality; other wrecks (ruins) keep the prototype loot.
- Quality: one roll per item type per map from the `ic-defects-classification` mod-data of
  ic-more-qualities. Minimum: defect-capable finished items and all electric poles get `ic-defect-1…5` by the level weights (5/15/25/25/20/10%, 0 = normal); rich: every
  finished item gets 0…5 steps along `normal.next` by the level weights (25/30/20/13/8/4%); materials and belts/undergrounds/splitters/loaders are always normal. `config.normal_share`:
  half of all start repair packs (rounded up, at least 10) is always normal, the rest gets the
  rolled quality, so the first refine workshop can be crafted on every level. Without
  ic-more-qualities everything is normal.
- Salvaged generator: production × `default_multiplier`, buffer × `accumulator_capacity_multiplier`
  of the entity quality, set when built and on configuration change.

## BnL start (2.0.0)

Everything starts only on a new map (`game.tick < 2` at init); each part has a map setting.

| Part | Files | Notes |
|---|---|---|
| Falling debris | `scripts/falling.lua`, `prototypes/bnl-falling.lua` | Artillery projectiles from the WSW, impact trigger creates a start wreck; one big piece has the flight recorder; the shadow over the impact point shrinks from ×20–32 / 15% to ×1 / 100%; the impact blows up over its area and its sound plays for every player at full volume (on_nth_tick(2) only while a shadow exists) |
| Burning wrecks | `scripts/fire.lua`, `prototypes/bnl-final.lua` | One kind of hazardous cargo per wreck (`config.fire.hazards`: ammo, fuel barrels, gas cylinders flying off, high-tech fuel, explosives, oxygen, batteries; ≤50% goes off in the fire, 30% of the rest at the end, the rest is loot); water barrels slow and put out the fire (ship kit of 10); ~35% of start wrecks ignite after the landing; burns steadily down to 2–10% health with cook-offs; −1 quality at 75/50/25% and when the fire goes out (4 steps), each step burns away a whole random stack with 20%; materials stay normal; a burning wreck is indestructible (only the scripted fire lowers its health); wreck health ×10, the ship ×1.25 |
| Debris trail, compartments | `scripts/trail.lua`, `prototypes/bnl-entities.lua` | Placed when the 3×3 chunks are generated; beacon tags; the engineering bay on a lake shore or in its own crater pond |
| Fire characters, torches | `scripts/fire.lua` (`config.fire.temperaments`, `config.fire.torches`), `prototypes/bnl-falling.lua` | Steady / smoulder / blaze / flaring; refinery flame torches (barrels: 3 holes, gas: flare stack, fuel: 1 torch by fuel, oxygen: vanilla blaze); rendering objects only, no extra handler |
| Reactor compartment | `scripts/reactor.lua` | P(t) = 10 MW·(1 − t/T)², T ≈ 14.6 min; radiation while hot |
| Flight recorder | `scripts/recorder.lua`, `prototypes/bnl-technology.lua` | Research ingredient; journal, tags, safe code B/N, 20–30 red packs |
| Journal | `scripts/journal.lua` | Button + `/bnl-journal` |
| Insurance pods | `scripts/pods.lua` | After the first radar; contents are a draft |
| Professions | `scripts/professions.lua`, `scripts/intro.lua` | Pause in single player; `/bnl-profession` |
| Anomalies | `scripts/anomalies.lua` | One per map |
| Scrap | `scripts/scrap.lua`, `prototypes/scrap.lua` | Space Age prototype and graphics, hand or recycler |
| Previous expedition, turret, safe, MP pods, distress | `trail.lua`, `turret.lua`, `safe.lua`, `capsules.lua`, `distress.lua` | |

Runtime structure: `scripts/events.lua` (one handler per event; dynamic handlers only while
needed), `scripts/scheduler.lua` (one `on_nth_tick(30)` only while jobs are queued),
`scripts/tags.lua` (chart tags that wait for charting). When the start content has played out,
only the 5-tick wreck mining helper of 1.0.0 remains (needed for every wreck, also in ruins).

BnL logo, seal, flyers, the journal button and the logo on the insurance pod: `review/start-bnl-graphics/logo/make_logo.py`
and `make_assets.py` (outside the mod, redrawn from scratch; the Buy n Large logo is a Disney/Pixar trademark).
The weathered logo on the crashed starliner is a rendering decal (`config.ship_decal`, `util.ship_decal`).

Compartment graphics are composed from the vanilla crash-site spaceship renders by
`review/start-bnl-graphics/make_graphics.py` (outside the mod; variants and previews there),
projectile sprites, icons and sounds by `make_extras.py`.

Credits: salvaged machines and their graphics come from Looting Spaceship Wrecks by darkfrei and
sbelyakov (MIT); the AAI wreck graphics from AAI Industry by Earendel; scrap graphics and the scrap
prototypes from Factorio: Space Age by Wube Software (the modpack requires the expansion through
the quality mod); the falling debris sound `sound/falling-flyby.ogg` is an excerpt (cut, mono, normalized) of
"airplane-boeing-flyby-right-to-left-a" by InspectorJ, https://freesound.org/people/InspectorJ/sounds/428086/,
CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/); the incoming shell whistle `sound/incoming-1..4.ogg` is
"Incoming mortar 1-4" by Zagge28 (https://freesound.org/s/241840/ and the next three), CC0 1.0, mono, normalized.
