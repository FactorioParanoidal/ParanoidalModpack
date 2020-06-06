local Event = require('__stdlib__/stdlib/event/event')
local table = require('__stdlib__/stdlib/utils/table')

local function summon_tree_deconstruction_planner(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    if player.clean_cursor() and stack.set_stack('deconstruction-planner') then
        stack.trees_and_rocks_only = true
    end
end
Event.register('picker-summon-trees-deconstruction-planner', summon_tree_deconstruction_planner)

local function toggle_filter_mode(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    local mode = event.input_name == 'picker-toggle-filter-mode' and 'entity_filter_mode' or 'tile_filter_mode'
    if stack.valid_for_read and stack.name == 'deconstruction-planner' then
        local whitelist = defines.deconstruction_item[mode].whitelist
        local blacklist = defines.deconstruction_item[mode].blacklist
        if stack[mode] == whitelist then
            stack[mode] = blacklist
            player.print({'deconstructor.' .. mode .. '-blacklist'})
        else
            stack[mode] = whitelist
            player.print({'deconstructor.' .. mode .. '-whitelist'})
        end
    end
end
Event.register({'picker-toggle-filter-mode', 'picker-toggle-tile-filter-mode'}, toggle_filter_mode)

local tile_mode = table.invert(defines.deconstruction_item.tile_selection_mode)
local function cycle_tile_mode(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    if stack.valid_for_read and stack.name == 'deconstruction-planner' then
        local next_mode = (stack.tile_selection_mode + 1 < table.size(tile_mode)) and (stack.tile_selection_mode + 1) or 0
        stack.tile_selection_mode = next_mode
        player.print({'deconstructor.tile-selection-mode', {'deconstructor.' .. tile_mode[next_mode]}})
    end
end
Event.register('picker-cycle-tile-selection-mode', cycle_tile_mode)

--Event.register('picker-pick-deconstruction-filter', pick_deconstruction_filter)
-- On keypress With no decon plan mark item for deconstruction,
-- with an item add the item to the white/black list.
local function mark_for_deconstruction(event)
    local player = game.get_player(event.player_index)
    local selected = player.selected
    if selected then
        local stack = player.cursor_stack
        if stack.is_deconstruction_item then
            if not (selected.type == 'resource' or selected.has_flag('not-deconstructable')) then
                local name, count = selected.name, stack.entity_filter_count
                local first_empty = 0
                local p = selected.position
                for i = 1, count do
                    local filter = stack.get_entity_filter(i)
                    if name == filter then
                        stack.set_entity_filter(i, nil)
                        player.create_local_flying_text {text = {'deconstructor.removed', {'entity-name.' .. selected.name}}, position = p}
                        return
                    elseif not filter and first_empty == 0 then
                        first_empty = i
                    end
                end
                if first_empty > 0 and stack.set_entity_filter(first_empty, name) then
                    player.create_local_flying_text {text = {'deconstructor.added', {'entity-name.' .. selected.name}}, position = p}
                else
                    player.create_local_flying_text {text = {'deconstructor.no-empty-slots'}, position = p}
                end
            end
        elseif not stack.valid_for_read then
            local force = player.force
            if force == selected.force then
                if selected.to_be_deconstructed(force) then
                    selected.cancel_deconstruction(force, player)
                else
                    selected.order_deconstruction(force, player)
                end
            end
        end
    end
end
Event.register('picker-mark-for-deconstruction', mark_for_deconstruction)
