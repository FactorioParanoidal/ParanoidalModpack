local rro = require("__PlanetsLib__.lib.remove-replace-object")

local base_render_layer = "lower-object-above-shadow"

local domes = maraxsis_constants.PRESSURE_DOMES

local PRESSURE_DOME_TILES = {

}

local MARAXSIS_REGULATORS = {

}

local PRESSURE_DOMES = {

}

local MARAXSIS_DOME_COLLIDERS = {

}

for _,dome_data in pairs(domes) do
    dome_data.check_size = dome_data.octagon_size - 0.01
    dome_data.DOME_POLYGON = {
        dome_data.corner_size, dome_data.check_size,
        -dome_data.corner_size, dome_data.check_size,
        -dome_data.check_size, dome_data.corner_size,
        -dome_data.check_size, -dome_data.corner_size,
        -dome_data.corner_size, -dome_data.check_size,
        dome_data.corner_size, -dome_data.check_size,
        dome_data.check_size, -dome_data.corner_size,
        dome_data.check_size, dome_data.corner_size,
    
    }
    rro.soft_insert(PRESSURE_DOME_TILES,dome_data.PRESSURE_DOME_TILE)
    rro.soft_insert(MARAXSIS_REGULATORS,dome_data.regulator)
    rro.soft_insert(PRESSURE_DOMES,dome_data.pressure_dome)
    rro.soft_insert(MARAXSIS_DOME_COLLIDERS,dome_data.dome_collider)
end

maraxsis.on_event(maraxsis.events.on_init(), function()
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
        for dome_name,_ in pairs(domes) do
            remote.call("PickerDollies", "add_blacklist_name", dome_name)
        end
        
    end

    storage.pressure_domes = storage.pressure_domes or {}
    storage.pressure_domes_transparent = storage.pressure_domes_transparent or {} --Subset of pressure domes in some stage of transparent due to player interaction
end)

-- By Pedro Gimeno, donated to the public domain 
 function is_point_in_polygon(x, y, dome_data)
    local octagon_size = dome_data.octagon_size
    if x > octagon_size or x < -octagon_size or y > octagon_size or y < -octagon_size then
        return false
    end
    local DOME_POLYGON = dome_data.DOME_POLYGON
    local x1, y1, x2, y2
    local len = #DOME_POLYGON
    x2, y2 = DOME_POLYGON[len - 1], DOME_POLYGON[len]
    local wn = 0
    for idx = 1, len, 2 do
        x1, y1 = x2, y2
        x2, y2 = DOME_POLYGON[idx], DOME_POLYGON[idx + 1]

        if y1 > y then
            if (y2 <= y) and (x1 - x) * (y2 - y) < (x2 - x) * (y1 - y) then
                wn = wn + 1
            end
        else
            if (y2 > y) and (x1 - x) * (y2 - y) > (x2 - x) * (y1 - y) then
                wn = wn - 1
            end
        end
    end
    return wn % 2 ~= 0 -- even/odd rule
end

local function get_four_corners(entity)
    local position = entity.position
    local x, y = position.x, position.y
    local collision_box = entity.prototype.collision_box
    local orientation = entity.orientation

    if entity.type == "straight-rail" then
        orientation = (orientation + 0.25) % 1
    elseif entity.type == "cliff" then
        collision_box = {
            left_top = {x = -2, y = -2},
            right_bottom = {x = 2, y = 2},
        }
    else -- expand the collision box to the actual tile size
        collision_box = {
            left_top = {x = math.floor(collision_box.left_top.x * 2) / 2, y = math.floor(collision_box.left_top.y * 2) / 2},
            right_bottom = {x = math.ceil(collision_box.right_bottom.x * 2) / 2, y = math.ceil(collision_box.right_bottom.y * 2) / 2},
        }
    end

    local left_top = collision_box.left_top
    local right_bottom = collision_box.right_bottom

    if orientation == 0 then
        return {
            {x = x + left_top.x,     y = y + left_top.y},
            {x = x + right_bottom.x, y = y + left_top.y},
            {x = x + right_bottom.x, y = y + right_bottom.y},
            {x = x + left_top.x,     y = y + right_bottom.y},
        }
    end

    local cos = math.cos(orientation * 2 * math.pi)
    local sin = math.sin(orientation * 2 * math.pi)

    local corners = {}
    for _, corner in pairs {
        {x = left_top.x,     y = left_top.y},
        {x = right_bottom.x, y = left_top.y},
        {x = right_bottom.x, y = right_bottom.y},
        {x = left_top.x,     y = right_bottom.y},
    } do
        local corner_x, corner_y = corner.x, corner.y
        corners[#corners + 1] = {
            x = x + corner_x * cos - corner_y * sin,
            y = y + corner_x * sin + corner_y * cos,
        }
    end
    return corners
end

local function count_points_in_dome(pressure_dome_data, entity)
    local dome_position = pressure_dome_data.position
    local x, y = dome_position.x, dome_position.y
    local prototype = domes[pressure_dome_data.prototype]
    if not prototype then
        error(pressure_dome_data .. "\n" ..serpent.block( domes))
    end
    local count = 0
    for _, entity_corner in pairs(get_four_corners(entity)) do
        if is_point_in_polygon(entity_corner.x - x, entity_corner.y - y,prototype) then
            count = count + 1
        end
    end
    return count
end

--- Whether the entity needs a dome to prevent flooding.
--- @param entity LuaEntity
local function needs_dome(entity)
    return maraxsis_constants.NEEDS_DOME[entity.name] or false
end

--- Whether the entity needs a dome *with atmosphere* to prevent flooding.
--- @param entity LuaEntity
local function needs_atmosphere(entity)
    return needs_dome(entity) and not maraxsis_constants.DOME_EXCLUDED_FROM_DISABLE[entity.name]
end

local FLOODED_STATUS = {
    diode = defines.entity_status_diode.red,
    label = {"entity-status.flooded"},
}

--- Some entities only need the dome, atmosphere optional.
local FLOODED_DOME_ONLY_STATUS = {
    diode = defines.entity_status_diode.red,
    label = {"entity-status.flooded-dome-only"},
}

