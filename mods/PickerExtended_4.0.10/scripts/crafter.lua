-------------------------------------------------------------------------------
--[Picker Crafter]-- Craft selected entity on hotkey press
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local lib = require('__PickerAtheneum__/utils/lib')

local function santas_little_helper(player, name)
    local allow_multiple = player.mod_settings['picker-allow-multiple-craft'].value
    if game.recipe_prototypes[name] and player.force.recipes[name].enabled and (allow_multiple or player.get_item_count(name) == 0) then
        player.begin_crafting {count = 1, recipe = name, silent = false}
    end
end

local function picker_crafter(event)
    local player = game.players[event.player_index]
    local selected, stack = player.selected, player.cursor_stack
    if selected then
        if not stack.valid_for_read then
            local _, _, ip = lib.get_placeable_item(selected)
            if ip then
                santas_little_helper(player, ip.name)
            end
        end
    elseif player.cursor_ghost then
        santas_little_helper(player, player.cursor_ghost.name)
    end
end
Event.register('picker-crafter', picker_crafter)
