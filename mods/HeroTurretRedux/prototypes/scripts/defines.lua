--[[dsync checking No Changes]]

--[[code reviewed 6.10.19]]
if not heroturrets.defines then heroturrets.defines = {} end
if not heroturrets.defines.names then heroturrets.defines.names = {} end
if not heroturrets.defines.defaults then heroturrets.defines.defaults = {} end
if not heroturrets.events then heroturrets.events = {} end

--[[names]]
heroturrets.defines.names.force_player = "player"
heroturrets.defines.names.force_enemy = "enemy"
heroturrets.defines.names.force_neutral = "neutral"

-- rank modification multiplier
local rank_modifier = settings.startup["heroturrets-setting-level-up-modifier"].value/100

local calc_Level_Up_Values = function (initialValue)
	return initialValue + (math.floor(initialValue * (rank_modifier / 10)))
end

local test = false



--- Rank up threshold values
--Kills
heroturrets.defines.turret_initial_one_kills_value = 150
heroturrets.defines.turret_initial_two_kills_value = 1000
heroturrets.defines.turret_initial_three_kills_value = 2500
heroturrets.defines.turret_initial_four_kills_value = 5000
heroturrets.defines.turret_initial_five_kills_value = 10000 -- Field Marshal
heroturrets.defines.turret_initial_six_kills_value = 20000 -- Supreme Commander
--Damage

heroturrets.defines.turret_initial_one_damage_value = 10000
heroturrets.defines.turret_initial_two_damage_value = 50000
heroturrets.defines.turret_initial_three_damage_value = 100000
heroturrets.defines.turret_initial_four_damage_value = 2000000
heroturrets.defines.turret_initial_five_damage_value = 6000000
heroturrets.defines.turret_initial_six_damage_value = 12000000

if test then
	--Kills
			heroturrets.defines.turret_initial_one_kills_value = 5
			heroturrets.defines.turret_initial_two_kills_value = 10
			heroturrets.defines.turret_initial_three_kills_value = 15
			heroturrets.defines.turret_initial_four_kills_value = 20
			heroturrets.defines.turret_initial_five_kills_value = 25 -- Field Marshal
			heroturrets.defines.turret_initial_six_kills_value = 30 -- Supreme Commander
			--Damage

			heroturrets.defines.turret_initial_one_damage_value = 100
			heroturrets.defines.turret_initial_two_damage_value = 1000
			heroturrets.defines.turret_initial_three_damage_value = 2000
			heroturrets.defines.turret_initial_four_damage_value = 3000
			heroturrets.defines.turret_initial_five_damage_value = 10000
			heroturrets.defines.turret_initial_six_damage_value = 20000
end

---[[defaults]]
-- kills
heroturrets.defines.turret_levelup_kills_one =   calc_Level_Up_Values(heroturrets.defines.turret_initial_one_kills_value) 
heroturrets.defines.turret_levelup_kills_two =  calc_Level_Up_Values(heroturrets.defines.turret_initial_two_kills_value) 
heroturrets.defines.turret_levelup_kills_three =   calc_Level_Up_Values(heroturrets.defines.turret_initial_three_kills_value) 
heroturrets.defines.turret_levelup_kills_four =  calc_Level_Up_Values(heroturrets.defines.turret_initial_four_kills_value)  
heroturrets.defines.turret_levelup_kills_five = calc_Level_Up_Values(heroturrets.defines.turret_initial_five_kills_value)
heroturrets.defines.turret_levelup_kills_six = calc_Level_Up_Values(heroturrets.defines.turret_initial_six_kills_value )

-- damage
heroturrets.defines.turret_levelup_damage_one =   calc_Level_Up_Values(heroturrets.defines.turret_initial_one_damage_value ) 
heroturrets.defines.turret_levelup_damage_two =   calc_Level_Up_Values(heroturrets.defines.turret_initial_two_damage_value) 
heroturrets.defines.turret_levelup_damage_three =  calc_Level_Up_Values(heroturrets.defines.turret_initial_three_damage_value) 
heroturrets.defines.turret_levelup_damage_four =   calc_Level_Up_Values(heroturrets.defines.turret_initial_four_damage_value) 
heroturrets.defines.turret_levelup_damage_five =  calc_Level_Up_Values(heroturrets.defines.turret_initial_five_damage_value)
heroturrets.defines.turret_levelup_damage_six =   calc_Level_Up_Values(heroturrets.defines.turret_initial_six_damage_value) 

--[[events]]
heroturrets.events.on_build = {defines.events.on_built_entity, defines.events.on_robot_built_entity,defines.events.script_raised_built,defines.events.script_raised_revive}
heroturrets.events.on_remove = {defines.events.on_entity_died,defines.events.on_robot_pre_mined,defines.events.on_robot_mined_entity,defines.events.on_player_mined_entity,defines.events.script_raised_destroy}
heroturrets.events.on_pick_up_item = {defines.events.on_picked_up_item,defines.events.on_player_mined_item,defines.events.on_robot_mined}

heroturrets.events.low_priority = 44
heroturrets.events.medium_priority = 30
heroturrets.events.high_priority = 9

