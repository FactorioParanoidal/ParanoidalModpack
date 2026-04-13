-- Bosses and leviathan for ZombieHordeFaction
-- requires setting updates to not replace vanilla
-- v1.0   08/2024

if mods["ZombieHordeFaction"] then
local resistances = require(path.."prototypes/resistances")
local zgraph = "__ZombieHordeFaction__/graphics/"



-- The mod calling this may have globals
local boss_hp_multiplier  = mf_hp_multiplier or 1
local boss_dmg_multiplier = mf_boss_dmg_multiplier or 1


-- Boss nest
local boss_scale = 3.4
local boss_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-zombie-spawner"])
boss_spawner.name = "boss-zombie-spawner"
boss_spawner.max_health = 200000
boss_spawner.order='z-b-s'
boss_spawner.icons={{icon=boss_spawner.icon, icon_size=64, scale = 1.1},
					{icon="__base__/graphics/icons/signal/signal_B.png", scale = 0.4, shift={25,25}}}
boss_spawner.resistances = resistances.boss_fire_only
boss_spawner.healing_per_tick = 0.02
boss_spawner.max_count_of_owned_units = 600
boss_spawner.max_friends_around_to_spawn = 300
boss_spawner.collision_box = scale_box(boss_spawner.collision_box, boss_scale)
boss_spawner.selection_box = scale_box(boss_spawner.selection_box, boss_scale)
boss_spawner.map_generator_bounding_box = scale_box(boss_spawner.map_generator_bounding_box, boss_scale)
boss_spawner.spawning_radius = 40
boss_spawner.call_for_help_radius = 250
boss_spawner.corpse = "boss-zombie-spawner-corpse"
boss_spawner.dying_explosion = "blood-explosion-huge"
boss_spawner.loot = get_mf_Loot() 
boss_spawner.autoplace=nil
hack_scale(boss_spawner, boss_scale+1.5)
boss_spawner.result_units = {
                     	     {"small-spitter-zombie", {{0.0, 0.3}, {0.3, 0.0}}},
                     	     {"small-biter-zombie", {{0.0, 0.3}, {0.3, 0.0}}},
						     {"medium-spitter-zombie", {{0.1, 0.0}, {0.3, 0.3}, {0.35, 0.1}, {0.5, 0}}},
						     {"medium-biter-zombie", {{0.1, 0.0}, {0.3, 0.3}, {0.35, 0.1}, {0.5, 0}}},
						     {"big-spitter-zombie", {{0.25, 0.0}, {0.5, 0.4}, {0.7, 0}}},
						     {"big-biter-zombie", {{0.25, 0.0}, {0.5, 0.4}, {0.7, 0}}},
						     {"behemoth-spitter-zombie", {{0.45, 0.0}, {0.5, 0.3}, {0.8, 0}}},
						     {"behemoth-biter-zombie", {{0.45, 0.0}, {0.5, 0.3}, {0.8, 0}}},
						     {"abomination-spitter-zombie", {{0.5, 0.0}, {0.6, 0.05}, {0.9, 0}}},
						     {"abomination-biter-zombie", {{0.5, 0.0}, {0.6, 0.05}, {0.9, 0}}},
							 {"maf-boss-zombie-2", {{0.6, 0.0}, {0.7, 0.03}}},
							 {"maf-boss-zombie-4", {{0.7, 0.0}, {0.8, 0.03}}},
							 {"maf-boss-zombie-6", {{0.8, 0.0}, {0.9, 0.03}}},
							 {"maf-boss-zombie-8", {{0.9, 0.0}, {0.95, 0.03}}},
							 {"maf-boss-zombie-10", {{0.95, 0.0}, {1, 0.03}}}
							 }

							 
local spawner_corpse = table.deepcopy(data.raw["corpse"]["zombie-spawner-corpse"]) 	
	if spawner_corpse then 						 
	spawner_corpse.name = "boss-zombie-spawner-corpse"					 
	hack_scale(spawner_corpse, boss_scale+1.5)
	data:extend({boss_spawner, spawner_corpse})
	end


-- BOSSES UNIT
local function make_biter_area_damage(damage,radius)
return  {
					type = "area",
					radius = radius,
					force = "enemy",
					ignore_collision_condition = true,
					action_delivery =
					{
					  type = "instant",
					  target_effects =
					  {
						{
						  type = "damage",
						  damage = {amount = damage, type = "physical"}
						},
						{
						type = "create-particle",
						repeat_count = 5,
						particle_name = "explosion-remnants-particle",
						initial_height = 0.5,
						speed_from_center = 0.08,
						speed_from_center_deviation = 0.15,
						initial_vertical_speed = 0.08,
						initial_vertical_speed_deviation = 0.15,
						offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
						},
					  }
					}
                   }
end


