if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value


---- Spitter / Worm  - Attack Functions

-- Projectile Spitters - Honing
function Spitter_Attack_Projectile(data)
  return
  {
    type = "projectile",
    ammo_category = "rocket",
    cooldown = data.cooldown,
    range = data.range,
    projectile_creation_distance = 1.9,
    damage_modifier = data.damage_modifier,
    warmup = 30,
    ammo_type =
    {
      category = "biological",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = data.projectile,
          starting_speed = 1
        }
      }
    },
    sound = make_spitter_roars(data.roarvolume),
    animation = spitterattackanimation(data.scale, data.tint1, data.tint2),
  }
end


-- Spitter Projectile - Non-Honing
function Spitter_Attack_Projectile_NH(data)
  return
  {
    type = "projectile",
    ammo_category = "rocket",
    cooldown = data.cooldown,
    range = data.range,
    projectile_creation_distance = data.projectile_creation_distance,
    ammo_type =
    {
      category = "rocket",
	  clamp_position = true,
	  target_type = "position",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = data.projectile,
          starting_speed = 0.3,
		  max_range = data.range,
        }
      }
    },
	sound = make_spitter_roars(data.roarvolume),
    animation = spitterattackanimation(data.scale, data.tint1, data.tint2),
  }
end


-- Worm Unit Launching Projectile - Non-Honing
function Worm_Attack_Projectile_NH(data)
  return
  {
    type = "projectile",
    ammo_category = "rocket",
    cooldown = data.cooldown,
    range = data.range,
    projectile_creation_distance = data.projectile_creation_distance,
    ammo_type =
    {
      category = "rocket",
	  clamp_position = true,
	  target_type = "position",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = data.projectile,
          starting_speed = 0.3,
		  max_range = data.range,
        }
      }
    },
  }
end


-- Stream Spitters - Fire Streams
function Spitter_Attack_Stream(data)
  return
  {
    type = "stream",
	force = "enemy",
    ammo_category = "flamethrower",
    cooldown = data.cooldown,
    range = data.range,
    projectile_creation_distance = 1.9,
    damage_modifier = data.damage_modifier or 1.0,
    warmup = data.range * 1.5, --15,
	min_range = 6,
    turn_range = 1.0,
	fire_penalty = 30,	
	gun_barrel_length = 1 * data.scale,
	gun_center_shift = {
	    north = {0, -0.65 * data.scale},
	    east = {0, 4 * data.scale},
	    south = {0, 1 * data.scale},
	    west = {0.65 * data.scale, 4 * data.scale}
	
	},
    ammo_type =
	    {
        category = "flamethrower",
        action =
		    {
			type = "direct",
			force = "enemy",
			action_delivery =
			    {
				type = "stream",
				force = "enemy",
				stream = "ne-fire-stream",
				source_offset = {0.15, -0.5},
				max_length = data.range,
				duration = 160,
			    }
		    }
	    },
      cyclic_sound =
      {
        begin_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-start.ogg",
            volume = 0.7
          }
        },
        middle_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-mid.ogg",
            volume = 0.7
          }
        },
        end_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-end.ogg",
            volume = 0.7
          }
        }
      },
	sound = make_spitter_roars(data.roarvolume),  
    animation = spitterattackanimation(data.scale, data.tint1, data.tint2),
  }
end


-- Stream Spitters - Fire Streams
function Worm_Attack_Stream(data)
  return
  {
    type = "stream",
	force = "enemy",
    ammo_category = "flamethrower",
    cooldown = data.cooldown,
    range = data.range,
    projectile_creation_distance = 1.9,
    damage_modifier = data.damage_modifier or 1.0,
    warmup = data.range * 1.5,
	min_range = 2,
    turn_range = 1.0,
	fire_penalty = 15,	
	gun_barrel_length = 0.5,
	gun_center_shift = {
	    north = {0, -1.2},
	    east = {1.2, 0},
	    south = {0, -1.2},
	    west = {-1.2, 0}
	},
    ammo_type =
	    {
        category = "flamethrower",
        action =
		    {
			type = "direct",
			force = "enemy",
			action_delivery =
			    {
				type = "stream",
				force = "enemy",
				stream = "ne-fire-stream",
				source_offset = {0.15, -0.5},
				max_length = data.range,
				duration = 200,
			    }
		    }
	    },
      cyclic_sound =
      {
        begin_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-start.ogg",
            volume = 0.7
          }
        },
        middle_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-mid.ogg",
            volume = 0.7
          }
        },
        end_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-end.ogg",
            volume = 0.7
          }
        }
      },
  }
