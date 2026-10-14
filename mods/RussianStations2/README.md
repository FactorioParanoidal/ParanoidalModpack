# Russian Station Names (RussianStations2)

Factorio 2.0 port of the Beta 8 mod `RussianStations` 9.1.2 (GotLag, touched by nastyslave) for the Paranoidal modpack.

## What it does

Adds a list of 12 543 Russian station names (`stations.lua`) and registers it in [Name Lists](https://mods.factorio.com/mod/Namelists) (`Namelists`). Namelists then uses these names instead of the built-in Factorio backer names.

- Train stop ghosts (blueprints, ghost placement) get a random Russian name from Namelists, as in Beta 8.
- Added in the port: a hand-built train stop whose name is one of the engine backer names (`game.backer_names`) is renamed through Namelists. A name carried over from a ghost or blueprint is not a backer name and is kept.
- The Namelists hotkey "Choose random name" (Ctrl+N) gives the selected station a new name from the registered lists.

## Settings (map, runtime-global)

| Setting | Default | Entities |
|---|---|---|
| `russian-stations-stations` | on | train stops |
| `russian-stations-locomotives` | off | locomotives |
| `russian-stations-roboports` | off | roboports |
| `russian-stations-labs` | off | labs |
| `russian-stations-radars` | off | radars |
| `russian-stations-default` | off | any entity with a name, as a fallback list |

`zzzparanoidal` (`settings-final-fixes.lua`) hides the Namelists setting `namelists-backer-stations` and forces it off, so backer names are not mixed into station names. Russian setting locale is in `ParanoidalLocale/locale/ru/RussianStations2.locale.cfg`.

## Differences from the 1.1 original

- `factorio_version` 2.0, explicit dependency on `Namelists >= 2.2.0`.
- Registration in Namelists happens in `on_init` and on Namelists' `on_list_rebuild` event; `on_load` only subscribes to the event and does not write to Namelists' `storage`.
- Hand-built station renaming (see above).

Limitation: if a hand-built station is placed over a ghost that carries a backer name, it is renamed; a robot-built one keeps the ghost name.
