local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Area = require('__stdlib__/stdlib/area/area')
local Position = require('__stdlib__/stdlib/area/position')
local Color = require('__stdlib__/stdlib/utils/color')

local config = require('__PickerAtheneum__/scenarios/testing/config')

local map_area = Area():adjust({config.width / 2, config.height / 2})
local center_chunk_position = Position()
local initial_area = Area()
local initial_chunks = Area()
local water_chunks = {Position(-1, 2), Position(0, 2)}

local rolling_stock = {
    ['locomotive'] = true,
    ['cargo-wagon'] = true,
    ['artillery-wagon'] = true,
    ['fluid-wagon'] = true
}
local color = {r = 1, g = 1, b = 1}


local function set_map_gen_settings(surface)
    local mgs = surface.map_gen_settings
    local _, width, height = map_area:size()
    -- width :: uint: Width in tiles. If 0, the map has infinite width.
    -- height :: uint: Height in tiles. If 0, the map has infinite height.
    -- starting_area :: MapGenSize: Size of the starting area.
    -- peaceful_mode :: boolean: Whether peaceful mode is enabled for this map.

    initial_area = initial_area:adjust({mgs.width / 2, mgs.height / 2})
    initial_chunks = initial_area:to_chunk_coords():expand(1)

    global.initial_chunk_count = #initial_chunks:positions()
    global.water_count = #water_chunks
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
    surface.generate_with_lab_tiles = true
    surface.always_day = true
    surface.force_generate_chunk_requests()
end

local function create_bp_from_string(surface, force)
    -- Create proxy blueprint from string, read in the entities and remove it.
    local bp = surface.create_entity{name = 'item-on-ground', position = {0, 0}, force = force, stack = 'blueprint'}
    bp.stack.import_stack(config.bpstring)
    local revive = bp.stack.build_blueprint{
        surface = surface,
        force = force,
        position = {0, 0},
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
                if loco then
                    loco.burner.currently_burning = 'rocket-fuel'
                    loco.burner.remaining_burning_fuel = 222222222
                end
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

local function generate_lab_tile_grid(surface, chunk_area)
    local tiles = {}
    local floor_tile = 'lab-dark-1'
    local floor_tile_alt = 'lab-dark-2'
    for x = chunk_area.left_top.x, chunk_area.right_bottom.x - 1 do
        for y = chunk_area.left_top.y, chunk_area.right_bottom.y - 1 do
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
    surface.set_tiles(tiles, false)
end

local function render_center_point(surface)
    rendering.draw_circle{
        width = 2,
        color = color,
        surface = surface,
        radius = 1,
        filled = false,
        target = {x = 0, y = 0},
        only_in_alt_mode = true
    }
end

local function render_chunk_grid(surface, chunk_area, chunk_position)
    local left_top = chunk_area.left_top
    local right_bottom = chunk_area.right_bottom

    local function render_chunk_boundries(from, to)
        rendering.draw_line{width = 2, color = color, from = from, to = to, surface = surface, only_in_alt_mode = true}
    end

    render_chunk_boundries({left_top.x, left_top.y}, {right_bottom.x, left_top.y})
    render_chunk_boundries({left_top.x, right_bottom.y}, {right_bottom.x, right_bottom.y})
    render_chunk_boundries({left_top.x, left_top.y}, {left_top.x, right_bottom.y})
    render_chunk_boundries({right_bottom.x, left_top.y}, {right_bottom.x, right_bottom.y})

    rendering.draw_text{
        text = chunk_position.x .. ', ' .. chunk_position.y,
        surface = surface,
        target = left_top,
        color = Color.color.white,
        scale = 1.25,
        draw_on_ground = true,
        orientation = 0,
        scale_with_zoom = true,
        only_in_alt_mode = true
        -- target_offset=,
        -- font=,
        -- alignment=,
        -- time_to_live=,
        -- forces=,
        -- players=,
        -- visible=,
    }
end

local function generate_starting_resources(surface)
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

local function chart_area(surface, force)
    local chart = map_area()
    chart.right_bottom.x = chart.right_bottom.x - 32
    chart.right_bottom.y = chart.right_bottom.y - 32
    force.chart(surface, chart)
end

local function generate_water(surface, chunk_area)
    local water_tiles = {}
    for pos in chunk_area:shrink(1):iterate(true, true) do
        water_tiles[#water_tiles + 1] = {name = 'water', position = pos}
    end
    surface.set_tiles(water_tiles, false)
end

local function on_init()
    local force = game.forces['player']
    local surface = game.surfaces['nauvis']

    set_map_gen_settings(surface)

    generate_starting_resources(surface)
    create_bp_from_string(surface, force)

    chart_area(surface, force)
end
Event.on_init(on_init)

local function on_chunk_generated(event)
    local surface = event.surface
    local chunk_area = Area.load(event.area)
    local chunk_position = Position.load(event.position)

    surface.destroy_decoratives(chunk_area)
    for _, entity in pairs(surface.find_entities_filtered{area = chunk_area, type = 'character', invert = true}) do
        entity.destroy()
    end

    -- Generate water
    if global.water_count > 0 then
        for _, pos in pairs(water_chunks) do
            if pos == chunk_position then generate_water(surface, chunk_area) end
        end
    end

    -- Generate initial grid tiles
    if global.initial_chunk_count > 0 and chunk_position:inside(initial_chunks) then
        generate_lab_tile_grid(surface, chunk_area)
        global.initial_chunk_count = global.initial_chunk_count - 1
    end


    -- Generate resources
    if global.initial_chunk_count == 0 and not global.resources_generated then
        generate_starting_resources(surface)
        create_bp_from_string(surface, game.forces['player'])
        global.resources_generated = true
    end

    -- Renderings
    if chunk_position == center_chunk_position then render_center_point(surface) end
    render_chunk_grid(surface, chunk_area, chunk_position)
end
Event.on_event(defines.events.on_chunk_generated, on_chunk_generated)

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
