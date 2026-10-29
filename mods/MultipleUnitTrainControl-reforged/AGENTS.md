# MultipleUnitTrainControl-reforged — notes for agents

Read this before changing the mod. Player-facing behaviour is in [README.md](README.md) (Russian),
history in [changelog.txt](changelog.txt). Local Paranoidal mod (`mods-metadata/MultipleUnitTrainControl-reforged.json`,
`source: local`), a rewrite of MultipleUnitTrainControl 1.0.5 + the replacement part of Robot256Lib 2.0.16.
Both originals are removed from the modpack; do not bring them back or depend on them.

## Mechanism in one paragraph

A locomotive only pulls the way it faces. For every pair "faces train front + faces train back" of the
same base type the mod swaps both locomotives to a hidden twin `<name>-mu` with `max_power × 2`.
The engine cannot change an entity's prototype, so a swap is destroy + create in the same place,
which also gives the train a new id. Everything else (labels, shared fuel) hangs on that.

## Files

| File | Stage | Role |
|---|---|---|
| `shared.lua` | all | Names: suffix, multiplier, mod-data name, sprite, technologies, settings. Change names only here. |
| `settings.lua` | settings | `mutc-mode` (research/always/off), `mutc-share-fuel`, `mutc-show-labels` (per user). |
| `data.lua` | data | Two technologies (names kept from the original for save compatibility) and the label sprite. |
| `data-final-fixes.lua` → `prototypes/mu-locomotives.lua` | final-fixes | Deep copies of the final locomotives + mod-data `mutc-reforged-locomotives` (`std → {mu, bonus}`). |
| `control.lua` | runtime | Events, queue, safety rules, mode, technology visibility. |
| `script/catalog.lua` | runtime | Read-only maps from mod-data; `quality_matters(std)`. |
| `script/planner.lua` | runtime | Pure: blocks of a train and the pair plan (`replace`, `labels`, `linked`). |
| `script/replace.lua` | runtime | Destroy/create of locomotives with full state transfer; restores the train once per batch. |
| `script/labels.lua` | runtime | Alt-mode render objects and their per-player audience. |
| `script/fuel.lua` | runtime | Even-out of fuel/burnt inventories over linked locomotives. |
| `script/blueprint.lua` | runtime | Renames twins to normal names in blueprints (stack, record, blueprint_to_setup, cursor). |

## Data stage rules

- Load order matters: optional dependencies `? zzzparanoidal` and `? JunkTrain3` put this mod's
  data-final-fixes after the locomotive balance (`zzzparanoidal/tweaks/entity/trains.lua`,
  `locomotive-fuel-efficiency.lua`), the reskin and JunkTrain3's final values. A locomotive changed by a
  mod that loads later is not mirrored: add an optional dependency on that mod instead of patching twins
  elsewhere. Never use a `~` dependency (data cache, see `agent-context/technical/01-execution-order.md`).
- A twin is made for every locomotive that is not hidden, has a placing item (`placeable_by` or an item
  with `place_result`) and is not in `EXCLUDED` (`prototypes/mu-locomotives.lua`). The twin keeps every
  field of the base except `name`, `hidden`, `factoriopedia_alternative`, `placeable_by`, `max_power`,
  `localised_name`, `localised_description`.
- Twins have **no item, recipe or catalogue technology**. Placement, pipette, robots and mining use the
  base item through `placeable_by` / `minable`. Do not add MU items: they would need recycling and defect
  handling (`ic-more-qualities`) and leak into inventories.
- The runtime knows the pairs only from mod-data. A locomotive whose name merely ends in `-mu` is not a twin.

## Runtime model

`storage` (all keyed by ids, all may hold invalid objects until cleanup):

| Key | Content |
|---|---|
| `queue` | train id → LuaTrain to process on the next ticks (5 per tick, dynamic `on_tick`) |
| `pending` | train id → LuaTrain that needs a swap but may not be touched now |
| `linked` | train id → LuaTrain with at least one pair (fuel sharing) |
| `fuel_cursor` | last train id balanced (round robin over `linked`) |
| `labels` | locomotive unit_number → render object id |

