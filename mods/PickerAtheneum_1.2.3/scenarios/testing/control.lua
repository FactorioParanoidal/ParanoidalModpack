local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Position = require('__stdlib__/stdlib/area/position')
__DebugAdapter.levelPath('PickerAtheneum', 'scenarios/testing/')

local config = require('__PickerAtheneum__/scenarios/testing/config')
local area = Area():expand(7 * 32)
local rolling_stock = {
    ['locomotive'] = true,
    ['cargo-wagon'] = true,
    ['artillery-wagon'] = true,
    ['fluid-wagon'] = true
}

local water1 = Position(-1, 2)
local water2 = Position(0, 2)

local function map_gen_settings(surface)
    local mgs = surface.map_gen_settings
    local _, width, height = area:size()
    -- width :: uint: Width in tiles. If 0, the map has infinite width.
    -- height :: uint: Height in tiles. If 0, the map has infinite height.
    -- starting_area :: MapGenSize: Size of the starting area.
    -- peaceful_mode :: boolean: Whether peaceful mode is enabled for this map.

    if mgs.width ~= 0 and (mgs.width < width or mgs.height < height) then
        mgs.width = width
        mgs.height = height
        mgs.default_enable_all_autoplace_controls = false

        for _, resource in pairs(mgs.autoplace_controls) do
            resource.frequency = 0
            resource.size = 0
            resource.richness = 0
        end

        mgs.cliff_settings.richness = 0

        surface.map_gen_settings = mgs
    end
end