--- Sets or unsets an entity's flooded debuff, which prevents it from working.
--- @param entity LuaEntity
--- @param flooded boolean
local function set_flooded(entity, flooded)
    if not entity.valid or not entity.is_updatable then return end
    if entity.disabled_by_script == flooded then return end
    entity.disabled_by_script = flooded

    storage.flooded_warning_info_icons = storage.flooded_warning_info_icons or {}
    local warning = storage.flooded_warning_info_icons[entity.unit_number]

    if not flooded then
        entity.custom_status = nil
        if warning then
            warning.destroy()
            storage.flooded_warning_info_icons[entity.unit_number] = nil
        end
    else
        entity.custom_status = needs_atmosphere(entity) and FLOODED_STATUS or FLOODED_DOME_ONLY_STATUS
        if not warning then
            warning = rendering.draw_sprite {
                sprite = "maraxsis-flooded-warning",
                target = {
                    entity = entity,
                    offset = entity.prototype.alert_icon_shift
                },
                surface = entity.surface_index,
                x_scale = 1.04,
                y_scale = 1.04,
            }
            storage.flooded_warning_info_icons[entity.unit_number] = warning
        end
    end
end

--- Floods the entity in a dome if applicable.
--- @param entity LuaEntity
--- @param dome_has_atmosphere boolean
local function flood_in_dome(entity, dome_has_atmosphere)
    if not entity.valid then return end
    if needs_atmosphere(entity) then
        set_flooded(entity, not dome_has_atmosphere)
    elseif needs_dome(entity) then
        -- entity only needs a dome, atmosphere not required
        set_flooded(entity, false)
    end
end

--- Floods the entity on the seabed if applicable.
--- @param entity LuaEntity
local function flood_on_seabed(entity)
    if not entity.valid then return end
    local is_on_seabed = entity.surface.get_tile(entity.position).collides_with(maraxsis_underwater_collision_mask)
    if needs_dome(entity) and is_on_seabed then
        set_flooded(entity, true)
    end
end

maraxsis.on_nth_tick(66667, function()
    local new_warning_icons = {}
    for k, warning_icon in pairs(storage.flooded_warning_info_icons or {}) do
        if warning_icon.valid then
            new_warning_icons[k] = warning_icon
        end
    end
    storage.flooded_warning_info_icons = new_warning_icons
end)

local function create_dome_light(pressure_dome_data)
    local surface = pressure_dome_data.surface
    if not surface.valid then return end
    local dome_prototype = domes[pressure_dome_data.prototype]
    local light = surface.create_entity {
        name = dome_prototype.lamp,
        position = pressure_dome_data.position,
        force = pressure_dome_data.force_index,
        quality = pressure_dome_data.quality,
        create_build_effect_smoke = false,
    }

    light.minable_flag = false
    light.destructible = false

    local control_behavior = light.get_or_create_control_behavior()
    control_behavior.use_colors = true

    pressure_dome_data.light = light
end

local function create_dome_combinator(pressure_dome_data)
    local light = pressure_dome_data.light
    local dome_prototype = domes[pressure_dome_data.prototype]
    if not light or not light.valid then
        create_dome_light(pressure_dome_data)
        light = pressure_dome_data.light
    end

    local combinator = light.surface.create_entity {
        name = dome_prototype.combinator,
        position = light.position,
        force = light.force,
        quality = light.quality,
        create_build_effect_smoke = false,
    }

    combinator.minable_flag = false
    combinator.destructible = false
    combinator.operable = false

    local red = combinator.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green = combinator.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    local light_red = light.get_wire_connector(defines.wire_connector_id.circuit_red, false)
    local light_green = light.get_wire_connector(defines.wire_connector_id.circuit_green, false)

    local red_success = red.connect_to(light_red, false)
    local green_success = green.connect_to(light_green, false)

    assert(red_success, "Failed to connect red wire to the dome light. Please report this!")
    assert(green_success, "Failed to connect green wire to the dome light. Please report this!")

    pressure_dome_data.combinator = combinator
end

local function update_combinator(pressure_dome_data)
    local combinator = pressure_dome_data.combinator
    if not combinator or not combinator.valid then
        create_dome_combinator(pressure_dome_data)
        combinator = pressure_dome_data.combinator
    end

    local all_machines_inside = {}
    for _, e in pairs(pressure_dome_data.contained_entities) do
        if e.valid then
            local quality = e.quality.name
            for _, item_to_place in pairs(e.prototype.items_to_place_this or {}) do
                all_machines_inside[item_to_place.name] = all_machines_inside[item_to_place.name] or {}
                all_machines_inside[item_to_place.name][quality] = (all_machines_inside[item_to_place.name][quality] or 0) + 1
            end
        end
    end

    local control_behavior = combinator.get_or_create_control_behavior()

    if not control_behavior.get_section(1) then
        control_behavior.add_section()
    end

    local section = control_behavior.get_section(1)
    section.group = ""

    local parameters = {}
    for name, by_quality in pairs(all_machines_inside) do
        for quality, count in pairs(by_quality) do
            parameters[#parameters + 1] = {
                value = {type = "item", name = name, quality = quality},
                min = count,
                max = count,
            }
        end
    end

    section.filters = parameters
end

local mobile_entities = {
    ["unit"] = true,
    ["spider-unit"] = true,
    ["car"] = true,
    ["spider-vehicle"] = true,
    ["cargo-wagon"] = true,
    ["fluid-wagon"] = true,
    ["locomotive"] = true,
    ["artillery-wagon"] = true,
    ["logistic-robot"] = true,
    ["construction-robot"] = true,
    ["combat-robot"] = true,
    ["character"] = true,
    ["segmented-unit"] = true,
    ["segment"] = true,
    ["spider-leg"] = true,
    ["fish"] = true,
    ["elevated-curved-rail-a"] = true,
    ["elevated-curved-rail-b"] = true,
    ["elevated-half-diagonal-rail"] = true,
    ["elevated-straight-rail"] = true,
}


maraxsis.on_event(maraxsis.events.on_built(), function(event)
    local entity = event.entity or event.created_entity
    if not entity.valid or domes[entity.name] then return end
    local entity_name = entity.name
    if mobile_entities[entity.type] then return end
    local surface = entity.surface
    if not maraxsis_constants.MARAXSIS_SURFACES[surface.name] then return end
    local dome_data = domes[entity.name]
    for _, pressure_dome_data in pairs(storage.pressure_domes) do
        local dome = pressure_dome_data.entity
        if not dome.valid or dome.surface ~= surface then goto continue end

        local points_in_dome = count_points_in_dome(pressure_dome_data, entity)
        if points_in_dome == 0 then
            goto continue
        elseif points_in_dome == 4 then
            flood_in_dome(entity, pressure_dome_data.powered_and_has_fluid)
            table.insert(pressure_dome_data.contained_entities, entity)
            update_combinator(pressure_dome_data)
        else
            maraxsis.cancel_creation(entity, event.player_index, {"cant-build-reason.entity-in-the-way", prototypes.entity[entity_name].localised_name})
        end

        do return end
        ::continue::
    end

    flood_on_seabed(entity)
end)

