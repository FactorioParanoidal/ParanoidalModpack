# RuNames Reforged

Paranoidal mod that replaces Name Lists 2.2.0, Russian Station Names 9.2.0 (RussianStations2) and Renamer 2.2.2 (all three are declared incompatible in `info.json`).

## Behaviour

- Entity types with a backer name in Factorio 2.0: train stops, locomotives, labs, radars, roboports.
- `on_built_entity`: a ghost with an empty name gets a name (names from blueprints and undo are kept, robots build the entity with the ghost's name); a built entity is renamed only if its name is an engine backer name (`game.backer_names`).
- `script_raised_built`: the same rule for entities created by other mods' scripts; with the backer set enabled, backer names are kept there.
- Ctrl+N (`runames-random-name`): new random name for the selected entity. Ctrl+R (`runames-rename`): rename window.
- Every enabled set that has a list for the entity type has an equal chance; a name already given (`storage.used`) is rerolled up to 10 times.

## Name sets

`sets.lua` lists the sets in settings order; each set module in `names/` returns lists keyed by entity type and optional `pools`. A list entry is a string or `{string, weight}`. In a string, `{@pool}` is replaced by a random word of the pool, `{@^pool}` by the same word with a capital first letter, `{N-M}` by a number from N to M (zero-padded when N starts with 0).

`names/data/rs2.lua` and `names/data/cities.lua` were generated once: from RussianStations2 `stations.lua` (12,543 names; first letter capitalised, one Cyrillic/Latin Roman numeral typo fixed) and from the ru.wikipedia list of cities of Russia with their former names (names after political figures excluded). They can be edited by hand.

Adding a set: a module in `names/`, an entry in `sets.lua`, setting name and description in `locale/en` and `locale/ru`.
