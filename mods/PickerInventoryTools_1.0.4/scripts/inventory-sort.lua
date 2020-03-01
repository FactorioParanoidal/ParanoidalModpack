--(( Sorting ))
local Event = require('__stdlib__/stdlib/event/event')

local types = {
    ['car'] = defines.inventory.car_trunk,
    ['cargo-wagon'] = defines.inventory.cargo_wagon,
    ['container'] = defines.inventory.chest,
    ['logistic-container'] = defines.inventory.chest
}

local function sort_inventory(event)
    local player = game.players[event.player_index]
    if player.opened_self and event.input_name == 'picker-manual-inventory-sort' then
        player.get_main_inventory().sort_and_merge()
    elseif player.opened and player.opened_gui_type == defines.gui_type.entity then
        local inventory = player.opened.get_inventory(types[player.opened.type] or 255)
        if inventory and not inventory.is_empty() and (event.input_name == 'picker-manual-inventory-sort' or player.mod_settings['picker-auto-sort-inventory'].value) then
            inventory.sort_and_merge()
        end
    end
end
Event.register({'picker-manual-inventory-sort', defines.events.on_gui_opened}, sort_inventory)
--))
