# Agent notes — Maraxsis

Maraxsis is a Factorio 2.1 overhaul mod (Space Age + quality) that adds a fully
submerged planet, submarines, pressure domes, a deep-sea trench and an inverted
tech path. The mod is Lua only; there is no build step and no automated test
suite. Everything is validated by loading the mod in Factorio and reading
`factorio-current.log`.

Current metadata lives in `info.json` (version `1.40.26`, `base >= 2.1.22`,
`factorio_version` 2.1). Do not hand-edit the version or `changelog.txt`; the
release workflow generates both.

## Repository layout

```
.
├── data.lua                 base prototypes (runs first)
├── data-updates.lua         balance changes, vanilla edits, most compat
├── data-final-fixes.lua     collision masks, late ordering, APS final fixes
├── settings.lua             startup settings (data stage)
├── settings-updates.lua     forces/locks other mods' settings
├── control.lua              runtime entry point
├── lib/                     shared helpers (maraxsis.*, table/string/color)
├── prototypes/              data-stage prototypes, one subsystem per file
├── scripts/                 control-stage systems, one system per file
├── compat/                  one file per supported third-party mod
├── migrations/              save-migration Lua + entity-rename JSON
├── locale/                  <lang>/locale.cfg + GUI width table
├── graphics/, sounds/       assets (source files are export-ignored)
├── maraxsis-start/          Any Planet Start integration bundled in this mod
├── .github/workflows/       semantic-release on push to main
└── .releaserc               release + changelog configuration
```

The parent directory (`../`) is a **different, deprecated git repository**
(`maraxsis-start`, the standalone starting-planet mod) that also contains a
nested clone of `factorissimo-2-notnotmelon`. Do not confuse files in `../` or
`../factorissimo-2-notnotmelon/` with this mod. Work in this directory.

## Load order and where code belongs

| Stage | File | Use for |
| --- | --- | --- |
| settings | `settings.lua`, `settings-updates.lua` | settings prototypes |
| data | `data.lua` | brand-new prototypes, planet/surface definitions |
| data-updates | `data-updates.lua` | editing vanilla and other mods' prototypes, balancing |
| data-final-fixes | `data-final-fixes.lua` | collision masks, ordering that must see every prototype |
| control | `control.lua` | runtime events, GUI, per-tick logic |

`data.lua` and `control.lua` create `_G.maraxsis = {}` and set
`_G.maraxsis_constants` **before** `require "lib.lib"`. `lib/lib.lua` detects the
stage (`maraxsis.stage` is `"settings"`, `"data"` or `"control"`) and loads the
matching helper file:

- data stage: `lib/data-stage.lua` (`maraxsis.merge`, surface-condition helpers,
  `maraxsis.shorten_localised_string`, `maraxsis.empty_image`, …)
- control stage: `lib/control-stage.lua` (`maraxsis.cancel_creation`,
  `maraxsis.draw_error_sprite`, `maraxsis.format_energy`, …) plus `lib/events.lua`

When adding a subsystem:

1. Data prototypes: create `prototypes/<area>/<name>.lua`, then add a
   `require "prototypes.<area>.<name>"` line in `data.lua` at the correct point
   (order matters: recipes/technologies must come after the entities they use).
2. Runtime logic: create `scripts/<name>.lua` and add a
   `require "scripts.<name>"` line in `control.lua`.
3. Compat: create `compat/<mod-name>.lua`, guard its body, and require it from
   the data stage that matches when the prototype it patches exists.

`require` paths are either relative to the mod root (`"prototypes.entity.submarine"`)
or relative to the requiring file (`"maraxsis-noise-expressions"` from inside
`prototypes/planet/`). Both are used.

## The data/control split (read this before debugging nil errors)

- `mods` exists **only** in the settings and data stages. At control stage use
  `script.active_mods["mod-name"]`.

  ```lua
  -- data stage
  if mods["any-planet-start"] then ... end

  -- control stage
  if script.active_mods["any-planet-start"] then ... end
  ```

