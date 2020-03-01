-------------------------------------------------------------------------------
--[[Pipe Clamps]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
require('__stdlib__/stdlib/area/area')
local Position = require('__stdlib__/stdlib/area/position')
local not_clampable = require('utils/not-clampable')
local utils = require('scripts/utils')
local abs = math.abs

--[[
    defines.direction.north     == 0    1
    defines.direction.east     == 2         4
    defines.direction.south     == 4        16
    defines.direction.west     == 6         64
--]]

local map_clamped_name = {
    --[0] = "-clamped-none",
    ['-clamped-N'] = {name = '-clamped-single', direction = defines.direction.north},
    ['-clamped-E'] = {name = '-clamped-single', direction = defines.direction.east},
    ['-clamped-NE'] = {name = '-clamped-l', direction = defines.direction.east},
    ['-clamped-S'] = {name = '-clamped-single', direction = defines.direction.south},
    ['-clamped-NS'] = {name = '-clamped-i', direction = defines.direction.north},
    ['-clamped-SE'] = {name = '-clamped-l', direction = defines.direction.south},
    ['-clamped-NSE'] = {name = '-clamped-t', direction = defines.direction.east},
    ['-clamped-W'] = {name = '-clamped-single', direction = defines.direction.west},
    ['-clamped-NW'] = {name = '-clamped-l', direction = defines.direction.north},
    ['-clamped-EW'] = {name = '-clamped-i', direction = defines.direction.east},
    ['-clamped-NEW'] = {name = '-clamped-t', direction = defines.direction.north},
    ['-clamped-SW'] = {name = '-clamped-l', direction = defines.direction.west},
    ['-clamped-NSW'] = {name = '-clamped-t', direction = defines.direction.west},
    ['-clamped-SEW'] = {name = '-clamped-t', direction = defines.direction.south},
    ['-clamped-NSEW'] = {name = '-clamped-x', direction = defines.direction.north}
}

local clamped_name = {
    --[0] = "-clamped-none",
    [1] = '-clamped-N',
    [4] = '-clamped-E',
    [5] = '-clamped-NE',
    [16] = '-clamped-S',
    [17] = '-clamped-NS',
    [20] = '-clamped-SE',
    [21] = '-clamped-NSE',
    [64] = '-clamped-W',
    [65] = '-clamped-NW',
    [68] = '-clamped-EW',
    [69] = '-clamped-NEW',
    [80] = '-clamped-SW',
    [81] = '-clamped-NSW',
    [84] = '-clamped-SEW',
    [85] = '-clamped-NSEW'
}

-- can return nil or entity
local function get_last_pipe(player, pdata)
    return pdata.last_pipe_position and (player.surface.find_entities_filtered {position = pdata.last_pipe_position, type = 'pipe'})[1]
end

-- returns a table which may or may not have contents if entity passed is nil
local function get_pipe_info(entity)
    local data = {}
    if entity and entity.valid then
        local box = entity.fluidbox[1]
        data.entity = entity
        data.fluid_name = box and box.name
    end
    return data
end

--((
-- Clamping and Unclamping need to check for for a filter and add it to the replaced pipe
local function place_clamped_pipe(entity, table_entry, player, lock_pipe, autoclamp, area_clamp)
    --local player, pdata = Player.get(player.index)
    local entity_position = entity.position
    local old_entity_unit_number = entity.unit_number
    local new
    if table_entry <= 85 and clamped_name[table_entry] then
        local filter_table = entity.fluidbox.get_filter(1)
        local event_data = {
            entity = entity,
            player_index = player.index
        }
        script.raise_event(defines.events.script_raised_destroy, event_data)
        new =
            entity.surface.create_entity {
            name = entity.prototype.mineable_properties.products[1].name .. map_clamped_name[clamped_name[table_entry]].name,
            position = entity_position,
            direction = map_clamped_name[clamped_name[table_entry]].direction,
            force = entity.force,
            fast_replace = true,
            spill = false
        }
        if not autoclamp and not area_clamp then
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'pipe-tools.clamped'},
                time_to_live = 60,
                color = utils.color.green
            }
        end
        new.last_user = player
        new.fluidbox.set_filter(1, filter_table)
        local event = {
            created_entity = new,
            player_index = player.index,
            clamped = true,
            replaced_entity_unit_number = old_entity_unit_number
        }
        script.raise_event(defines.events.script_raised_built, event)
        if entity then
            entity.destroy()
        end
    else
        if lock_pipe then
            entity.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'pipe-tools.fail'},
                time_to_live = 120,
                color = utils.color.red
            }
        end
    end
    return new
end