end


data:extend({
---Fire Stream
  {
    type = "stream",
    name = "ne-fire-stream",
	force = "enemy",
    flags = {"not-on-map"},
    stream_light = {intensity = 1, size = 4},
    ground_light = {intensity = 0.8, size = 4},

    smoke_sources =
    {
      {
        name = "soft-fire-smoke",
        frequency = 0.05, --0.25,
        position = {0.0, 0}, -- -0.8},
        starting_frame_deviation = 60
      }
    },
    particle_buffer_size = 90,
    particle_spawn_interval = 2,
    particle_spawn_timeout = 8,
    particle_vertical_acceleration = 0.005 * 0.60,
    particle_horizontal_speed = 0.2* 0.75 * 1.5,
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_start_scale = 0.2,
    particle_loop_frame_count = 3,
    particle_fade_out_threshold = 0.9,
    particle_loop_exit_threshold = 0.25,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-fire",
              entity_name = "ne-fire-flame-2",
			  trigger_created_entity = true,
			  
            },
          }
        }
      },
      {
        type = "area",
        radius = 1.5,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
			  force = "enemy",
              sticker = "ne-fire-sticker-2"
            },
            {
              type = "damage",
              damage = { amount = 3, type = "ne_fire", force = "enemy" },
              apply_damage_to_trees = true
            },
            {
              type = "damage",
              damage = { amount = 0.5, type = "physical", force = "enemy"  },
              apply_damage_to_trees = false
            }
          }
        }
      }
    },

    spine_animation =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-fire-stream-spine.png",
      blend_mode = "additive",
      line_length = 4,
      width = 32,
      height = 18,
      frame_count = 32,
      axially_symmetrical = false,
      direction_count = 1,
      animation_speed = 2,
      shift = {0, 0}
    },

    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-purple-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },

    particle =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      frame_count = 32,
      line_length = 8
    }
  },

  
--- Mine Projectile
  {
    type = "projectile",
    name = "Mine-Projectile",
    flags = {"not-on-map"},
    acceleration = 0.005,
	force = "enemy",
    action =
    {
      type = "direct",
	  force = "enemy",
      action_delivery =
      {
        type = "instant",
		force = "enemy",
        target_effects =
        {		  
          {
            type = "create-entity",
			entity_name = "land-mine" -- will be replaced with a Spitter mine below.
          },
        }
      }
    },
    animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/land_mine_projectile.png",
      line_length = 16,
      width = 16,
      height = 18,
      frame_count = 16,
      priority = "high"
    },
    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/land_mine_projectile_shadow.png",
      line_length = 16,
      width = 28,
      height = 16,
      frame_count = 16,
      priority = "high",
	  scale = 0.5,
      shift = {-0.09, 0.395}
    },
    rotatable = false
  },


--- Unit Unit-Projectiles
  {
    type = "projectile",
    name = "Unit-Projectile",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {		  
          {
            type = "create-entity",
			entity_name = "ne_unit_launcher_trigger_1",			
          },
		  {
			type = "damage",
			damage = { amount = 2 , type = "physical"}
		  },
		  {
			type = "create-sticker",
			sticker = "slowdown-sticker"
          },
        }
      }
    },
	animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-green.png",
      line_length = 5,
      width = 16,
      height = 18,
      frame_count = 33,
      priority = "high"
    },
    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-purple-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },
    rotatable = false
  },
  
  
--- Worm Unit-Projectiles
  {
    type = "projectile",
    name = "Worm-Unit-Projectile",
    flags = {"not-on-map"},
    acceleration = 0.005,
	--force = "enemy",
    action =
    {
      type = "direct",
	  --force = "enemy",
      action_delivery =
      {
        type = "instant",
		--force = "enemy",
        target_effects =
        {		  
          {
            type = "create-entity",
			--force = "enemy",
			entity_name = "ne_worm_launcher_trigger_1",			
          },
		  {
			type = "damage",
			damage = { amount = 3 , type = "physical"}
		  },
		  {
			type = "create-sticker",
			sticker = "slowdown-sticker"
          },
        }
      }
    },
	animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-green.png",
      line_length = 5,
      width = 16,
      height = 18,
      frame_count = 33,
      priority = "high"
    },
    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-purple-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },
    rotatable = false
  },
  
  
