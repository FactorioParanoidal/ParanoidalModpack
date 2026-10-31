# Pipe Visualizer Reforged

Paranoidal fork of [Pipe Visualizer 2.0](https://mods.factorio.com/mod/PipeVisualizer-Updated) by ashier (AtelierAmber), itself based on [Pipe Visualizer](https://mods.factorio.com/mod/PipeVisualizer) by raiguard. The runtime is rewritten for speed; see `changelog.txt`.

Press `Y` to draw the selected entity's fluid systems. Press `Shift + Y` to draw all visible fluid systems. Press `Alt + Y` to automatically visualize systems on mouse-over. Press `Control + Shift + Y` to toggle between color-by-fluid and color-by-system.

## Mod developers

Remote interface `PipeVisualizer`:

- `blacklist(entity_names)` — never draw or cross these entities.
- `pipelist_add(entity_type, entity_name)` — draw the entity like a pipe (connection lines).
- `complexlist_add(entity_type, entity_name)` — draw the entity like a building (box and arrows).

The lists are kept in the save; calling them again is harmless.

## Credits

Shortcut icons were sourced from [Font Awesome Free](https://fontawesome.com/search?m=free) under the [CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/). Licence: MIT (see `LICENSE`).
