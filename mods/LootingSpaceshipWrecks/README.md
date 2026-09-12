# Looting Spaceship Wrecks — Paranoidal Beta 8 port

Local, maintained Factorio 2.0 port of the user's unpacked Beta 8 mod, version
1.1.0. Original authors: **darkfrei, sbelyakov**. The source declares MIT;
original graphics and attribution are retained. This is not an exact Mod Portal
release. Requires Factorio 2.0.77 or newer; tested without DLC.

## Preserved content

- `salvaged-assembling-machine`: speed 0.25, 90 kW, pollution 4/min, 50 HP,
  3×2 footprint, stack size 1. Retains Bob electronics capability from Beta 8.
- `salvaged-lab`: speed 0.15, 650 kW, 50 HP, 5×3 footprint, stack size 1.
  Normal science packs and Angels bio tokens in the full Paranoidal pack.
- `salvaged-generator`: 750 kW production, 15 MJ buffer, 1.5 MW output limit,
  no fuel or external charging, 150 HP, 2×2 footprint, stack size 1.
- Ship inventory size 80; unchanged random ranges and quantities for all 12
  wreck mining tables. The hull yields one generator plus the starter pump
  added by Beta 8's late `zzzparanoidal` patch (when that item is available).
- Bonus setting retains its internal name, runtime-global type and true default.
  It adds 2–3 salvaged assemblers, one salvaged lab and the original supplies
  to freeplay's item tables on mod initialization. It does not control mining
  loot, does not refill existing wrecks, and does not reroll on save/reload.

## Port boundaries

Prototypes use Factorio 2.0 fields directly: assembler `graphics_set`, the
pollutant map and current Bob/Angels item IDs. The nine original HR sprites and
three machine icons are retained unchanged; unused low-resolution duplicates,
inactive armor resources and the legacy conversion layer are removed.
Data-stage loot runs in data-updates so optional pack items are already
registered. Missing optional items are logged, not replaced with arbitrary
alternatives. The invalid `offshore-pump-0` entry is removed: Beta 8 freeplay
also discarded it, and the real pump remains hull mining loot.

The mod remains additive, as it was in Beta 8. **AAI 2.0's additional starting
burner assembler, 3 drills, 84 yellow belts and 24 motors are not removed.**
Therefore restoring this mod alone does not establish parity of the entire
starting inventory. AAI's own science settings are also left alone.

No new recipes, technologies, survival armor or respawn bonuses are introduced.
Adding the mod to an existing save does not recreate a previously mined ship.
Own prototype IDs stay unchanged; no automatic migration of Beta 8 saves is
claimed.

## Checks / limitations

Full-pack data-stage comparisons against Beta 8 1.1.107 and 2.0.77 baseline,
actual freeplay starts, mining every wreck type, powered crafting/research,
and day/night screenshots were performed during the port review. The detailed
test artifacts are intentionally kept outside this repository. Machine tests
use a separate test surface with supplied inputs/research and do
not prove normal progression. Audio playback, full campaign progression and
real multiplayer need separate verification.