- Prototype data (`data.raw`) is unavailable at control stage. Runtime code reads
  the exported constants prototype instead:

  ```lua
  -- data stage: the table created by data:extend
  maraxsis_constants = data.raw["mod-data"]["maraxsis-constants"].data

  -- control stage: same table, exported through prototypes
  maraxsis_constants = prototypes.mod_data["maraxsis-constants"].data
  ```

  The source of truth is `prototypes/mod-data/control-constants.lua`. Add shared
  constants there so both stages see the same values.
- Settings are readable in both stages via `settings.startup["name"].value`.
- No code uses the legacy `global` table. Runtime state belongs in `storage`.
  `storage` is created automatically; initialise fields in an `on_init` handler
  (`storage.foo = storage.foo or {}`) and validate stored entity references with
  `.valid` before use.

## Event system

Never call `script.on_event` directly from a subsystem. Register handlers through
the wrapper so multiple files can subscribe to the same event:

```lua
maraxsis.on_event(defines.events.on_built_entity, function(event) ... end)
maraxsis.on_event(maraxsis.events.on_built(), function(event) ... end)
maraxsis.on_nth_tick(73, function(event) ... end)

maraxsis.on_event(maraxsis.events.on_init(), function(event)
    -- runs for both on_init and on_configuration_changed
    if event then return end -- on_init only
end)

maraxsis.finalize_events() -- after all registrations, at the end of control.lua
```

`maraxsis.events` sentinels expand to groups of events: `on_built`, `on_destroyed`,
`on_built_tile`, `on_mined_tile`, `on_init`, `on_entity_clicked`. String event
names are also accepted (`maraxsis.on_event("toggle-driving", …)`); custom events
are declared as `custom-event` prototypes (`prototypes/custom-input.lua`).

Other utilities:

- `maraxsis.register_delayed_function(key, fn)` + `maraxsis.execute_later(key, ticks, ...)`
  runs `fn` after N ticks using a render-object lifetime, so it survives saves.
- GUI handlers are registered in the global `gui_events` table by element-name
  pattern, keyed by GUI event:

  ```lua
  _G.gui_events[defines.events.on_gui_click]["^my_button_"] = function(event) end
  ```

- `data.raw` entity `created_effect` can raise a `script` effect and be handled in
  `on_script_trigger_effect` (e.g. `on_built_a_breath_of_fresh_air`,
  `maraxsis-trench-wall-created`) instead of listening to build events.

## Prototype conventions

- Prefix every new prototype with `maraxsis-` (`maraxsis-hydro-plant`,
  `maraxsis-sonar`, `maraxsis-supercritical-steam`). Vanilla overrides keep the
  vanilla name.
- Use the double-brace idiom: `data:extend {{ type = ..., name = ... }}`.
- Four-space indentation is the norm (a few old files use tabs; match the file).
  Lua 5.2 syntax. There is no formatter or linter configured.
- Clone an existing prototype with `maraxsis.merge(old, new)`; set a field to the
  string `"nil"` to delete it. Prefer `PlanetsLib.rro.soft_insert(list, value)`
  when inserting into another mod's table (it avoids duplicates).
- Icons: 64×64 items/recipes, 256×256 technologies, referenced as
  `__maraxsis__/graphics/...` and declared with `icon_size`.
- New items/entities/technologies need locale entries; see “Localisation”.
- Recipes that only make sense on Maraxsis use
  `surface_conditions = maraxsis.surface_conditions()` (or
  `maraxsis.trench_surface_conditions()` / `maraxsis.shallow_surface_conditions()`).

### Buildability rules and collision masks

Maraxsis cannot use vanilla collision masks for “water vs dome vs coral vs trench”,
so entities carry a custom six-key table:

```lua
maraxsis_buildability_rules = {
    water = true, dome = true, coral = true,
    trench = true, trench_entrance = false, trench_lava = false,
}
```

Exactly six keys are required (asserted in `prototypes/collision-mask.lua`).
`prototypes/collision-mask.lua` consumes the table during **data-final-fixes** and
creates tile-buildability rules and surface conditions. Therefore any rule must be
set before that file is required. Example: the PlanetsLib ground-digger rules are
assigned at the top of `data-final-fixes.lua`, before
`require "prototypes.collision-mask"`.

