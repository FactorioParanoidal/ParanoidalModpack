-------------------------------------------------------------------------------
--[[Pipe Highlighter]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Player = require('__stdlib__/stdlib/event/player')
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local Direction = require('__stdlib__/stdlib/area/direction')
local utils = require('scripts/utils')
local pipe_connections = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

--? Tables for read-limits
local allowed_types = {
    ['pipe'] = true,
    ['pipe-to-ground'] = true,
    ['pump'] = true
}

local not_allowed_names = {
    ['factory-fluid-dummy-connector'] = true,
    ['factory-fluid-dummy-connector-south'] = true,
    ['offshore-pump-output'] = true
}

--? Bit styled table. 2 ^ defines.direction is used for entry to the table. Only compatible with 4 way directions.
local directional_table = {
    [0] = '',
    [1] = '-n',
    [4] = '-e',
    [5] = '-ne',
    [16] = '-s',
    [17] = '-ns',
    [20] = '-se',
    [21] = '-nse',
    [64] = '-w',
    [65] = '-nw',
    [68] = '-ew',
    [69] = '-new',
    [80] = '-sw',
    [81] = '-nsw',
    [84] = '-sew',
    [85] = '-nsew'
}

--? Table for types and names to draw dashes between
local draw_dashes_types = {
    ['pipe-to-ground'] = true
}
local draw_dashes_names = {
    ['underground-mini-pump'] = true,
    ['underground-mini-pump-t1'] = true,
    ['underground-mini-pump-t2'] = true,
    ['underground-mini-pump-t3'] = true,
    ['4-to-4-pipe'] = true
}

--? Entity creation name reference table
local pipe_highlight_markers = {
    pump = {
        ['normal'] = {
            [defines.direction.north] = 'picker-pump-marker-n',
            [defines.direction.east] = 'picker-pump-marker-e',
            [defines.direction.west] = 'picker-pump-marker-w',
            [defines.direction.south] = 'picker-pump-marker-s'
        },
        ['good'] = {
            [defines.direction.north] = 'picker-pump-marker-good-n',
            [defines.direction.east] = 'picker-pump-marker-good-e',
            [defines.direction.west] = 'picker-pump-marker-good-w',
            [defines.direction.south] = 'picker-pump-marker-good-s'
        },
        ['bad'] = {
            [defines.direction.north] = 'picker-pump-marker-bad-n',
            [defines.direction.east] = 'picker-pump-marker-bad-e',
            [defines.direction.west] = 'picker-pump-marker-bad-w',
            [defines.direction.south] = 'picker-pump-marker-bad-s'
        }
    },
    dot = {
        ['normal'] = 'picker-pipe-dot',
        ['good'] = 'picker-pipe-dot-good',
        ['bad'] = 'picker-pipe-dot-bad'
    },
    beam = {
        ['normal'] = 'picker-pipe-marker-beam',
        ['good'] = 'picker-pipe-marker-beam-good',
        ['bad'] = 'picker-pipe-marker-beam-bad'
    }
}

local function show_underground_sprites(event)
    local player, pdata = Player.get(event.player_index)
    local create = player.surface.create_entity
    local read_entity_data = {}
    local all_entities_marked = {}
    local all_markers = {}
    local markers_made = 0

    --? Assign working table reference to global reference under player
    pdata.current_underground_marker_table = all_markers

    local max_distance = settings.global['picker-max-distance-checked'].value

    local filter = {
        area = {{player.position.x - max_distance, player.position.y - max_distance}, {player.position.x + max_distance, player.position.y + max_distance}},
        type = {'pipe-to-ground', 'pump'},
        force = player.force
    }
    for _, entity in pairs(player.surface.find_entities_filtered(filter)) do
        local entity_unit_number = entity.unit_number
        local entity_position = entity.position
        local entity_neighbours = entity.neighbours[1]
        local entity_type = entity.type
        local entity_name = entity.name
        if (draw_dashes_types[entity_type] or draw_dashes_names[entity_name]) and not string.find(entity_name, '%-clamped%-') then
            read_entity_data[entity_unit_number] = {
                entity_position,
                entity_neighbours,
                entity_type,
                entity_name
            }
        end
    end
    for unit_number, entity_data in pairs(read_entity_data) do
        local max_neighbours = pipe_connections[entity_data[4]] or 2
        if (#entity_data[2]) < max_neighbours then
            markers_made = markers_made + 1
            all_markers[markers_made] =
                create {
                name = 'picker-pipe-marker-box-bad',
                position = entity_data[1]
            }
        else
            markers_made = markers_made + 1
            all_markers[markers_made] =
                create {
                name = 'picker-pipe-marker-box-good',
                position = entity_data[1]
            }
        end
        for _, neighbour in pairs(entity_data[2]) do
            local neighbour_unit_number = neighbour.unit_number
            local neighbour_data = read_entity_data[neighbour_unit_number]
            if neighbour_data then
                if draw_dashes_types[neighbour_data[3]] or draw_dashes_names[neighbour_data[4]] and not string.find(neighbour_data[4], '%-clamped%-') and not all_entities_marked[neighbour_unit_number] then
                    local start_position = Position.translate(entity_data[1], utils.get_direction(entity_data[1], neighbour_data[1]), 0.5)
                    local end_position = Position.translate(neighbour_data[1], utils.get_direction(neighbour_data[1], entity_data[1]), 0.5)
                    markers_made = markers_made + 1
                    all_markers[markers_made] =
                        create {
                        name = 'picker-underground-marker-beam',
                        position = entity_data[1],
                        source_position = {start_position.x, start_position.y + -0.1},
                        --TODO 0.17 source_position = {entity_position.x, entity_position.y - 0.1},
                        target_position = end_position,
                        duration = 2000000000
                    }
                end
            end
        end
        all_entities_marked[unit_number] = true
    end
end

local function destroy_markers(markers)
    if markers then
        for _, entity in pairs(markers) do
            entity.destroy()
        end
    end
end

local function highlight_underground(event)
    local _, pdata = Player.get(event.player_index)
    pdata.current_underground_marker_table = pdata.current_underground_marker_table or {}
    if next(pdata.current_underground_marker_table) then
        destroy_markers(pdata.current_underground_marker_table)
        pdata.current_underground_marker_table = nil
    else
        show_underground_sprites(event)
    end
end
Event.register('picker-show-underground-paths', highlight_underground)

local function highlight_pipeline(starter_entity, player_index)
    local player, pdata = Player.get(player_index)
    --? Declare working tables
    local read_entity_data = {}
    local read_neighbour_data = {}
    local all_entities_marked = {}
    local all_markers = {}
    local tracked_orphans = {}

    --? Assign working table references to global reference under player
    pdata.current_marker_table = all_markers
    pdata.current_pipeline_table = all_entities_marked

    --? Setting and cache create entity function
    -- TODO max_pipes can be cached at the TLD and updated in settings changed event
    local max_pipes = settings.global['picker-max-checked-pipes'].value
    local create = starter_entity.surface.create_entity

    --? Variables
    local orphan_counter = 0
    local pipes_read = 0
    local markers_made = 0

    local function draw_marker(position, type, directions)
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create {
            name = pipe_highlight_markers.dot[type] .. directional_table[directions],
            position = position
        }
    end

    --? Handles drawing dashes between two pipe to ground.
    local function draw_dashes(entity_position, neighbour_position, type)
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create {
            name = pipe_highlight_markers.beam[type],
            position = entity_position,
            source_position = {entity_position.x, entity_position.y - 0.1},
            target_position = {neighbour_position.x, neighbour_position.y - 0.1},
            duration = 2000000000
        }
    end

    local function get_directions(entity_position, entity_neighbours, pump)
        local table_entry = 0
        local directions_table = {}
        --? Store the direction as the index to the table. This allows multiple references to the same direction, such as in the case of pipemod pipes.
        for _, neighbour_unit_number in pairs(entity_neighbours) do
            local current_neighbour = read_entity_data[neighbour_unit_number]
            if current_neighbour then
                --end
                --if not (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) then
                directions_table[utils.get_direction(entity_position, current_neighbour[1])] = true
            else
                local alternate_neighbour = read_neighbour_data[neighbour_unit_number]
                if alternate_neighbour then
                    directions_table[utils.get_direction(entity_position, alternate_neighbour[1])] = true
                end
            end
        end
        if pump then --? This just ensures marking against a rail.
            if (entity_neighbours[1] and not entity_neighbours[2]) then
                local neighbour_to_check = (read_entity_data[entity_neighbours[1]] and read_entity_data[entity_neighbours[1]][1]) or (read_neighbour_data[entity_neighbours[1]] and read_neighbour_data[entity_neighbours[1]][1])
                local check_direction = utils.get_direction(neighbour_to_check, entity_position)
                local rail_connection = player.surface.find_entities_filtered {position = Position(entity_position):translate(check_direction, 1.5), type = 'straight-rail'}[1]
                if rail_connection then
                    directions_table[check_direction] = true
                end
            end
        end
        for directions, _ in pairs(directions_table) do
            table_entry = table_entry + (2 ^ directions)
        end
        return table_entry
    end

    local function draw_pump_marker(position, type, direction, pump_neighbours)
        local name = pipe_highlight_markers.pump[type][direction]
        if type == 'bad' then
            name = pipe_highlight_markers.pump[type][direction] .. directional_table[get_directions(position, pump_neighbours, true)]
        end
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create {
            name = name,
            position = position
        }
    end

    --? Gather and cache pipeline info.
    local function read_pipeline(entity, entity_unit_number, entity_position, entity_type, entity_name)
        local entity_neighbours = entity.neighbours[1]
        pipes_read = pipes_read + 1
        --? Stored as indexed array internally.
        read_entity_data[entity_unit_number] = {
            entity_position,
            entity_neighbours,
            entity_type,
            entity_name,
            entity
        }
        --? Checks for orphans
        if #entity_neighbours < 2 then
            if entity_type == 'pump' and not draw_dashes_names[entity_name] then
                --? If it's a pump, and it does have one neighbour, see if the other side is a rail.
                if (#entity_neighbours == 1) then
                    --? Get directional relation from connected neighbour to pump
                    local check_direction = utils.get_direction(entity_neighbours[1].position, entity_position)
                    --? Then translate in that direction outwards to see if there's a track.
                    local rail_connection = player.surface.find_entities_filtered {position = Position(entity_position):translate(check_direction, 1.5), type = 'straight-rail'}[1]
                    if rail_connection then
                        local current_direction = utils.get_direction(entity_position, rail_connection.position)
                        draw_marker(Position(entity_position):translate(current_direction, 1.5), 'good', 2 ^ Direction.opposite_direction(current_direction))
                    else
                        orphan_counter = orphan_counter + 1
                        tracked_orphans[entity_unit_number] = true
                    end
                else
                    --? If it's a pump and doesn't report having a neighbour, I'm not even gonna check if there's a track. It's an orphan.
                    orphan_counter = orphan_counter + 1
                    tracked_orphans[entity_unit_number] = true
                end
            else
                orphan_counter = orphan_counter + 1
                tracked_orphans[entity_unit_number] = true
            end
        end
        for neighbour_index_number, neighbour in pairs(entity_neighbours) do
            --? Pre-cache all data
            local neighbour_type = neighbour.type
            local neighbour_name = neighbour.name
            local neighbour_position = neighbour.position
            local neighbour_unit_number = neighbour.unit_number
            entity_neighbours[neighbour_index_number] = neighbour_unit_number
            --? Make sure we stick with pipes/pumps and don't read disallowed names (Such as factorissimo)
            if allowed_types[neighbour_type] and not not_allowed_names[neighbour_name] then
                --? Verify we haven't been here before
                if not read_entity_data[neighbour_unit_number] then
                    --? Ensures reading and marking no more than maximum pipes per the setting.
                    if pipes_read < max_pipes then
                        --? Step to next pipe
                        read_pipeline(neighbour, neighbour_unit_number, neighbour_position, neighbour_type, neighbour_name)
                    end
                end
            else
                --? Store and mark objects that aren't allowed to be traversed to. (Endpoints such as storage-tank, oil-refinery, etc.)
                read_neighbour_data[neighbour_unit_number] = {
                    neighbour_position,
                    neighbour_type,
                    neighbour_name,
                    neighbour
                }
                local current_direction = utils.get_direction(entity_position, neighbour_position)
                local draw_marker_distance
                if entity_type == 'pump' then
                    --? Pumps are longer. Marker has to be bumped a little further.
                    draw_marker_distance = 1.5
                else
                    draw_marker_distance = 1
                end
                --? This marks from the neighbour to the current entity. This ensures properly aligned markers that connect to the current entity.
                draw_marker(Position(entity_position):translate(current_direction, draw_marker_distance), 'good', 2 ^ Direction.opposite_direction(current_direction))
                all_entities_marked[neighbour_unit_number] = true
            end
        end
    end

    --? Entry point to read pipeline
    local starter_unit_number = starter_entity.unit_number
    local starter_entity_name = starter_entity.name
    local starter_entity_type = starter_entity.type
    local starter_entity_position = starter_entity.position
    read_pipeline(starter_entity, starter_unit_number, starter_entity_position, starter_entity_type, starter_entity_name)

    local function step_to_junction(entity_unit_number)
        --? Grab cached data. Removes need for API calls alltogether at this stage.
        local entity = read_entity_data[entity_unit_number]
        --? Mark current entity
        if entity[3] == 'pump' and not draw_dashes_names[entity[4]] then
            draw_pump_marker(entity[1], 'bad', entity[5].direction, entity[2])
        else
            draw_marker(entity[1], 'bad', get_directions(entity[1], entity[2]))
        end
        all_entities_marked[entity_unit_number] = true
        for _, neighbour_unit_number in pairs(entity[2]) do
            local current_neighbour = read_entity_data[neighbour_unit_number]
            if current_neighbour then
                --? If it's a pump or certain other entities, draw dashes between it and the neighbour if that neighbour is also a pump or other certain entities.
                if (draw_dashes_types[entity[3]] or draw_dashes_names[entity[4]]) and not string.find(entity[4], '%-clamped%-') then
                    if (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) and not string.find(current_neighbour[4], '%-clamped%-') then
                        draw_dashes(entity[1], current_neighbour[1], 'bad')
                    --TODO 0.17 draw_dashes(current_neighbour[1], entity[1], 'bad')
                    end
                end
                --? Check to see if it's still part of a pipeline. If it's a junction, it will not step any further.
                if #current_neighbour[2] < 3 and not all_entities_marked[neighbour_unit_number] then
                    step_to_junction(neighbour_unit_number)
                end
            end
        end
    end

    if orphan_counter > 0 then
        for unit_number, _ in pairs(tracked_orphans) do
            local current_orphan = read_entity_data[unit_number]
            if current_orphan[3] == 'pump' and not draw_dashes_names[current_orphan[4]] then
                draw_pump_marker(current_orphan[1], 'bad', current_orphan[5].direction, current_orphan[2])
            else
                markers_made = markers_made + 1
                all_markers[markers_made] =
                    create {
                    name = 'picker-pipe-marker-box-bad',
                    position = current_orphan[1]
                }
                draw_marker(current_orphan[1], 'bad', get_directions(current_orphan[1], current_orphan[2]))
            end
            all_entities_marked[unit_number] = true
            for _, neighbour_unit_number in pairs(current_orphan[2]) do
                local current_neighbour = read_entity_data[neighbour_unit_number]
                if current_neighbour then
                    if (draw_dashes_types[current_orphan[3]] or draw_dashes_names[current_orphan[4]]) and not string.find(current_orphan[4], '%-clamped%-') then
                        if (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) and not string.find(current_neighbour[4], '%-clamped%-') then
                            draw_dashes(current_orphan[1], current_neighbour[1], 'bad')
                        --TODO 0.17 draw_dashes(current_neighbour[1], current_orphan[1], 'bad')
                        end
                    end
                    if #current_neighbour[2] < 3 and not all_entities_marked[neighbour_unit_number] then
                        step_to_junction(neighbour_unit_number)
                    end
                end
            end
        end --? Anything that wasn't marked as an orphan that is part of this pipeline will be marked in yellow.
        for unit_number, current_entity in pairs(read_entity_data) do
            if not all_entities_marked[unit_number] then
                if draw_dashes_types[current_entity[3]] or draw_dashes_names[current_entity[4]] then
                    for _, neighbour_unit_number in pairs(current_entity[2]) do
                        local current_neighbour = read_entity_data[neighbour_unit_number]
                        if current_neighbour then
                            if (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) and not string.find(current_neighbour[4], '%-clamped%-') and not all_entities_marked[neighbour_unit_number] then
                                draw_dashes(current_entity[1], current_neighbour[1], 'normal')
                            end
                        end
                    end
                end
                if current_entity[3] == 'pump' and not draw_dashes_names[current_entity[4]] then
                    draw_pump_marker(current_entity[1], 'normal', current_entity[5].direction)
                else
                    draw_marker(current_entity[1], 'normal', get_directions(current_entity[1], current_entity[2]))
                end
                all_entities_marked[unit_number] = true
            end
        end
    else
        --? If there's not an orphan, mark the whole line green.
        for unit_number, current_entity in pairs(read_entity_data) do
            if not all_entities_marked[unit_number] then
                if draw_dashes_types[current_entity[3]] or draw_dashes_names[current_entity[4]] then
                    for _, neighbour_unit_number in pairs(current_entity[2]) do
                        local current_neighbour = read_entity_data[neighbour_unit_number]
                        if current_neighbour then
                            if not all_entities_marked[neighbour_unit_number] and not string.find(current_neighbour[4], '%-clamped%-') and (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) then
                                draw_dashes(current_entity[1], current_neighbour[1], 'good')
                            end
                        end
                    end
                end
                if current_entity[3] == 'pump' and not draw_dashes_names[current_entity[4]] then
                    draw_pump_marker(current_entity[1], 'good', current_entity[5].direction)
                else
                    draw_marker(current_entity[1], 'good', get_directions(current_entity[1], current_entity[2]))
                end
                all_entities_marked[unit_number] = true
            end
        end
    end
    if player.mod_settings['picker-count-pipes-highlighted'].value then
        player.print(pipes_read .. ' pipes found in currently selected network')
    end
end

local function get_pipeline(event)
    local player, pdata = Player.get(event.player_index)
    pdata.current_pipeline_table = pdata.current_pipeline_table or {}
    pdata.current_marker_table = pdata.current_marker_table or {}
    if not pdata.disable_auto_highlight then
        local selection = player.selected
        -- TODO Faster check if table method possibly
        if selection and allowed_types[selection.type] then
            if not pdata.current_pipeline_table[selection.unit_number] then
                if next(pdata.current_pipeline_table) then
                    destroy_markers(pdata.current_marker_table)
                    pdata.current_pipeline_table = nil
                    pdata.current_marker_table = nil
                end
                highlight_pipeline(selection, event.player_index)
            end
        else
            if next(pdata.current_pipeline_table) then
                destroy_markers(pdata.current_marker_table)
                pdata.current_pipeline_table = nil
                pdata.current_marker_table = nil
            end
        end
    end
end
Event.register(defines.events.on_selected_entity_changed, get_pipeline)

local function highlight_update_rotated(event)
    local entity = event.entity
    if entity and string.find(entity.name, '%-clamped%-') then
        local _, pdata = Player.get(event.player_index)
        pdata.current_pipeline_table = pdata.current_pipeline_table or {}
        pdata.current_marker_table = pdata.current_marker_table or {}
        if next(pdata.current_pipeline_table) then
            destroy_markers(pdata.current_marker_table)
            pdata.current_pipeline_table = nil
            pdata.current_marker_table = nil
            highlight_pipeline(entity, event.player_index)
        end
    end
end
Event.register(defines.events.on_player_rotated_entity, highlight_update_rotated)

local function clear_markers(event)
    local player, _ = Player.get(event.player_index)
    if player.admin then
        for _, pdata in pairs(global.players) do
            destroy_markers(pdata.current_marker_table)
            pdata.current_pipeline_table = nil
            pdata.current_marker_table = nil
            destroy_markers(pdata.current_underground_marker_table)
            pdata.current_underground_marker_table = nil
        end
    end
end
commands.add_command('clear-all-markers', {'highlight-commands.clear-markers'}, clear_markers)

local function toggle_auto_highlight(event)
    local player, pdata = Player.get(event.player_index)
    if utils.truthy[event.parameter] then
        pdata.disable_auto_highlight = false
    elseif utils.falsey[event.parameter] then
        pdata.disable_auto_highlight = true
    else
        pdata.disable_auto_highlight = not pdata.disable_auto_highlight
    end
    if pdata.disable_auto_highlight then
        if pdata.current_pipeline_table and next(pdata.current_pipeline_table) then
            destroy_markers(pdata.current_marker_table)
            pdata.current_pipeline_table = nil
            pdata.current_marker_table = nil
        end
    else
        get_pipeline(event)
    end
    player.print({'pipe-tools.auto-highlight', pdata.disable_auto_highlight and {'pipe-tools.off'} or {'pipe-tools.on'}})
    return pdata.disable_auto_highlight
end
Event.register('picker-auto-highlight-toggle', toggle_auto_highlight)