local function clamp_pipe(entity, player, lock_pipe, autoclamp, reverse_entity, area_clamp)
    local table_entry = 0
    local neighbour_count = 0
    local entity_position = entity.position
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            local neighbour_position = neighbour.position
            local delta_x = entity_position.x - neighbour_position.x
            local delta_y = entity_position.y - neighbour_position.y
            if delta_x ~= 0 then
                if delta_y == 0 then
                    table_entry = table_entry + 2 ^ (utils.get_ew(delta_x))
                    neighbour_count = neighbour_count + 1
                else
                    local adx,ady = abs(delta_x), abs(delta_y)
                    if adx > ady then
                        table_entry = table_entry + 2 ^ (utils.get_ew(delta_x))
                    else
                        table_entry = table_entry + 2 ^ (utils.get_ns(delta_y))
                    end
                    neighbour_count = neighbour_count + 1
                end
            else
                table_entry = table_entry + 2 ^ (utils.get_ns(delta_y))
                neighbour_count = neighbour_count + 1
            end
        end
    end
    if neighbour_count > 0 then
        if reverse_entity then
            table_entry = table_entry - 2 ^ (Position.direction_to(entity_position, reverse_entity.position))
        end
        place_clamped_pipe(entity, table_entry, player, lock_pipe, autoclamp, area_clamp)
    end
end

local function check_sub_neighbours(sub_neighbours, neighbour, entity)
    local fluid_box_counter = 0
    for _, subsequent_entities in pairs(sub_neighbours) do
        for _, subsequent_neighbour in pairs(subsequent_entities) do
            if subsequent_neighbour ~= entity then
                fluid_box_counter = fluid_box_counter + 1
            end
        end
        if fluid_box_counter > 1 then
            return neighbour
        end
    end
end

local function pipe_autoclamp_clamp(event, unclamp)
    local entity = event.created_entity or event.entity
    local player, pdata = Player.get(event.player_index)

    local pipes_to_clamp = {}
    local clamp_self

    local current_fluid = get_pipe_info(entity).fluid_name
    local last_pipe_data = get_pipe_info(get_last_pipe(player, pdata))
    local last_pipe = last_pipe_data.entity

    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if neighbour.type == 'pipe' or (neighbour.type == 'pipe-to-ground' and string.find(neighbour.name, '%-clamped%-')) then
                local neighbour_fluid = get_pipe_info(neighbour).fluid_name
                if current_fluid then
                    --! Ensure fluids don't mix
                    if neighbour_fluid and (neighbour_fluid ~= current_fluid) then
                        --? If the neighbour has a fluid and they don't match, we're clamping it. Period.
                        neighbour.surface.create_entity {
                            name = 'flying-text',
                            position = neighbour.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = utils.color.red
                        }
                        pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                    elseif not unclamp and not pdata.disable_auto_clamp then
                        --? This is not a logic duplicate of below. This branch is different and has a different purpose than above.
                        --! If the player wasn't unclamping, do further checks if auto clamp is on.
                        if last_pipe and neighbour ~= last_pipe then
                            --? If there's a last pipe make sure it isnt the neighbour. If it's not clamp it. Allows parallel laying and T-ing into a pipeline.
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        elseif not last_pipe then
                            --? Explicit check to make sure there isn't a last pipe. I don't want false to the above but then last pipe getting clamped anyways.
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        end
                    end
                elseif not unclamp and not pdata.disable_auto_clamp then
                    --? If the current pipe doesn't have a fluid, make sure the player wasn't just unclamping, and make sure auto clamp is on.
                    --! <AUTO CLAMP MODE>
                    if last_pipe and neighbour ~= last_pipe and Position.distance(entity.position, last_pipe.position) == 1 then
                        --? This will see if last pipe exists, make sure that the neighbour isn't the last pipe, and if it isn't, see if it's within a tile (Tracking last pipes fluid)
                        if last_pipe_data.fluid_name and neighbour_fluid and (last_pipe_data.fluid_name ~= neighbour_fluid) then
                            --? Within, if the last pipe has a fluid name see if the neighbour has a fluid. If so, do they match? If not clamp that neighbour. Allows parallel pipe laying of dissimilar fluids.
                            neighbour.surface.create_entity {
                                name = 'flying-text',
                                position = neighbour.position,
                                text = {'pipe-tools.mismatch'},
                                time_to_live = 120,
                                speed = 0,
                                color = utils.color.red
                            }
                            pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                        else
                            --? Clamp the neighbour if it's part of an existing pipeline
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        end
                    elseif not last_pipe or (last_pipe and Position.distance(entity.position, last_pipe.position) ~= 1) then --? Catches all other cases
                        pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                    end
                end
            elseif not pdata.disable_auto_clamp and neighbour.type == 'storage-tank' then
                --? If it's not a pipe, we need to clamp our own pipe instead.
                local neighbour_fluid = get_pipe_info(neighbour).fluid_name
                --? NOTES: Try simple entity placement to prevent spam.
                if current_fluid then --?
                    if current_fluid ~= neighbour_fluid then --?
                        entity.surface.create_entity {
                            name = 'flying-text',
                            position = entity.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = utils.color.red
                        }
                        clamp_self = neighbour
                    end
                elseif last_pipe and neighbour ~= last_pipe and Position.distance(entity.position, last_pipe.position) == 1 then
                    if last_pipe_data.fluid_name and neighbour_fluid and (last_pipe_data.fluid_name ~= neighbour_fluid) then
                        --? Last tracked fluid
                        entity.surface.create_entity {
                            name = 'flying-text',
                            position = entity.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = utils.color.red
                        }
                        clamp_self = neighbour
                    end
                end
            end
        end
    end
    for _, entities in pairs(pipes_to_clamp) do
        clamp_pipe(entities, player, false, true, entity)
    end
    if clamp_self then
        clamp_pipe(entity, player, false, true, clamp_self)
    end
