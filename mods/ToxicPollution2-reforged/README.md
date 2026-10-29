# Toxic Pollution 2 Reforged

Polluted air poisons the player. Rewrite of Toxic Pollution (Likos, ArtMares, ViridiVir; 2.0 port of toxicPollution2 by Lampotrias) for the Paranoidal modpack.

## How it works

- The body tolerates the pollution of a chunk up to **150** (startup setting `tpr-tolerance`; +10 % per level of the research *Smog protection*). Breathing more raises **intoxication** (0–100 %), breathing less lowers it.
- From **50 %** intoxication the smog damages health (up to 8 % of max health per second at 100 %) — only while the player breathes smog. Leaving it stops the damage at once.
- Protection **filters** a share of the smog, in layers: vehicle cabin → breathing module in the armor grid (uses energy) → item in the armor slot (its `toxin` resistance). Safe level = tolerance ÷ (1 − filtration).
- Filters wear only in harmful air, in proportion to what they filter. Items with an equipment grid are never destroyed; others are, and the best spare is put on. `CW-air-filter` (Carbon Capture) in the inventory refills worn protection and returns a used filter; the respirator is disposable.
- Panel on the left (per-player setting), one alert at a time, sounds, tips and tricks, command `/toxic`.
- Pollution sensor: the signal *Pollution sensor* in a constant combinator outputs the chunk pollution once per second.

Formulas, numbers and the reference timings: `scripts/model.lua`, `shared/config.lua`, tests in `tests/` (`lua tests/<name>.lua`, Lua 5.1/5.2, mocks only).

## Remote interface `toxic_pollution`

- `get_intoxication(player_index)` → 0..100
- `set_intoxication(player_index, value)`
- `get_state(player_index)` → `{pollution, tolerance, inhaled, filtration, rate, intoxication}` or nil

## Credits of the graphics

Icons and sprites are composites of the following works (trimmed, tinted, resized, shadows and plates added):

| Source | Author | License | Used in |
|---|---|---|---|
| [Air-Purifying Respirator.png](https://commons.wikimedia.org/wiki/File:Air-Purifying_Respirator.png) | John Dimos and Paul Satti | Public domain | respirator |
| [Gas mask.svg](https://commons.wikimedia.org/wiki/File:Gas_mask.svg) | rg1024 (openclipart) | CC0 | gas mask, closed-loop breathing, alert, technology, thumbnail |
| [GHS-pictogram-skull.svg](https://commons.wikimedia.org/wiki/File:GHS-pictogram-skull.svg) | GHS (UN) | Public domain | intoxication alert |
| [HEPA filter 02.svg](https://commons.wikimedia.org/wiki/File:HEPA_filter_02.svg) | Mcbdixon | CC0 | filter module |
| [Oxygen-Tank.svg](https://commons.wikimedia.org/wiki/File:Oxygen-Tank.svg) | freesvg.org | CC BY-SA 4.0 | closed-loop breathing module (icon and sprite are CC BY-SA 4.0) |
| [Fluent Emoji](https://github.com/microsoft/fluentui-emoji): Cloud, Dashing away, Factory, Lungs, Warning, Hourglass not done | Microsoft Corporation | MIT | smog, sensor, alerts, technology, effects, thumbnail |

Fluent Emoji — MIT License, Copyright (c) Microsoft Corporation: permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, subject to including the copyright notice and this permission notice in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