local function create_bp_from_string(surface, force)
    -- Create proxy blueprint from string, read in the entities and remove it.
    local bp = surface.create_entity{name = 'item-on-ground', position = {0, 0}, force = force, stack = 'blueprint'}
    bp.stack.import_stack(config.bpstring)
    local revive = bp.stack.build_blueprint{
        surface = surface,
        force = force,
        position = {0, 2},
        force_build = true,
        skip_fog_of_war = false
    }
    local count = #revive
    for i, ent in ipairs(revive) do
        -- put rolling stock at the end.
        if i < count and rolling_stock[ent.ghost_type] then
            revive[#revive + 1] = ent
        else
            if ent.ghost_type == 'locomotive' then
                local _, loco = ent.revive()
                loco.burner.currently_burning = 'rocket-fuel'
                loco.burner.remaining_burning_fuel = 222222222
            else
                ent.revive()
            end
        end
    end
    bp.destroy()
    if game.entity_prototypes['debug-energy-interface'] then
        local es = surface.create_entity{
            name = 'debug-energy-interface',
            position = {0, 0},
            force = force,
            raise_built = true
        }
        es.destructible = false
    end
    if game.entity_prototypes['debug-substation'] then
        local sb = surface.create_entity{
            name = 'debug-substation',
            position = {0, 0},
            force = force,
            raise_built = true
        }
        sb.destructible = false
    end
end

local function get_lab_tile_grid()
    local tiles = {}
    local floor_tile = 'lab-dark-1'
    local floor_tile_alt = 'lab-dark-2'
    for x = area.left_top.x, area.right_bottom.x - 1 do
        for y = area.left_top.y, area.right_bottom.y - 1 do
            if y % 2 == 0 then
                if x % 2 == 0 then
                    tiles[#tiles + 1] = {name = floor_tile, position = {x = x, y = y}}
                else
                    tiles[#tiles + 1] = {name = floor_tile_alt, position = {x = x, y = y}}
                end
            else
                if x % 2 ~= 0 then
                    tiles[#tiles + 1] = {name = floor_tile, position = {x = x, y = y}}
                else
                    tiles[#tiles + 1] = {name = floor_tile_alt, position = {x = x, y = y}}
                end
            end
        end
    end
    return tiles
end

local function create_grid(surface)
    local black = {r = 0, g = 0, b = 0}
    for x = 32, area.right_bottom.x, 32 do
        for y = 32, area.right_bottom.y, 32 do
            -- Horizontal
            rendering.draw_line{
                width = 2,
                color = black,
                from = {x = x, y = -y},
                to = {x = -x, y = -y},
                surface = surface,
                only_in_alt_mode = true
            }
            rendering.draw_line{
                width = 2,
                color = black,
                from = {x = x, y = y},
                to = {x = -x, y = y},
                surface = surface,
                only_in_alt_mode = true
            }
            -- Vertical
            rendering.draw_line{
                width = 2,
                color = black,
                from = {x = -x, y = y},
                to = {x = -x, y = -y},
                surface = surface,
                only_in_alt_mode = true
            }
            rendering.draw_line{
                width = 2,
                color = black,
                from = {x = x, y = y},
                to = {x = x, y = -y},
                surface = surface,
                only_in_alt_mode = true
            }
        end
    end
    -- Center
    rendering.draw_line{
        width = 2,
        color = black,
        from = {x = area.right_bottom.x, y = 0},
        to = {x = area.left_top.x, y = 0},
        surface = surface,
        only_in_alt_mode = true
    }
    rendering.draw_line{
        width = 2,
        color = black,
        from = {x = 0, y = area.right_bottom.y},
        to = {x = 0, y = area.left_top.y},
        surface = surface,
        only_in_alt_mode = true
    }
    rendering.draw_circle{
        width = 2,
        color = black,
        surface = surface,
        radius = 1,
        filled = false,
        target = {x = 0, y = 0},
        only_in_alt_mode = true
    }

    for chunk in surface.get_chunks() do
        rendering.draw_text{
            text = chunk.x .. ', ' .. chunk.y,
            surface = surface,
            target = chunk.area.left_top,
            -- target_offset=,
            color = defines.color.white,
            scale = 1.25,
            -- font=,
            -- time_to_live=,
            -- forces=,
            -- players=,
            -- visible=,
            draw_on_ground = true,
            orientation = 0,
            -- alignment=,
            scale_with_zoom = true,
            only_in_alt_mode = true
        }
    end
end

local function create_starting_resources(surface)
    -- Top left
    for pos in Area{{-37.5, -27.5}, {-32.5, -4.5}}:iterate(true) do
        surface.create_entity{name = 'coal', position = pos, amount = 2500}
    end
    -- Top Right
    for pos in Area{{32.5, -27.5}, {37.5, -4.5}}:iterate(true) do
        surface.create_entity{name = 'iron-ore', position = pos, amount = 2500}
    end
    -- Top Middle left
    for pos in Area{{-27.5, -37.5}, {-4.5, -32.5}}:iterate(true) do
        surface.create_entity{name = 'uranium-ore', position = pos, amount = 2500}
    end
    -- Top middle right
    for pos in Area{{4.5, -37.5}, {27.5, -32.5}}:iterate(true) do
        surface.create_entity{name = 'uranium-ore', position = pos, amount = 2500}
    end
    -- Bottom Right
    for pos in Area{{32.5, 4.5}, {37.5, 27.5}}:iterate(true) do
        surface.create_entity{name = 'copper-ore', position = pos, amount = 2500}
    end
    -- Bottom Left
    for pos in Area{{-37.5, 4.5}, {-32.5, 27.5}}:iterate(true) do
        surface.create_entity{name = 'stone', position = pos, amount = 2500}
    end
    surface.create_entity{name = 'crude-oil', position = {-35.5, 1.5}, amount = 32000}
    surface.create_entity{name = 'crude-oil', position = {-35.5, -1.5}, amount = 32000}
    surface.create_entity{name = 'crude-oil', position = {35.5, 1.5}, amount = 32000}
    surface.create_entity{name = 'crude-oil', position = {35.5, -1.5}, amount = 32000}
end

local function chart_area(surface, starting_area, force)
    local chart = starting_area()
    chart.right_bottom.x = chart.right_bottom.x - 32
    chart.right_bottom.y = chart.right_bottom.y - 32
    force.chart(surface, chart)
end

local function conditional_on_chunk_generated(event)
    local chunk_pos = Position(event.position)
    local surface = event.surface
    if surface == game.surfaces[1] and (chunk_pos == water1 or chunk_pos == water2) then
        local water_tiles = {}
        for pos in Area(event.area):shrink(1):iterate(true, true) do
            water_tiles[#water_tiles + 1] = {name = 'water', position = pos}
        end
        surface.set_tiles(water_tiles, false)
        global.water1_generated = global.water1_generated or chunk_pos == water1
        global.water2_generated = global.water2_generated or chunk_pos == water2
    end
    if global.water1_generated and global.water2_generated then
        Event.remove(defines.events.on_chunk_generated, conditional_on_chunk_generated)
    end
end

local function on_init()
    local force = game.forces['player']
    local surface = game.surfaces['nauvis']

    surface.generate_with_lab_tiles = true
    surface.always_day = true

    map_gen_settings(surface)

    for _, entity in pairs(surface.find_entities_filtered{area = area, type = 'character', invert = true}) do
        entity.destroy()
    end

    surface.set_tiles(get_lab_tile_grid(), true)
    surface.destroy_decoratives(area)

    create_grid(surface)

    chart_area(surface, area, force)

    create_starting_resources(surface)

    create_bp_from_string(surface, force)

    if surface.is_chunk_generated(water1) and surface.is_chunk_generated(water2) then
        global.water1_generated, global.water2_generated = true, true
    else
        Event.register(defines.events.on_chunk_generated, conditional_on_chunk_generated)
    end
end
Event.on_init(on_init)

local function on_load()
    if not (global.water1_generated and global.water2_generated) then
        Event.register(defines.events.on_chunk_generated, conditional_on_chunk_generated)
    end
end
Event.on_load(on_load)

local function on_player_created(event)
    local player = game.get_player(event.player_index)
    player.cheat_mode = true

    local main_inv = player.get_main_inventory()
    main_inv.clear()
    for name, count in pairs(config.items) do
        if game.item_prototypes[name] then main_inv.insert({name = name, count = count}) end
    end

    if player.character then
        local gun_inv = player.get_inventory(defines.inventory.character_guns)
        gun_inv.clear()
        for name, count in pairs(config.weapons) do
            if game.item_prototypes[name] then gun_inv.insert({name = name, count = count}) end
        end

        if game.item_prototypes['power-armor-mk2'] then
            player.get_inventory(defines.inventory.character_armor).insert('power-armor-mk2')
            local grid = player.character.grid
            if grid then
                for _, eq in pairs(config.equipment) do
                    if game.equipment_prototypes[eq] then grid.put{name = eq} end
                end
            end
        end
    end
end
Event.on_event(defines.events.on_player_created, on_player_created)

local function on_player_cheat_mode_enabled(event)
    local player = game.get_player(event.player_index)
    player.force.research_all_technologies()
    player.clear_recipe_notifications()
    local character = player.character
    if character then
        player.character_running_speed_modifier = 2
        player.character_reach_distance_bonus = 200
        player.character_build_distance_bonus = 200
    end
end
Event.on_event(defines.events.on_player_cheat_mode_enabled, on_player_cheat_mode_enabled)

local function on_player_promoted(event)
    local player = game.get_player(event.player_index)
    player.clear_recipe_notifications()
end
Event.on_event(defines.events.on_player_promoted, on_player_promoted)
