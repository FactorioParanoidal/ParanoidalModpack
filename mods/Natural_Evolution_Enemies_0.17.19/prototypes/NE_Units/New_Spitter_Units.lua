
require ("prototypes.NE_Units.Projectiles")

local ne_collision_box = {}
local c1 = 0.0375

local ne_spitter_selection_box = {}
local ss1 = 0.4
local ss2 = 0.2
local ss3 = 0.2
local ss4 = 1.0

local ne_spitter_drawing_box = {}

local ne_scale = {}
local scale = 0.1825

---- Health
local ne_spitter_health = {}
local health_scale = 105 - (NE_Enemies.Settings.NE_Difficulty * 5)


--- Attack Range
local attack_range = 8  -- 8.5 to 18
local damage_modifier = 0.175 -- 0.5 to 6.675

local pollution_attack_increment = 1

--- BASE Spitter Unit
	NE_Base_Spitter_Unit = table.deepcopy(data.raw.unit["small-spitter"])
    NE_Base_Spitter_Unit.name = "ne-spitter-base-unit"
    NE_Base_Spitter_Unit.max_health = 5
	NE_Base_Spitter_Unit.alert_when_damaged = false 
	NE_Base_Spitter_Unit.alert_when_attacking = false
	NE_Base_Spitter_Unit.resistances = {}
	NE_Base_Spitter_Unit.loot = {}
    
	data:extend{NE_Base_Spitter_Unit}

		
------------------------------------------------------------------------------------------

	

for i = 1, 20 do

	
	-- Collision Box
	table.insert(ne_collision_box, {{-(c1), -(c1)}, {(c1), (c1)}})	
	c1 = c1 + 0.0125 --- from 0.05 to 0.3
	
	-- Selection Box
	table.insert(ne_spitter_selection_box, {{-(ss1), -(ss2)}, {(ss3), (ss4)}})	
	ss1 = ss1 + 0.05 --- from 0.4 to 1.4
	ss2 = ss2 + 0.185 --- from 0.1 to 3.8 
	ss3 = ss3 + 0.09 --- from 0.2 to 2
	ss4 = ss4 + 0.03 --- from 1.0 to 1.6
	
	-- Drawing Box
	table.insert(ne_spitter_drawing_box, {{-(ss1+0.5), -(ss2+0.5)}, {(ss3+0.5), (ss4+0.5)}})
	
	-- Scale
	table.insert(ne_scale, scale)
	scale = scale + 0.0675 -- from 0.25 to 1.6
	
	-- Spitter Health
	health_2000_max = ((health_scale - i) / health_scale)*(1.462355 ^ i) + ((i/health_scale)*(100 * i)) -- 2,000 health
	health_3000_max = ((health_scale - i) / health_scale)*(1.492300 ^ i) + ((i/health_scale)*(150 * i)) -- 3,000 health

	if settings.startup["NE_Challenge_Mode"].value == true then
	
		table.insert(ne_spitter_health, health_3000_max)

	else
	
		table.insert(ne_spitter_health, health_2000_max)
	
	end

	-- Loot - Only apply is Leet is enabled.
	if settings.startup["NE_Alien_Artifacts"].value == true then
		ne_loot = 
			{
				{
				  item = "small-alien-artifact",
				  probability = 1/NE_Enemies.Settings.NE_Difficulty,
				  count_min = math.floor(math.max(1,i/4)),
				  count_max = math.floor(math.max(2,i/3))
				}
			}
	else
		ne_loot = {}
	end
	

	attack_range = attack_range + 0.4 + (NE_Enemies.Settings.NE_Difficulty / 10) -- 8.5 to 18
	damage_modifier = damage_modifier + 0.125 + (NE_Enemies.Settings.NE_Difficulty / 5) -- 0.5 to 6.675
	
	
	
	pollution_attack_increment = math.floor((((100 - i) / 100)*(1.3645 ^ i) + ((i/100)*(50 * i)) * 2) / 3)  
	if pollution_attack_increment <= 2 then pollution_attack_increment = 2 end	
