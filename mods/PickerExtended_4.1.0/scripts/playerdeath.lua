local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')

-- https://forums.factorio.com/viewtopic.php?f=6&t=60302

local function save_settings(event)
    local player, pdata = Player.get(event.player_index)
    local char = player.character
    if char and player.mod_settings['picker-transfer-settings-death'].value then
        pdata.saved_settings = {}
        pdata.saved_settings['character_crafting_speed_modifier'] = char.character_crafting_speed_modifier
        pdata.saved_settings['character_mining_speed_modifier'] = char.character_mining_speed_modifier
        pdata.saved_settings['character_running_speed_modifier'] = char.character_running_speed_modifier
        pdata.saved_settings['character_build_distance_bonus'] = char.character_build_distance_bonus
        pdata.saved_settings['character_item_drop_distance_bonus'] = char.character_item_drop_distance_bonus
        pdata.saved_settings['character_reach_distance_bonus'] = char.character_reach_distance_bonus
        pdata.saved_settings['character_resource_reach_distance_bonus'] = char.character_resource_reach_distance_bonus
        pdata.saved_settings['character_item_pickup_distance_bonus'] = char.character_item_pickup_distance_bonus
        pdata.saved_settings['character_loot_pickup_distance_bonus'] = char.character_loot_pickup_distance_bonus
        pdata.saved_settings['character_inventory_slots_bonus'] = char.character_inventory_slots_bonus
        pdata.saved_settings['character_logistic_slot_count_bonus'] = char.character_logistic_slot_count_bonus
        pdata.saved_settings['character_trash_slot_count_bonus'] = char.character_trash_slot_count_bonus
        pdata.saved_settings['character_maximum_following_robot_count_bonus'] = char.character_maximum_following_robot_count_bonus
        pdata.saved_settings['character_health_bonus'] = char.character_health_bonus
    end
end

local function restore_settings(event)
    local player, pdata = Player.get(event.player_index)
    local char = player.character
    if char and pdata.saved_settings and player.mod_settings['picker-transfer-settings-death'].value then
        for setting, value in pairs(pdata.saved_settings) do
            char[setting] = value
        end
    end
    pdata.saved_settings = nil
end

Event.register(defines.events.on_pre_player_died, save_settings)
Event.register(defines.events.on_player_respawned, restore_settings)
