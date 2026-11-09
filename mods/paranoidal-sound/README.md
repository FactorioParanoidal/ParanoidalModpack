# Paranoidal Sound 9.0.0

Three sound packs integrated for Factorio 2.1.24, without changing combat statistics, recipes or progression.

## Sources and attribution

| Included source | Version in Paranoidal | Author / original page |
| --- | --- | --- |
| EpicWeaponSounds — SoundPack: Epic Weapon Sounds | 0.1.0 | MrKalle — https://mods.factorio.com/mod/EpicWeaponSounds |
| immersive-sounds2 — Boombastique Immersive Sound Pack | 0.1.1 | Fooltaurus (source info.json), Flouterose (upstream provenance) — https://mods.factorio.com/mod/immersive-sounds |
| newtrainsfx2 — New train sounds for CIS countries (SFX) | 1.2.2 | Artanis_Mattias — https://mods.factorio.com/mod/newtrainsfx |

The original Immersive audio credits and redistribution notice are retained verbatim in **SOUND-CREDITS.txt**. They credit Jack Martisson / Epic Thunder, Gaijin Entertainment / War Thunder, Crowbar Collective / Black Mesa, New World Interactive / Day of Infamy, Saber Interactive / Snowrunner, Wolfire Games / Receiver 2, and Wube Software / Factorio. These assets are not claimed as original Paranoidal work or relicensed by this integration.

All **476 audio files** from the three installed sources are retained byte-for-byte, including previously unused alternatives. No transcoding, normalisation or sample replacement. The new Lua integration and rewrite are maintained by Paranoidal.

## Settings

Eleven independent **startup** dropdowns, each labelled with its source mod names. Changing them requires restarting Factorio.

- Pistol, submachine gun, shotgun, gun turret, car machine gun and grenade explosion: `EpicWeaponSounds` / **`immersive-sounds2` (default)**.
- Locomotive engine, cargo-wagon wheel noise, locomotive main braking sound, locomotive clatter and cargo-wagon clatter: **`newtrainsfx2` (default)** / `immersive-sounds2`.

Defaults preserve the source selection that won in the previous three-mod load order. They are **not a claim of byte-for-byte identical playback**: broken variation lists and the nuclear sound indexing bug are corrected below.

Door sounds, engine shutdown, brake squeal and rail footsteps remain separate events. Laser turret shots (Epic), laser beam working sound and turret deployment/folding (Immersive) coexist. Fluid-wagon wheel noise and fluid/artillery-wagon clatter retain New Train SFX because the old Immersive pack supplied no alternative for those fields.

Changing the grenade does not change every medium explosion sharing its Sound wrapper. Changing the car machine gun does not change the separate tank machine gun. Base-derived prototypes can inherit choices; later explicit sound overrides from other mods are respected. This is not a blanket replacement of every modded vehicle or weapon.

## Rewrite and corrections

- Private sound libraries replace leaked data-stage globals. Compact variation constructors preserve filenames, gains and ordering.
- All original prototype sound applications, nine runtime sound prototypes, twelve linked custom-input IDs and the inert `tracks-noise` projectile are retained. Previously unused audio is retained as resources, not indiscriminately attached to new events.
- One event dispatcher replaces twelve repetitive handlers. It reads the actual character/vehicle inventory with `is_empty()`, guards absent/invalid players, characters, vehicles and burners, and plays spatial sound at the entity. No tick handler, polling, persistent state, timers or inventory counting.
- Car/tank engine loops, starts/stops, fire loops, flamethrower phases and train shutdown variations are now inside the correct Sound fields rather than ignored numeric siblings. Immersive wheel clatter uses `drive_over_tie_trigger.sound`, not the unused `drive_over_tie` field. The ignored `max_sounds_per_type` field is removed without introducing a new audio concurrency limit.
- Nuclear sounds are selected by `play-sound` effects rather than hard-coded array slots. This preserves the camera effect that the old code accidentally overwrote, and puts the explosion and aftershock samples in their proper events. Damage/cliff/tile effects are untouched.
- Explosion assignment order is preserved because base shares Sound wrappers. The grenade alternative alone gets a detached wrapper.
- Existing shallow-copy clatter sharing with BatteryElectricTrain is preserved. Narrow compatibility restores MIRV fire copies and Picker's five laser variations after the load-order change; MIRV's own nuke explosion sound remains its own. No broad late patch is applied.
- The shared graphics-atlas alias follows the moved transparent sprite.

## Existing saves and installation

Replace the three source mod folders with this mod; do not enable the old packs alongside it (declared incompatible). Source mods had no persistent progression/storage to migrate. Prototype IDs used by their runtime handlers and their projectile are retained, so there is no save-data migration script. Existing saves and new maps use the selected startup prototype sounds.

The merge does not edit `mod-list.json`, `mod-settings.dat`, `player-data.json` or saves. When synchronising an old save's mod list, keep the new merged mod rather than reinstalling the three removed packs.

## Checks

`tests/unit.lua` runs with Lua 5.2 and the mod root as its argument. It exercises all eleven independent switches, shared grenade wrappers, default sources, laser coexistence, nuclear non-sound effects, known early-copy compatibility, referenced file existence, and every input binding including missing/empty inventory, invalid objects, unrelated vehicles and unlit/absent burners. These mocks do not prove engine audio playback or acoustic quality.

Actual engine load/dump checks and their local artifacts are recorded outside the repository. Listening, loudness, key-press feel and settings presentation remain an in-game acceptance task.