------------------------- Units --------------------
	
	------ SPITTERS
	---- Breeder Spitter
	NE_Spitter_Breeder_Unit = table.deepcopy(data.raw.unit["ne-spitter-base-unit"])
    NE_Spitter_Breeder_Unit.name = "ne-spitter-breeder-" .. i
	NE_Spitter_Breeder_Unit.collision_box = ne_collision_box[i]
	NE_Spitter_Breeder_Unit.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Breeder_Unit.drawing_box = ne_spitter_drawing_box[i]
    NE_Spitter_Breeder_Unit.max_health = ne_spitter_health[i]
    NE_Spitter_Breeder_Unit.loot = ne_loot
	NE_Spitter_Breeder_Unit.resistances = {{type = "electric", percent = 100}} -- Immune to Electric Damage
	NE_Spitter_Breeder_Unit.corpse = "ne-spitter-breeder-corpse-" .. i
	NE_Spitter_Breeder_Unit.attack_parameters = Spitter_Attack_Projectile_NH(
						{
							range = attack_range - 0.5, -- slightly less of an attack range
                            cooldown = 80,
                            damage_modifier = damage_modifier,
                            scale = ne_scale[i],
                            tint1 = ne_blue_tint2,
							tint2 = ne_blue_tint1,
                            roarvolume = i/25 + 0.2,
							projectile = "Electric-Projectile" 
						})
	NE_Spitter_Breeder_Unit.run_animation = spitterrunanimation(ne_scale[i], ne_blue_tint2, ne_blue_tint1)
    NE_Spitter_Breeder_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Spitter_Breeder_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.18)
    NE_Spitter_Breeder_Unit.working_sound =  make_biter_calls(i/25 + 0.08)
	NE_Spitter_Breeder_Unit.localised_description = {"entity-description.ne-spitter-breeder"} 
    
	data:extend{NE_Spitter_Breeder_Unit}

	
	---- Fire Spitter
	NE_Spitter_Fire_Unit = table.deepcopy(data.raw.unit["ne-spitter-base-unit"])
    NE_Spitter_Fire_Unit.name = "ne-spitter-fire-" .. i
	NE_Spitter_Fire_Unit.collision_box = ne_collision_box[i]
	NE_Spitter_Fire_Unit.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Fire_Unit.drawing_box = ne_spitter_drawing_box[i]
    NE_Spitter_Fire_Unit.max_health = ne_spitter_health[i]
    NE_Spitter_Fire_Unit.loot = ne_loot
	NE_Spitter_Fire_Unit.resistances = {{type = "fire", percent = 100}} --- Immune to Fire Damage
	NE_Spitter_Fire_Unit.corpse = "ne-spitter-fire-corpse-" .. i
	NE_Spitter_Fire_Unit.attack_parameters = Spitter_Attack_Stream(
						{
							range = attack_range + 1, -- slightly higher of an attack range,
                            cooldown = 110,
                            damage_modifier = damage_modifier,
                            scale = ne_scale[i],
                            tint1 = ne_fire_tint,
							tint2 = ne_fire_tint2,
                            roarvolume = i/25 + 0.2,
						})
	NE_Spitter_Fire_Unit.run_animation = spitterrunanimation(ne_scale[i], ne_fire_tint, ne_fire_tint2)
    NE_Spitter_Fire_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Spitter_Fire_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.18)
    NE_Spitter_Fire_Unit.working_sound =  make_biter_calls(i/25 + 0.08)
	NE_Spitter_Fire_Unit.localised_description = {"entity-description.ne-spitter-fire"} 
    
	data:extend{NE_Spitter_Fire_Unit}
	

		
	---- Unit Launcher Spitter (Green)
	NE_Spitter_ULaunch_Unit = table.deepcopy(data.raw.unit["ne-spitter-base-unit"])
    NE_Spitter_ULaunch_Unit.name = "ne-spitter-ulaunch-" .. i
	NE_Spitter_ULaunch_Unit.collision_box = ne_collision_box[i]
	NE_Spitter_ULaunch_Unit.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_ULaunch_Unit.drawing_box = ne_spitter_drawing_box[i]
    NE_Spitter_ULaunch_Unit.max_health = ne_spitter_health[i]
    NE_Spitter_ULaunch_Unit.loot = ne_loot
	NE_Spitter_ULaunch_Unit.resistances = {{type = "acid", percent = 100}} -- Immune to Acid Damage
	NE_Spitter_ULaunch_Unit.corpse = "ne-spitter-ulaunch-corpse-" .. i
	NE_Spitter_ULaunch_Unit.attack_parameters = Spitter_Attack_Projectile(
						{
							range = attack_range - 1, -- slightly less of an attack range,,
                            cooldown = 120,
                            damage_modifier = damage_modifier,
                            scale = ne_scale[i],
                            tint1 = ne_green_tint2,
							tint2 = ne_green_tint,
                            roarvolume = i/25 + 0.2,
							projectile = "Unit-Projectile"
						})
	NE_Spitter_ULaunch_Unit.run_animation = spitterrunanimation(ne_scale[i], ne_green_tint2, ne_green_tint)
    NE_Spitter_ULaunch_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Spitter_ULaunch_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.18)
    NE_Spitter_ULaunch_Unit.working_sound =  make_biter_calls(i/25 + 0.08)
	NE_Spitter_ULaunch_Unit.localised_description = {"entity-description.ne-spitter-ulaunch"} 
    
	data:extend{NE_Spitter_ULaunch_Unit}

		
	---- Web Shooter  (Yellow)
	NE_Spitter_Webshooter = table.deepcopy(data.raw.unit["ne-spitter-base-unit"])
    NE_Spitter_Webshooter.name = "ne-spitter-webshooter-" .. i
	NE_Spitter_Webshooter.collision_box = ne_collision_box[i]
	NE_Spitter_Webshooter.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Webshooter.drawing_box = ne_spitter_drawing_box[i]
    NE_Spitter_Webshooter.max_health = ne_spitter_health[i]
    NE_Spitter_Webshooter.loot = ne_loot
	NE_Spitter_Webshooter.resistances = {{type = "poison", percent = 100}} --- Immune to Posion Damage
	NE_Spitter_Webshooter.corpse = "ne-spitter-webshooter-corpse-" .. i
	NE_Spitter_Webshooter.attack_parameters = Spitter_Attack_Projectile_NH(
						{
							range = attack_range,
                            cooldown = 100,
                            damage_modifier = damage_modifier,
                            scale = ne_scale[i],
                            tint1 = ne_orange_tint,
							tint2 = ne_yellow_tint2,
                            roarvolume = i/25 + 0.2,
							projectile = "Web-Projectile"
						})
	NE_Spitter_Webshooter.run_animation = spitterrunanimation(ne_scale[i], ne_orange_tint, ne_yellow_tint2)
    NE_Spitter_Webshooter.pollution_to_join_attack = pollution_attack_increment
	NE_Spitter_Webshooter.dying_sound =  make_biter_dying_sounds(i/25 + 0.18)
    NE_Spitter_Webshooter.working_sound =  make_biter_calls(i/25 + 0.08)
	NE_Spitter_Webshooter.localised_description = {"entity-description.ne-spitter-webshooter"}     
	
	data:extend{NE_Spitter_Webshooter}
	
	
	---- Mine Spitter (Pink)
	NE_Spitter_Mine_Unit = table.deepcopy(data.raw.unit["ne-spitter-base-unit"])
    NE_Spitter_Mine_Unit.name = "ne-spitter-mine-" .. i
	NE_Spitter_Mine_Unit.collision_box = ne_collision_box[i]
	NE_Spitter_Mine_Unit.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Mine_Unit.drawing_box = ne_spitter_drawing_box[i]
    NE_Spitter_Mine_Unit.max_health = ne_spitter_health[i]
    NE_Spitter_Mine_Unit.loot = ne_loot
	NE_Spitter_Mine_Unit.resistances = {{type = "explosion", percent = 100}, {type = "laser", percent = i * 2}} --- Immune to Explosion damage, higher Laser
	NE_Spitter_Mine_Unit.corpse = "ne-spitter-mine-corpse-" .. i
	NE_Spitter_Mine_Unit.attack_parameters = Spitter_Attack_Projectile(
						{
							range = attack_range - 1, -- slightly less of an attack range
                            cooldown = 100,
                            damage_modifier = damage_modifier,
                            scale = ne_scale[i],
                            tint1 = ne_pink_tint,
							tint2 = ne_black_tint,
                            roarvolume = i/25 + 0.2,
							projectile = "Mine-Projectile-"..i
						})
	NE_Spitter_Mine_Unit.run_animation = spitterrunanimation(ne_scale[i], ne_pink_tint, ne_black_tint)
    NE_Spitter_Mine_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Spitter_Mine_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.18)
    NE_Spitter_Mine_Unit.working_sound =  make_biter_calls(i/25 + 0.08)
	NE_Spitter_Mine_Unit.localised_description = {"entity-description.ne-spitter-mine"}     
	
	data:extend{NE_Spitter_Mine_Unit}

	
	--------------------------------------
	
	
	--- Spitters Corpses
	---- Breeder Spitter


	NE_Spitter_Breeder_Unit_Corpse = table.deepcopy(data.raw.corpse["small-spitter-corpse"])
    NE_Spitter_Breeder_Unit_Corpse.name = "ne-spitter-breeder-corpse-" .. i
	NE_Spitter_Breeder_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Spitter_Breeder_Unit_Corpse.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Breeder_Unit_Corpse.animation = spitterdyinganimation(ne_scale[i], ne_blue_tint2)
    NE_Spitter_Breeder_Unit_Corpse.localised_name = {"entity-name.ne-spitter-breeder-corpse"}
    
	data:extend{NE_Spitter_Breeder_Unit_Corpse}

	
	---- Fire Spitter
	NE_Spitter_Fire_Unit_Corpse = table.deepcopy(data.raw.corpse["small-spitter-corpse"])
    NE_Spitter_Fire_Unit_Corpse.name = "ne-spitter-fire-corpse-" .. i
	NE_Spitter_Fire_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Spitter_Fire_Unit_Corpse.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Fire_Unit_Corpse.animation = spitterdyinganimation(ne_scale[i], ne_fire_tint)
    NE_Spitter_Fire_Unit_Corpse.localised_name = {"entity-name.ne-spitter-fire-corpse"}   
	
	data:extend{NE_Spitter_Fire_Unit_Corpse}

	
	---- Unit Launcher Spitter
	NE_Spitter_ULaunch_Unit_Corpse = table.deepcopy(data.raw.corpse["small-spitter-corpse"])
    NE_Spitter_ULaunch_Unit_Corpse.name = "ne-spitter-ulaunch-corpse-" .. i
	NE_Spitter_ULaunch_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Spitter_ULaunch_Unit_Corpse.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_ULaunch_Unit_Corpse.animation = spitterdyinganimation(ne_scale[i], ne_green_tint)
    NE_Spitter_ULaunch_Unit_Corpse.localised_name = {"entity-name.ne-spitter-ulaunch-corpse"}  
	
	data:extend{NE_Spitter_ULaunch_Unit_Corpse}

	
	---- Unit Launcher Spitter
	NE_Spitter_Webshooter_Corpse = table.deepcopy(data.raw.corpse["small-spitter-corpse"])
    NE_Spitter_Webshooter_Corpse.name = "ne-spitter-webshooter-corpse-" .. i
	NE_Spitter_Webshooter_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Spitter_Webshooter_Corpse.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Webshooter_Corpse.animation = spitterdyinganimation(ne_scale[i], ne_yellow_tint)
    NE_Spitter_Webshooter_Corpse.localised_name = {"entity-name.ne-spitter-webshooter-corpse"}  
    
	data:extend{NE_Spitter_Webshooter_Corpse}

	
	---- Mine Spitter
	NE_Spitter_Mine_Unit_Corpse = table.deepcopy(data.raw.corpse["small-spitter-corpse"])
    NE_Spitter_Mine_Unit_Corpse.name = "ne-spitter-mine-corpse-" .. i
	NE_Spitter_Mine_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Spitter_Mine_Unit_Corpse.selection_box = ne_spitter_selection_box[i]
	NE_Spitter_Mine_Unit_Corpse.animation = spitterdyinganimation(ne_scale[i], ne_pink_tint)
    NE_Spitter_Mine_Unit_Corpse.localised_name = {"entity-name.ne-spitter-mine-corpse"}  
    
	data:extend{NE_Spitter_Mine_Unit_Corpse}



end




  
