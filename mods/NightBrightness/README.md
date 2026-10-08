# Night Brightness — Paranoidal

Maintained Factorio 2.0 port of darkfrei's NightBrightness 1.1.8 from the user's Paranoidal Beta 8 (MIT, as declared in the original info.json). Original PNG resources and previous changelog are preserved. Runtime implementation is maintained by Paranoidal.

## Preserved behaviour

- Four startup LUT modes: normal, dark, very dark and black, including zoomed map view.
- Nauvis only; every 1,200 ticks detect the day wrap, then apply the original cosine formulas.
- Night brightness 5–15%; dusk/evening/morning/dawn = 0.2/0.3/0.7/0.8, seasonal tilt ±0.15.
- Solar factor 0.5–1, scheduled at the day wrap and applied at midnight.
- Upstream year default 64 days; zzzparanoidal sets the Beta 8 pack default to 24 days.
- Season messages only for periods above 31 days, as in Beta 8. Debug and reset-to-summer settings retained.

## 2.0 adaptations

- Persistent state uses storage; no writes in on_load. Unrelated setting changes do not reset seasons.
- Surface brightness_visual_weights = {1,1,1}, so runtime brightness influences rendering in 2.0. Exact visual matching requires in-game acceptance.
- Initial lighting is deterministic (non-seasonal baseline until the first day wrap). Reset restarts the cycle; existing cycle state survives normal configuration changes and reloads.
- Disabling the cycle restores the Beta 8 fixed lighting baseline and neutral seasonal solar factor. Startup LUT darkening remains until the startup setting is changed and the game restarted.
- On removal of Clockwork-2, Nauvis day length returns to 25,000 ticks and its permanent-night freeze is removed. Other surfaces are not controlled by this mod.
- Clockwork-2 and DarkNight are incompatible alternatives, not dependencies to reinstall. Clockwork capsules disappear and its accumulator capacity multiplier is intentionally removed.

## Pollution integration

The documented Paranoidal patch for visible-pollutants 1.4.4 composes solar output as **seasonal factor × pollution factor**. Neither factor replaces the other. NightBrightness requests recomputation at midnight and after its settings change. Without either mod, the other works independently.

Read-only remote interface `NightBrightness`: `get_solar_multiplier(surface_index)` (1 outside Nauvis/when disabled) and `get_state()` (cycle diagnostics). No remote mutation/debug setters are shipped.
