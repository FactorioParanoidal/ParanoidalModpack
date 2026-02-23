# Miniloader (Redux)

The all-popular [Miniloader](https://mods.factorio.com/mod/miniloader) has not seen a release for Factorio 2.x and while there are a number of spiritual successors, they all lack something.

- [Loader Modernized](https://mods.factorio.com/mod/loaders-modernized) is a fine solution, but it can not pick up items from an adjacent belt. Entities also can not be moved.
- Migrating the 1.1 Miniloader mod to 2.0 would have been possible, but the code is gnarly and especially the wire handling has changed a bit. It also uses an intermediate container which is no longer needed. Basically, migrating would have been a full rewrite.
- [Loader Redux](https://mods.factorio.com/mod/LoaderRedux) was never migrated to 2.0 (which would have been trivial) and suffers from the same problems as Loader Modernized. Also the entities are 1x2.

And there are a more mods, which are basically reskinning the existing 1x1 or 1x2 loaders. None of them covered what I needed.

The genius of the 1x1 Miniloader module is that it checks all the boxes. Hence Miniloader Redux.

![All supported Loader types](https://raw.githubusercontent.com/hgschmie/factorio-miniloader-redux/refs/heads/main/portal/all_belts.gif)
![Sideloading from/to a belt](https://raw.githubusercontent.com/hgschmie/factorio-miniloader-redux/refs/heads/main/portal/sideloading.gif)
![Extended rotation](https://raw.githubusercontent.com/hgschmie/factorio-miniloader-redux/refs/heads/main/portal/extended_rotation.gif)
![Moving Miniloaders](https://raw.githubusercontent.com/hgschmie/factorio-miniloader-redux/refs/heads/main/portal/picker-dollies.gif)

## Features

- 1x1 compact size.
- Picks up from adjacent belts.
- Can be moved with [Even Pickier Dollies](https://mods.factorio.com/mod/even-pickier-dollies)
- Supports migrating games from the "old" Miniloaders to Miniloader (Redux) with a startup setting.
- Rotates better than the old miniloader (flips through belt directions and orientation).
- Supports Fast replacement, Blueprinting, Copy&Paste, Cloning.
- Supports a simple "chute" loader that is available early in the game (configurable).

There are three available tiers in the base game ("Vanilla", Fast and Express) and five when playing Space Age (additionally Turbo and Stack). I made a conscious decision to not support any additional tiers or enable stacking in the base game. The mod tries to follow the "spirit" of the game and there are other options (such as Loader Modernized) that work fine if this is not wanted.

Miniloader supports some other mods:

- [Matt's Logistics](https://mods.factorio.com/mod/matts-logistics)
- [Krastorio 2](https://mods.factorio.com/mod/Krastorio2)
- [Bob's Logistics](https://mods.factorio.com/mod/boblogistics)
- [Advanced Furnaces 2 SpaceAgeFix](https://mods.factorio.com/mod/Load-Furn-2-SpaceAgeFix)
- [Space Exploration](https://mods.factorio.com/mod/space-exploration)

The miniloaders are activated if the corresponding module is detected.

Getting the speeds for additional tiers beyond the basic levels (base games and Space Age DLC) is tricky and the game mechanics are stretched when going faster than ~ 120 items/sec. Supporting faster loaders is at best unreliable and might be outright wrong. YMMV.

I spent four weeks on and off getting the mechanics for the supported mods right. This was extremely unpleasant work and I do not intend to do this again. With 0.9 and beyond the speeds should be as closely as possible to the belt speeds in the different tiers.

I am open to support additional tiers from other mods from PRs (see below) but I do not plan to actively add any support for other mods.

## Limitations

- High speed (> 120 items/sec) miniloader will only achieve maximum throughput if loading from or to a chest. Any other loading operation will reduce the throughput.
- When sideloading onto a belt with High speed miniloaders, they may spray items across both lanes of the belt they are loading to.

### Fixing Collision mask failures

When using Miniloaders with some other mods (most prominent offender seems to be the [Advanced Furnaces 2 SpaceAgeFix](https://mods.factorio.com/mod/Load-Furn-2-SpaceAgeFix) mod), the game fails to load with an error message like this:

``` text
Failed to load mods: entity prototype "... some miniloader entity ending in -l..." (loader-1x1) collision_mask(Modifications: Miniloader (Redux)) must collide with entity prototype "... some entity ... " (loader-1x1) collision_mask(...).
```

This happens when the other mod does not declare collision with the `transport_belt` layer. The default collision mask for loaders includes this and most custom loader should simply use the default.

Starting with version 0.10.2, there is now a startup switch (`Sanitize non-Miniloader loader entities`) that tries to 'fix up' such loaders. It adds the `transport_belt` layer to the collision mask of all configured loaders.

Note that this may break functionality of those other loaders. If that is the case, the mod and Miniloader are not compatible.

If you encounter this error, try enabling this setting first. It has no permanent effect on the game; if it breaks another mod, simply uncheck it again.

To enable this setting, when the game fails to start:

- first disable the *other* mod that causes the problem. Keep Miniloader enabled
- set the startup setting
- re-enable the other mod

## How you can help

I am not a graphics person. E.g. Matt's Logistics belts have a different tint and I convinced ChatGPT to recolor the existing graphics with a different tint that somewhat matches the belts. But getting better graphics would be greatly appreciated.

See [adding more miniloaders for other mods](https://github.com/hgschmie/factorio-miniloader-redux/blob/main/ADD_NEW_LOADERS.md) for details on how to add loaders for other belt tiers.

## Config options

### Loader Snapping (Runtime, per Map)

Similar to other mods, Loaders can automatically "snap" to entities that are either placed around them or when they are placed next to entities. The snapping algorithm differs from other loaders, though. It only takes entities at the "loader" end into account and tries to be smart (the old Miniloader notoriously "flipped" around if it was placed with the non-loader side next to a belt).

Default value is "on".

### Enable Chute miniloader (Startup)

Enables a simple, "gravity driven" Miniloader that is very slow (1/4 speed of a "Vanilla" Miniloader but still much faster than e.g. a "Vanilla" Inserter). It is available as soon as "Logistics" has been researched and 100 iron gear wheels have been crafted.

The chute loader is very helpful in the base game but may be considered OP compared to regular inserters.

Default value is "off".

### Don't consume power (Startup)

All miniloaders no longer consume any electrical (or other) power. They just work. Because they are not OP enough as-is.

Default value is "off".

### Migrate Factorio 1.1 Miniloaders (Startup)

This option needs to be enabled before opening a 1.1 saved game in Factorio 2.0. It is *not* necessary to have the old Miniloader module installed (which is not 2.0 compatible). When opening the game, all existing Miniloaders will be migrated to Miniloader (Redux) and all blueprints in the game library and in players' main inventory, that reference the old miniloaders will be automatically updated as well (The player library can not be updated as it is read-only to mods).

- Miniloader, Filter Miniloader -> Miniloader
- Fast Miniloader, Fast Filter Miniloader -> Fast Miniloader
- Express Miniloader, Express Filter Miniloader -> Express Miniloader

Note that this will not migrate any custom tier loaders (as of now).

Default value is "off".

### Sanitize non-Miniloader loader entities (Startup)

Patch non-Miniloader loader-1x1 entities to collide with the `transport_belt` layer. See the section `Fixing Collision mask failures` above for an explanation. This is a highly experimental and dangerous setting. If you do not encounter any errors with other mods, do not enable.

Default value is "off".

### Debugging Mode (Startup)

Show pickup, dropoff positions for the internal inserters and the area scanned when placing loaders or other entities when loader snapping is enabled. Useful for troubleshooting / but reporting but should not be needed otherwise.

Default value is "off".

## Console commands

### /inspect-miniloaders - Inspect miniloader status

There are a number of spurious bug reports from users where the miniloader module crashes with

```text
Error while running event miniloader-redux::on_built_entity (ID 6)
miniloader-redux/scripts/controller.lua:181: assertion failed!
stack traceback:
[C]: in function 'assert'
miniloader-redux/scripts/controller.lua:181: in function 'create_loader'
```

This should only happen if a miniloader was not cleaned out correctly and some of the internal (invisible) entities have remained. In that case, the `/inspect-miniloaders` command can scan all miniloaders and remove such remnants. When the command completes, it will report:

```text
[Inspect Miniloaders] Invalid entities detected: MiniLoaders: 0 / Internal Loaders: 0 / Internal Inserters: 0.
[Inspect Miniloaders] Invalid entities removed: Entities: 0, MiniLoaders: 0 / Internal Loaders: 0 / Internal Inserters: 0.
```

The first line lists all entities that were discovered but are invalid. Such entities have been marked for deconstruction or are otherwise invalid. This line should normally have all 0 values.

The second line lists the number of inconsistent entities that were removed. A non-zero value here means, that there *might* be miniloaders removed from the current game. The last three numbers are orphaned internal entities.

If the error above occurs, please run the command when reloading the game.

Please file a bug [on github](https://github.com/hgschmie/factorio-miniloader-redux/issues/) when

- running the command reports all '0' values in the second line (especially the "Internal Loader" value)
- The command reports all '0' values but the crash still occurs.

### /control-miniloader-inserters (on|off)

Turn the internal inserters in all (!) miniloaders on and off. This is only for debugging. When running `/control-miniloader-inserters off`, all miniloaders should cease to move items. If any miniloader still moves items after running this command, please file a bug report. All inserters are reactivate with `/control-miniloader-inserters on`.

### /rebuild-miniloader-inserters

Tear down and rebuild all internal inserters. This is useful for debugging if a template changed and the hand size and/or inserter count for a miniloader change.

## Planned features

- Better UI. Currently this opens the inserter UI and copies the settings around in the background.
- Support the loader specific "filter per lane" feature.

## Known issues

- Each miniloader only shows *HALF* of its actual energy consumption. Before reporting that "miniloader xxx uses less energy than inserter xxx", please multiply the energy consumption by 2. In the electrical network display, there are "miniloader" and "internal logic for miniloader" entities draining power, these need to be added.
- Similar to the old Miniloader module, Blueprints do not show the "correct" orientation of the loader due to limitations of the game.
- The rotation speed reported for a miniloader is wildly different based on the hand size and the inserter count.
- Until release 0.10.0, miniloaders might have been placed with the wrong orientation when blueprinted.
- In very rare cases, when 'snapping' is enabled, it is possible that the build order of entities affects the loader orientation (a loader may 'snap' if e.g. a belt is placed after the loader). Any blueprint created with the 0.10.0 or later release marks such entities as 'non-snapping'. For older blueprints, snapping should be temporarily disabled when placing a problematic blueprint to work around the issue.

## Credits

- Therax for the original miniloader.
- Kirazy &mdash; for the original graphics; taken from the miniloader mod

## Legal

(C) 2024-2025 Henning Schmiedehausen (hgschmie). Released under the MIT License.
