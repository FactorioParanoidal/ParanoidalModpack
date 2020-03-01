-------------------------------------------------------------------------------
--[[Picker Blueprinter]] --
-------------------------------------------------------------------------------
--Mirroring and Upgradeing code from "Foreman", by "Choumiko"

local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Inventory = require('__stdlib__/stdlib/entity/inventory')
local Entity = require('__stdlib__/stdlib/entity/entity')

local lib = require('__PickerAtheneum__/utils/lib')

local function blueprint_single_entity(player, entity, target_name, area)
    if area:size() > 0 then
        local bp = lib.get_planner(player, 'picker-blueprint-tool', 'Pipette Blueprint')
        if bp then
            bp.clear_blueprint()
            bp.label = 'Pipette Blueprint'
            bp.allow_manual_label_change = false
            -- Build from surface
            bp.create_blueprint {
                surface = entity.surface,
                force = player.force,
                area = area,
                always_include_tiles = false
            }

            -- Remove garbage
            local found = false
            for i, ent in pairs(bp.get_blueprint_entities() or {}) do
                if ent.name == target_name then
                    bp.set_blueprint_entities {ent}
                    found = true
                    break
                end
            end
            if not found then
                return bp.clear() and nil
            end
        else
            player.print({'picker.msg-cant-insert-blueprint'})
        end
    end
end

-- Make Simple Blueprint --Makes a simple blueprint of the selected entity, including recipes/modules
local function make_simple_blueprint(event)
    local player = game.get_player(event.player_index)
    if player.controller_type ~= defines.controllers.ghost and player.mod_settings['picker-simple-blueprint'].value then
        if player.selected and not (player.selected.type == 'resource' or player.selected.has_flag('not-blueprintable')) then
            if not (player.cursor_stack.valid_for_read) then
                local entity = player.selected
                if player.clean_cursor() then
                    if entity.force == player.force and Entity.damaged(entity) and lib.get_planner(player, 'repair-tool') then
                        return
                    else
                        local area = Area(entity.bounding_box)
                        blueprint_single_entity(player, entity, player.selected.name, area)
                    end
                end
            end
        end
    end
end
Event.register('picker-make-ghost', make_simple_blueprint)

--(( Blueprint Book tools ))--
local function add_empty_bp_to_book(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    if stack.valid_for_read and stack.is_blueprint_book then
        local inv = stack.get_inventory(defines.inventory.item_main)
        --insert a dummy print so we have an easy way to find the idx
        if inv and inv.insert('picker-blueprint-tool') then
            local slot, idx = inv.find_item_stack('picker-blueprint-tool')
            if slot and idx and slot.set_stack('blueprint') then
                stack.active_index = idx
                -- Cycling blueprints in books raises cursor changed event, lets emulate that.
                script.raise_event(defines.events.on_player_cursor_stack_changed, {player_index = event.player_index})
            end
        end
    end
end
Event.register('picker-add-empty-bp-to-book', add_empty_bp_to_book)

local function _clear_empty_bp(slot)
    if slot.valid_for_read and not slot.is_blueprint_setup() then
        slot.clear()
    end
end
local function clean_empty_bps_in_book(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    if stack.valid_for_read and stack.is_blueprint_book then
        local inv = stack.get_inventory(defines.inventory.item_main)
        if inv and not inv.is_empty() then
            local change_index = not (inv[stack.active_index].valid_for_read and inv[stack.active_index].is_blueprint_setup())

            Inventory.each_reverse(inv, _clear_empty_bp)

            if change_index then
                local _, idx = inv.find_item_stack('blueprint')
                stack.active_index = idx or 1
                script.raise_event(defines.events.on_player_cursor_stack_changed, {player_index = event.player_index})
            end
        end
    end
end
Event.register('picker-clean-empty-bps-in-book', clean_empty_bps_in_book) --))