--- Lays dome floor at the given positions, saving what was underneath.
---
--- We need to save the tile under the dome floor tile to know what to restore
--- if/when the dome is mined.
--- @param args {surface: LuaSurface, positions: TilePosition[],pressure_dome_tile: TilePrototypeName}
local function lay_dome_floor(args)
    local surface, positions = args.surface, args.positions
    local below = {}
    -- `unplace_tiles` skips restoring on space platforms, so we can skip
    -- saving here too.
    if not surface.platform then
        for i, position in pairs(positions) do
            local top = surface.get_tile(position).name
            if top ~= args.pressure_dome_tile then
                below[i] = {top = top, hidden = surface.get_hidden_tile(position)}
            end
        end
    end

    local tiles = {}
    for i, position in pairs(positions) do
        tiles[i] = {name = args.pressure_dome_tile, position = position}
    end
    surface.set_tiles(tiles, true, false, true, false)

    for i, stack in pairs(below) do
        surface.set_hidden_tile(positions[i], stack.top)
        surface.set_double_hidden_tile(positions[i], stack.hidden)
    end
end

local function place_tiles(pressure_dome_data)
    local surface = pressure_dome_data.surface
    local pressure_dome_prototype = domes[pressure_dome_data.prototype]
    local octagon_size = pressure_dome_prototype.octagon_size
    if not surface.valid then return end
    local position = pressure_dome_data.position
    local x, y = position.x, position.y

    local positions = {}

    for xx = -math.floor(octagon_size), math.floor(octagon_size) do
        for yy = -math.floor(octagon_size), math.floor(octagon_size) do
            if is_point_in_polygon(xx + 0.5, yy,pressure_dome_prototype) then
                positions[#positions + 1] = {x + xx, y + yy}
            end
        end
    end

    lay_dome_floor {surface = surface, positions = positions, pressure_dome_tile = pressure_dome_prototype.PRESSURE_DOME_TILE}
end

local DEFAULT_MARAXSIS_TILE = "sand-3-underwater"
local function unplace_tiles(pressure_dome_data)
    local surface = pressure_dome_data.surface
    local pressure_dome_prototype = domes[pressure_dome_data.prototype]
    local octagon_size = pressure_dome_prototype.octagon_size
    local PRESSURE_DOME_TILE = pressure_dome_prototype.PRESSURE_DOME_TILE
    if not surface.valid then return end
    local position = pressure_dome_data.position
    local x, y = position.x, position.y

    local tile_to_unplace
    if surface.platform then
        tile_to_unplace = "space-platform-foundation"
    end

    local area = {
        {x - octagon_size, y - octagon_size},
        {x + octagon_size, y + octagon_size},
    }

    local tiles_in_square = surface.find_tiles_filtered {
        area = area,
        name = PRESSURE_DOME_TILE,
    }

    local tiles = {}
    local restore_hidden = {}

    for _, tile in pairs(tiles_in_square) do
        local tile_position = tile.position
        local xx, yy = tile_position.x, tile_position.y
        if is_point_in_polygon(xx - x + 0.5, yy - y,pressure_dome_prototype) then
            tiles[#tiles + 1] = {name = tile_to_unplace or tile.hidden_tile or DEFAULT_MARAXSIS_TILE, position = {xx, yy}}
            restore_hidden[#tiles] = tile.double_hidden_tile
        end
    end

    surface.set_tiles(tiles, true, false, true, false)

    if not tile_to_unplace then
        for i, tile in pairs(tiles) do
            surface.set_hidden_tile(tile.position, restore_hidden[i])
            surface.set_double_hidden_tile(tile.position, nil)
        end
    end
    if not surface.platform then
        surface.destroy_decoratives {
            area = area,
            name = prototypes.tile[PRESSURE_DOME_TILE].bound_decoratives,
        }
    end
end

local function place_collision_boxes(pressure_dome_data, health, player)
    local surface = pressure_dome_data.surface
    local pressure_dome_prototype = domes[pressure_dome_data.prototype]
    local octagon_size = pressure_dome_prototype.octagon_size
    if not surface.valid then return end
    local position = pressure_dome_data.position
    local x, y = position.x, position.y
    local force = pressure_dome_data.force_index
    local quality = pressure_dome_data.quality

    local diagonal_offset = pressure_dome_prototype.diagonal_offset
    local size = octagon_size
    local positions_and_orientations = {
        {x,                            y - size,                     defines.direction.north},
        {x,                            y + size,                     defines.direction.south},
        {x - size,                     y,                            defines.direction.east},
        {x + size,                     y,                            defines.direction.west},
        {x + (size - diagonal_offset), y - (size - diagonal_offset), defines.direction.northeast},
        {x - (size - diagonal_offset), y - (size - diagonal_offset), defines.direction.southeast},
        {x + (size - diagonal_offset), y + (size - diagonal_offset), defines.direction.southeast},
        {x - (size - diagonal_offset), y + (size - diagonal_offset), defines.direction.northeast},
    }

    for _, pos_and_orient in pairs(positions_and_orientations) do
        local pos_x, pos_y, orientation = pos_and_orient[1], pos_and_orient[2], pos_and_orient[3]
        local collision_box = surface.create_entity {
            name = pressure_dome_prototype.dome_collider,
            position = {pos_x, pos_y},
            force = force,
            quality = quality,
            create_build_effect_smoke = false,
            direction = orientation,
            player = player -- setup the undo queue
        }
        collision_box.health = health
        collision_box.disabled_by_script = true
        collision_box.operable = false -- vanilla bug: operable does nothing on cars
        table.insert(pressure_dome_data.collision_boxes, collision_box)

        player = nil -- only setup the undo queue for 1 entity. do not spam the undo queue
    end
end

local function intersects_with_2x2_box(entity, box_location)
    local corners = get_four_corners(entity)

    local box_x, box_y = box_location.x, box_location.y
    local box_left_top = {x = box_x - 1, y = box_y - 1}
    local box_right_bottom = {x = box_x + 1, y = box_y + 1}

    for _, corner in pairs(corners) do
        local x, y = corner.x, corner.y
        if x >= box_left_top.x and x <= box_right_bottom.x and y >= box_left_top.y and y <= box_right_bottom.y then
            return true
        end
    end

    return false
end

local function check_can_build_dome(surface, position, dome_prototype)
    local error_message = nil
    local contained_entities = {}
    local colliding_entities = {}
    local x, y = position.x, position.y
    local octagon_size = dome_prototype.octagon_size
    local entities_inside_square = surface.find_entities_filtered {
        area = {
            {x - octagon_size, y - octagon_size},
            {x + octagon_size, y + octagon_size},
        },
        collision_mask = prototypes.entity[dome_prototype.regulator].collision_mask.layers,
    }

    for _, e in pairs(entities_inside_square) do
        local count = count_points_in_dome({position = position,prototype=dome_prototype.pressure_dome},e)
        if count == 0 then
            -- pass
        elseif count == 4 then
            local layers = e.prototype.collision_mask.layers
            if e.force.name == "neutral" or layers[maraxsis_dome_collision_mask] then
                error_message = error_message or {"cant-build-reason.entity-in-the-way", e.localised_name}
                colliding_entities[#colliding_entities + 1] = e
            elseif surface.entity_prototype_collides(dome_prototype.regulator, position, false) then
                error_message = error_message or {"cant-build-reason.entity-in-the-way", e.localised_name}
                colliding_entities[#colliding_entities + 1] = e
            elseif layers.object then
                contained_entities[#contained_entities + 1] = e
            end
        else
            error_message = error_message or {"cant-build-reason.entity-in-the-way", e.localised_name}
            colliding_entities[#colliding_entities + 1] = e
        end
    end

    for xx = -math.floor(octagon_size) + x, math.floor(octagon_size) + x do
        for yy = -math.floor(octagon_size) + y, math.floor(octagon_size) + y do
            local tile = surface.get_tile(xx, yy)
            local tile_collision = tile.collides_with("object")
                or tile.collides_with(maraxsis_lava_collision_mask)
                or tile.collides_with(maraxsis_trench_entrance_collision_mask)

            if tile_collision and is_point_in_polygon(xx - x + 0.5, yy - y,dome_prototype) then
                -- The problem here is the terrain, not an entity. Say so, otherwise
                -- the tile's name (ex: "Deepsea geothermal vent") reads like an entity.
                return false, colliding_entities, {"cant-build-reason.cant-build-on-tile", tile.prototype.localised_name}, true
            end
        end
    end

    if error_message then
        return false, colliding_entities, error_message
    else
        return true, contained_entities, nil
    end
end

--- Whether the given tile prevents the pressure dome from being built, but can
--- be paved over with foundation. Only lava qualifies; other invalid terrain
--- (such as the trench entrance) cannot be fixed with foundation.
--- @param tile LuaTile
local function tile_needs_foundation(tile)
    return tile.collides_with(maraxsis_lava_collision_mask)
end

--- Places foundation ghosts on the lava underneath a pressure dome ghost so that
--- the dome can actually be constructed. This happens when a pressure dome is
--- placed with shift held, which places a ghost instead of cancelling the build.
--- @param surface LuaSurface
--- @param position MapPosition
--- @param dome_prototype table
--- @param force LuaForce
--- @param player LuaPlayer?
local function place_foundation_ghosts(surface, position, dome_prototype, force, player)
    if not surface.valid then return end
    local x, y = position.x, position.y
    -- The engine's lava rule covers the dome's collision box, a 32x32 square that
    -- is slightly larger than the octagon floor. Cover that whole square, because
    -- the corners may need foundation too.
    local half_size = math.floor(dome_prototype.octagon_size)

    for xx = x - half_size - 1, x + half_size do
        for yy = y - half_size - 1, y + half_size do
            local tile = surface.get_tile(xx, yy)
            if not tile_needs_foundation(tile) then goto continue end
            if tile.has_tile_ghost(force) then goto continue end

            surface.create_entity {
                name = "tile-ghost",
                inner_name = "foundation",
                position = {xx, yy},
                force = force,
                player = player,
            }

            ::continue::
        end
    end
end

local function place_regulator(pressure_dome_data)
    local surface = pressure_dome_data.surface
    if not surface.valid then return end
    local position = pressure_dome_data.position
    local x, y = position.x, position.y
    local force = pressure_dome_data.force_index
    local quality = pressure_dome_data.quality
    local prototype = domes[pressure_dome_data.prototype]
    local regulator = pressure_dome_data.regulator
    if not regulator or not regulator.valid then
        storage.script_placing_the_regulator = true
        local regulator = surface.create_entity {
            name = prototype.regulator,
            position = {x, y},
            quality = quality,
            force = force,
            create_build_effect_smoke = false,
            raise_built = true,
        }
        storage.script_placing_the_regulator = false
        pressure_dome_data.regulator = regulator
    end
    local regulator = pressure_dome_data.regulator

    regulator.minable_flag = false
    regulator.destructible = false
    regulator.operable = true

    pressure_dome_data.regulator = regulator

    local regulator_fluidbox = pressure_dome_data.regulator_fluidbox
    if not regulator_fluidbox or not regulator_fluidbox.valid then
        regulator_fluidbox = surface.create_entity {
            name = prototype.regulator_fluidbox_prefix .. quality.name,
            position = {x, y},
            force = force,
            create_build_effect_smoke = false,
        }
    end

    regulator_fluidbox.minable_flag = false
    regulator_fluidbox.destructible = false
    regulator_fluidbox.operable = false

    pressure_dome_data.regulator_fluidbox = regulator_fluidbox
end

-- ensure regulators always have the correct temperature of atmosphere (25 deg C)
maraxsis.on_nth_tick(631, function()
    for _, pressure_dome_data in pairs(storage.pressure_domes) do
        local regulator_fluidbox = pressure_dome_data.regulator_fluidbox
        if not regulator_fluidbox or not regulator_fluidbox.valid then
            place_regulator(pressure_dome_data)
            regulator_fluidbox = pressure_dome_data.regulator_fluidbox
        end

        if regulator_fluidbox and regulator_fluidbox.valid then
            local fluid = regulator_fluidbox.get_fluid(1)
            if fluid and fluid.temperature ~= 25 then
                fluid.temperature = 25
                regulator_fluidbox.set_fluid(1, fluid)
            end
        end
    end
end)

--- sorts all domes by y position and re-draws.
--- this prevents Z-fighting.
--- https://github.com/notnotmelon/maraxsis/issues/174
function maraxsis.rerender_all_domes()
    local sorted_by_y_position = {}
    if not storage.pressure_domes then return end
    for _, pressure_dome_data in pairs(storage.pressure_domes) do
        table.insert(sorted_by_y_position, pressure_dome_data)
    end
    table.sort(sorted_by_y_position, function(a, b)
        return a.position.y < b.position.y
    end)

    storage.pressure_domes = {}
    for _, pressure_dome_data in pairs(sorted_by_y_position) do
        local surface = pressure_dome_data.surface
        if surface.valid then
            if pressure_dome_data.entity then
                pressure_dome_data.entity.destroy()
            end
            if pressure_dome_data.entity_base then
                pressure_dome_data.entity_base.destroy()
            end
            
            local prototype = domes[pressure_dome_data.prototype]
            pressure_dome_data.opacity = pressure_dome_data.opacity or 255
            local opacity = pressure_dome_data.opacity
            local entity = rendering.draw_sprite {
                sprite = prototype.sprite,
                render_layer = "higher-object-above",
                target = pressure_dome_data.position,
                surface = pressure_dome_data.surface,
                tall = true,
            }
            local entity_base = rendering.draw_sprite {
                sprite = prototype.base_sprite,
                render_layer = base_render_layer,
                target = pressure_dome_data.position,
                surface = pressure_dome_data.surface,
            }
            entity.color = {opacity, opacity, opacity, opacity}
            pressure_dome_data.entity = entity
            pressure_dome_data.entity_base = entity_base
            storage.pressure_domes[entity.id] = pressure_dome_data
        elseif pressure_dome_data.entity.valid then
            storage.pressure_domes[pressure_dome_data.entity.id] = nil
        end
    end
end

--- Finds the pressure dome that owns the given entity.
---@param entity LuaEntity
---@return table? pressure_dome_data
local function find_pressure_dome_data_by_entity(entity)
    for _, pressure_dome_data in pairs(storage.pressure_domes) do
        if pressure_dome_data.regulator == entity or pressure_dome_data.light == entity then
            return pressure_dome_data
        end
    end
end

--- Moves a single entity by an offset, ignoring build checks.
---
--- Most entities can simply be teleported. Transport belts and other
--- belt-connectables refuse to teleport, so those are cloned onto the new
--- position and the original is destroyed in their place.
---@param entity LuaEntity
---@param dx number
---@param dy number
---@return LuaEntity? moved_entity The entity at its new position, or nil if it could not be moved.
local function move_entity_by(entity, dx, dy)
    if not entity.valid then return nil end
    local position = entity.position
    local target = {x = position.x + dx, y = position.y + dy}
    if entity.teleport(target) then return entity end

    local clone = entity.clone {position = target, create_build_effect_smoke = false}
    if clone then
        entity.destroy()
        return clone
    end
end

--- Moves an entire pressure dome by an offset.
---
--- `moved_entity` is the entity Even Pickier Dollies has already teleported. It
--- is skipped so that it does not get shifted a second time.
---@param pressure_dome_data table
---@param dx number
---@param dy number
---@param moved_entity LuaEntity?
function maraxsis.move_pressure_dome(pressure_dome_data, dx, dy, moved_entity,event)
    local surface = pressure_dome_data.surface
    if not surface.valid then return end
    local position = pressure_dome_data.position

    -- The dome moves as a single rigid body, so every entity it owns is shifted
    -- by the same offset. Gather them all up and move them from the front of the
    -- move towards the back. That way a cloned entity (see `move_entity_by`)
    -- never tries to land on top of one that has not moved out of the way yet.
    local moves = {}
    local function add_move(entity, contained_index)
        if entity and entity.valid and entity ~= moved_entity then
            moves[#moves + 1] = {entity = entity, contained_index = contained_index}
        end
    end

    local contained_entities = pressure_dome_data.contained_entities
    for i, entity in pairs(contained_entities) do
        if entity ~= pressure_dome_data.regulator
            and entity ~= pressure_dome_data.regulator_fluidbox
            and entity ~= pressure_dome_data.combinator
            and entity ~= pressure_dome_data.light
        then
            add_move(entity, i)
        end
    end
    for _, collision_box in pairs(pressure_dome_data.collision_boxes) do
        add_move(collision_box)
    end

    add_move(pressure_dome_data.light)
    add_move(pressure_dome_data.regulator)
    add_move(pressure_dome_data.regulator_fluidbox)
    add_move(pressure_dome_data.combinator)


    table.sort(moves, function(a, b)
        local a_position, b_position = a.entity.position, b.entity.position
        return (a_position.x * dx + a_position.y * dy) > (b_position.x * dx + b_position.y * dy)
    end)

    -- Restore whatever was hidden underneath the dome floor at the old position.
    unplace_tiles(pressure_dome_data)

    pressure_dome_data.position = {x = position.x + dx, y = position.y + dy}

    -- Lay the dome floor down at the new position before moving entities onto it.
    place_tiles(pressure_dome_data)

    -- EPD defines the event as a custom-event prototype. Re-raise it for
    -- contained entities that had to be cloned, so other mods observe the new
    -- entity rather than the destroyed original.
    local custom_event = prototypes.custom_event["even-pickier-dollies-on-entity-moved"]
    for _, move in pairs(moves) do
        local start_pos = move.entity.position
        local start_direction = move.entity.direction
        local start_unit_number = move.entity.unit_number
        local moved = move_entity_by(move.entity, dx, dy)
        -- A cloned entity is a new entity, so update the dome's bookkeeping.
        if moved and move.contained_index then

            contained_entities[move.contained_index] = moved

            ---@type EvenPickierDolliesRemoteInterfaceDollyMovedEvent
            local event_data = {
                player_index = event.player_index,
                moved_entity = moved,
                start_pos = start_pos,
                start_direction = start_direction,
                start_unit_number = start_unit_number,
                tick = game.tick,
                name = custom_event.event_id,
            }

            script.raise_event(custom_event.event_id, event_data)
        end
    end

    -- Redraw the dome sprites at the new position (this also re-sorts them).
    maraxsis.rerender_all_domes()
end

--- Called by Even Pickier Dollies after it teleports an entity.
---@param event {moved_entity: LuaEntity, start_pos: MapPosition}
local function on_epd_entity_moved(event)
    local moved_entity = event.moved_entity
    if not (moved_entity and moved_entity.valid) then return end
    local start_pos = event.start_pos
    if not start_pos then return end

    local pressure_dome_data = find_pressure_dome_data_by_entity(moved_entity)
    if not pressure_dome_data then return end

    local position = moved_entity.position
    local dx, dy = position.x - start_pos.x, position.y - start_pos.y
    if dx == 0 and dy == 0 then return end

    maraxsis.move_pressure_dome(pressure_dome_data, dx, dy, moved_entity,event)
end

-- Even Pickier Dollies defines the event id as a `custom-event` prototype, so it
-- can be registered by name. This must happen before `maraxsis.finalize_events`.
if script.active_mods["even-pickier-dollies"] then
    maraxsis.on_event("even-pickier-dollies-on-entity-moved", on_epd_entity_moved)
end

maraxsis.on_event(maraxsis.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end

    -- Placing a pressure dome with shift held places a ghost instead of a real
    -- entity. Pave over the lava underneath with foundation ghosts so that the
    -- dome can actually be constructed.
    if entity.name == "entity-ghost" then
        local ghost_dome_prototype = entity.ghost_name and domes[entity.ghost_name]
        if not ghost_dome_prototype then return end
        if not maraxsis_constants.MARAXSIS_SURFACES[entity.surface.name] then return end
        local player = event.player_index and game.get_player(event.player_index)
        place_foundation_ghosts(entity.surface, entity.position, ghost_dome_prototype, entity.force, player)
        return
    end

    if not domes[entity.name] then return end
    local prototype_name = entity.name
    local dome_prototype = domes[entity.name]
    local player = event.player_index and game.get_player(event.player_index)

    local surface, position = entity.surface, entity.position
    local can_build, contained_entities, error_msg, tile_collision = check_can_build_dome(surface, position,dome_prototype)
    local force_index = entity.force_index
    local quality = entity.quality

    if tile_collision then
        maraxsis.cancel_creation(entity, player and player.index, error_msg)
        return
    end

    if not can_build then
        local successfully_cleared_area = true
        local to_unmark = {}
        local undo_index = 0
        for _, colliding_entity in pairs(contained_entities) do
            if colliding_entity.valid and not colliding_entity.to_be_deconstructed() then
                local deconstructed
                if player then
                    deconstructed = pcall(colliding_entity.order_deconstruction, entity.force, player, undo_index)
                    undo_index = 1
                else
                    deconstructed = colliding_entity.order_deconstruction(entity.force)
                end
                successfully_cleared_area = successfully_cleared_area and deconstructed
                if deconstructed then to_unmark[#to_unmark + 1] = colliding_entity end
            end
        end
        if not successfully_cleared_area then
            for _, colliding_entity in pairs(to_unmark) do
                if colliding_entity.valid then colliding_entity.cancel_deconstruction(entity.force) end
            end
        end

        local tags = entity.tags
        maraxsis.cancel_creation(entity, player and player.index, error_msg)

        if successfully_cleared_area then
            surface.create_entity {
                name = "entity-ghost",
                inner_name = prototype_name,
                tags = tags,
                force = force_index,
                position = position,
                player = player,
                quality = quality,
            }
        end
        return
    end

    local health = entity.health
    
    entity.destroy()
    local entity = rendering.draw_sprite {
        sprite = dome_prototype.sprite,
        render_layer = "higher-object-above",
        target = position,
        surface = surface,
        tall = true,
    }
    local entity_base = rendering.draw_sprite {
        sprite = dome_prototype.base_sprite,
        render_layer = base_render_layer,
        target = position,
        surface = surface,
    }

    local pressure_dome_data = {
        entity = entity,
        entity_base = entity_base,
        position = position,
        surface = surface,
        quality = quality,
        contained_entities = contained_entities,
        force_index = force_index,
        collision_boxes = {},
        prototype = prototype_name
    }

    create_dome_light(pressure_dome_data)
    update_combinator(pressure_dome_data)
    place_collision_boxes(pressure_dome_data, health, player)
    place_tiles(pressure_dome_data)
    place_regulator(pressure_dome_data)

    for _, e in pairs(contained_entities) do
        flood_in_dome(e, pressure_dome_data.powered_and_has_fluid)
    end

    storage.pressure_domes[entity.id] = pressure_dome_data
    maraxsis.rerender_all_domes()
end)

maraxsis.on_event(maraxsis.events.on_init(), function()
    maraxsis.rerender_all_domes()

end)

local function delete_invalid_entities_from_contained_entities_list(pressure_dome_data, additional_entity_to_delete)
    local contained_entities = pressure_dome_data.contained_entities
    for _, e in pairs(contained_entities) do
        if not e.valid or e == additional_entity_to_delete then
            local new_contained = {}
            for _, e in pairs(contained_entities) do
                if e.valid and e ~= additional_entity_to_delete then
                    new_contained[#new_contained + 1] = e
                end
            end
            pressure_dome_data.contained_entities = new_contained
            update_combinator(pressure_dome_data)
            break
        end
    end
end

local function cleanup_dome_for_deletion(pressure_dome_data, buffer)
    unplace_tiles(pressure_dome_data)

    for _, entity in pairs(pressure_dome_data.contained_entities) do
        flood_on_seabed(entity)
    end

    for _, collision_box in pairs(pressure_dome_data.collision_boxes) do
        collision_box.destroy()
    end
    pressure_dome_data.collision_boxes = {}

    local regulator = pressure_dome_data.regulator
    if regulator and regulator.valid then
        -- Drop stored robots onto the floor or buffer inventory.
        -- https://github.com/notnotmelon/maraxsis/issues/243
        local surface = pressure_dome_data.surface
        for i = 1, regulator.get_max_inventory_index() do
            local inventory = regulator.get_inventory(i)
            for k = 1, #inventory do
                local stack = inventory[k]
                if buffer and surface.valid then
                    buffer.insert(stack)
                elseif surface.valid then
                    surface.spill_item_stack{
                        position = pressure_dome_data.position,
                        stack = stack,
                        enable_looted = true,
                        force = regulator.force_index,
                        allow_belts = false,
                        use_start_position_on_failure = true,
                    }
                end
            end
        end

        pressure_dome_data.regulator.destroy()
    end
    pressure_dome_data.regulator = nil

    if pressure_dome_data.regulator_fluidbox then
        pressure_dome_data.regulator_fluidbox.destroy()
        pressure_dome_data.regulator_fluidbox = nil
    end

    local light = pressure_dome_data.light
    if light then light.destroy() end

    local combinator = pressure_dome_data.combinator
    if combinator then combinator.destroy() end
end

local function bigass_explosion(surface, x, y) -- this looks really stupid. too bad!
    if not surface.valid then return end
    x = x + math.random(-5, 5)
    y = y + math.random(-5, 5)
    surface.create_entity {
        name = "cargo-landing-pad-remnants",
        position = {x, y},
    }
    if math.random() > 0.33 then
        surface.create_entity {
            name = "nuclear-reactor-explosion",
            position = {x, y},
        }
        rendering.draw_light {
            sprite = "utility/light_medium",
            scale = 3,
            intensity = 0.5,
            target = {x, y},
            time_to_live = 60,
            surface = surface,
        }
    end
end
maraxsis.register_delayed_function("bigass_explosion", bigass_explosion)

local function random_point_in_circle(radius)
    local angle = math.random() * 2 * math.pi
    radius = math.random() * radius
    return radius * math.cos(angle), radius * math.sin(angle)
end

local function on_dome_died(event, pressure_dome_data)
    local surface = pressure_dome_data.surface
    local dome_prototype = domes[pressure_dome_data.prototype_name]
    local DOME_POLYGON = dome_prototype.DOME_POLYGON
    if not surface.valid then return end
    local position = pressure_dome_data.position

    local contained_entities = pressure_dome_data.contained_entities
    for _, e in pairs(contained_entities) do
        if e.valid then
            if event.cause then
                e.die(event.force, event.cause)
            elseif event.force then
                e.die(event.force)
            else
                e.die()
            end
        end
    end

    for i = 1, #DOME_POLYGON, 2 do
        local x, y = position.x + DOME_POLYGON[i], position.y + DOME_POLYGON[i + 1]
        maraxsis.execute_later("bigass_explosion", math.random(1, 90), surface, x, y)
    end
    for i = 1, #DOME_POLYGON, 2 do
        local x, y = position.x + DOME_POLYGON[i], position.y + DOME_POLYGON[i + 1]
        maraxsis.execute_later("bigass_explosion", math.random(1, 90), surface, x, y)
    end
    for i = 1, 16 do
        local rx, ry = random_point_in_circle(dome_prototype.octagon_size)
        maraxsis.execute_later("bigass_explosion", math.random(1, 90), surface, position.x + rx, position.y + ry)
    end
end

maraxsis.on_event(maraxsis.events.on_destroyed(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    local render_object_id

    if rro.contains(MARAXSIS_DOME_COLLIDERS,entity.name) then
        for _, pressure_dome_data in pairs(storage.pressure_domes) do
            local dome = pressure_dome_data.entity
            if dome.valid then
                for _, collision_box in pairs(pressure_dome_data.collision_boxes) do
                    if collision_box.valid and collision_box == entity then
                        entity = dome
                        render_object_id = dome.id
                        goto parent_dome_found
                    end
                end
            end
        end
    end
    ::parent_dome_found::

    if render_object_id and storage.pressure_domes[render_object_id] then
        local pressure_dome_data = storage.pressure_domes[render_object_id]
        cleanup_dome_for_deletion(pressure_dome_data, event.buffer)
        storage.pressure_domes[render_object_id] = nil
        storage.pressure_domes_transparent[render_object_id] = nil
        if event.name == defines.events.on_entity_died then
            on_dome_died(event, pressure_dome_data)
        end
        entity.destroy()
        pressure_dome_data.entity_base.destroy()
        return
    end

    local surface = entity.surface
    local surface_name = surface.name
    if not maraxsis_constants.MARAXSIS_SURFACES[surface_name] then
        return
    end

    for key, pressure_dome_data in pairs(storage.pressure_domes) do
        local dome = pressure_dome_data.entity

        if dome.valid then
            delete_invalid_entities_from_contained_entities_list(pressure_dome_data, entity)
        else
            storage.pressure_domes[key] = nil
        end
    end
end)

local function find_pressure_dome_data_by_collision_entity(collision_box)
    for _, pressure_dome_data in pairs(storage.pressure_domes) do
        for _, cb in pairs(pressure_dome_data.collision_boxes) do
            if cb.valid and cb == collision_box then
                return pressure_dome_data
            end
        end
    end
end

maraxsis.on_event(defines.events.on_selected_entity_changed, function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    local entity = player.selected
    if not entity or not entity.valid then return end

    if not rro.contains(MARAXSIS_DOME_COLLIDERS,entity.name) then return end

    local pressure_dome_data = find_pressure_dome_data_by_collision_entity(entity)
    if not pressure_dome_data then return end

    delete_invalid_entities_from_contained_entities_list(pressure_dome_data, nil)
end)

maraxsis.on_event(defines.events.on_entity_damaged, function(event)
    local entity = event.entity
    if not entity.valid then return end

    -- Only dome collision boxes need their health mirrored to the other boxes.
    -- Bail out for every other entity first: damage events can fire hundreds of
    -- times per tick (e.g. captive biter spawners), and the dome lookup below
    -- scans every pressure dome and collision box.
    if not rro.contains(MARAXSIS_DOME_COLLIDERS, entity.name) then return end
    local pressure_dome_data = find_pressure_dome_data_by_collision_entity(entity)
    if not pressure_dome_data then return end

    for _, collision_box in pairs(pressure_dome_data.collision_boxes) do
        if collision_box.valid then
            collision_box.health = entity.health
        end
    end
end)

local function figure_out_wire_type(player)
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read then
        local stack_name = cursor_stack.name
        if stack_name == "red-wire" then
            return defines.wire_connector_id.circuit_red
        elseif stack_name == "green-wire" then
            return defines.wire_connector_id.circuit_green
        end
    end

    return nil
end

local sqrt = math.sqrt
local function distance(entity1, entity2)
    local x1, y1 = entity1.position.x, entity1.position.y
    local x2, y2 = entity2.position.x, entity2.position.y
    return sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

maraxsis.on_event(maraxsis.events.on_entity_clicked(), function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    local entity = player.selected
    if not entity or not entity.valid then return end

    if not rro.contains(MARAXSIS_DOME_COLLIDERS,entity.name) then return end
    local pressure_dome_data = find_pressure_dome_data_by_collision_entity(entity)
    if not pressure_dome_data then return end
    local light = pressure_dome_data.light
    if not light or not light.valid then
        local dome = pressure_dome_data.entity
        if not dome.valid then return end
        create_dome_light(pressure_dome_data)
        light = pressure_dome_data.light
    end

    local wire_type = figure_out_wire_type(player)
    if not wire_type then
        player.opened = nil
        player.opened = light
        return
    end

    local drag_target = player.drag_target
    if drag_target then
        local entity = player.drag_target.target_entity
        if distance(entity, light) < 24 then
            local wire = entity.get_wire_connector(drag_target.wire_connector_id, true)
            local light_wire = light.get_wire_connector(wire_type, false)
            local success = wire.connect_to(light_wire, false)
            if not success then
                wire.disconnect_from(light_wire)
            end
        end
        return
    end

    player.selected = light
    player.drag_wire {position = light.position}
    player.selected = entity
end)

-- handle the case of ghost pressure domes being built via blueprint
maraxsis.on_event(maraxsis.events.on_built(), function(event)
    if storage.script_placing_the_regulator then return end

    local entity = event.entity
    if not entity.valid then return end
    local is_ghost = entity.name == "entity-ghost" -- this would only be false in the editor mode.

    local name = is_ghost and entity.ghost_name or entity.name
    if not rro.contains(MARAXSIS_REGULATORS,name) then return end
    local dome_prototype
    for _,prototype in pairs(domes) do
        if prototype.regulator == name then
            dome_prototype = prototype
            break
        end
    end
    if not dome_prototype then
        error(name.. "\n"..serpent.block(domes))
    end
    local quality = entity.quality
    local position = entity.position
    local name = dome_prototype.pressure_dome
    local surface = entity.surface
    local force_index = entity.force_index
    local tags = entity.tags
    local player = event.player_index and game.get_player(event.player_index)

    entity.destroy()

    -- https://github.com/notnotmelon/maraxsis/issues/359
    local existing = surface.find_entities_filtered{
        position = position,
        name = "entity-ghost",
        inner_name = dome_prototype.pressure_dome
    }
    for _, existing in pairs(existing) do
        if existing.position.x == position.x and existing.position.y == position.y then
            return
        end
    end

    surface.create_entity {
        name = is_ghost and "entity-ghost" or name,
        inner_name = is_ghost and name or nil,
        tags = tags,
        force = force_index,
        position = position,
        player = player,
        quality = quality,
        raise_built = true,
    }
end)

maraxsis.on_nth_tick(73, function()
    for _, dome_data in pairs(storage.pressure_domes) do
        local regulator = dome_data.regulator
        if not regulator or not regulator.valid then goto continue end
        local regulator_fluidbox = dome_data.regulator_fluidbox
        if not regulator_fluidbox or not regulator_fluidbox.valid then goto continue end

        local powered_and_has_fluid = (regulator_fluidbox.get_fluid_count("maraxsis-atmosphere") > 0) and regulator_fluidbox.is_crafting()
        if powered_and_has_fluid == dome_data.powered_and_has_fluid then goto continue end

        for _, e in pairs(dome_data.contained_entities) do
            flood_in_dome(e, powered_and_has_fluid)
        end

        dome_data.powered_and_has_fluid = powered_and_has_fluid

        ::continue::
    end
end)

--- Tiles that are "unminable" don't remember what's under them. We need that to
--- restore whatever was under a Pressure Dome when it's mined. For this reason,
--- pressure dome tiles are technically mineable with a mining time of 2^63. If
--- it's actually mined for whatever reason, this handler un-mines it.
maraxsis.on_event(maraxsis.events.on_mined_tile(), function(event)
    local positions = {}
    local name 
    for _, tile in pairs(event.tiles) do
        name = tile.old_tile.name
        if rro.contains(PRESSURE_DOME_TILES,name) then
            positions[#positions + 1] = tile.position
        end
    end
    if not positions[1] then return end
    local surface = game.get_surface(event.surface_index)
    lay_dome_floor {surface = surface, positions = positions,pressure_dome_tile=name}
end)

--Changes opacity of domes player is focusing on.
maraxsis.on_nth_tick(15, function(event)
    for i, pressure_dome_data in pairs(storage.pressure_domes) do
        local surface = pressure_dome_data.surface
        local players_on_surface = {}
        local has_players_on_surface = false
        for index, player in pairs(game.connected_players) do
            if player.surface == surface then
                players_on_surface[index] = player
                has_players_on_surface = true
            end
        end

        if not has_players_on_surface then goto continue end

        

        

        
        

        local opacity = pressure_dome_data.opacity or 255
        local dome_position = pressure_dome_data.position
        local x, y = dome_position.x, dome_position.y
        local any_player_inside = false
        for _, player in pairs(players_on_surface) do
            local player_position = player.position
            if player.surface == surface and is_point_in_polygon(player_position.x - x, player_position.y - y, domes[pressure_dome_data.prototype]) then
                any_player_inside = true
                break
            end
        end
     
        if any_player_inside then
            if opacity > 60 then
                storage.pressure_domes_transparent[i] = {
                    any_player_inside = true, 
                }
            end
            --opacity = math.max(opacity - 16, 60)
            
        elseif opacity < 255 then
            --opacity = math.min(opacity + 16, 255)
            storage.pressure_domes_transparent[i] = {
                any_player_inside = false, 
            }
        end

        
        ::continue::
    end
end)

maraxsis.on_event(defines.events.on_tick, function(event)
    for pressure_dome_index,transparancy_data in pairs(storage.pressure_domes_transparent) do
        local pressure_dome_data = storage.pressure_domes[pressure_dome_index]
        if not pressure_dome_data then 
            storage.pressure_domes_transparent[pressure_dome_index] = nil
            goto continue
        end
        local opacity = pressure_dome_data.opacity or 255
        if transparancy_data.any_player_inside then
            if opacity > 60 then
                opacity = math.max(opacity - 4, 60)
            else
                storage.pressure_domes_transparent[pressure_dome_index] = nil
                goto continue
            end
            
        elseif opacity < 255 then
            opacity = math.min(opacity + 4, 255)
        else
            storage.pressure_domes_transparent[pressure_dome_index] = nil
            goto continue
        end
        local dome_sprite = pressure_dome_data.entity
        
        if not dome_sprite.valid or not pressure_dome_data.surface.valid then goto continue end
        --if opacity ~= pressure_dome_data.opacity then
            dome_sprite.color = {opacity, opacity, opacity, opacity}
            pressure_dome_data.opacity = opacity
        --end
        ::continue::
    end

end)