General
===
A weapontype is a way of deploying a warhead - think a launcher, casing or similar.
A given weapontype has a size, which determines what warheads it can fire.

A weapontype is specified by an entry in the `weaponTypes` table, these entries take the following form:

    weaponTypes[name] = weaponType_specifier
    
Where `weaponType_specifier` is a table.

The weapontype is specified by the following fields:
- `item`
- `projectile`
- `type`
- `size`
- `max_size`
- `min_size`
- `override`
- `appearance_fallbacks`
- `appearance_fallback`
- `image_base_shift`
- `image_warhead_shift`
- `ignore_warhead_image`
- `icon`
- `picture`
- `light`
- `icons`
- `pictures`
- `lights`
- `addon_icons`
- `addon_icon`
- `addon_pictures`
- `addon_picture`
- `addon_lights`
- `addon_light`
- `subgroup`
- `stack_size`
- `magazine_size`
- `reload_time`
- `radius_color`
- `default_radius_color`
- `target_type`
- `range_modifier`
- `cooldown_modifier`
- `clamp_position`
- `action_creator`
- `ammo_category`

- `result_count`
- `additional_results`
- `base_item`
- `extra_ingredients`
- `energy_required`
- `recipe_category`
- `recipe_subgroup`
- `hide_from_player_crafting`
- `warhead_count`

- `land_mine_corpse`
- `trigger_radius`
- `land_mine_max_health`
- `land_mine_damaged_trigger_effect`
- `land_mine_selection_box`
- `land_mine_collision_box`
- `land_mine_dying_explosion`
- `land_mine_pictures`
- `land_mine_mining_time`
- `land_mine_mining_particle`

- `projectile_acceleration`
- `projectile_picture`
- `projectile_shadow`
- `projectile_smoke`
- `projectile_light`
- `projectile_animation`
- `max_speed`
- `collision_box`
- `height`
- `height_from_ground`
- `direction_only`
- `collide_anyway`
- `turn_speed`
- `reveal_map`
- `map_color`


Field meanings
===

`item`
---
The item to take other fields from - allows a basic copy of an item. Optional

`projectile`
---
A projectile to take missing fields from - allows a basic copy. Optional

`landmine`
---
A landmine to take missing fields from. Defaults to basegame landmine.

`type`
---
What kind of weapon/item. Valid values:
- `projectile` - most things
- `artillery` - very similar to projectile
- `land-mine`
- `bullet` - e.g. machine gun rounds - has no actual projectile.
- `capsule` - e.g. grenade.


`size`
---
The maximum size of warhead to put in this weapontype.

    tiny = 10
    small = 20
    medium = 30
    large = 40
    huge = 50,
    
`max_size`
---
Same as `size` - only applies if `size` not specified. Default: 100 ("all")

`min_size`
---
The minimum size of warhead to put in this weapontype, of same type as `size`/`max_size`. Default: 0 ("none")

`override`
---
Does a complete override of how this weapon is created - is a function taking a sanitised warhead and sanitised weapontype. Optional

Appearance
===
See appearance.md for more details on how these fields work.

If no default appearance is given, the `item` icon or icons are used.
The priority for icons/pictures/lights (all together, but using icons for illustrative purposes):
1: `icons[appendName]`
2: `weaponTypes[appearance_fallbacks[1]].icons[appendName]` ... `weaponTypes[appearance_fallbacks[n]].icons[appendName]`
3: `weaponTypes[appearance_fallback].icons[appendName]`
4: `icon`
5: `icons.default`
6: `weaponTypes[appearance_fallbacks[1]].icons.default` ... `weaponTypes[appearance_fallbacks[n]].icons.default`
7: `weaponTypes[appearance_fallback].icons.default`
8: `item.icon`/`item.icons`

If any of these give an icon or light or picture, then that stage is used on its own.

`appearance_fallbacks`
---
An array of weapontypes to use for appearances of warheads which have no configuration under this weapontype. Optional

`appearance_fallback`
---
What weapontype to use for appearances of warheads which have no configuration under this weapontype. Optional

`image_base_shift`
---
The shift applied to the weapontype icons/pictures, works in icon style units. Default: {0,0}

`image_warhead_shift`
---
The shift applied to the warhead icons/pictures, works in icon style units. Default: {0,0}

`ignore_warhead_image`
---
If this is set the warhead image will not be put on the combination image. Default: false


`icon`
---
The default icon for this weapontype.

`picture`
---
The default picture for this weapontype.

`light`
---
The default light for this weapontype.

`icons`
---
A map from warhead appendName to an icon or an array of icons.
Elements under numberic keys (i.e. array like elements) are treated as being under "default".

`pictures`
---
A map from warhead appendName to a picture or an array of pictures.
Elements under numberic keys (i.e. array like elements) are treated as being under "default".

`lights`
---
A map from warhead appendName to a light or an array of lights.
Elements under numberic keys (i.e. array like elements) are treated as being under "default".


`addon_icons`
---
A table of extra icons to add after everything else is done.

`addon_icon`
---
An extra icon to add after everything else is done.

`addon_pictures`
---
A table of extra pictures to add after everything else is done.

