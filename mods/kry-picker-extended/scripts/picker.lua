-------------------------------------------------------------------------------
--[Environment Picker] -- Picks dropped item fron environment
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local lib = require('utils/lib')

local function pick_from_environment(event)
    local player = game.players[event.player_index]
    local selected = player.selected
    if player.is_cursor_empty() and selected and selected.type == "resource" then
        new_item = lib.find_item_in_inventory(selected.name,player.get_main_inventory())
        if new_item then
            -- this doesn't work because vanilla pipette calls for mining drills and overrides
            player.cursor_stack.transfer_stack(new_item)
            --game.print(player.cursor_stack)
        end
    end
end
Event.register('picker-select', pick_from_environment)