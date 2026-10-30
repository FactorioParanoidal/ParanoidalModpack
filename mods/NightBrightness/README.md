# Night Brightness — Paranoidal

Maintained Factorio 2.0 port of darkfrei's NightBrightness 1.1.8 from the user's Paranoidal Beta 8 (MIT, as declared in the original info.json). Original PNG resources and previous changelog are preserved. Runtime implementation is maintained by Paranoidal.

## Preserved behaviour

- Four startup LUT modes: normal, dark, very dark and black, including zoomed map view.
- Nauvis only; the original cosine formulas (`season.lua`).
- Night brightness 5–15%; dusk/evening/morning/dawn = 0.2/0.3/0.7/0.8, seasonal tilt ±0.15.
- Solar factor 0.5–1.
- Upstream year default 64 days; zzzparanoidal sets the Beta 8 pack default to 24 days.
- Debug and reset-to-summer settings retained.

## Calendar and seasons

- Every 300 ticks the mod looks for the midnight (daytime 0.5) on Nauvis. At midnight the calendar day grows, and light, solar factor and season of the new day are applied together. Midnight lies between evening and morning for every tilt, so the step is not visible. Beta 8 changed light at noon and solar output at midnight.
- Calendar: `days passed` = midnights since the landing, day 1 is the landing day. Year = `Year length` days; the landing year is year 1. A new year length applies from the current year. Reset to summer restarts only the season cycle (`cycle_offset`), the calendar goes on. A save from NightBrightness 2.0.0 gets the number of midnights since the start of the map (constant day length assumed) and keeps its applied season.
- Every season change and every landing anniversary is announced in the chat for any year length (Beta 8 required years over 31 days). The chat message names only the season; its effects (solar factor, wind of Wind-Turbines-Reforged, wire losses of ElectricResistance2) are shown by the EvoUI season line on request. Those mods poll `get_season` and switch at the announcement.
- Per-player string setting `nb_season_names`: `plain` (default), `daylight` (long day / waning day / long night / waxing day) or `bnl` (Buy n Large seasons™).
- `nb_winter_tint` (on): in winter `brightness_visual_weights` = {1, 1, 0.96}, so dusk and nights keep a little more blue. Daylight (brightness 1) is never affected by the weights.

## 2.0 adaptations

- Persistent state uses storage; no writes in on_load. Unrelated setting changes do not reset seasons. Saves without the calendar are migrated on the first update, also without a version change.
- Surface brightness_visual_weights ≠ 0 (also while the cycle is disabled), so runtime brightness influences rendering in 2.0.
- The night LUT follows the time of day only. It covers the shortest (summer) night: identity until 0.35, full night 0.45–0.55, identity from 0.65 (Beta 8: 0.2–0.45 / 0.55–0.8), in all four modes; longer nights are darkened by brightness. Exact visual matching requires in-game acceptance.
- Day parameters are written in one go through `LuaSurface.daytime_parameters`.
- Disabling the cycle restores the Beta 8 fixed lighting baseline and neutral seasonal solar factor; days and years are still counted. Startup LUT darkening remains until the startup setting is changed and the game restarted.
- On removal of Clockwork-2, Nauvis day length returns to 25,000 ticks and its permanent-night freeze is removed. Other surfaces are not controlled by this mod.
- Clockwork-2 and DarkNight are incompatible alternatives, not dependencies to reinstall. Clockwork capsules disappear and its accumulator capacity multiplier is intentionally removed.

## Pollution integration

The documented Paranoidal patch for visible-pollutants 1.4.4 composes solar output as **seasonal factor × pollution factor**. Neither factor replaces the other. NightBrightness requests recomputation at midnight and after its settings change. Without either mod, the other works independently.

## Remote interface `NightBrightness` (read-only)

- `get_solar_multiplier(surface_index)` — 1 outside Nauvis/when disabled.
- `get_state()` — `days_passed`, `day`, `year`, `years_passed`, `day_of_year`, `period`, `disabled`, `active_solar`, `dusk`/`evening`/`morning`/`dawn`, `min_brightness`; with the cycle on also `cycle_day`, `season`, `season_day`, `season_length`, `next_season`, `days_to_next_season`. `nil` before the first configuration.
- `get_season()` — `"summer"`, `"fall"`, `"winter"`, `"spring"` or nil while disabled.
- `get_season_name(season, player_index)` — LocalisedString in the player's style; `get_season_color(season)`; `clock(daytime)` — "7:12" as the EvoUI clock.

Consumers: EvoUi (season sensor, day number), paranoidal-CodexRPG (world statistics), MxlChievements-Reforged (seasons, years), Wind-Turbines-Reforged and ElectricResistance2 (season steps), visible-pollutants (solar factor). No remote mutation/debug setters are shipped.