`addon_picture`
---
An extra picture to add after everything else is done.


`addon_lights`
---
A table of extra lights to add after everything else is done.

`addon_light`
---
An extra light to add after everything else is done.



Item
===

`subgroup`
---
The item subgroup to use. Default: `item.subgroup`

`stack_size`
---
The `stack_size` to use. Default: `item.stack_size`

`magazine_size`
---
The `magazine_size` to use. Default: `item.magazine_size` then Default: 1

`reload_time`
---
The `reload_time` to use. Default: `item.reload_time` then Default: 0

`radius_color`
---
The `radius_color` to use. Default: none

`default_radius_color`
---
The default `radius_color` to use. Default: `item.radius_color`
If `radius_color` is specified, that is used, defaulting to the warhead `radius_color` then defaulting to `default_radius_color`.

`target_type`
---
The `ammo_type.target_type` to use, warhead `target_type` overrides this. Default: none

`range_modifier`
---
The `range_modifier` to use. The weapon `ammo_type.range_modifier` is `range_modifier * warhead.range_modifier`

`cooldown_modifier`
---
The `cooldown_modifier` to use. The weapon `ammo_type.cooldown_modifier` is `cooldown_modifier * warhead.cooldown_modifier`

`clamp_position`
---
Whether to set `ammo_type.clamp_position`. Is or'd with `warhead.clamp_position`

`action_creator`
---
This is a function which can set the projectile, range multiplier, source action, final action, etc. 
It is filled in based on `type` so shouldn't need touching unless you have a very weird entry for `item`.

`ammo_category`
---
The `ammo_type.category` or landmine `ammo_category` to use - this is only used if `warhead.ammo_category` is not specified.

Recipe
===

`result_count`
---
How many weapons are produced in a single craft. Can be changed to line up with `warhead_count_per_item`, but will always be a multiple of this. 
Default: 1

`additional_results`
---
Any other items produced in the same form as a recipe prototype's `results`. Default: none

`base_item`
---
The item to use as the main basis of the weapon - much as cannon shells are used as the basis of cannon shell recipes.

`extra_ingredients`
---
Any other ingredients requires. Same form as a recipe prototype's `ingredients`. Default: none

`energy_required`
---
The `energy_required` for combining this weapontype with a warhead.

`recipe_category`
---
The `category` for the combining recipe. Default: none

`recipe_subgroup`
---
The `subgroup` for the combining recipe. Default: none

`hide_from_player_crafting`
---
The `hide_from_player_crafting` for the combining recipe. Default: false

`warhead_count`
---
The number of warheads taken to craft this weapon. Default: 1

Land-mine
===
These are all copied into the the final landmine entity created.

`land_mine_corpse`
---
Default: `landmine.corpse`

`trigger_radius`
---
Default: `landmine.trigger_radius`

`land_mine_max_health`
---
Default: `landmine.max_health`

`land_mine_damaged_trigger_effect`
---
Default: `landmine.damaged_trigger_effect`

`land_mine_selection_box`
---
Default: `landmine.selection_box`

`land_mine_collision_box`
---
Default: `landmine.collision_box`

`land_mine_dying_explosion`
---
Default: `landmine.dying_explosion`

`land_mine_pictures`
---
Works in the same way as `pictures`, although without `appearance_fallbacks`, so simply goes:

1: `land_mine_pictures[appendName]`
2: `land_mine_pictures.default`
3: Copy from landmine
Each entry must be a table with three values:
- `picture_safe`
- `picture_set`
- `picture_set_enemy`

`land_mine_mining_time`
---
Used to generate the mining information, `minable.mining_time`. Default: `landmine.minable.mining_time`

`land_mine_mining_particle`
---
Used to generate the mining information, `minable.mining_particle`. Default: `landmine.minable.mining_particle`


Projectiles
===

`projectile_acceleration`
---
The `acceleration` field of the projectile. Default: `projectile.acceleration`

`projectile_picture`
---
The `picture` field of the projectile. Default: `projectile.picture`

`projectile_shadow`
---
The `shadow` field of the projectile. Default: `projectile.shadow`

`projectile_smoke`
---
The `smoke` field of the projectile. Default: `projectile.smoke`

`projectile_light`
---
The `light` field of the projectile. Default: `projectile.light`

`projectile_animation`
---
The `animation` field of the projectile. Default: `projectile.animation`

`max_speed`
---
The `max_speed` field of the projectile. Default: `projectile.max_speed`

`collision_box`
---
The `collision_box` field of the projectile. Default: `projectile.collision_box`

`height` and `height_from_ground`
---
Only one of these needs specifying.
The `height` or `height_from_ground` field of the projectile. Default: `projectile.height` or `projectile.height_from_ground`

`direction_only`
---
The `direction_only` field of the projectile. Default: `projectile.direction_only`

`collide_anyway`
---
Allows collisions even if `warhead.collisions` is false. Default: false

`turn_speed`
---
The `turn_speed` field of the projectile. Default: `projectile.turn_speed`

`reveal_map`
---
The `reveal_map` field of the projectile. Default: `projectile.reveal_map`

`map_color`
---
The `map_color` field of the projectile. Default: `projectile.map_color`



