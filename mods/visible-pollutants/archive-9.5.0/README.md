## Pollution: Impactful Smog / Spore Cloud — Paranoidal fork

Maintained in Paranoidal, based on somethingtohide's version 1.4.4 (MIT).
The mod ID, existing setting IDs and saved values are retained. Four HD cloud
shapes share one render per cell; stage 4 adds an optional native veil animation.
The shared pollution curve and solar formulas are unchanged. There is no extra
full-size layer or per-machine entity.

### Four HD cloud shapes

The renderer uses four 1024 x 1024 RGBA8 resources in `graphics/`:

* `pollution-veil.png`: soft, broad veil.
* `pollution-haze.png`: elongated airflow structure.
* `pollution-broken.png`: asymmetric separated masses with transparent gaps.
* `pollution-smog.png`: heavier, more concentrated structure.

These are variations of one effect, not different pollution severity levels.
They use straight alpha with neutral RGB, fully transparent outer edges and
comparable optical weight. Procedural sources and comparison sheets stay outside
the distributed mod. One render object per cell selects its variant, initial
orientation and center offset deterministically from surface/cell coordinates,
without consuming map RNG. Recreation keeps the same initial layout.

Clouds cover a 128-tile square (scale 4) on the 32-tile grid, with no extra
opacity gain. The initial 64-tile calibration combined reduced overlap with
masks having roughly half the legacy optical depth: real polluted factories
looked almost clean. The larger footprint restores aggregate optical weight
without replacing the HD resources, changing saved opacity/see-through values,
or retuning the shared pollution/solar curve. This is not an exact pixel or
perceptual match to the old 96-tile blanket. Final density, motion and readability
remain subject to in-game acceptance.

The original `visible-pollutants-pollution` ID and `pollution.png` remain intact.
With motion off, old objects fade out over 60 game ticks from their first service,
then change resource and pose in place at zero opacity and blend back in. Sparse
service can lengthen that transition; a temporary local dip is preferable to a
texture pop. New clouds also start transparent. There is no mass clear or mass
recreation; missing derivative state is initialized during bounded event work.

New sprites request smoke mipmaps, linear minification/magnification and linear
mip-level filtering. Straight PNGs are premultiplied by the loader; runtime tint
is premultiplied once through the existing color function. No glow/light mode is
enabled. The default layer for a missing setting is now `smoke`, below selection
boxes and robots but above ground ALT icons; it is not a guarantee that all
annotations remain unobscured. Existing saved layers (including `arrow`) remain
unchanged. The user can select another existing layer without recreating clouds.

### Optional motion

`Cloud motion` (`visible-pollutants-motion`, runtime-global) is off by default.
Static mode keeps all four 1024-square forms and stops rotation, translation and
frame animation; opacity still follows pollution. Existing clouds converge to
the chosen mode through bounded service/maintenance, not a synchronous scan.

When enabled, only cells deterministically assigned the soft veil use a native
animation: one 512-square, 32-frame cycle at two frames per game second. The other
three forms remain HD sprites. Its small periodic internal warp is normalized
for mean optical depth; it is not a crossfade between unrelated cloud shapes.
Per-cell phase offsets avoid a single global starting pose. Native rendering
advances frames; Lua does not switch every object's frame each tick.

The additional 4096x2048 RGBA8 atlas is 32 MiB of pixel data before mipmaps,
atlases or engine compression (not measured VRAM). The four static forms remain
16 MiB, plus the retained old texture. Motion off does not unload the atlas.
The smaller animated frame is an explicit memory/definition trade-off, not a
replacement of the four HD resources. It covers the same 128-tile square.

Wind direction and speed set a small bounded offset, at most 1.5 tiles per axis
from each stable center, with elapsed-tick smoothing (two-second half-life).
Clouds do not drift indefinitely or snap their orientation around with the wind;
the old continuous rotation is removed. Native internal motion has a constant
16-second period, independent of wind speed and pollution density. Its softness,
frame stepping, 4K readability and night appearance await in-game acceptance.

Sprite/animation mode changes fade the old object to zero, retire it, then create
the current mode on a later visit under the existing four-creates-per-tick cap.
There is never a second overlapping cloud for that cell. A toggle back before
retirement cancels the fade from its current alpha. Already animated objects
pause/resume phase when serviced; switching off is gradual across the cache.
Legacy 96-tile sprites still upgrade in place when the target is a static form;
an animated target uses the same budgeted retirement/recreation path. Brief
local opacity dips during replacement are possible. No save migration is added.

### Bounded visual scheduler