Custom collision layers are created in `prototypes/collision-mask.lua` and exposed
as globals from `scripts/constants.lua`:
`maraxsis_underwater_collision_mask`, `maraxsis_dome_collision_mask`,
`maraxsis_lava_collision_mask`, `maraxsis_coral_collision_mask`,
`maraxsis_trench_entrance_collision_mask`.

Pressure drives surface conditions: the ocean surface is `200000`, the trench is
`800000`. Use the helper functions rather than writing `pressure` conditions by
hand.

### Surfaces and planets

- Surfaces: `maraxsis` (ocean, pressure 200000) and `maraxsis-trench` (hidden,
  pressure 800000). Constants: `maraxsis_constants.MARAXSIS_SURFACES` and
  `MARAXSIS_TRENCH_SURFACES`.
- Factorissimo provides the `maraxsis-factory-floor` and
  `maraxsis-trench-factory-floor` planet variants; their surfaces are included in
  the water-mechanics surface tables.
- The trench must share the ocean's map seed so terrain lines up. Call
  `maraxsis.sync_trench_map_seed()` whenever the seed can change (it is also called
  on surface creation and on init).
- Planet and space-location prototypes live in `prototypes/planet/` (`space-location.lua`,
  `map-gen.lua`, `*-noise-expressions.lua`). `data.raw.planet`/`space-location`
  come from PlanetsLib.
- Late entity variants use `PlanetsLib.create_planet_entity_variant(..., "maraxsis-runtime-entity-replacement", ...)`;
  the final argument is the hidden startup setting that controls whether the
  variant is swapped in at runtime.

## Runtime systems (`scripts/`)

| File | Responsibility |
| --- | --- |
| `map-gen/maraxsis.lua`, `map-gen/maraxsis-trench.lua` | water shader per chunk, cliffs, coral, trench generation/seed |
| `submarine.lua` | entering/exiting submarines, surface transfers, fuel, patrols |
| `drowning.lua` | oxygen/breath damage outside domes and submarines |
| `swimming.lua` | surface-switch GUI button, swimming on Maraxsis |
| `pressure-dome.lua` | dome octagon geometry, flooding, regulators, GUI, transparency |
| `trench-foundation.lua`, `trench-duct.lua` | trench walls/foundations and ducts |
| `sonar.lua` | sonar scanning and map tags |
| `nukes.lua` | restricted nuke effects |
| `fishing-tower.lua` | fishing tower spawner logic |
| `abyssal-diving-gear.lua`, `nightvision.lua` | equipment behaviour |
| `supercritical-steam.lua`, `hydraulic-science-pack.lua` | Maraxsis fluids/science |
| `legendary-quality.lua` | promethium/legendary quality behaviour |
| `storage-migration.lua` | storage hand-off from `maraxsis-classic`, 2.0→2.1 warning |
| `remote.lua` | remote interface `maraxsis` (`get_submarine_list`, `get_storage`) |

`pressure-dome.lua` is the largest and most delicate file: dome membership is a
polygon test over an entity's collision box, and many event handlers update
`storage.pressure_domes`. Read the surrounding code before changing it.

## Compatibility mods

One `compat/<mod>.lua` per supported mod, all currently required from a data stage:

- `data.lua`: `krastorio-2`
- `data-updates.lua`: `aai-industry`, `aai-signal-transmission`, `editor-extensions`,
  `transport-ring-teleporter`, `quality-seeds`, `modules-t4`, `5-dim-automation`,
  `rcu-restored`, `aircraft-space-age`, `corrundum`, `muluna`,
  `aai-programmable-structures`
- `data-final-fixes.lua`: `5-dim`, `alien-biomes`, `visible-planets-in-space`,
  `rocket-silo-construction`, `combat-mechanics-overhaul`, `castra`,
  `krastorio-2-final-fixes`, `water-refining`, `science-tab`
- control stage: `compat/call-plumber.lua`
- `compat/schall-transport-group.lua` is loaded from `prototypes/item-subgroups.lua`

Rules:

- Guard with `if not mods["ModName"] then return end` at the top of the file
  (or make every access conditional). The mod id is the one in `info.json`, not
  the display name.
- Add the mod as optional (`? mod-name`) or hidden (`(?) mod-name`) in
  `info.json` instead of an unconditional dependency unless the mod truly cannot
  work without it.