end

local function un_clamp_pipe(entity, player, area_unclamp)
    local old_entity_unit_number = entity.unit_number
    local pos = entity.position
    local filter_table = entity.fluidbox.get_filter(1)
    local event_data = {
        entity = entity,
        player_index = player.index
    }
    script.raise_event(defines.events.script_raised_destroy, event_data)
    local new =
        entity.surface.create_entity {
        name = entity.prototype.mineable_properties.products[1].name,
        position = pos,
        force = entity.force,
        fast_replace = true,
        spill = false
    }
    if not area_unclamp then
        new.surface.create_entity {
            name = 'flying-text',
            position = pos,
            text = {'pipe-tools.unclamped'},
            color = utils.color.yellow
        }
    end
    new.last_user = player
    new.fluidbox.set_filter(1, filter_table)
    local event = {
        created_entity = new,
        player_index = player.index,
        clamped = true,
        replaced_entity_unit_number = old_entity_unit_number
    }
    script.raise_event(defines.events.script_raised_built, event)
    if entity then
        entity.destroy()
    end
    pipe_autoclamp_clamp(event, true)
end

local function toggle_pipe_clamp(event)
    local player = game.players[event.player_index]
    local pforce = player.force

    local tool = utils.selection_tool_event[event.name]
    if tool and event.item ~= 'picker-pipe-clamper' then
        return
    end

    local selected = player.selected
    local clamp = event.name == defines.events.on_player_selected_area or (not tool and selected and selected.type == 'pipe')
    local entities = event.entities or {selected}
    local player_held_type = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.prototype and player.cursor_stack.prototype.place_result and player.cursor_stack.prototype.place_result.type

    for _, entity in pairs(entities) do
        if entity.valid then
            local name, type = entity.name, entity.type

            if (player_held_type == 'pipe' or player_held_type == 'pipe-to-ground') and entity.force == pforce then
                if clamp then
                    if entity.type == 'pipe' and not not_clampable(name) then
                        clamp_pipe(entity, player, not tool and clamp, false, false, tool)
                    end
                else
                    if type == 'pipe-to-ground' and name:find('%-clamped%-') then
                        un_clamp_pipe(entity, player, tool)
                    end
                end
            end
        end
    end
end

local function on_built_entity(event)
    if event.created_entity and event.created_entity.type == 'pipe' and not not_clampable(event.created_entity.name) then
        local _, pdata = Player.get(event.player_index)
        --? Store position ahead of time. Entity can be invalidated (replaced) during the following function before storing it's position.
        local position_to_save = event.created_entity.position
        pipe_autoclamp_clamp(event, false)
        pdata.last_pipe_position = position_to_save
    end
end

local function on_player_rotated_entity(event)
    if event.entity and event.entity.name:find('%-clamped%-') then
        pipe_autoclamp_clamp(event, true)
    end
end

local function toggle_auto_clamp(event)
    local player, pdata = Player.get(event.player_index)
    if utils.truthy[event.parameter] then
        pdata.disable_auto_clamp = false
    elseif utils.falsey[event.parameter] then
        pdata.disable_auto_clamp = true
    else
        pdata.disable_auto_clamp = not pdata.disable_auto_clamp
    end
    player.print({'pipe-tools.auto-clamp', pdata.disable_auto_clamp and {'pipe-tools.off'} or {'pipe-tools.on'}})
    return pdata.disable_auto_clamp
end

if settings.startup['picker-tool-pipe-clamps'].value then
    Event.register('picker-toggle-pipe-clamp', toggle_pipe_clamp)
    Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, toggle_pipe_clamp)
    Event.register(defines.events.on_built_entity, on_built_entity)
    Event.register(defines.events.on_player_rotated_entity, on_player_rotated_entity)
    Event.register('picker-auto-clamp-toggle', toggle_auto_clamp)
    commands.add_command('autoclamp', {'autoclamp-commands.toggle-autoclamp'}, toggle_auto_clamp)
end
--remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
