
if mods["space-age"] then
--local util = require('util')
require("__space-age__.prototypes.entity.gleba-enemy-animations")
require("sound-util")

--[[
	{"small-wriggler-pentapod", {{0.0, 0.4}, {0.3, 0.4}, {0.35, 0}}},
	{"small-strafer-pentapod", {{0.0, 0.4}, {0.3, 0.4}, {0.35, 0}}},  --spider-unit
	{"small-stomper-pentapod", {{0.0, 0.2}, {0.3, 0.2}, {0.35, 0}}},  --spider-unit
	{"medium-wriggler-pentapod", {{0.3, 0}, {0.35, 0.4}, {0.6, 0.4}, {0.65, 0}}},
	{"medium-strafer-pentapod", {{0.3, 0}, {0.35, 0.4}, {0.6, 0.4}, {0.65, 0}}},
	{"medium-stomper-pentapod", {{0.3, 0}, {0.35, 0.2}, {0.6, 0.2}, {0.65, 0}}},
	{"big-wriggler-pentapod", {{0.6, 0}, {0.65, 0.4}, {1, 0.4}}},
	{"big-strafer-pentapod", {{0.6, 0}, {0.65, 0.4}, {1, 0.4}}},
	{"big-stomper-pentapod", {{0.6, 0}, {0.65, 0.2}, {1, 0.2}}},
]]

-- makes gleba enemies variants to attack to nauvis (pollution)
function make_bm_gleba_spawner(name,spawns_mp)
	local gleba_spawner = table.deepcopy( data.raw["unit-spawner"][name])
	gleba_spawner.name  = "mf-"..name
	gleba_spawner.localised_name = {"entity-name."..name}
	gleba_spawner.absorptions_per_second = gleba_spawner.absorptions_per_second or {}
	gleba_spawner.absorptions_per_second.pollution = { absolute = 4, proportional = 0.002 }
	gleba_spawner.max_count_of_owned_units = gleba_spawner.max_count_of_owned_units*spawns_mp  --no no ... extreme crazy! or maybe... yes... =]
	gleba_spawner.max_friends_around_to_spawn = gleba_spawner.max_friends_around_to_spawn*spawns_mp
	gleba_spawner.collision_mask =nil
	gleba_spawner.loot = get_mf_loot_rpg_potion()
	for r,ru in pairs(gleba_spawner.result_units) do
		local uname = ru[1]
		local unit
		if data.raw.unit[uname] then unit=table.deepcopy (data.raw.unit[uname]) 
			else unit=table.deepcopy (data.raw["spider-unit"][uname]) end
		unit.name= "bm-"..uname
		unit.localised_name = {"entity-name."..uname}
		unit.max_health = unit.max_health * mf_hp_multiplier
		unit.absorptions_to_join_attack.pollution = unit.absorptions_to_join_attack.spores
		data:extend{unit}
		ru[1] = unit.name
		end
	data:extend({gleba_spawner})
end
make_bm_gleba_spawner("gleba-spawner-small",2)
make_bm_gleba_spawner("gleba-spawner",1)



local space_age_sounds = require("__space-age__.prototypes.entity.sounds")	
--local tint = {r=0.8,g=0.5,b=0.0,a=0.5}

function make_alienpod_projectile(name,create_entity,scale,tint)
	data:extend({
		{
		  type = "projectile",
		  name = name,
		  hidden = true,
		  flags = {"not-on-map"},
		  acceleration = 0.002,
		  turn_speed = 0.002,
		  max_speed = 1,
		  turning_speed_increases_exponentially_with_projectile_speed = true,
		  --hit_collision_mask = {layers={player=true, train=true, is_object=true}, not_colliding_with_itself=true},
		  --force_condition = "not-friend", --don't hit allies or trees, rocks, etc
		  action =
		  {
			type = "direct",
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {
				{
					type = "play-sound",
					sound = space_age_sounds.strafer_pentapod.big.projectile_impact,
				  },
				  {
					type = "create-entity",
					entity_name = "behemoth-spitter-die"
				  },
				  {
					type = "create-entity",
					entity_name = create_entity, --check_buildability = false,
					find_non_colliding_position = true
				  }				  
			  }
			}
		  },
		  animation =
		  {
			layers = {
			  util.sprite_load("__space-age__/graphics/entity/wriggler/wriggler-projectile",
			  {
				frame_count = 4,
				scale = 0.36 * scale,
				tint_as_overlay = true,
				rotate_shift = true,
				--tint = tint_projectile
			  }),
			 util.sprite_load("__space-age__/graphics/entity/wriggler/wriggler-projectile-tint",
			  {
				frame_count = 4,
				scale = 0.36 * scale,
				tint_as_overlay = true,
				rotate_shift = true,
				tint = tint
			  })
			}
		  },
		  shadow = util.sprite_load("__space-age__/graphics/entity/wriggler/wriggler-projectile",
		  {
			frame_count = 4,
			scale = 0.36 * scale,
			rotate_shift = true,
			draw_as_shadow = true
		  }),
		  smoke =
		  {
			{
			  name = "smoke-fast",
			  deviation = {0.15, 0.15},
			  frequency = 1,
			  position = {0, 1},
			  starting_frame = 3,
			  starting_frame_deviation = 5
			}
		  },
		}
	})
end
make_alienpod_projectile("mf_alienpod_arrival_projectile_1","mf-gleba-spawner-small",3)
make_alienpod_projectile("mf_alienpod_arrival_projectile_2","mf-gleba-spawner",4,{r=1,g=0,b=0.2})




-- BIG ONES? TODO...
--[[
function make_strafer(name,scale,tint1,tint2,health)
local strafer = table.deepcopy(data.raw["spider-unit"]["big-strafer-pentapod"])
strafer.name = name
strafer.max_health = health * mf_hp_multiplier
strafer.selection_box = scale_box(strafer.selection_box, scale)
strafer.vision_distance = 90
local gs=strafer.graphics_set
gs.animation.layers[1].tint  = tint1
gs.animation.layers[2].tint  = tint2
gs.animation.layers[1].scale = gs.animation.layers[1].scale*scale
gs.animation.layers[2].scale = gs.animation.layers[2].scale*scale
gs.base_animation.layers[1].scale = gs.base_animation.layers[1].scale * scale
gs.base_animation.layers[2].scale = gs.base_animation.layers[2].scale * scale
gs.shadow_animation.scale = gs.shadow_animation.scale * scale
gs.shadow_base_animation.scale = gs.shadow_base_animation.scale * scale
--gs.water_reflection.scale = gs.water_reflection.scale * scale
--??	base_animation.layers[1].tint = torso_main
--	base_animation.layers[1].tint = torso_main
data:extend({strafer})
end
make_strafer("BOSS-strafer-pentapod",2,colors.red,colors.blue,5000)
]]


end