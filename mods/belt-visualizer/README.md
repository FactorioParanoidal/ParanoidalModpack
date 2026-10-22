# Belt Visualizer — Paranoidal fork

Fork of [Belt Visualizer](https://mods.factorio.com/mod/belt-visualizer) 2.0.2 by **_CodeGreen**,
maintained for the [Paranoidal](https://github.com/FactorioParanoidal/ParanoidalModpack) modpack.
Origin details for the build checks: `mods-metadata/belt-visualizer.json`.

## Thanks

Many thanks to _CodeGreen for Belt Visualizer and for allowing us to fork it. It is one of the
most useful tools in a modpack this belt-heavy, and the changes below are offered back to the
original mod: take whatever is useful.

## Changes in 9.0.3

Full list: `changelog.txt`.

### Performance

- `on_tick` is registered only while highlights are being drawn, cleared or refreshed, and is
  restored in `on_load` from `storage`. Previously it ran every tick and read
  `settings.global` even when nothing was highlighted.
- The `bv-highlight-maximum` setting is cached and reset in `on_runtime_mod_setting_changed`.
- A modification near a highlight refreshes it after 60 ticks of quiet, but no later than
  300 ticks after the first modification. Constant robot building next to a highlighted bus used
  to rebuild the whole highlight every second.
- Renders are stored in an array and destroyed from the end, instead of rescanning a hash table
  from the start every tick.
- Belt line caching stops on closed loops and reads `belt_neighbours` once per belt.
- Container passthrough searches each container once per traversal.
- Traversal-only tables (`drawn_*`, queue, passthrough) are removed from `storage` when the
  highlight is finished.
- Renders use `surface_index` and a shared player list.

### Bugfixes

- Splitter filter vs. cursor ghost: in 2.0 `cursor_ghost.name` is a `LuaItemPrototype`, so the
  comparison with `splitter_filter.name` (a string) never matched.
- `add_to_queue` checked only the last splitter side in `pairs` order, so a splitter could be
  skipped or queued twice.
- Circles, loader rectangles and underground dashes could be drawn twice.
- `highlight` and `refresh` share one `start()`: refresh now marks the origin as checked, handles
  a ghost splitter origin and re-reads the container passthrough setting.
- Belt line caching skipped one belt at each tick boundary.
- A refresh is run when its tick is reached or passed (`<=`), not only on the exact tick.
- Highlights refresh after rotating or flipping a belt next to them, after pasting splitter
  settings and after placing or removing belt ghosts.
- Hover mode state is kept when a player leaves the game, matching the shortcut toggle.

### Locale

- Russian: translation for container passthrough, clearer names of the G / Shift+G keybinds.

### Not covered

- Quality in splitter filters.
- Splitter filter changes made in its GUI (there is no event for them).
- Belts reversed by scripts through `LuaEntity.rotate()`, which raises no event.

### Checks

Static checks and a plain Lua 5.1 run of the traversal with API stubs (line and 300-belt loop:
render count, refresh timing, `on_tick` on/off, `on_load`). Not yet checked in the game or in
multiplayer.

---

## Кратко по-русски

Форк Belt Visualizer 2.0.2 (_CodeGreen) для сборки Paranoidal, сделан с разрешения автора, за
что ему большое спасибо. В версии 9.0.3 мод не работает в простое (`on_tick` включается только
при работе), реже перестраивает подсветку при стройке рядом, исправлены фильтр сортировщика по
«призраку» в руке, проверка сторон сортировщика, двойная отрисовка и пропуски обновлений;
дополнен русский перевод. В игре изменения пока не проверены.