- Prefer `PlanetsLib` helpers (`restrict_surface_conditions`,
  `create_planet_entity_variant`, `rro.soft_insert`) over editing foreign
  prototypes directly.
- Compat patches that touch entities must be applied before
  `prototypes/collision-mask.lua` (data-final-fixes) if they set
  `maraxsis_buildability_rules`.

## Any Planet Start integration (`maraxsis-start/`)

This subfolder is **not** a separate mod here even though it has `info.json`; it
is the bundled “start on Maraxsis” content, and `info.json` declares
`"! maraxsis-start"` because the standalone mod is superseded.

- `data.lua` registers the planet with `APS.add_planet { ... }` when
  `any-planet-start` is active and requires `maraxsis-start.data` only when
  `settings.startup["aps-planet"].value == "maraxsis"`.
- `maraxsis-start/settings.lua` calls `APS.add_choice("maraxsis")`.
- `maraxsis-start/maraxsis.lua` rewrites the tech tree and recipes (loaded via
  APS, not `require`d directly).
- `maraxsis-start/data-final-fixes.lua` runs last in `data-final-fixes.lua`, after
  the mod's collision-mask pass.
- `maraxsis-start/control.lua` runs only when APS is active and Maraxsis is the
  chosen start.
- `maraxsis-start/changelog.txt`/`info.json` are standalone-mod leftovers; do not
  treat them as this mod's release metadata.

## Migrations

- `migrations/*.json` rename old prototypes on load, e.g.
  `{"entity": [["electric-mining-drill-sand-extractor", "electric-mining-drill-ground-digger"]]}`.
- `migrations/*.lua` run in the migration stage (game is available, `maraxsis` is
  not guaranteed). They are for fixing existing saves when a prototype or recipe
  changes, not for normal gameplay setup.
- `scripts/storage-migration.lua` handles runtime storage import from
  `maraxsis-classic`; keep it running before other systems that assume storage
  exists.
- `info.json` has `"migrates_from": ["maraxsis-classic"]`.

## Localisation

- Add keys to `locale/en/locale.cfg` (and optionally other languages) under the
  correct section: `[item-name]`, `[entity-name]`, `[entity-description]`,
  `[recipe-name]`, `[technology-name]`, `[technology-description]`,
  `[fluid-name]`, `[tile-name]`, `[space-location-name]`, etc.
- Reference localisation with `{"section.key"}`; never put raw English in a
  `localised_name` for something players will see.
- A localised string may not exceed 20 components, or Factorio crashes. Use
  `maraxsis.shorten_localised_string(value)` when building long strings at data
  stage, especially `factoriopedia_description` lists.
- GUI element widths that vary by language go in `locale/gui-locale.lua`
  (`maraxsis.get_gui_locale(locale)`). `locale/gui_locale.lua` is a duplicate of
  the same table; the file actually required by `control.lua` is
  `locale.gui-locale`.
- Translations are managed on Crowdin (see `README.md`); it is fine to add English
  keys only and leave the rest to translators.

## Assets

- `graphics/` and `sounds/` are referenced as `__maraxsis__/graphics/...`.
- Source files (`.pdn`, `.psd`, `.xcf`, `.py`, `.sh`, `.aup3`, `.blend`) are
  export-ignored in `.gitattributes` and excluded from release zips. Add new
  source formats to `.gitattributes` if needed.
- Sprite sheets are built with `graphics/mipgenerator*/make4mips.sh`; icons are
  generated/resized with the Python helpers under `graphics/icons/ez-resize/`.
- Keep sprite metadata (`width`, `height`, `frame_count`, `line_length`, `scale`,
  `shift`) consistent with the PNGs; Factorio reports mismatches at load time.

## Versioning, changelog and releases

`.releaserc` + `.github/workflows/release.yml` run **semantic-release** on every
push to `main`:

1. `.github/scripts/update-planetslib-dependency.js` bumps the required PlanetsLib
   version to the latest on the mod portal.
2. semantic-release computes the bump from conventional commit types, rewrites
   `changelog.txt` and `info.json`, commits them, creates the GitHub release and
   uploads the packaged zip to the mod portal.

