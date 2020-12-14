--[[
    "author": "ThaPear"
    "name": "Item Count"
--]]
local Event = require('__stdlib__/stdlib/event/event')

local function get_or_create_itemcount_gui(player)
    local gui = player.gui.center.itemcount
    if not gui then
        gui = player.gui.center.add {type = 'label', name = 'itemcount', caption = '0', direction = 'vertical'}
        gui.style.font = 'default-bold'
    end
    local enabled = player.mod_settings['picker-item-count'].value
    gui.visible = enabled and player.cursor_stack.valid_for_read
    return gui
end

local function get_itemcount_counts(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack
    local gui = get_or_create_itemcount_gui(player)
    if stack and (stack.prototype.stackable or stack.prototype.stack_size > 1) then
        local inventory_count = player.get_item_count(stack.name)
        local vehicle_count
        if player.vehicle and player.vehicle.get_inventory(defines.inventory.car_trunk) then
            vehicle_count = player.vehicle.get_inventory(defines.inventory.car_trunk).get_item_count(stack.name)
        end
        gui.caption = inventory_count .. (vehicle_count and (' (' .. vehicle_count .. ')') or '')
    else
        gui.caption = ''
    end
end

local item_count_events = {
    defines.events.on_player_cursor_stack_changed,
    defines.events.on_player_driving_changed_state,
    defines.events.on_player_main_inventory_changed,
    defines.events.on_player_ammo_inventory_changed
}
Event.register(item_count_events, get_itemcount_counts)

local function update_item_count_settings(event)
    local player = game.players[event.player_index]
    if event.setting == 'picker-item-count' then
        local enabled = player.mod_settings['picker-item-count'].value
        local gui = get_or_create_itemcount_gui(player)
        gui.visible = enabled and player.cursor_stack.valid_for_read or false
    end
end
Event.register(defines.events.on_runtime_mod_setting_changed, update_item_count_settings)

return get_or_create_itemcount_gui
