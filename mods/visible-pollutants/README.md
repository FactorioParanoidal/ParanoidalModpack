## Pollution: Impactful Smog / Spore Cloud

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