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

local test = false	

heroturrets.defines.turret_initial_one_kills_value = 50
heroturrets.defines.turret_initial_one_damage_value = 10000
heroturrets.defines.turret_initial_two_kills_value = 250
heroturrets.defines.turret_initial_two_damage_value = 50000
heroturrets.defines.turret_initial_three_kills_value = 500
heroturrets.defines.turret_initial_three_damage_value = 100000
heroturrets.defines.turret_initial_four_kills_value = 5000
heroturrets.defines.turret_initial_four_damage_value = 1000000
if test then
	heroturrets.defines.turret_initial_one_kills_value = 10
	heroturrets.defines.turret_initial_one_damage_value = 100
	heroturrets.defines.turret_initial_two_kills_value = 50
	heroturrets.defines.turret_initial_two_damage_value = 1000
	heroturrets.defines.turret_initial_three_kills_value = 100
	heroturrets.defines.turret_initial_three_damage_value = 2000
	heroturrets.defines.turret_initial_four_kills_value = 250
	heroturrets.defines.turret_initial_four_damage_value = 4000
end

--[[defaults]]
local percent = settings.startup["heroturrets-setting-level-up-modifier"].value/100
heroturrets.defines.turret_levelup_kills_one = heroturrets.defines.turret_initial_one_kills_value + (math.floor((heroturrets.defines.turret_initial_one_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_one = heroturrets.defines.turret_initial_one_damage_value + (math.floor((heroturrets.defines.turret_initial_one_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_two = heroturrets.defines.turret_initial_two_kills_value + (math.floor((heroturrets.defines.turret_initial_two_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_two = heroturrets.defines.turret_initial_two_damage_value + (math.floor((heroturrets.defines.turret_initial_two_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_three = heroturrets.defines.turret_initial_three_kills_value + (math.floor((heroturrets.defines.turret_initial_three_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_three = heroturrets.defines.turret_initial_three_damage_value + (math.floor((heroturrets.defines.turret_initial_three_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_four = heroturrets.defines.turret_initial_four_kills_value + (math.floor((heroturrets.defines.turret_initial_four_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_four = heroturrets.defines.turret_initial_four_damage_value + (math.floor((heroturrets.defines.turret_initial_four_damage_value*percent)/10)*100)
--[[events]]
heroturrets.events.on_build = {defines.events.on_built_entity, defines.events.on_robot_built_entity,defines.events.script_raised_built,defines.events.script_raised_revive}
heroturrets.events.on_remove = {defines.events.on_entity_died,defines.events.on_robot_pre_mined,defines.events.on_robot_mined_entity,defines.events.on_player_mined_entity,defines.events.script_raised_destroy}
heroturrets.events.on_pick_up_item = {defines.events.on_picked_up_item,defines.events.on_player_mined_item,defines.events.on_robot_mined}

heroturrets.events.low_priority = 44
heroturrets.events.medium_priority = 30
heroturrets.events.high_priority = 9