Flow: `on_train_created` (also from this mod's own swaps) and research/setting/configuration events
enqueue trains → `process(train)`: `planner.plan` → if `replace` is not empty and `can_replace` → `replace.batch`,
then plan again on the result → `labels.apply` → `fuel.link/unlink`. A train that may not be touched
goes to `pending`; `on_train_changed_state` re-queues it when it stands in a safe state.

Rules that keep it correct:

- Never swap inside another mod's event: only from `on_tick` (queue). Trains created during a swap are
  queued on purpose — the neighbour a new carriage briefly coupled to must get its own pass (this was a
  real bug: uncoupling left one twin). Intermediate trains are invalid by the next tick and skipped.
- `can_replace`: speed 0 and a waiting/manual state; no locomotive to be deconstructed/upgraded; no
  ground rail together with an elevated rail or ramp within 2.5 tiles (the engine puts a created
  locomotive on the elevated rail — checked); no Cybersyn delivery (`read_global("trains", id, "status")`
  other than 0 = depot).
- The planner pairs existing twins first, so a stable train produces an empty `replace` list. Keep this:
  otherwise every event would rebuild trains.
- Quality: pairs ignore quality while `catalog.quality_matters` is false. It compares
  `get_max_energy_usage` over all qualities; in 2.0.77 it is the same for every quality and the measured
  acceleration of normal and top quality locomotives is identical.
- Dynamic handlers (`on_tick`, `on_nth_tick` for fuel) are re-registered from storage/settings in `on_load`;
  module-level caches depend only on prototypes. Keep both properties (multiplayer determinism).
- `replace.lua` must free every `game.create_inventory` it makes (`unstash` destroys the copy) and must
  carry quality for the entity, fuel, burning item, equipment and spilled items.
- Removing an entry from a table that `next` walks: clear only existing keys; `fuel.unlink` resets the
  cursor when it removes it.

## Integrations in the modpack

- `zzzparanoidal/controls/battery-locomotive-return.lua` returns BET batteries for any locomotive burning
  `bet-fuel-battery`, twins included.
- `MxlChievements-Reforged` "push-pull" requires this mod and looks for locomotive names ending in `-mu`.
- `ParanoidalLocale` holds no keys of this mod; the locale lives here (en, ru only).
- `zzzparanoidal/tweaks/technology/early-material-prerequisites.lua` also adds `chemical-science-pack` to the wireless technology.

## Verified engine facts (2.0.77, 2026-10-29)

- `surface.create_entity` of a locomotive over ground + elevated rails picks the elevated rail.
- Locomotive power does not depend on quality (equal `get_max_energy_usage`, equal acceleration).
- Hidden twins are included in blueprints (`include_trains`) and are built from the base item.
- Writing `color` on a `locomotive` of this build reads back `nil` (no custom colour), so colour restore
  could not be observed here.
- A script write of `settings.global[...]` raises `on_runtime_mod_setting_changed` (off mode test).

## Checks to repeat after a change

Local workspace tools (outside Git):

- `test-runs/_mutc-src/mock.lua` — `lua.exe mock.lua <path to this mod>`: planner and fuel balance mocks.
- `test-runs/_mutc-src/check_dump.py <data-raw-dump.json>` — twins equal the final locomotives, mod-data,
  no MU items/recipes, technologies.
- `python -B test-runs/_mutc-src/run_smoke.py RUN` — headless server on a physical copy of the mods with
  `mutc-smoke.lua` appended to this mod's `control.lua`; results in `RUN/write-data/script-output/mutc-smoke.txt`.
  Follow `agent-context/procedures/TESTING.md` (180 s limit, no automatic retries).

Not covered by automated checks: Cybersyn depot behaviour in a real network, save/load, multiplayer,
how the labels look.