--- Web Projectile
  {
	type = "projectile",
	name = "Web-Projectile",
	flags = {"not-on-map"},
	collision_box =  {{-0.01, -0.01}, {0.01, 0.01}},
	collision_mask = { "layer-11" },
	direction_only = true,
	acceleration = 0.01,
	force = "enemy",
	action =
    {
		{
			type = "area",
			radius = 1.5,
			force = "enemy",
			action_delivery =
			{
			type = "instant",
			force = "enemy",
			target_effects =
			{   
				{
					type = "create-entity",
					force = "enemy",
					entity_name = "ne_web",         
				}, 
				{
					type = "damage",
					damage = { amount = 1 , type = "physical"}
				},
				{
					type = "create-sticker",
					sticker = "slowdown-sticker"
				},
			}
		  },
		  },
		  {
		  type = "direct",
		  force = "enemy",
		  action_delivery =
		  {
			type = "instant",
			force = "enemy",

				  target_effects =
				  {
					type = "create-entity",
					entity_name = "ne-acid-splash-purple"
				  },
				},
		  },
      
    },
	animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-yellow.png",
      line_length = 5,
      width = 16,
      height = 18,
      frame_count = 33,
      priority = "high"
    },
    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-purple-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },
    rotatable = false
  },

  
 --- Electric Projectile
  {
    type = "projectile",
    name = "Electric-Projectile",
    flags = {"not-on-map"},
    acceleration = 0.05,
	force = "enemy",
    action =
    {
      type = "direct",
	  force = "enemy",
      action_delivery =
      {
        type = "instant",
		force = "enemy",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "ne_spark"
          },		  	  		  
          {
            type = "nested-result",
			force = "enemy",
            action =
            {
              type = "area",
			  force = "enemy",
              radius = 3,
              action_delivery =
              {
                type = "instant",
				force = "enemy",
                target_effects =
                  {
					type = "damage",
					force = "enemy",
					damage = {amount = 7*NE_Enemies.Settings.NE_Difficulty, type = "electric", force = "enemy"}
				  },
              }
            }
          }
        }
      }
    },
    animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-blue.png",
      line_length = 5,
      width = 16,
      height = 18,
      frame_count = 33,
      priority = "high"
    },
    shadow =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/acid-projectile-purple-shadow.png",
      line_length = 5,
      width = 28,
      height = 16,
      frame_count = 33,
      priority = "high",
      shift = {-0.09, 0.395}
    },
    rotatable = false
  },

  
})



--- Spitter Land Mine
local trigger_radius = 1
local damage_radius = 2
local damage_amount = 5

--- Land Mine
for i = 1, 20 do

local spitter_land_mine = util.table.deepcopy(data.raw["land-mine"]["land-mine"])
spitter_land_mine.name = "ne-spitter-land-mine-"..i
spitter_land_mine.icon = "__Natural_Evolution_Enemies__/graphics/icons/ne-spitter-land-mine.png"
spitter_land_mine.collision_box = {{-0,-0}, {0, 0}}
spitter_land_mine.collision_mask = {"not-colliding-with-itself"}
spitter_land_mine.minable = nil
spitter_land_mine.alert_when_damaged = false
spitter_land_mine.picture_safe.filename = "__Natural_Evolution_Enemies__/graphics/icons/ne-spitter-land-mine.png"
spitter_land_mine.picture_set.filename = "__Natural_Evolution_Enemies__/graphics/icons/ne-spitter-land-mine-set.png"
spitter_land_mine.picture_set_enemy.filename = "__Natural_Evolution_Enemies__/graphics/icons/ne-spitter-land-mine-set.png"
spitter_land_mine.order = "ne-land-mine-"..i
spitter_land_mine.localised_name = {"entity-name.ne-spitter-land-mine"}
spitter_land_mine.localised_description = {"entity-description.ne-spitter-land-mine"}
spitter_land_mine.corpse = "ne-acid-splash-purple"
spitter_land_mine.trigger_radius = trigger_radius
spitter_land_mine.action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "nested-result",
            affects_target = true,
            action =
            {
              type = "area",
              radius = damage_radius,
              force = "enemy",
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = { amount = damage_amount, type = "explosion", force = "enemy"}
                  },
				  {
					type = "damage",
					damage = { amount = math.floor(math.max(1,damage_amount/4)) , type = "physical"}
				  },
                }
              }
            }
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          },
          {
            type = "damage",
            damage = { amount = (damage_amount * NE_Enemies.Settings.NE_Difficulty * 2), type = "explosion", force = "enemy"}
          }
        }
      }
    }

trigger_radius = trigger_radius + 0.25 --- 1 to 5.75
damage_radius = damage_radius + 0.3 -- 2 to 7.7
damage_amount = damage_amount + 8 + NE_Enemies.Settings.NE_Difficulty -- 5 to 176 "Explosion" and 1 - 44 Physical

