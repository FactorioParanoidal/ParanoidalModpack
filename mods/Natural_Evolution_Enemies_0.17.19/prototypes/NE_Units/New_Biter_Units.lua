

local ne_collision_box = {}
local c1 = 0.0325

local ne_biter_selection_box = {}
local bs1 = 0.225
local bs2 = 0.35
local bs3 = 0.675

local ne_biter_drawing_box = {}

local ne_scale = {}
local scale = 0.1825

---- Health
local ne_tank_health = {}
local ne_biter_health = {}
local health_scale = 105 - (NE_Enemies.Settings.NE_Difficulty * 5)

--- Attack Range
local attack_range = 0.4375  -- 0.5 to 1.75
local damage_modifier = 0.8 + (NE_Enemies.Settings.NE_Difficulty / 5)

local pollution_attack_increment = 1


--- BASE Biter Unit
	NE_Base_Biter_Unit = table.deepcopy(data.raw.unit["small-biter"])
    NE_Base_Biter_Unit.name = "ne-biter-base-unit"
    NE_Base_Biter_Unit.max_health = 5
	NE_Base_Biter_Unit.alert_when_damaged = false 
	NE_Base_Biter_Unit.alert_when_attacking = false
	NE_Base_Biter_Unit.resistances = {}
	NE_Base_Biter_Unit.loot = {}
    
	data:extend{NE_Base_Biter_Unit}

------------------------------------------------------------------------------------------
--- Create 20 Levels of each Enemy
for i = 1, 20 do

	-- Collision Box
	table.insert(ne_collision_box, {{-(c1), -(c1)}, {(c1), (c1)}})	
	c1 = c1 + 0.0175 -- from 0.05 to 0.4
	
	
	-- Selection Box
	table.insert(ne_biter_selection_box, {{-(bs1), -(bs2)}, {(bs3), (0.4)}})	
	bs1 = bs1 + 0.115 -- from 0.2 to 2.5 
	bs2 = bs2 + 0.1225 -- from 0.35 to 2.8
	bs3 = bs3 + 0.105 -- from 0.7 to 2.8
	
	-- Drawing Box
	table.insert(ne_biter_drawing_box, {{-(bs1+0.5), -(bs2+0.5)}, {(bs3+0.5), (0.4+0.5)}})		
	
	-- Scale
	table.insert(ne_scale, scale)
	scale = scale + 0.0675 -- from 0.25 to 1.6
		
	-- Health
	
	-- Biter Health
	health_3000_max = ((health_scale - i) / health_scale)*(1.492300 ^ i) + ((i/health_scale)*(150 * i)) -- 3,000 health
	health_4000_max = ((health_scale - i) / health_scale)*(1.513921 ^ i) + ((i/health_scale)*(200 * i)) -- 4,000 health
	health_5000_max = ((health_scale - i) / health_scale)*(1.530909 ^ i) + ((i/health_scale)*(250 * i)) -- 5,000 health
	health_6500_max = ((health_scale - i) / health_scale)*(1.551129 ^ i) + ((i/health_scale)*(325 * i)) -- 6,500 health
	
	if settings.startup["NE_Challenge_Mode"].value == true then
	
		table.insert(ne_tank_health, health_6500_max)
		table.insert(ne_biter_health, health_4000_max)

	else
	
		table.insert(ne_tank_health, health_5000_max)
		table.insert(ne_biter_health, health_3000_max)
	
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
	
	attack_range = attack_range + 0.0625  -- 0.5 to 1.75
	
	pollution_attack_increment = math.floor((((100 - i) / 100)*(1.3645 ^ i) + ((i/100)*(100 * i)) * 2) / 3)  
	if pollution_attack_increment <= 2 then pollution_attack_increment = 2 end
	
