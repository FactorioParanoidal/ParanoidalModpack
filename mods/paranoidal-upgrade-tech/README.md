# PARANOIDAL: Upgrade Tech

Upgrade technologies of the Paranoidal build, ported from Beta 8 instead of All-infinit-tech.
Data stage only: no control.lua, no runtime cost.

## What it does

| Technology | Levels | Per level | Cost | Prerequisites |
|---|---|---|---|---|
| `research-efficiency-1` | 1–3 | research productivity +1 %, lab speed −6 % | `25*L+75` × 2 packs, 45 s | `research-speed-1` |
| `research-efficiency-4` | 4–6 | +1 %, −8 % | `25*L+100` × 2, 45 s | `research-speed-2` |
| `research-efficiency-7` | 7–9 | +1 %, −10 % | `100*L-450` × 3, 45 s | `research-speed-3` |
| `research-efficiency-10` | 10–12 | +1 %, −12 % | 500 × 3, 45 s | `research-speed-4` |
| `research-efficiency-13` | 13–16 | +1 %, −9 % | 500 × 4, 45 s | `research-speed-5` |
| `research-efficiency-17` | 17–20 | +1 %, −9 % | `100*L-1200` × 5, 45 s | `research-speed-6` |
| `worker-robot-battery-1` | 1–3 | worker robot battery +10 % | `100*L` × 3, 30 s | `robotics`, chemical science |
| `worker-robot-battery-4` | 4–7 | +10 % | `100*L` × 4, 45 s | production science |
| `worker-robot-battery-8` | 8–11 | +10 % | `100*L` × 5, 60 s | utility science |
| `worker-robot-battery-12` | 12–∞ | +10 % | `2^(L-11)*1000` × 6, 60 s | space science |

Totals: research productivity +20 % for −180 % lab speed (research-speed 1–6 give +250 %);
robot battery +110 % before space science. Each tier also needs the previous tier.

None of these chains raises enemy evolution: `research_evolution_factor` skips the prefixes
`research-efficiency-` and `worker-robot-battery-` (`ignored_prefixes` in its `parameters.lua`).
A new chain that must not raise evolution needs its prefix there too.

Cost of foreign infinite technologies (`prototypes/infinite-costs.lua`, applied in `data-final-fixes.lua`):
`mining-productivity-4` → `2^(L-3)*1000`, `follower-robot-count-5` → `2^(L-4)*1000`, 60 s.

## Structure

| File | Role |
|---|---|
| `prototypes/chains.lua` | All chains as data: tiers, effects, costs, packs, prerequisites. Edit balance here. |
| `prototypes/infinite-costs.lua` | Cost formulas for infinite technologies of other mods. |
| `lib/chain.lua` | Validates a chain and builds its technologies (`<chain>-<first level>`, previous tier as prerequisite, `upgrade`, `max_level`). |
| `lib/science.lua` | Science pack sets: `science.upto("chemical-science-pack")` = red, green, blue. |
| `data.lua` | Creates the chains early, so zzzparanoidal and research_evolution_factor see them. |
| `data-final-fixes.lua` | Applies the infinite costs and checks that every own technology, prerequisite and pack still exists. |
| `locale/{en,ru}/upgrade-tech.cfg` | Names and descriptions (key = chain name). |

### Adding a chain

1. Add an entry to `prototypes/chains.lua`; levels of the tiers must follow each other from 1, only the last tier may be
   `"infinite"`, each tier has exactly one of `count` / `count_formula`.
2. Add `technology-name.<chain>` and `technology-description.<chain>` to both locales.
3. Level markers on icons: `zzzparanoidal/tweaks/technology/icon-markers-rules.lua`.

Mistakes in a chain stop loading with a message naming the chain and tier.

## Saves

Factorio re-applies technology effects whenever mods change, so bonuses of removed All-infinit-tech technologies
disappear on load and the new technologies start unresearched. Renaming a tier (changing `first`) loses its research
progress: add a migration then.

## Lore

Names and jokes follow the BnL canon of `zzzparanoidal-start-bnl`: Directive 99-99 "Cost optimization" from the
Axiom-7 flight log, Directive A113 setting the "return date" of the cruise.