Movement, teleport, selection and display events only flag a player's context.
A persistent round-robin, center-out cursor visits current camera demand without
allocating whole chunk rectangles or accumulating old movement jobs. Coverage
includes rotation, deterministic center offset and the full wind reserve (about
94.0 tiles beyond the viewport, including in static mode so frozen offsets fit).
During old-cache adoption, coverage uses the larger of current and legacy
footprints (the old one is 69.9 tiles), never a smaller transitional margin; no
full-cache scan is needed. The larger footprint can increase total camera demand,
not the existing per-tick budgets. The old four-chunk camera-radius cap is gone. Chart-only views
and surfaces without a pollutant do not generate visual demand.

Per tick, the visual worker visits at most 64 candidate turns, refreshes at most
4 player contexts, performs at most the configured update limit of cell work
(default 20, including discovery), creates at most 4 renders and maintains at
most 8 cache records. A cell-work operation reads pollution at most once and
creates or updates at most one render. Clean fading can retire at most one
render per cell-work operation, in addition to bounded maintenance removals.
Budget exhaustion preserves the next player's turn rather than starving it.

Pollution samples, including clean cells, are reused for 60 ticks. Entirely
clean views sleep between sweeps and wake on view events. See-through areas use
per-surface reference counts, not repeated all-player scans. Connected-player
enumeration is a one-time topology snapshot at init/upgrade, not a per-tick scan.
Zoom and available camera changes are polled through the bounded worker.

The cache holds at most 8192 sampled cells/renders after legacy adoption.
Under extreme aggregate demand, each online player's near-camera share is
prioritized; complete distant-edge coverage is not promised beyond that cap.
Unvisited entries are retired incrementally after a workload-aware grace period
(at least 120 ticks), limited by the user's maximum lifetime. TTL is an upper
bound, not a promise to retain off-screen pollution for that many minutes.
Old saves' render handles are adopted/trimmed in bounded batches; an oversized
legacy cache may temporarily exceed the cap while being drained, without new
growth. No storage is changed during on_load.

Opacity blending and wind-offset smoothing use elapsed game ticks rather than
queue visits. Clean clouds disappear completely. Layer/opacity settings retain
render identities; changing the veil's object kind uses the bounded transition
above, never a mass clear. Shared pollution-curve changes invalidate samples.

### Gameplay and integration

* Clouds reflect actual chunk pollution, with configurable opacity and curve.
* Player/selected-entity areas are more transparent; this effect is shared.
* Spores retain their separate tint and compatibility groundwork.
* Optional solar occlusion retains the existing surface-wide legacy formula,
  quality accounting, seasonal composition with NightBrightness and read-only
  status interface. Its queues are separate from visual scheduling.
* Solar synchronization on relevant settings/configuration changes still scans
  panels as before; visual budgets do not claim to bound that independent work.
* Planet pollutant assignment and chart-color settings retain their behavior.

No measured FPS/UPS improvement is claimed without a representative benchmark.
Headless runtime checks do not establish visual quality.

### Technical verification boundary

Targeted Factorio 2.1.24 checks validated the six graphic prototype definitions,
natural camera discovery, legacy in-place upgrades, native Sprite/Animation
replacement, real setting events, pause/resume property updates, clean retirement
and the existing work/create budgets. A real save/load of a synthetic mixed-handle
cache preserved both render identities and derived fields before the first
scheduler step, then continued a pending transition through retirement/recreation.
No original player save was used; this is not an exhaustive save-upgrade or
multiplayer test. Headless does not load image pixels or prove visible frame
progress, seamless motion, lighting, 4K readability or subjective density.
Those headless limits remain; the asset checks and CPU sheets are separate.

A later graphical before/after check on physical copies of a supplied polluted
factory save established the visibility regression: 27-29 valid, nontransparent
clouds were serviced normally, but the initial 64-tile coverage was too weak.
The corrected 128-tile coverage produced visible smog at the same game tick,
camera, light, pollution and saved settings, preserving all 28 render identities
in the comparison frame. Work/create limits were checked over 331 service ticks.
Only the copied surface's daytime was frozen for comparison; no original save or
working settings were changed. This checks that save/camera, not every zoom,
night scene or multiplayer configuration. Subjective density is still user
acceptance. Restart the game to load changed graphic prototypes.

### Known camera limits

Pinned remote-view tooltips do not provide their own demand events, so they may
show absent or stale pollution. Extending TTL alone does not guarantee coverage.
During remote-view dragging, polling can follow only the view coordinates the
engine exposes; a camera position withheld until release cannot be reconstructed.
