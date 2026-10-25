# Robot Army Reforged — Paranoidal fork of Robot Army for Factorio 2.0

Manufacture and deploy robot soldiers. Droid assemblers turn droid items into units; the units form
squads that hunt once they are big enough and retreat to the nearest assembler when they get too
small. Guard stations keep a garrison next to them. The quick reaction force (QRF) sends nearby squads
to destroyed buildings. A droid counter outputs droid counts to the circuit network.

Fork of Kyranzor's Robot Army 2.4.27 ("reforged"). Version 9 marks the Paranoidal fork: rewritten
control script, a mid-game technology tree (chemical + military science), recipes built from Bob's,
Angels and Paranoidal parts (vanilla fallbacks without them), a new interface. See `changelog.txt`, 9.0.0.
Saves made with 2.4.x start the mod state over.

## Playing

- Research **Army robotics** (needs chemical and military science), build a **droid assembler**, pick a
  deploy recipe and insert droid items. Rotate the assembler to choose the side where droids appear.
- **Squad command tool** (shortcut bar): drag over a squad to pick it, Shift + drag to send it,
  right-drag to pick droids up.
- **Droid army** window (shortcut bar): squad thresholds of the force and the list of squads
  (show on the map, pick, recall / release).
- **Guard station**: its window has a panel with the garrison size.

## Layout

- `lib/shared.lua` — names and defaults shared by all stages.
- `settings.lua`, `data.lua` (items, units, buildings, signals, controls), `data-updates.lua`
  (recipes and technologies, which use items and technologies of other mods), `prototypes/*.lua`.
- `control.lua` — event wiring and lifecycle; `script/*.lua` — logic: `state` (storage layout), `squad`
  (squads, unit groups, orders), `ai` (decisions, targeting, QRF steps), `spawners` (deploying),
  `circuit` (counter), `tools` (command tool, selection marks), `gui` (army window, spawner panel),
  `qrf`, `loot`, `compat` (Unit Control), `config` (tuning constants), `settings_cache`, `util`.

## Settings

Map: QRF distance / vehicles / walls / alert, targeting mode, teleport stray droids, squad alerts, debug log.
Startup: army loot chest (off), harmless acid puddles (off), droid health and damage multipliers.

## Remote interface "robotarmy-reforged"

`squads(force)`, `thresholds(force)`, `set_threshold(force, key, value)`, `spawner(unit_number)`,
`set_garrison(unit_number, size)`, `tracked_units()`, `squad_of(unit_number)`.

## Credits

* Kyranzor — original mod
* YuokiTani for the droid models
* Klonan for his Combat Units and the Unit Control mod
* Dauphin for squad AI and performance contributions
* Earendel for the RTS-style control ideas from AAI Programmable Vehicles
* Felipe Bueno Aliski Alves (pt-BR), Varoga (ru), Ziomek24 (pl) translations
* cyril-orlov for the Factorio 2.0 migration work

Original author: donations to Kyranzor — https://www.paypal.me/KyranF
