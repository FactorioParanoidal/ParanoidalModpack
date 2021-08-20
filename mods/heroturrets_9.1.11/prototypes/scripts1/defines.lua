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

heroturrets.defines.turret_initial_1_kills_value = 500
heroturrets.defines.turret_initial_1_damage_value = 10000
heroturrets.defines.turret_initial_2_kills_value = 700
heroturrets.defines.turret_initial_2_damage_value = 50000
heroturrets.defines.turret_initial_3_kills_value = 1000
heroturrets.defines.turret_initial_3_damage_value = 100000
heroturrets.defines.turret_initial_4_kills_value = 1500
heroturrets.defines.turret_initial_4_damage_value = 1000000
heroturrets.defines.turret_initial_5_kills_value = 3000
heroturrets.defines.turret_initial_5_damage_value = 10000
heroturrets.defines.turret_initial_6_kills_value = 7500
heroturrets.defines.turret_initial_6_damage_value = 50000
heroturrets.defines.turret_initial_7_kills_value = 12500
heroturrets.defines.turret_initial_7_damage_value = 100000
heroturrets.defines.turret_initial_8_kills_value = 25000
heroturrets.defines.turret_initial_8_damage_value = 1000000
heroturrets.defines.turret_initial_9_kills_value = 50000
heroturrets.defines.turret_initial_9_damage_value = 10000
heroturrets.defines.turret_initial_10_kills_value = 100000
heroturrets.defines.turret_initial_10_damage_value = 50000

if test then
heroturrets.defines.turret_initial_1_kills_value = 10
heroturrets.defines.turret_initial_1_damage_value = 1000
heroturrets.defines.turret_initial_2_kills_value = 20
heroturrets.defines.turret_initial_2_damage_value = 5000
heroturrets.defines.turret_initial_3_kills_value = 30
heroturrets.defines.turret_initial_3_damage_value = 10000
heroturrets.defines.turret_initial_4_kills_value = 40
heroturrets.defines.turret_initial_4_damage_value = 50000
heroturrets.defines.turret_initial_5_kills_value = 50
heroturrets.defines.turret_initial_5_damage_value = 100000
heroturrets.defines.turret_initial_6_kills_value = 60
heroturrets.defines.turret_initial_6_damage_value = 500000
heroturrets.defines.turret_initial_7_kills_value = 70
heroturrets.defines.turret_initial_7_damage_value = 1000000
heroturrets.defines.turret_initial_8_kills_value = 80
heroturrets.defines.turret_initial_8_damage_value = 5000000
heroturrets.defines.turret_initial_9_kills_value = 90
heroturrets.defines.turret_initial_9_damage_value = 10000000
heroturrets.defines.turret_initial_10_kills_value = 100
heroturrets.defines.turret_initial_10_damage_value = 50000000
end

--[[defaults]]
local percent = settings.startup["heroturrets-setting-level-up-modifier"].value/100
heroturrets.defines.turret_levelup_kills_1 = heroturrets.defines.turret_initial_1_kills_value + (math.floor((heroturrets.defines.turret_initial_1_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_1 = heroturrets.defines.turret_initial_1_damage_value + (math.floor((heroturrets.defines.turret_initial_1_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_2 = heroturrets.defines.turret_initial_2_kills_value + (math.floor((heroturrets.defines.turret_initial_2_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_2 = heroturrets.defines.turret_initial_2_damage_value + (math.floor((heroturrets.defines.turret_initial_2_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_3 = heroturrets.defines.turret_initial_3_kills_value + (math.floor((heroturrets.defines.turret_initial_3_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_3 = heroturrets.defines.turret_initial_3_damage_value + (math.floor((heroturrets.defines.turret_initial_3_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_4 = heroturrets.defines.turret_initial_4_kills_value + (math.floor((heroturrets.defines.turret_initial_4_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_4 = heroturrets.defines.turret_initial_4_damage_value + (math.floor((heroturrets.defines.turret_initial_4_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_5 = heroturrets.defines.turret_initial_1_kills_value + (math.floor((heroturrets.defines.turret_initial_5_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_5 = heroturrets.defines.turret_initial_1_damage_value + (math.floor((heroturrets.defines.turret_initial_5_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_6 = heroturrets.defines.turret_initial_2_kills_value + (math.floor((heroturrets.defines.turret_initial_6_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_6 = heroturrets.defines.turret_initial_2_damage_value + (math.floor((heroturrets.defines.turret_initial_6_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_7 = heroturrets.defines.turret_initial_3_kills_value + (math.floor((heroturrets.defines.turret_initial_7_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_7 = heroturrets.defines.turret_initial_3_damage_value + (math.floor((heroturrets.defines.turret_initial_7_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_8 = heroturrets.defines.turret_initial_4_kills_value + (math.floor((heroturrets.defines.turret_initial_8_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_8 = heroturrets.defines.turret_initial_4_damage_value + (math.floor((heroturrets.defines.turret_initial_8_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_9 = heroturrets.defines.turret_initial_1_kills_value + (math.floor((heroturrets.defines.turret_initial_9_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_9 = heroturrets.defines.turret_initial_1_damage_value + (math.floor((heroturrets.defines.turret_initial_9_damage_value*percent)/10)*100)
heroturrets.defines.turret_levelup_kills_10 = heroturrets.defines.turret_initial_2_kills_value + (math.floor((heroturrets.defines.turret_initial_10_kills_value*percent)/10)*100)
heroturrets.defines.turret_levelup_damage_10 = heroturrets.defines.turret_initial_2_damage_value + (math.floor((heroturrets.defines.turret_initial_10_damage_value*percent)/10)*100)

--[[events]]
heroturrets.events.on_build = {defines.events.on_built_entity, defines.events.on_robot_built_entity,defines.events.script_raised_built,defines.events.script_raised_revive}
heroturrets.events.on_remove = {defines.events.on_entity_died,defines.events.on_robot_pre_mined,defines.events.on_robot_mined_entity,defines.events.on_player_mined_entity,defines.events.script_raised_destroy}
heroturrets.events.on_pick_up_item = {defines.events.on_picked_up_item,defines.events.on_player_mined_item,defines.events.on_robot_mined}

heroturrets.events.low_priority = 44
heroturrets.events.medium_priority = 30
heroturrets.events.high_priority = 9