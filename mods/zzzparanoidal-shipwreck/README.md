# PARANOIDAL: start shipwreck

Local project mod. All start-crash balance is in `shipwreck-config.lua`: the ship contents, the
debris stacks, the AAI wreck contents, the mining loot of every wreck and the ship, the start
levels, the AAI crash scene and the salvaged generator values.

- Data stage: AAI wreck prototypes and the salvaged assembling machine, lab and generator
  (`data.lua`, lab inputs copied from the vanilla lab); in `data-final-fixes.lua` (after
  ic-more-qualities) every wreck and the ship get mining time 1.5 s, the medium loot of the config
  and an invisible pickaxe target, the ship 80 slots, the generator its values and quality tooltip.
- Control: on a new map the freeplay item lists are emptied (the player starts empty, respawn items
  stay), the AAI scene is created and, when freeplay has created the crash site, the ship and its
  debris are filled. Start wrecks get their mining loot from the config with the start level and
  quality; other wrecks (ruins) keep the prototype loot.
- Quality: one roll per item type per map from the `ic-defects-classification` mod-data of
  ic-more-qualities. Minimum: defect-capable finished items and all electric poles get `ic-defect-1…5` by the level weights (5/15/25/25/20/10%, 0 = normal); rich: every
  finished item gets 0…5 steps along `normal.next` by the level weights (25/30/20/13/8/4%); materials and belts/undergrounds/splitters/loaders are always normal. Without
  ic-more-qualities everything is normal.
- Salvaged generator: production × `default_multiplier`, buffer × `accumulator_capacity_multiplier`
  of the entity quality, set when built and on configuration change.

Credits: salvaged machines and their graphics come from Looting Spaceship Wrecks by darkfrei and
sbelyakov (MIT); the AAI wreck graphics from AAI Industry by Earendel.
