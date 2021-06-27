require("values")
require("colors")
local sounds = require("__base__/prototypes/entity/sounds.lua")

local enemy_autoplace = require ("__base__/prototypes/entity/enemy-autoplace-utils.lua")

local behemoth_worm_scale = 2.2
local behemoth_worm_tint = {r=0.64, g=0.88, b=0.90, a=1.0}

local colossal_worm_scale = 3.3
local colossal_worm_tint = {r=0.94, g=0.98, b=0.90, a=1.0}

local boss_scale = 3.5

function shift_behemoth_worm(shiftx, shifty)
  return {shiftx - 0.3, shifty + 0.3}
end

function shift_colossal_worm(shiftx, shifty)
  return {shiftx - 0.4, shifty + 0.4}
end

local Loot = 
	{
	{ item = "productivity-module-2",  count_min = 1,  count_max = 4,  probability = 0.50 }	,
	{ item = "productivity-module-3",  count_min = 1,  count_max = 3,  probability = 0.25 }	,
	{ item = "effectivity-module-2",  count_min = 1,  count_max = 4,  probability = 0.50 }	,
	{ item = "effectivity-module-3",  count_min = 1,  count_max = 3,  probability = 0.25 }	,
	{ item = "speed-module-2",  count_min = 1,  count_max = 4,  probability = 0.50 }	,
	{ item = "speed-module-3",  count_min = 1,  count_max = 3,  probability = 0.25 }	,
	{ item = "uranium-fuel-cell",  count_min = 1,  count_max = 1,  probability = 0.10 }	,
	}