Commit message format: `type(scope): subject`, where scope is optional and is
rendered as `[scope]` in the changelog. Types that trigger a **minor** bump:
`feat`, `feature`. Everything else is a **patch**: `fix`, `compat`,
`compatibility`, `balance`, `gui`, `perf`, `performance`, `graphics`, `sound`,
`locale`, `translate`, `control`, `info`, `other`. Use the most specific type
(`fix(compat): ...` rather than `fix: ...` with a vague subject).

Do not:

- edit the version in `info.json` or the top of `changelog.txt` by hand,
- run release steps locally,
- add non-conventional commit subjects (the changelog will be wrong).

## Testing and verification

There is no test runner, linter or CI check other than the release. To verify a
change:

1. Load a save or start a new game with the mod enabled and inspect
   `factorio-current.log` for `Error while running …`, prototype errors, or
   `attempt to index a nil value` traces.
2. Data-stage changes are validated at prototype load time; runtime changes need
   a game tick (or `/editor`/remote view) to exercise.
3. Use the in-game console to inspect state, e.g.
   `/c game.print(serpent.block(storage))` and
   `/c game.print(serpent.block(prototypes.mod_data["maraxsis-constants"].data))`.
4. For GUI work, open the relevant entity (dome, submarine, sonar) and verify
   every event path, including closing/reopening and multiplayer player indexes.
5. For save compatibility, test loading a save made before the change; migrations
   and `storage` initialisation must both be idempotent.
6. `.vscode/settings.json` lists the Factorio/Lua globals and recommendations
   (`sumneko.lua`, `justarandomgeek.factoriomod-debug`); it is a hint for editor
   diagnostics, not a build configuration.

## Common pitfalls

- `mods` is `nil` at control stage — use `script.active_mods`.
- Use `storage`, not `global` (2.1 API). Validate stored entities with `.valid`.
- `maraxsis.finalize_events()` must run after every `maraxsis.on_event` /
  `maraxsis.on_nth_tick` registration; in `control.lua` only the optional `gvv`
  hook follows it. Require new script files above it.
- Register events through `maraxsis.on_event`, not `script.on_event`, or one
  handler silently replaces another.
- An entity's `maraxsis_buildability_rules` must have exactly six boolean keys and
  must be set before `prototypes/collision-mask.lua` runs in data-final-fixes.
- Do not `table.insert` into shared lists without checking — use
  `PlanetsLib.rro.soft_insert`; duplicates corrupt tech/recipe effects.
- Building the same data-stage prototype twice errors at load; check whether a
  compat file or vanilla already defines it, and mutate the existing `data.raw`
  entry instead.
- `localised_string` tables are limited to 20 elements; use
  `maraxsis.shorten_localised_string`.
- The trench and ocean map seeds must stay in sync; call
  `maraxsis.sync_trench_map_seed()` after changing either planet's map generation.
- APS-gated code must check `settings.startup["aps-planet"].value == "maraxsis"`
  at data stage and `script.active_mods["any-planet-start"]` at control stage;
  never load `maraxsis-start` content unconditionally.
- `data.lua` runs before `data-updates.lua` before `data-final-fixes.lua`. A
  prototype created in `data-updates.lua` cannot be referenced from `data.lua`.
- Recipe `categories` is a list; `category` is the old singular field. Match the
  surrounding code (the codebase mixes legacy singular fields in a few places).

## Key files cheat sheet

| Looking for… | Open |
| --- | --- |
| planet, map generation, surfaces | `prototypes/planet/space-location.lua`, `prototypes/planet/map-gen.lua` |
| shared constants (surfaces, submarines, domes) | `prototypes/mod-data/control-constants.lua` |
| buildability/collision rules | `prototypes/collision-mask.lua` |
| all recipes / technologies | `prototypes/recipe/recipes.lua`, `prototypes/technology/` |
| entities | `prototypes/entity/` |
| runtime entry points | `control.lua` → `scripts/*.lua` |
| helpers | `lib/data-stage.lua`, `lib/control-stage.lua`, `lib/table.lua` |
| compat | `compat/` (mapping above) |
| starting-planet content | `maraxsis-start/` |
| release config | `.releaserc`, `.github/workflows/release.yml` |
