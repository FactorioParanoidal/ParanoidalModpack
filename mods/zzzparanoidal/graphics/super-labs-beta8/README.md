# Beta 8 super-lab assets

The six PNG files are unchanged copies from the supplied Paranoidal Beta 8
`mods/BigLab/graphics/` (BigLab 9.1.1; author field: DellAquila touched by DrD_AVEL).
`sound/lab.ogg` is the original Factorio 1.1.107 base lab sound used by that mod.
These are existing assets, not newly generated artwork.

The new `paranoidal-beta8-big-lab` and `paranoidal-beta8-hyper-lab` prototypes
use these assets. BigLabFork's existing `big-lab` remains separate.

Factorio 2.0 adaptations: direct `module_slots`, long-form recipe results,
Bob/Angels ID remapping, and `impact_category = "metal"` in place of the
removed `vehicle_impact_sound`. The obsolete `apparent_volume` and
lab `crafting_categories` fields are not copied. Both labs additionally accept
`planetary-data` and `station-science` by user request.