local function get_z_resist(k)
	local base_resist = 20+k*2
	local resistances =  
    {
      {
        type = "physical",
        decrease = k,
        percent = base_resist,
      },
      {
        type = "explosion",
        decrease = k,
        percent = base_resist,
      },
      {
        type = "laser",
        percent = base_resist + 50,
      },
      {
        type = "impact",
        percent = base_resist,
      },

      {
        type = "fire",
        percent = -50-k,
      },
      {
        type = "electric",
        percent = base_resist + 50,
      },
      {
        type = "poison",
        percent = 100,
      },
      {
        type = "acid",
        percent = 100,
      },
    }
	return resistances
	end

	local function make_zombie_boss(k)
		local scale = 1.2 + k/5
		local zombie = table.deepcopy(data.raw.unit["behemoth-biter-zombie"])
		hack_scale(zombie, scale)
		zombie.name="maf-boss-zombie-"..k
		zombie.icons={{icon=zgraph.."icons/zombie-behemoth.png", icon_size=64, tint={r=0.1,g=0.9,b=0.9}, scale = 1.1},
						{icon="__base__/graphics/icons/signal/signal_B.png", icon_size=64, scale = 0.4, shift={25,25}}}
		zombie.order='b-a-k'..k				
		zombie.localised_name =  {"",{"entity-name.maf-boss-zombie"}," ",tostring(k)}
		zombie.max_health = 100000 * k * boss_hp_multiplier
		zombie.vision_distance = 50
		zombie.call_for_help_radius = 100+k*6
		zombie.resistances = get_z_resist(k)
		zombie.absorptions_to_join_attack = { pollution = 100 }
		zombie.ai_settings = {destroy_when_commands_fail = false}
		zombie.attack_parameters.range = 2+k/3
		zombie.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount = (300+k*50 * boss_dmg_multiplier)
		table.insert (zombie.attack_parameters.ammo_type, make_biter_area_damage((100+k*30)* boss_dmg_multiplier,(k+2)/2)     )
		zombie.attack_parameters.animation.layers[2].tint=colors.cyan
		zombie.run_animation.layers[2].tint=colors.cyan
		zombie.loot = get_mf_Loot()
		
		local corpse = table.deepcopy(data.raw.corpse[zombie.corpse])
		corpse.name=zombie.name .. "-corpse"
		corpse.localised_name =  {"",zombie.localised_name," corpse"}
		hack_scale(corpse, scale)

		zombie.corpse=corpse.name
		data:extend({zombie,corpse})
		end


for k=1, 10 do make_zombie_boss(k) end



--leviathan/abomination
	local scale=1.1
	local zombie = table.deepcopy(data.raw.unit["behemoth-biter-zombie"])
	hack_scale(zombie, scale)
	zombie.name="abomination-biter-zombie"
	zombie.order='b-a-e'	
	zombie.icons={{icon=zgraph.."icons/zombie-medium.png", icon_size=64, tint={r=0.9,g=0.2,b=0.9}, scale = 1.1}}
	zombie.max_health = 80000 
	zombie.vision_distance = 50
	zombie.call_for_help_radius = 100	
	zombie.resistances = get_z_resist(1)
	zombie.absorptions_to_join_attack = { pollution = 100 }
	zombie.attack_parameters.range = 2
	zombie.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount = 100 * boss_dmg_multiplier
	table.insert (zombie.attack_parameters.ammo_type, make_biter_area_damage(100*boss_dmg_multiplier,2) )
		zombie.attack_parameters.animation.layers[2].tint=colors.purple
		zombie.run_animation.layers[2].tint=colors.purple
	local corpse = table.deepcopy(data.raw.corpse[zombie.corpse])
	corpse.name=zombie.name .. "-corpse"
	corpse.localised_name =  {"","entity-name.abomination-biter-zombie", " corpse"}
	hack_scale(corpse, scale)
	zombie.corpse=corpse.name
	data:extend({zombie,corpse})
	
	data.raw["unit-spawner"]["biter-zombie-spawner"].result_units[5] = {"abomination-biter-zombie", {{0.95, 0.0}, {1.0, 0.035}}}



--leviathan/abomination
	local zombie = table.deepcopy(data.raw.unit["behemoth-spitter-zombie"])
	hack_scale(zombie, scale)
	zombie.name="abomination-spitter-zombie"
	zombie.order='b-b-e'	
	zombie.icons={{icon=zgraph.."icons/zombie-medium.png", icon_size=64, tint={r=0.9,g=0.2,b=0.9}, scale = 1.1}}
	zombie.max_health = 60000 
	zombie.vision_distance = 50
	zombie.call_for_help_radius = 100	
	zombie.resistances = get_z_resist(1)
	zombie.absorptions_to_join_attack = { pollution = 100 }
	zombie.attack_parameters.range = 22
	zombie.attack_parameters.min_attack_distance =11
	zombie.attack_parameters.damage_modifier = 90 * boss_dmg_multiplier
    zombie.attack_parameters.ooldown=100
	zombie.attack_parameters.cooldown_deviation = 0.15
		zombie.attack_parameters.animation.layers[2].tint=colors.purple
		zombie.run_animation.layers[2].tint=colors.purple
	local corpse = table.deepcopy(data.raw.corpse[zombie.corpse])
	corpse.name=zombie.name .. "-corpse"
	corpse.localised_name =  {"","entity-name.abomination-spitter-zombie", " corpse"}
	hack_scale(corpse, scale)
	zombie.corpse=corpse.name
	data:extend({zombie,corpse})
	
	data.raw["unit-spawner"]["spitter-zombie-spawner"].result_units[5] = {"abomination-spitter-zombie", {{0.95, 0.0}, {1.0, 0.035}}}


end