if data.raw.capsule['rpg_level_up_potion'] then
	table.insert ( Loot , {item = "rpg_level_up_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
	table.insert ( Loot , {item = "rpg_amnesia_potion",  count_min = 1,  count_max = 1,  probability = 0.15})
	table.insert ( Loot , {item = "rpg_small_xp_potion",  count_min = 1,  count_max = 3,  probability = 0.50})
	table.insert ( Loot , {item = "rpg_big_xp_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
	end

local boss_hp_multiplier =  settings.startup["bm-worm-enemy-hp-multiplier"].value
local boss_dmg_multiplier = settings.startup["bm-enemy-damage-multiplier"].value


data:extend(
{
  {
    type = "turret",
    name = "maf-behemoth-worm-turret",
    icon = "__base__/graphics/icons/big-worm.png",
	icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "not-repairable", "breaths-air"},
    max_health = 400000 * boss_hp_multiplier,
    order="b-b-f",
    subgroup="enemies",
    resistances = acid_resistances,
    healing_per_tick = 0.01,
    collision_box = {{-1.9, -1.4}, {1.9, 1.4}},
    selection_box = {{-1.9, -1.4}, {1.9, 1.4}},
	map_generator_bounding_box = {{-2.4, -2.2}, {2.4, 2.2}},
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "behemoth-worm-corpse",
    dying_explosion = "blood-explosion-big",
    dying_sound = sounds.worm_dying(1.0),
    inventory_size = 2,

    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(behemoth_worm_scale, behemoth_worm_tint),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(behemoth_worm_scale, behemoth_worm_tint, "forward"),
    preparing_sound = sounds.worm_standup(1),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(behemoth_worm_scale, behemoth_worm_tint),
    prepared_sound = sounds.worm_breath(1),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(behemoth_worm_scale, behemoth_worm_tint),
    prepared_alternative_sound = sounds.worm_roar_alternative(1),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(behemoth_worm_scale, behemoth_worm_tint),
    starting_attack_sound = sounds.worm_roars(1),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(behemoth_worm_scale, behemoth_worm_tint),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(behemoth_worm_scale, behemoth_worm_tint, "backward"),
    folding_sound = sounds.worm_fold(1.25),
    integration = worm_integration(behemoth_worm_scale),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    prepare_range = range_worm_behemoth + prepare_range_worm_behemoth,
    allow_turning_when_starting_attack = true,
	loot = Loot,
    attack_parameters =
    {
      type = "stream",
      ammo_category = "biological",
      damage_modifier = 110 * boss_dmg_multiplier,--defined in demo-spitter-projectiles.lua --96
      cooldown = 4,
      range = 48,--defined in demo-spitter-projectiles.lua--48
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(behemoth_worm_scale, behemoth_worm_scale * scale_worm_stream),
      use_shooter_direction = true,
      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream
      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "bm-acid-stream", --"acid-stream-worm-behemoth",
            duration = 160,
            source_offset = {0.15, -0.5}
          }
        }
      },
    },
    build_base_evolution_requirement = 0.93,
    autoplace = enemy_autoplace.enemy_worm_autoplace(10),
    call_for_help_radius = 90,
  },

  
  {
    type = "turret",
    name = "maf-colossal-worm-turret",
    icon = "__base__/graphics/icons/big-worm.png",
	icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "not-repairable", "breaths-air"},
    max_health =  800000 * boss_hp_multiplier,
    order="b-b-f",
    subgroup="enemies",
    resistances = acid_resistances,
    healing_per_tick = 0.02,
    collision_box = {{-2.9, -2.5}, {2.9, 2.5}},
    selection_box = {{-2.9, -2.5}, {2.9, 2.5}},
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "colossal-worm-corpse",
    dying_explosion = "blood-explosion-big",
    dying_sound = sounds.worm_dying(1.5),
    inventory_size = 2,
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(colossal_worm_scale, colossal_worm_tint),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(colossal_worm_scale, colossal_worm_tint, "forward"),
    preparing_sound = sounds.worm_standup(1.5),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(colossal_worm_scale, colossal_worm_tint),
    prepared_sound = sounds.worm_breath(1.5),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(colossal_worm_scale, colossal_worm_tint),
    prepared_alternative_sound = sounds.worm_roar_alternative(1),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(colossal_worm_scale, colossal_worm_tint),
    starting_attack_sound = sounds.worm_roars(1.5),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(colossal_worm_scale, colossal_worm_tint),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(colossal_worm_scale, colossal_worm_tint, "backward"),
    folding_sound = sounds.worm_fold(1.5),
    integration = worm_integration(colossal_worm_scale),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,
	build_base_evolution_requirement = 1,
    prepare_range = range_worm_behemoth + prepare_range_worm_behemoth,
    allow_turning_when_starting_attack = true,
	loot = Loot,
	call_for_help_radius = 90,
    attack_parameters =
    {
      type = "stream",
      ammo_category = "biological",
      damage_modifier = 150 * boss_dmg_multiplier,--defined in demo-spitter-projectiles.lua --96
      cooldown = 5,
      range = 50,--defined in demo-spitter-projectiles.lua--48
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(colossal_worm_scale, colossal_worm_scale * scale_worm_stream),
      use_shooter_direction = true,
      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream
      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "maf-area-acid-projectile-purple",
            duration = 200,
            source_offset = {0.15, -0.5}
          }
        }
      },
    },
  },
  



 
  {
    type = "turret",
    name = "bm-worm-boss-fire-shooter",
    icon = "__base__/graphics/icons/big-worm.png",
	icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "not-repairable", "breaths-air"},
    max_health = 400000 * 2.5 * boss_hp_multiplier,
    order="b-b-f",
    subgroup="enemies",
    resistances = fire_resistances,
    healing_per_tick = 0.02,
    collision_box = {{-4, -4}, {4, 4}},
    selection_box = {{-4, -4}, {4, 4}},
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "msi-worm-boss-fire-shooter-corpse",
    dying_explosion = "blood-explosion-big",
    dying_sound = sounds.worm_dying(2.0),
    inventory_size = 2,
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(boss_scale, red),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(boss_scale, red, "forward"),
    preparing_sound = sounds.worm_standup(2),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(boss_scale, red),
    prepared_sound = sounds.worm_breath(2),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(boss_scale, red),
    prepared_alternative_sound = sounds.worm_roar_alternative(2),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(boss_scale, red),
    starting_attack_sound = sounds.worm_roars(2),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(boss_scale, red),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(boss_scale, red, "backward"),
    folding_sound = sounds.worm_fold(2),
    integration = worm_integration(boss_scale),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,
    prepare_range = range_worm_behemoth + prepare_range_worm_behemoth,
    allow_turning_when_starting_attack = true,
	call_for_help_radius = 300,
    loot = Loot,
	build_base_evolution_requirement = 1,
    autoplace = enemy_autoplace.enemy_worm_autoplace(10),
    attack_parameters =
    {
      type = "stream",
      ammo_category = "biological",
      damage_modifier = 200 * boss_dmg_multiplier,
      cooldown = 120,
      range = 80,
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(boss_scale, boss_scale * scale_worm_stream),
      use_shooter_direction = true,
      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream
      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "maf-cluster-fire-projectile",
            duration = 100,
            source_offset = {0.15, -0.5}
          }
        }
      },
    },
  },
 


   {
    type = "corpse",
    name = "msi-worm-boss-fire-shooter-corpse",
    icon = "__base__/graphics/icons/behemoth-worm-corpse.png",
    icon_size = 64, icon_mipmaps = 4,
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selectable_in_game = false,
    subgroup="corpses",
    order = "c[corpse]-c[worm]-d[big]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
    dying_speed = 0.01,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "lower-object-above-shadow",
    animation = worm_die_animation(boss_scale, red),
    ground_patch =
    {
      sheet = worm_integration(boss_scale)
    }
  },
  
  



  {
    type = "turret",
    name = "bm-worm-boss-acid-shooter",
    icon = "__base__/graphics/icons/big-worm.png",
	icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "placeable-enemy", "not-repairable", "breaths-air"},
    max_health = 400000 * 2.5 *boss_hp_multiplier,
    order="b-b-f",
    subgroup="enemies",
    resistances = acid_resistances,
    healing_per_tick = 0.02,
    collision_box = {{-3, -3}, {3, 3}},
    selection_box = {{-3, -3}, {3, 3}},
    shooting_cursor_size = 4,
    rotation_speed = 1,
    corpse = "bm-worm-boss-acid-shooter-corpse",
    dying_explosion = "blood-explosion-big",
    dying_sound = sounds.worm_dying(2.0),
    inventory_size = 2,
    folded_speed = 0.01,
    folded_speed_secondary = 0.024,
    folded_animation = worm_folded_animation(boss_scale, green),
    preparing_speed = 0.024,
    preparing_animation = worm_preparing_animation(boss_scale, green, "forward"),
    preparing_sound = sounds.worm_standup(2),
    prepared_speed = 0.024,
    prepared_speed_secondary = 0.012,
    prepared_animation = worm_prepared_animation(boss_scale, green),
    prepared_sound = sounds.worm_breath(2),
    prepared_alternative_speed = 0.014,
    prepared_alternative_speed_secondary = 0.010,
    prepared_alternative_chance = 0.2,
    prepared_alternative_animation = worm_prepared_alternative_animation(boss_scale, green),
    prepared_alternative_sound = sounds.worm_roar_alternative(2),
    starting_attack_speed = 0.034,
    starting_attack_animation = worm_start_attack_animation(boss_scale, green),
    starting_attack_sound = sounds.worm_roars(2),
    ending_attack_speed = 0.016,
    ending_attack_animation = worm_end_attack_animation(boss_scale, green),
    folding_speed = 0.015,
    folding_animation =  worm_preparing_animation(boss_scale, green, "backward"),
    folding_sound = sounds.worm_fold(2),
    integration = worm_integration(boss_scale),
    secondary_animation = true,
    random_animation_offset = true,
    attack_from_start_frame = true,

    prepare_range = range_worm_behemoth + prepare_range_worm_behemoth,
    allow_turning_when_starting_attack = true,
    loot = Loot,
	build_base_evolution_requirement = 0.97,
    autoplace = enemy_autoplace.enemy_worm_autoplace(10),
	call_for_help_radius = 120,
    attack_parameters =
    {
      type = "stream",
      ammo_category = "biological",
      damage_modifier = 200*boss_dmg_multiplier,--defined in demo-spitter-projectiles.lua --96
      cooldown = 6,
      range = 60,--defined in demo-spitter-projectiles.lua--48
      min_range = 0,
      projectile_creation_parameters = worm_shoot_shiftings(boss_scale, boss_scale * scale_worm_stream),
      use_shooter_direction = true,
      lead_target_for_projectile_speed = 0.2* 0.75 * 1.5 * 1.5, -- this is same as particle horizontal speed of flamethrower fire stream
      ammo_type =
      {
        category = "biological",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = "maf-area-acid-projectile-purple",
            duration = 200,
            source_offset = {0.15, -0.5}
          }
        }
      },
    },
  },

  
  
   {
    type = "corpse",
    name = "bm-worm-boss-acid-shooter-corpse",
    icon = "__base__/graphics/icons/behemoth-worm-corpse.png",
    icon_size = 64, icon_mipmaps = 4,
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selectable_in_game = false,
    subgroup="corpses",
    order = "c[corpse]-c[worm]-d[big]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
    dying_speed = 0.01,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "lower-object-above-shadow",
    animation = worm_die_animation(boss_scale, green),
    ground_patch =
    {
      sheet = worm_integration(boss_scale)
    }
  },
    

  
  
  
  
  
 }
)
 
  
  
  
 data:extend(
{

  
   {
    type = "corpse",
    name = "behemoth-worm-corpse",
    icon = "__base__/graphics/icons/behemoth-worm-corpse.png",
    icon_size = 64, icon_mipmaps = 4,
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selectable_in_game = false,
    subgroup="corpses",
    order = "c[corpse]-c[worm]-d[big]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
    dying_speed = 0.01,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "lower-object-above-shadow",
    animation = worm_die_animation(behemoth_worm_scale, behemoth_worm_tint),
    ground_patch =
    {
      sheet = worm_integration(behemoth_worm_scale)
    }
  },
 
    
   {
    type = "corpse",
    name = "colossal-worm-corpse",
    icon = "__base__/graphics/icons/behemoth-worm-corpse.png",
    icon_size = 64, icon_mipmaps = 4,
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selectable_in_game = false,
    subgroup="corpses",
    order = "c[corpse]-c[worm]-d[big]",
    flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-repairable", "not-on-map"},
    dying_speed = 0.01,
    time_before_removed = 15 * 60 * 60,
    final_render_layer = "lower-object-above-shadow",
    animation = worm_die_animation(colossal_worm_scale, colossal_worm_tint),
    ground_patch =
    {
      sheet = worm_integration(colossal_worm_scale)
    }
  },
  

})