data:extend({spitter_land_mine})


---- Land Mine Projectile
	local my_new_mine_projectiles = util.table.deepcopy(data.raw["projectile"]["Mine-Projectile"])
	my_new_mine_projectiles.name = "Mine-Projectile-"..i
	my_new_mine_projectiles.action =
		{
		  type = "direct",
		  force = "enemy",
		  action_delivery =
		  {
			type = "instant",
			force = "enemy",
			target_effects =
			{
			  {
				type = "create-entity",
				entity_name = "ne-spitter-land-mine-"..i,
				trigger_created_entity = true,
			  },
			}
		  }
		}

data:extend({my_new_mine_projectiles})

end

--- NE File Flame
local my_new_fire_flame = util.table.deepcopy(data.raw["fire"]["fire-flame"])
my_new_fire_flame.name = "ne-fire-flame-2"
my_new_fire_flame.force = "enemy"
my_new_fire_flame.damage_per_tick = {amount = 5 / 60, type = "ne_fire", force = "enemy"}
my_new_fire_flame.initial_lifetime = 20
my_new_fire_flame.maximum_lifetime = 300
my_new_fire_flame.burnt_patch_lifetime = 200
my_new_fire_flame.emissions_per_second = 0
my_new_fire_flame.lifetime_increase_by = 50
my_new_fire_flame.smoke = {}


data:extend({my_new_fire_flame})

--- NE Fire Sticker
local my_new_fire_sticker = util.table.deepcopy(data.raw["sticker"]["fire-sticker"])
my_new_fire_sticker.name = "ne-fire-sticker-2"
my_new_fire_sticker.force = "enemy"
my_new_fire_sticker.duration_in_ticks = 10 * 60
my_new_fire_sticker.target_movement_modifier = 0.8
my_new_fire_sticker.damage_per_tick = { amount = 80 / 60, type = "ne_fire",force = "enemy" }
my_new_fire_sticker.spread_fire_entity = "fire-flame-on-tree"
my_new_fire_sticker.fire_spread_cooldown = 30
my_new_fire_sticker.fire_spread_radius = 0.75
	

data:extend({my_new_fire_sticker})

		
--- Unit Launcher Smoke that will cause the Trigger
Unit_Launcher_Trigger_1 = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
Unit_Launcher_Trigger_1.name = "ne_unit_launcher_trigger_1"
Unit_Launcher_Trigger_1.duration = 60 * 1
Unit_Launcher_Trigger_1.fade_away_duration = 0
Unit_Launcher_Trigger_1.spread_duration = 0
Unit_Launcher_Trigger_1.action = {
	type = "direct",
    action_delivery =
    {
       type = "instant",
        target_effects =
        {
            type = "create-entity",
			entity_name = "ne_green_splash_1",
			trigger_created_entity = true,
        },
      }
    }
Unit_Launcher_Trigger_1.slow_down_factor = 1
Unit_Launcher_Trigger_1.cyclic = true
Unit_Launcher_Trigger_1.color = { r = 0/255, g = 0/255, b = 0/255, a = 0}
Unit_Launcher_Trigger_1.animation =

    { -- No Animations
      filename = "__Natural_Evolution_Enemies__/graphics/entity/empty.png",
      flags = { "compressed" },
      priority = "low",
      width = 32,
      height = 32,
      frame_count = 1,
      animation_speed = 1,
      line_length = 1,
      scale = 1
    }

data:extend{Unit_Launcher_Trigger_1}

--- WORM Unit Launcher Smoke that will cause the Trigger
Worm_Launcher_Trigger_1 = table.deepcopy(data.raw["smoke-with-trigger"]["ne_unit_launcher_trigger_1"])
Worm_Launcher_Trigger_1.name = "ne_worm_launcher_trigger_1"
Worm_Launcher_Trigger_1.action = {
	type = "direct",
	force = "enemy",
    action_delivery =
    {
       type = "instant",
		force = "enemy",
        target_effects =
        {
            type = "create-entity",
			force = "enemy",
			entity_name = "ne_green_splash_2",
			trigger_created_entity = true,
        },
      }
    }

data:extend{Worm_Launcher_Trigger_1}


