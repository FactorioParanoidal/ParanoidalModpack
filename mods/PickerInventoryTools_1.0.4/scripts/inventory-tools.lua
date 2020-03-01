-------------------------------------------------------------------------------
--[Open held item inventory]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local function open_held_item_inventory(event)
    local player = game.players[event.player_index]
    if player.cursor_stack.valid_for_read then
        player.opened = player.cursor_stack
    end
end
Event.register('picker-inventory-editor', open_held_item_inventory)
