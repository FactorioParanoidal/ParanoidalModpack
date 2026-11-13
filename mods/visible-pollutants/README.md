## Pollution: Impactful Smog / Spore Cloud — Paranoidal fork

Maintained in Paranoidal, based on somethingtohide's version 1.4.4 (MIT).
The mod ID and settings are retained for existing saves. Version 1.4.5 rebuilds
its derived caches through the existing configuration-change handler.

The fork caches see-through regions per surface, avoids unrelated player scans,
reuses chunk layouts and solar queues, and incrementally cleans expired render
references. Solar totals are rebased over the existing update batches rather
than through a full scan every cycle; topology changes still rebuild the queue
at a cycle boundary. Full synchronization when enabling solar occlusion or
changing the mod configuration still scans existing panels.

Multiplayer queues, diagonal movement, cross-surface see-through, and solar
panel teleport/clone bookkeeping are corrected. Texture, coverage, lifetime,
opacity/solar formulas, RNG-based rotation and blend coefficients are unchanged.
The upstream inclusive batch bounds and cycle-end pause are retained: the
configured batch size N can process N+1 entries, as before.
No FPS/UPS improvement percentage is claimed without a representative benchmark.

Do you feel like your factory is _too clean_? A gross, smoggy atmosphere might be what you need. This mod adds a visible pollution cloud, based on the actual pollution in the area. It can also reduce the effectiveness of solar panels based on how occluded they are by pollution. It's quite configurable, and very efficient, compared to similar but older mods.

### Features

* Visiblity of pollution cloud is based on the actual pollution in the area.
* Solar panels can be less effective if placed underneath heavy pollution.
* Thickness, minimum, and maximum opacity of the cloud is configurable.
* See-through the cloud to see what's underneath your cursor, no matter how polluted you are.
* Special support for spores (and potentially other modded pollutants).
* Configurable to add pollution to any planets, purely for visual effect.
* Performance-related configurations to handle any scale.

# Known Issues

### Pinned Remote Views may not show pollution

Because of the way this mod is designed, and given of the lack of events for the small Remote View tooltips, it's possible that "stale" pollution is removed and not added back when looking at the tooltip view. If you don't like this, you can extend the pollution lifetime so that it's hopefully not removed before you look at the tooltip again.

### Dragging the Remote View to move may not update pollution until dropped

Because of the way this mod is designed, and given of the lack of events for dragging the Remote View around, it's not possible to update the pollution until the dragging is finished. By default, a wide-enough area is constantly scanned, in the hopes that it fully covers the widest dragging distance.