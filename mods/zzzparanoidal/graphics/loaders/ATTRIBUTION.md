# Electric loader resources

- `loader-structure-base.png`, `loader-structure-mask.png`, `loader-structure-highlights.png`, and `icons/loader-icon-{base,mask,highlights}.png`: Artisanal Reskins: Compatibility, Kirazy. MIT: `LICENSE-Reskins-Compatibility.txt` (copyright 2023; source Lua copyright 2024).
- `loader-structure-{shadow,front-patch,back-patch}.png`: Vanilla Loaders 2.2.1 (`vanilla-loaders-hd`), Kirazy, copyright 2024. MIT: `LICENSE-Vanilla-Loaders.txt`.
- Sprite layout in `prototypes/electric-loaders.lua` adapts those two mods' loader definitions. Snapping in `controls/electric-loaders.lua` adapts Vanilla Loaders 2.2.1's control.lua. Upstream reports an unidentified earlier snapping-code author; that attribution limitation is retained.
- Runtime Artisanal Reskins library calls supply belt tints, tier labels, item pictures, explosions and particles; the library itself is not vendored here.

ElectricLoaders 1.1.0 was inspected as a behavioural reference. No separate license was found in the supplied folder/archive; no code or assets from it are included. Energy setup is implemented independently from the agreed balance and Factorio prototype API. The agreed buffer formula does not establish a half-second runtime reserve.