------------------------- Units --------------------

	--- Breeder Biter (Spwans Units on Death)
	NE_Biter_Breeder_Unit = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_Breeder_Unit.name = "ne-biter-breeder-" .. i
	NE_Biter_Breeder_Unit.collision_box = ne_collision_box[i]
	NE_Biter_Breeder_Unit.selection_box = ne_biter_selection_box[i]
	NE_Biter_Breeder_Unit.drawing_box = ne_biter_drawing_box[i]
    NE_Biter_Breeder_Unit.max_health = ne_biter_health[i]
	NE_Biter_Breeder_Unit.loot = ne_loot
	NE_Biter_Breeder_Unit.resistances = {{type = "physical", percent = i * 2}} -- High Physical resistances
	NE_Biter_Breeder_Unit.corpse = "ne-biter-breeder-corpse-" .. i
	NE_Biter_Breeder_Unit.attack_parameters = NE_Biter_Melee_Single_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "physical",
                            scale = ne_scale[i],
                            tint1 = ne_blue_tint2,
							tint2 = ne_blue_tint1,
							sound = i/25 + 0.1
						})
	NE_Biter_Breeder_Unit.run_animation = biterrunanimation(ne_scale[i], ne_blue_tint2, ne_blue_tint1)
	NE_Biter_Breeder_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_Breeder_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_Breeder_Unit.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_Breeder_Unit.localised_description = {"entity-description.ne-biter-breeder"}
    
	data:extend{NE_Biter_Breeder_Unit}

	
	--- Fire Biter (Explodes) Fire Attack, Resistant to Fire
	NE_Biter_Fire_Unit = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_Fire_Unit.name = "ne-biter-fire-" .. i
	NE_Biter_Fire_Unit.collision_box = ne_collision_box[i]
	NE_Biter_Fire_Unit.selection_box = ne_biter_selection_box[i]
	NE_Biter_Fire_Unit.drawing_box = ne_biter_drawing_box[i]
    NE_Biter_Fire_Unit.max_health = ne_biter_health[i]
	NE_Biter_Fire_Unit.loot = ne_loot
	NE_Biter_Fire_Unit.resistances = {{type = "fire", percent = 100}} -- Immune to Fire Damage
	NE_Biter_Fire_Unit.corpse = "ne-biter-fire-corpse-" .. i
	NE_Biter_Fire_Unit.attack_parameters = NE_Biter_Melee_Tripple_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "fire",
                            damage_amount_2 = i,
							damage_type_2 = "ne_fire",
							damage_amount_3 = i/4, -- to prevent stailmate
							damage_type_3 = "physical",
                            scale = ne_scale[i],
                            tint1 = ne_fire_tint2,
							tint2 = ne_fire_tint,
							sound = i/25 + 0.1
						})	
	NE_Biter_Fire_Unit.run_animation = biterrunanimation(ne_scale[i], ne_fire_tint2, ne_fire_tint)
    NE_Biter_Fire_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_Fire_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_Fire_Unit.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_Fire_Unit.localised_description = {"entity-description.ne-biter-fire"}
	
	data:extend{NE_Biter_Fire_Unit}

		
	--- Fast Biter (Green) -- Fast, Immune to Acid Damage
	NE_Biter_Fast_Unit = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_Fast_Unit.name = "ne-biter-fast-" .. i
	NE_Biter_Fast_Unit.collision_box = ne_collision_box[i]
	NE_Biter_Fast_Unit.selection_box = ne_biter_selection_box[i]
	NE_Biter_Fast_Unit.drawing_box = ne_biter_drawing_box[i]
    NE_Biter_Fast_Unit.max_health = ne_biter_health[i]
	NE_Biter_Fast_Unit.loot = ne_loot
	NE_Biter_Fast_Unit.resistances = {{type = "acid", percent = 100}} -- Immune to Acid Damage
	--- Fast
	NE_Biter_Fast_Unit.min_pursue_time = 20 * 60  -- v 10 * 60
    NE_Biter_Fast_Unit.max_pursue_distance = 100  -- v 50
	NE_Biter_Fast_Unit.vision_distance = 45 -- v 30
    NE_Biter_Fast_Unit.movement_speed = 0.25 -- v 0.17,
    NE_Biter_Fast_Unit.distance_per_frame = 0.4-- v0.2,
	NE_Biter_Fast_Unit.corpse = "ne-biter-fast-corpse-" .. i
	NE_Biter_Fast_Unit.attack_parameters = NE_Biter_Melee_Double_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "acid",
                            damage_amount_2 = i,
							damage_type_2 = "physical",
                            scale = ne_scale[i],
							tint1 = ne_green_tint2,
                            tint2 = ne_green_tint,
							sound = i/25 + 0.1
						})	
	NE_Biter_Fast_Unit.run_animation = biterrunanimation(ne_scale[i], ne_green_tint2, ne_green_tint)
    NE_Biter_Fast_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_Fast_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_Fast_Unit.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_Fast_Unit.localised_description = {"entity-description.ne-biter-fast"}   
	data:extend{NE_Biter_Fast_Unit}

		
	--- Fast Biter (Green) -- Fast, Immune to Acid Damage - CREATED BY SPITTER LAUNCHER unit. Will DIE after some time
	NE_Biter_Fast_Unit_L = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_Fast_Unit_L.name = "ne-biter-fastL-" .. i
	NE_Biter_Fast_Unit_L.collision_box = ne_collision_box[i]
	NE_Biter_Fast_Unit_L.selection_box = ne_biter_selection_box[i]
	NE_Biter_Fast_Unit_L.drawing_box = ne_biter_drawing_box[i]
    NE_Biter_Fast_Unit_L.max_health = ne_biter_health[i]
	NE_Biter_Fast_Unit_L.healing_per_tick = -(0.25 * i/20)-- Will slowly die over time
	NE_Biter_Fast_Unit_L.loot = ne_loot
	NE_Biter_Fast_Unit_L.resistances = {{type = "acid", percent = 100}} -- Immune to Acid Damage
	--- Fast
	NE_Biter_Fast_Unit_L.min_pursue_time = 20 * 60  -- v 10 * 60
    NE_Biter_Fast_Unit_L.max_pursue_distance = 100  -- v 50
	NE_Biter_Fast_Unit_L.vision_distance = 45 -- v 30
    NE_Biter_Fast_Unit_L.movement_speed = 0.25 -- v 0.17,
    NE_Biter_Fast_Unit_L.distance_per_frame = 0.4-- v0.2,
	NE_Biter_Fast_Unit_L.corpse = "ne-biter-fast-corpse-" .. i
	NE_Biter_Fast_Unit_L.attack_parameters = NE_Biter_Melee_Double_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "acid",
                            damage_amount_2 = i,
							damage_type_2 = "physical",
                            scale = ne_scale[i],
							tint1 = ne_green_tint2,
                            tint2 = ne_green_tint,
							sound = i/25 + 0.1
						})	
	NE_Biter_Fast_Unit_L.run_animation = biterrunanimation(ne_scale[i], ne_green_tint2, ne_green_tint)
    NE_Biter_Fast_Unit_L.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_Fast_Unit_L.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_Fast_Unit_L.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_Fast_Unit_L.localised_description = {"entity-description.ne-biter-fast"}   
	data:extend{NE_Biter_Fast_Unit_L}	

	--- Wall Breaker Biter (Yellow) -- Damages Walls easily, Immune to Poison Damage
	NE_Biter_WallBreaker_Unit = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_WallBreaker_Unit.name = "ne-biter-wallbreaker-" .. i
	NE_Biter_WallBreaker_Unit.collision_box = ne_collision_box[i]
	NE_Biter_WallBreaker_Unit.selection_box = ne_biter_selection_box[i]
	NE_Biter_WallBreaker_Unit.drawing_box = ne_biter_drawing_box[i]
    NE_Biter_WallBreaker_Unit.max_health = ne_biter_health[i]
	NE_Biter_WallBreaker_Unit.loot = ne_loot
	NE_Biter_WallBreaker_Unit.resistances = {{type = "poison", percent = 100}} -- Immune to Poison Damage
	NE_Biter_WallBreaker_Unit.corpse = "ne-biter-wallbreaker-corpse-" .. i
	NE_Biter_WallBreaker_Unit.attack_parameters = NE_Biter_Melee_Tripple_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "ne_wallbreaker",
                            damage_amount_2 = i,
							damage_type_2 = "poison",
							damage_amount_3 = i/4, -- to prevent stailmate
							damage_type_3 = "physical",
                            scale = ne_scale[i],
							tint1 = ne_orange_tint,
                            tint2 = ne_yellow_tint,
							sound = i/25 + 0.1
						})
	NE_Biter_WallBreaker_Unit.run_animation = biterrunanimation(ne_scale[i], ne_orange_tint, ne_yellow_tint)
    NE_Biter_WallBreaker_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_WallBreaker_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_WallBreaker_Unit.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_WallBreaker_Unit.localised_description = {"entity-description.ne-biter-wallbreaker"} 
    
	data:extend{NE_Biter_WallBreaker_Unit}

	
	--- TANK Biter, Extra Health.
	NE_Biter_Tank_Unit = table.deepcopy(data.raw.unit["ne-biter-base-unit"])
    NE_Biter_Tank_Unit.name = "ne-biter-tank-" .. i
	NE_Biter_Tank_Unit.collision_box = ne_collision_box[i]
	NE_Biter_Tank_Unit.selection_box = ne_biter_selection_box[i]
	NE_Biter_Tank_Unit.drawing_box = ne_biter_drawing_box[i]
    -- Extra Health 
	NE_Biter_Tank_Unit.max_health = ne_tank_health[i]
	NE_Biter_Tank_Unit.loot = ne_loot
	NE_Biter_Tank_Unit.resistances = {{type = "laser", percent = i * 5}} -- More Immune to Laser
	NE_Biter_Tank_Unit.healing_per_tick = 0.1 -- Vanilla 0.01
	NE_Biter_Tank_Unit.corpse = "ne-biter-tank-corpse-" .. i
	NE_Biter_Tank_Unit.attack_parameters = NE_Biter_Melee_Double_Attack(
						{
							range = attack_range,
                            cooldown = 34 + i,
							damage_modifier = damage_modifier,
                            damage_amount_1 = i * 4,
							damage_type_1 = "physical",
                            damage_amount_2 = i,
							damage_type_2 = "laser",
                            scale = ne_scale[i],
                            tint1 = ne_grey_tint,
							tint2 = ne_pink_tint,
							sound = i/25 + 0.1
						})
	NE_Biter_Tank_Unit.run_animation = biterrunanimation(ne_scale[i], ne_grey_tint, ne_pink_tint)
    NE_Biter_Tank_Unit.pollution_to_join_attack = pollution_attack_increment
	NE_Biter_Tank_Unit.dying_sound =  make_biter_dying_sounds(i/25 + 0.1)
    NE_Biter_Tank_Unit.working_sound =  make_biter_calls(i/25 + 0.05)
	NE_Biter_Tank_Unit.localised_description = {"entity-description.ne-biter-tank"} 
    
	data:extend{NE_Biter_Tank_Unit}
	

	---- Corpses
	--- Breeder
	NE_Biter_Breeder_Unit_Corpse = table.deepcopy(data.raw.corpse["small-biter-corpse"])
    NE_Biter_Breeder_Unit_Corpse.name = "ne-biter-breeder-corpse-" .. i
	NE_Biter_Breeder_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Biter_Breeder_Unit_Corpse.selection_box = ne_biter_selection_box[i]
	NE_Biter_Breeder_Unit_Corpse.animation = biterdieanimation(ne_scale[i], ne_blue_tint2, ne_blue_tint1)
    NE_Biter_Breeder_Unit_Corpse.localised_name = {"entity-name.ne-biter-breeder-corpse"}

	data:extend{NE_Biter_Breeder_Unit_Corpse}


	--- Fire Biter
	NE_Biter_Fire_Unit_Corpse = table.deepcopy(data.raw.corpse["small-biter-corpse"])
    NE_Biter_Fire_Unit_Corpse.name = "ne-biter-fire-corpse-" .. i
	NE_Biter_Fire_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Biter_Fire_Unit_Corpse.selection_box = ne_biter_selection_box[i]
	NE_Biter_Fire_Unit_Corpse.animation = biterdieanimation(ne_scale[i], ne_fire_tint, ne_black_tint)
    NE_Biter_Fire_Unit_Corpse.localised_name = {"entity-name.ne-biter-fire-corpse"}
	 
	data:extend{NE_Biter_Fire_Unit_Corpse}

	--- Fast Biter
	NE_Biter_Fast_Unit_Corpse = table.deepcopy(data.raw.corpse["small-biter-corpse"])
    NE_Biter_Fast_Unit_Corpse.name = "ne-biter-fast-corpse-" .. i
	NE_Biter_Fast_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Biter_Fast_Unit_Corpse.selection_box = ne_biter_selection_box[i]
	NE_Biter_Fast_Unit_Corpse.animation = biterdieanimation(ne_scale[i], ne_green_tint2, ne_green_tint)
    NE_Biter_Fast_Unit_Corpse.localised_name = {"entity-name.ne-biter-fast-corpse"}
	
	data:extend{NE_Biter_Fast_Unit_Corpse}	

	--- Wall Breaker Biter
	NE_Biter_Wallbreaker_Unit_Corpse = table.deepcopy(data.raw.corpse["small-biter-corpse"])
    NE_Biter_Wallbreaker_Unit_Corpse.name = "ne-biter-wallbreaker-corpse-" .. i
	NE_Biter_Wallbreaker_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Biter_Wallbreaker_Unit_Corpse.selection_box = ne_biter_selection_box[i]
	NE_Biter_Wallbreaker_Unit_Corpse.animation = biterdieanimation(ne_scale[i], ne_orange_tint, ne_yellow_tint)
    NE_Biter_Wallbreaker_Unit_Corpse.localised_name = {"entity-name.ne-biter-wallbreaker-corpse"} 
	
	data:extend{NE_Biter_Wallbreaker_Unit_Corpse}	
	
	
	-- TANKS
	NE_Biter_Tank_Unit_Corpse = table.deepcopy(data.raw.corpse["small-biter-corpse"])
    NE_Biter_Tank_Unit_Corpse.name = "ne-biter-tank-corpse-" .. i
	NE_Biter_Tank_Unit_Corpse.time_before_removed = (i/20 + 2) * 60 * 10
	NE_Biter_Tank_Unit_Corpse.selection_box = ne_biter_selection_box[i]
	NE_Biter_Tank_Unit_Corpse.animation = biterdieanimation(ne_scale[i], ne_grey_tint, ne_pink_tint)
    NE_Biter_Tank_Unit_Corpse.localised_name = {"entity-name.ne-biter-tank-corpse"}     
	
	data:extend{NE_Biter_Tank_Unit_Corpse}


end




  
