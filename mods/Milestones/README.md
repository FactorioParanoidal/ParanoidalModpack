## Milestones — Paranoidal fork

Maintained in the [Paranoidal](https://github.com/FactorioParanoidal/ParanoidalModpack) modpack, based on
Wiwiweb's Milestones 1.4.7 (GPL-3.0, unchanged). The published version number is retained with local Paranoidal patches. The mod
ID, settings, locale and storage layout are kept, so saves move between this fork and upstream.
What changed is listed in `changelog.txt` under 1.4.7. The original README follows below.
Replacing files at the same version does not itself trigger `on_configuration_changed`;
preset upgrades and sandbox-force cleanup run when a configuration change occurs.

Paranoidal-specific content does not live here: the "Paranoidal" preset comes from `zzzparanoidal`
through the standard `milestones_presets` remote interface. The pack also changes the default of
`milestones_check_frequency` from 60 to 600 ticks.

## Report for the upstream author

Hello Wiwiweb! Thank you for Milestones. We found an idle CPU cost in large modpacks and fixed it
locally. Below are the problem, the fix, and what we did and did not verify. Feel free to take any part
of it; the diff against 1.4.7 is in the Paranoidal repository (`mods/Milestones`). Nothing has been sent
upstream yet.

### Symptom

Milestones showed constant script time in `show-time-usage` even with the factory idle. The game has
Quality enabled plus a mod that adds about 40 qualities (47 quality prototypes, including hidden
`quality-unknown`), and several technical surfaces created by other mods.

### Cause

`track_item_creation` (on_tick) checks `#incomplete / frequency` milestones per tick. For every item or
kill milestone without an explicit quality, `sum_counts_merged_qualities` calls
`get_input_count({name=..., quality=...})` once **per surface per quality prototype**, building a new
Lua table each time. Infinite milestones never leave the incomplete list, so this runs forever:

| Load (offline count, stubbed API) | API calls per second | New `{name, quality}` tables per second |
|---|---|---|
| 1.4.7, 47 qualities, 5 surfaces, 179 milestones | ~34,400 | ~34,300 |
| 1.4.7, no Quality mod (normal + hidden unknown) | ~1,500 | ~1,460 |
| fork, 47 qualities, frequency 60 | 55 + 10 dictionary reads (~1,560 entries) | 0 |
| fork, 47 qualities, frequency 600 | ~6 + ~156 dictionary entries | 0 |

These are operation counts from a Lua 5.1 harness with stubbed statistics, not a UPS benchmark.

Two more things multiplied the cost:

* **Blueprint Sandboxes** moves the player into a force named `bpsb-sb-f-<force>`.
  `on_player_changed_force` initialized it as a separate force: a full milestone list, a backfill, and
  polling every cycle, even after the player left the sandbox. In our real save this force was tracked.
* **Surfaces from other mods** (minime previews, cybersyn analytics, sandbox labs, Factorissimo floors,
  teleporter surfaces) each add three LuaFlowStatistics per force.

### Engine fact the fix relies on

`LuaFlowStatistics.input_counts` / `output_counts` return counts **already summed over all qualities**
for item and kill statistics. We checked this in Factorio 2.0.77 with Quality enabled:
`set_input_count` of 5 normal and 7 uncommon `iron-plate` gives `input_counts["iron-plate"] == 12`.
`get_input_count("iron-plate")` returns 5 (normal only). A rare `small-biter` kill appears as
`input_counts["small-biter"] == 3`.

### What the fork does (scripts/tracker.lua, scripts/milestones_util.lua)

1. **Per-cycle totals.** At the start of a cycle (`tick % frequency == 0`) the tracker records which
   names it needs per force: incomplete non-technology milestones without a quality, plus their aliases.
   It then spreads the reads over the last 60 ticks of the cycle. One task is one LuaFlowStatistics
   (one surface, one key: item/fluid/kill × input/output), read once:
   * item and kill statistics with more than one visible quality: one `input_counts`/`output_counts`
     read, then a lookup per needed name;
   * otherwise (fluids, or no extra qualities): `get_*_count(name)` per needed name, no table argument.

   On the last tick of the cycle every incomplete milestone is evaluated from these totals. A milestone
   with an explicit `quality` is still read directly with `{name, quality}`. Technology milestones still
   use `on_research_finished` only. A milestone is detected within one cycle plus at most 60 ticks;
   1.4.7 needed at most one cycle. The state is in
   `storage.tracker`, so saving or loading mid-cycle stays deterministic. Any structural change (surfaces,
   forces, settings, preset merge, reset command) restarts the tracker at the next cycle boundary.
2. **GUI refresh** once per force and cycle instead of once per reached milestone. A chain of infinite
   milestones reached together is evaluated in one pass.
3. **Blueprint Sandboxes forces** (prefix `bpsb-sb-`, only when that mod is active) are not tracked. Old
   saves drop them in `on_configuration_changed`. Players inside a sandbox see, and are notified about,
   the parent force's milestones.
4. **Backfill**: `get_flow_sources` keeps only (statistics, quality) pairs with a non-zero total. The
   300-sample search no longer multiplies by every quality prototype. The bracket count is reused, which
   resolves the existing TODO. Kill backfill now uses all qualities: 1.4.7 summed kill totals over
   qualities but searched kill samples for normal quality only.
5. Without extra qualities, the hidden `quality-unknown` is no longer queried.
6. **Preset upgrade for existing saves.** When a mod update adds a preset that auto-detection now
   prefers, a save switches to it only if its set was never edited (multiset equal to the old preset plus
   the enabled addons). `merge_new_milestones` keeps completed times; the rest are backfilled. 1.4.7 only
   printed a hint. We need this because our pack preset arrived after games had started on "Vanilla".
   This is a behaviour change; it could also sit behind a setting.

### Bugs found along the way

* `initialize_alias_table`: `storage.production_aliases[x] = {} or storage.production_aliases[x]` always
  resets the list, so only the **last alias** of a milestone counts. Example: `bob-god-module` with two
  aliases (bobmodules addon). Fixed to `existing or {}`.
* `backfill_completion_times` inserts the result of `create_next_milestone` without a nil check. An
  invalid `next` formula crashes there; the live tracker already had the check.
* Kill backfill used normal quality only (see 4).
* Unrelated to performance, but worth a note for preset authors: with RampantFixed "new enemies" (default
  on), vanilla and Bob's enemies may not exist on the map, so kill milestones for them can be
  unreachable. Milestones has no "any entity of a type" kill milestone.

### What was verified

* Lua 5.1 offline harness with stubbed API: 44 assertions in 47-quality and no-quality modes. Covered:
  merged qualities, explicit-quality milestones, two aliases, consumption, fluids, kills, an infinite chain
  in one evaluation, a deleted surface mid-cycle, frequency change, sandbox forces, and preset
  upgrade/no-upgrade.
* Factorio 2.0.77 + Quality, headless, on a physical copy of the full Paranoidal modset:
  * loading a copy of a real save made with 1.4.7 removed the tracked sandbox force, switched the
    unmodified "Vanilla" set to "Paranoidal", backfilled 5 milestones, then ran 1300 ticks without
    script errors;
  * a new game auto-selected "Paranoidal" plus the addons.

Not verified: GUI, chat and sound in a real session, multiplayer, and a comparable UPS measurement.

---

[![Crowdin Translate](https://img.shields.io/badge/Crowdin-Translate-brightgreen)](https://crowdin.com/project/factorio-mods-localization) [![Factorio Mod Portal page](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2FMilestones)](https://mods.factorio.com/mod/Milestones)

# FactorioMilestones
Factorio Mod for tracking your milestones

Published here: https://mods.factorio.com/mod/Milestones

## Contributing

Please note that Milestones is in maintenance mode at the moment. Pull requests for new features are still welcome but I am looking to avoid feature creep.
Pull requests to add new presets in Milestones will be declined, instead please implement the remote interfaces in your own mod:

## Adding your own preset (using the remote interfaces)

If your mod is an overhaul mod, or just generally does not interact well with other mods (e.g. Space Exploration), add a preset by implementing the `milestones_presets` interface. Only one preset will be chosen from the available ones.

If your mod could be used with most other mods (e.g. Power Armor Mk3), add a preset addon by implementing the `milestones_preset_addons` interface. Any matching preset addon will add milestones to the preset.

### milestones_presets

```lua
remote.add_interface("my-cool-mod", {
    milestones_presets = function()
        return {
            ["My Cool Mod"] = {
                required_mods = {"my-cool-mod"},
                milestones = {
                    {type="group", name="Science"},
                    {type="item",  name="my-cool-mod-science-pack", quantity=1},
                }
            },
            ["My Cool Mod (with Weapons extras)"] = {
                required_mods = {"my-cool-mod", "my-cool-mod-weapons"},
                milestones = {
                    {type="group", name="Science"},
                    {type="item",  name="my-cool-mod-science-pack", quantity=1},
                    {type="group", name="Weapons"},
                    {type="item",  name="my-cool-mod-thermonuclear-antimatter-atomic-plasma-multibarrel-automatic-rocket-rifle", quantity=1},
                }
            }
        }
    end
})
```

You can take a look at examples in [`presets.lua`](presets/presets.lua).

Some implementation examples from other mods: [Krastorio 2](https://codeberg.org/raiguard/Krastorio2/src/commit/7c944c115637d21b87ef58db1d5fe4a0a0d29677/scripts/milestones.lua), [Pyanodons](https://github.com/pyanodon/pycoalprocessing/blob/abbdb642c2058c3975dc238ff7cdb7008c1f5968/scripts/milestones.lua), [Ultracube](https://github.com/grandseiken/factorio-ultracube/blob/953b3a4be47601877db16b3124cba20a1dd20319/scripts/milestones.lua)

### milestones_preset_addons

```lua
remote.add_interface("ice-armor", {
    milestones_preset_addons = function()
        return {
            ["Ice Armor"] = {
                required_mods = {"ice-armor"},
                milestones = {
                    {type="group", name="Progress"},
                    {type="item",  name="ice-armor", quantity=1},
                }
            }
        }
    end
})
```

You can take a look at examples in [`preset_addons.lua`](presets/preset_addons.lua).

### Nice-to-know features for preset makers

* You can mark milestones with `hidden=true` for spoilery things. Hidden milestones will still be tracked and announced, but will only be visible once they are achieved.
* You can track consumption instead of production with `type="item_consumption"` and `type="fluid_consumption"`. This can have some niche use (e.g. Ultracube cube consumption).
* You can create item "aliases", which will count as another item. 
  * For example you could have a "box of science" count the same as 5 science for the sake of milestones so that players still achieve science milestones even when they are producing boxes: `{type="alias", name="nullius-box-geology-pack", equals="nullius-geology-pack", quantity=5}` (Example from Nullius)
  * Or you could have an "upgraded" item also count for the original item so that players can still achieve the milestone for the original item: `{type="alias", name="digosaurus-turd", equals="digosaurus", quantity=1},` (Example from Pyanodons)


Thanks a lot!