--- Unit Launcher Smoke that will cause the Trigger
Launcher_Web_Entity = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
Launcher_Web_Entity.name = "ne_web"
Launcher_Web_Entity.duration = 60 * 15
Launcher_Web_Entity.fade_away_duration = 0
Launcher_Web_Entity.spread_duration = 0
Launcher_Web_Entity.force = "enemy"
Launcher_Web_Entity.render_layer = "remnants"
Launcher_Web_Entity.collision_mask = {"not-colliding-with-itself"}
Launcher_Web_Entity.selectable_in_game = false
Launcher_Web_Entity.action = 
{
	  type = "direct",
	  force = "enemy",
      action_delivery =
      {
        type = "instant",
		force = "enemy",
        target_effects =
		{
          type = "nested-result",
		  force = "enemy",
          action =
          {
            type = "area",
			force = "enemy",
            radius = 5,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
			  force = "enemy",
              target_effects =
              {
                type = "damage",
                damage = { amount = 4, type = "poison", force = "enemy"}
              },

			  {
				type = "create-sticker",
				sticker = "slowdown-sticker"
			  },
            },
          },
        },
      },    
}
Launcher_Web_Entity.slow_down_factor = 4
Launcher_Web_Entity.cyclic = true
Launcher_Web_Entity.color = nil;
Launcher_Web_Entity.animation =
    {
      filename = "__Natural_Evolution_Enemies__/graphics/entity/web_visible.png",
      flags = {},
	  render_layer = "remnants",
      priority = "medium",
      width = 128,
      height = 128,
      frame_count = 1,
      animation_speed = 1,
      line_length = 1,
      scale = 1.5
    }
    
data:extend{Launcher_Web_Entity}



data:extend(
{
 {
    type = "corpse",
    name = "ne-acid-splash-purple",
    flags = {"not-on-map"},
    time_before_removed = 60 * 30,
    final_render_layer = "corpse",
    splash =
    {
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-1.png",
        line_length = 5,
        width = 199,
        height = 159,
        frame_count = 20,
        shift = {0.484375, -0.171875}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-2.png",
        line_length = 5,
        width = 238,
        height = 157,
        frame_count = 20,
        shift = {0.8125, -0.15625}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-3.png",
        line_length = 5,
        width = 240,
        height = 162,
        frame_count = 20,
        shift = {0.71875, -0.09375}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-4.png",
        line_length = 5,
        width = 241,
        height = 146,
        frame_count = 20,
        shift = {0.703125, -0.375}
      }
    },
    splash_speed = 0.03
  },
}
)

--- Splash Animations, used for triggers

--- Green Splash 1 - Units
Green_Splash = table.deepcopy(data.raw["corpse"]["ne-acid-splash-purple"])
Green_Splash.name = "ne_green_splash_1"
Green_Splash.time_before_removed = 60 * 15
Green_Splash.splash =
    {
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-1.png",
        line_length = 5,
        width = 199,
        height = 159,
        frame_count = 20,
		tint = {r = 0, g = 1, b = 0, a = 1},
        shift = {0.484375, -0.171875}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-2.png",
        line_length = 5,
        width = 238,
        height = 157,
        frame_count = 20,
		tint = {r = 0, g = 1, b = 0, a = 1},
        shift = {0.8125, -0.15625}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-3.png",
        line_length = 5,
        width = 240,
        height = 162,
        frame_count = 20,
		tint = {r = 0, g = 1, b = 0, a = 1},
        shift = {0.71875, -0.09375}
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/splash-4.png",
        line_length = 5,
        width = 241,
        height = 146,
        frame_count = 20,
		tint = {r = 0, g = 1, b = 0, a = 1},
        shift = {0.703125, -0.375}
      }
    }

data:extend{Green_Splash}



--- Green Splash 2 - Worms
Green_Splash_2 = table.deepcopy(data.raw["corpse"]["ne_green_splash_1"])
Green_Splash_2.name = "ne_green_splash_2"


data:extend{Green_Splash_2}


--- Spark

Spark_Splash = table.deepcopy(data.raw["corpse"]["ne-acid-splash-purple"])
Spark_Splash.name = "ne_spark"
Spark_Splash.time_before_removed = 60 * 0.5
Spark_Splash.splash =
    {
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/ne_spark_1.png",
        line_length = 4,
        width = 175,
        height = 190,
        frame_count = 16,
		scale = 0.5,
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/ne_spark_2.png",
        line_length = 4,
        width = 190,
        height = 175,
        frame_count = 16,
		scale = 0.5,
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/ne_spark_3.png",
        line_length = 4,
        width = 175,
        height = 190,
        frame_count = 16,
		scale = 0.5,
      },
      {
        filename = "__Natural_Evolution_Enemies__/graphics/entity/ne_spark_4.png",
        line_length = 4,
        width = 190,
        height = 175,
        frame_count = 16,
		scale = 0.5,
      },
    }

data:extend{Spark_Splash}





	
