General
===
A warhead is a weapon deployable - e.g. an explosive warhead, a nuclear warhead, etc.
A given warhead has a size, which specifies what kind of weapon that warhead can be used in - you can't fit an artillery shell into a machine gun.
A warhead is specified by an entry in the global `warheads` table, these entries take the following form:

    warheads[item_name] = warhead_specifier
    
Where `warhead_specifier` is a table.

The appearance of the warhead (the icon, picture etc.) is specified with all the fields expected for an appearance.
The warhead and its recipe are specified with the following:
- `size`
- `preciseSize`
- `order`
- `appendOrder`
- `stack_size`
- `recipe_category`
- `energy_required`
- `ingredients`
- `recipe_result_count`
- `warhead_count_per_item`
- `tint`
- `tech`


The warhead has the following controls for the final weapon:
- `appendName`
- `appendOrder`
- `progressiveRecipe`
- `additional_ingedients`
- `additional_ingedient`

The entry `explosions` can define an array of different effects the weapon can have - for example if the warhead could easily be adjusted, these would represent the configurations.
Any entry under this could instead be under the warhead itself, in which case it would be applied to any explosion which doesn't override the value. If explosions is not defined, then only one form is created.

The fields under this are:
- An appearance
- `appendName`
- `appendOrder`
- `stack_size_max`
- `reload_time_modifier`
- `cooldown_modifier`
- `range_modifier`
- `radius_color`
- `clamp_position`
- `target_type`
- `energy_required_modifier`
- `additional_ingedients`
- `additional_ingedient`
- `ingredient_count`
- `weapon_creation_tint`
- `built_up_ingredient_amount`
- `additional_results`
- `chart_picture`
- `chart_tint`
- `collisions`
- `piercing`
- `piercing_damage_extra`
- `piercing_damage_modifier`
- `acceleration_modifier`
- `max_speed_modifier`
- `action`
- `effect`
- `final_action`
- `final_effect`
- `created_action`
- `created_effect`
- `trigger_radius_modifier`
- `max_health_modifier`
- `dying_explosion`


Field meanings
===


`size` and `preciseSize`
---
Only one of these needs specifying - size is a text definition, mapped by:

    tiny = 10
    small = 20
    medium = 30
    large = 40
    huge = 50,
    

`order`
---
Specifies the order for the warhead item, defaults to `appendOrder`


`stack_size`
---
Specifies the stack size of the warhead item itself.

`recipe_category`
---
The recipe category for crafting the warhead - defaults to `"crafting"`

`energy_required`
---
The energy required (time) for the crafting of the warhead item.

`ingredients`
---
The ingredients taken for the crafting of the warhead item.

`recipe_result_count`
---
The number of warheads made by each craft. Default 1

`warhead_count_per_item`
---
The number of warheads within each item - to avoid clogging up belts with a million shotgun pellets... Default 1

`tint`
---
The crafting tint for crafting the warhead - used by the chemical plant. Optional.

`tech`
---
The tech to put this warhead as an unlock of. Optional.


Final weapon controls
===

`appendName`
---
The name to be appended to the internal name of the weapontype.

`appendOrder`
---
Specifies the order to be appended to the weapontype's base-order.


`progressiveRecipe`
---
If present, the explosions are made by crafting from one to the next, rather than all being seperate recipes - e.g. adding fuel to a shell. Default: none
Can take the values:
- `"from-first"`: Each weapon is a craft made from the first - the first can be an 'empty' one, and the rest be various forms of 'filled'
- `"building-up"`: Each weapon is a craft made from the previous explosion - the first can be an 'empty' one, and the shell can be filled bit by bit.

`additional_ingedients`
---
Full ingredient specifiers, as seen in recipe prototype.
Any ingredients to be used alongside the warhead item when making the weapon. 
If `progressiveRecipe` these ingredients are only included in the craft of the first weapon is enabled. Optional

`additional_ingedient` and `ingredient_count`
---
Same as above, but just the name of an ingredient, the count is set to `ingredient_count`, defaulting to 1. Optional


Explosion fields
===


`appendName`
---
This is appended after the warhead appendName

`appendOrder`
---
This is appended after the warhead appendOrder

`stack_size_max`
---
Specifies the maximum stack size of the created weapon. Default: warhead `stack_size`

`reload_time_modifier`
---
The multiplier for reload time (the time between magazines). Default: 1.

`cooldown_modifier`
---
The multiplier for cooldown time (the time between each shot). Default: 1.

`range_modifier`
---
The multiplier for weapon range (to the extent that the modifier can be applied). Default: 1.

`radius_color`
---
The colour of the targeting radius for capsule type weapons. Optional

`clamp_position`
---
Whether to allow shooting beyond maximum range, resulting in shooting at max range - useful for very area-of-effect weapons. Default: false.

`target_type`
---
The `target_type` as seen in `ammo_type` in factorio's prototypes. Optional.

`energy_required_modifier`
---
The multiplier for the time taken to attach the warhead to the deployer. Default: 1.

`additional_ingedients`, `additional_ingedient` and `ingredient_count`
---
Same as for warhead, also appended, but is appended to `progressiveRecipe` as well - so can indicate the progression. Optional

`weapon_creation_tint`
---
Crafting machine tint for the connection of the warhead to the weapon.



`built_up_ingredient_amount`
---
How many of the previous stage of the `progressiveRecipe` to use. Default: 1

`additional_results`
---
Any other items produced by connecting the warhead to the weapon. Default: none.

`chart_picture`
---
The appearance to use if this warhead is fitted to an artillery shell. Default: standard artillery 

`chart_tint`
---
The tint to apply to the blank chart picture. Default: none.

`collisions`
---
Whether to allow the weapon projectile to collide with obstructions. Default: true.

`piercing`
---
Whether to allow the weapon projectile to do piercing damage. Default: true.

`piercing_damage_modifier`
---
Multiplier for `piercing_damage` for the projectile. Default: 1

`piercing_damage_extra`
---
Constant extra `piercing_damage` to add to projectile. Added after the multiplier is applied. Default: 0

`acceleration_modifier`
---
Multiplier for the projectile acceleration. Default: 1.

`max_speed_modifier`
---
Multiplier for the projectile max speed. Default: 1.

`action`
---
The action applied every time the weapon hits something - can happen many times for e.g. cannon shell. Is of type `Trigger`. Optional

`effect`
---
The effect applied every time the weapon hits something - can happen many times for e.g. cannon shell. Is of type `TriggerEffect`. Optional
`action` takes priority.

`final_action`
---
The action applied when the weapon hits its last thing (e.g. the projectile runs out of piercing). Is of type `Trigger`. Optional

`final_effect`
---
The effect applied when the weapon hits its last thing (e.g. the projectile runs out of piercing). Is of type `TriggerEffect`. Optional
`final_action` takes priority.

`created_action`
---
The action applied when the weapon is fired. Is of type `Trigger`. Optional

`created_effect`
---
The effect applied when the weapon is fired. Is of type `TriggerEffect`. Optional
`created_action` takes priority.


`trigger_radius_modifier`
---
Multiplier for the trigger radius of a landmine using this warhead. Default: 1

`max_health_modifier`
---
Multiplier for the max health of a landmine using this warhead. Default: 1

`dying_explosion`
---
`dying_explosion` of a landmine using this warhead (when the landmine is destroyed rather than triggered). Default: same as vanilla landmine.


