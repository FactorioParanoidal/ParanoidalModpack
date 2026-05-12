local get_factory_by_building = remote_api.get_factory_by_building
local find_surrounding_factory = remote_api.find_surrounding_factory

local has_layout = has_layout

-- INITIALIZATION --

factorissimo.on_event(factorissimo.events.on_init(), function()
    -- List of all factories
    storage.factories = storage.factories or {}
    -- Map: Id from item-with-tags -> Factory
    storage.saved_factories = storage.saved_factories or {}
    -- Map: Entity unit number -> Factory it is a part of
    storage.factories_by_entity = storage.factories_by_entity or {}
    -- Map: Surface index -> list of factories on it
    storage.surface_factories = storage.surface_factories or {}
end)

-- RECURSION TECHNOLOGY --

local function was_this_placed_on_a_space_exploration_spaceship(layout, building)
    local surface = building.surface

    if not script.active_mods["space-exploration"] then
        return false
    end

    if layout.surface_override ~= "space-factory-floor" then
        return false
    end

    if surface.name == "se-spaceship-factory-floor" then -- recursion
        return true
    end

    local x, y = building.position.x, building.position.y
    local D = layout.outside_size / 2
    local area = {{x - D, y - D}, {x + D, y + D}}
    return 1 == surface.count_tiles_filtered {
        area = area,
        name = "se-spaceship-floor",
        limit = 1,
    }
end

local function surface_localised_name(surface)
    if surface.localised_name then
        return surface.localised_name
    elseif surface.planet and surface.planet.prototype.localised_name then
        return {"", "[img=space-location.", surface.planet.name, "] ", surface.planet.prototype.localised_name}
    else
        return {"?", {"space-location-name." .. surface.name}, surface.name}
    end
end

--- @return string
local function which_surface_should_this_new_factory_be_placed_on(layout, building)
    if was_this_placed_on_a_space_exploration_spaceship(layout, building) then
        return "se-spaceship-factory-floor"
    end

    local surface = building.surface
    if layout.surface_override then
        return layout.surface_override
    elseif surface.platform then
        return "space-factory-floor"
    elseif surface.planet then
        return surface.planet.name:gsub("%-factory%-floor", "") .. "-factory-floor"
    else
        return surface.name:gsub("%-factory%-floor", "") .. "-factory-floor"
    end
end

local function is_legacy_factory_floor(surface_name)
    return surface_name:match("^%d+%-factory%-floor$") ~= nil
end

local function can_skip_factory_surface_check()
    return script.active_mods["warptorio-space-age"] or script.active_mods["Warp-Drive-Machine"] or script.active_mods["warptorio2"]
end

local function set_factory_active_or_inactive(factory)
    local building = factory.building
    if not building or not building.valid then
        factory.inactive = false
        return
    end
    local surface = building.surface
    local position = building.position

    local function can_place_factory_here()
        if not can_skip_factory_surface_check() then
            -- Check if a player is trying to cheat by moving factories between surfaces.
            local surface_name = factory.inside_surface.name
            -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/268
            local surface_name = surface_name:gsub("%-factory%-floor%-factory%-floor", "-factory-floor")
            if factory.inside_surface.valid and surface_name ~= which_surface_should_this_new_factory_be_placed_on(factory.layout, building) then
                if not is_legacy_factory_floor(surface_name) then
                    flying_text = {"factory-connection-text.invalid-placement-surface", surface_localised_name(factory.inside_surface), surface_localised_name(surface)}
                    return false, flying_text, true
                end
            end
        end

        if settings.global["Factorissimo2-free-recursion"].value then
            return true
        end

        local surrounding_factory = find_surrounding_factory(surface, position)
        if not surrounding_factory then
            return true
        end

        local has_tech_t2 = surrounding_factory.force.technologies["factory-recursion-t2"].researched
        local has_tech_t1 = has_tech_t2 or surrounding_factory.force.technologies["factory-recursion-t1"].researched

        local inner_tier = factory.layout.tier
        local outer_tier = surrounding_factory.layout.tier
        if not has_tech_t2 and inner_tier >= outer_tier then
            return false, {"factory-connection-text.invalid-placement-recursion-2"}, false
        end

        if not has_tech_t1 then -- cannot do any recursion
            return false, {"factory-connection-text.invalid-placement-recursion-1"}, false
        end

        return true
    end

    local can_place, msg, cancel_creation = can_place_factory_here()

    factory.inactive = not can_place
    if can_place then return end
    assert(msg)

    -- TODO: vanilla bug; `player.mine_entity` does not respect event.buffer
    -- if cancel_creation and storage.player_index then
    --     local player = game.get_player(storage.player_index)
    --     player.mine_entity(building, false)
    -- end
    factorissimo.create_flying_text {position = position, text = msg}

    for cid, _ in pairs(factory.layout.connections) do
        local conn = factory.connections[cid]
        factorissimo.destroy_connection(conn)
    end
end

local DEFAULT_FACTORY_UPGRADES = {
    {"factorissimo", "build_lights_upgrade"},
    {"factorissimo", "build_greenhouse_upgrade"},
    {"factorissimo", "build_display_upgrade"},
    {"factorissimo", "build_roboport_upgrade"}
}

local function build_factory_upgrades(factory)
    for _, upgrade in pairs(factory.layout.upgrades or DEFAULT_FACTORY_UPGRADES) do
        assert(#upgrade == 2)
        local mod, upgrade_function = upgrade[1], upgrade[2]
        if mod == "factorissimo" then
            factorissimo[upgrade_function](factory)
        else
            remote.call(mod, upgrade_function, factory)
        end
    end
end

--- If a factory factory is built without proper recursion technology, it will be inactive.
--- This function reactivates these factories once the research is complete.
local function activate_factories()
    for _, factory in pairs(storage.factories) do
        set_factory_active_or_inactive(factory)
        build_factory_upgrades(factory)
    end
end
factorissimo.on_event(factorissimo.events.on_init(), activate_factories)

factorissimo.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    if not storage.factories then return end -- In case any mod or scenario script calls LuaForce.research_all_technologies() during its on_init
    local name = event.research.name
    if name == "factory-recursion-t1" or name == "factory-recursion-t2" then
        activate_factories()
    else
        for _, factory in pairs(storage.factories) do build_factory_upgrades(factory) end
    end
end)

local function update_recursion_techs(force)
    if settings.global["Factorissimo2-hide-recursion"] and settings.global["Factorissimo2-hide-recursion"].value then
        force.technologies["factory-recursion-t1"].enabled = false
        force.technologies["factory-recursion-t2"].enabled = false
    elseif settings.global["Factorissimo2-hide-recursion-2"] and settings.global["Factorissimo2-hide-recursion-2"].value then
        force.technologies["factory-recursion-t1"].enabled = true
        force.technologies["factory-recursion-t2"].enabled = false
    else
        force.technologies["factory-recursion-t1"].enabled = true
        force.technologies["factory-recursion-t2"].enabled = true
    end
end

factorissimo.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting_type == "runtime-global" then activate_factories() end

    for _, force in pairs(game.forces) do
        update_recursion_techs(force)
    end
end)

factorissimo.on_event(defines.events.on_force_created, function(event)
    local force = event.force
    update_recursion_techs(force)
end)

factorissimo.on_event(factorissimo.events.on_init(), function()
    for _, force in pairs(game.forces) do
        update_recursion_techs(force)
    end
end)

-- FACTORY GENERATION --

factorissimo.on_event(defines.events.on_surface_created, function(event)
    local surface = game.get_surface(event.surface_index)
    if not surface.name:find("%-factory%-floor$") then return end

    local mgs = surface.map_gen_settings
    mgs.width = 2
    mgs.height = 2
    surface.map_gen_settings = mgs
end)

--- searches a factory floor for "holes" where a new factory could be created
--- else returns the next position
local function find_first_unused_position(surface)
    local used_indexes = {}
    for k in pairs(storage.surface_factories[surface.index] or {}) do
        table.insert(used_indexes, k)
    end
    table.sort(used_indexes)

    for i, index in pairs(used_indexes) do
        if i ~= index then -- found a gap
            return (used_indexes[i - 1] or 0) + 1
        end
    end

    return #used_indexes + 1
end

local function surface_sanity_checks(surface, building)
    if remote.interfaces["RSO"] then -- RSO compatibility
        pcall(remote.call, "RSO", "ignoreSurface", surface.name)
    end

    if surface.name == "space-factory-floor" then
        surface.localised_name = {"space-location-name.space-factory-floor"}
        surface.set_property("gravity", 0)
        surface.set_property("pressure", 0)
        surface.set_property("magnetic-field", 0)
    elseif surface.name == "se-spaceship-factory-floor" then
        surface.localised_name = {"space-location-name.se-spaceship-factory-floor"}
        surface.set_property("gravity", 0)
        surface.set_property("pressure", 0)
        surface.set_property("magnetic-field", 0)
    else
        surface.localised_name = surface_localised_name(surface)
    end

    surface.daytime = 0.5
    surface.freeze_daytime = true

    -- Ensure grass does not generate.
    surface.map_gen_settings = {width = 2, height = 2}
end

local function create_factory_surface(surface_name)
    assert(_G.surface == nil)

    if remote.interfaces["RSO"] then -- RSO compatibility
        pcall(remote.call, "RSO", "ignoreSurface", surface_name)
    end

    local surface = game.get_surface(surface_name)
    if surface then
        return surface
    end

    local planet = game.planets[surface_name]
    if planet then
        return planet.create_surface()
    end

    return game.create_surface(surface_name, {width = 2, height = 2})
end

local function create_factory_position(layout, building)
    local surface_name = which_surface_should_this_new_factory_be_placed_on(layout, building)
    local surface = game.get_surface(surface_name)

    if not surface then
        surface = create_factory_surface(surface_name)
    end

    surface_sanity_checks(surface, building)

    local n = find_first_unused_position(surface) - 1
    local FACTORISSIMO_CHUNK_SPACING = 16
    local cx = FACTORISSIMO_CHUNK_SPACING * (n % 8)
    local cy = FACTORISSIMO_CHUNK_SPACING * math.floor(n / 8)
    -- To make void chnks show up on the map, you need to tell them they've finished generating.
    for xx = -2, 2 do
        for yy = -2, 2 do
            surface.set_chunk_generated_status({cx + xx, cy + yy}, defines.chunk_generated_status.entities)
        end
    end
    surface.destroy_decoratives {area = {{32 * (cx - 2), 32 * (cy - 2)}, {32 * (cx + 2), 32 * (cy + 2)}}}
    factorissimo.spawn_maraxsis_water_shaders(surface, {x = cx, y = cy})

    local factory = {}
    factory.inside_surface = surface
    factory.inside_x = 32 * cx
    factory.inside_y = 32 * cy
    factory.stored_pollution = 0
    factory.outside_x = building.position.x
    factory.outside_y = building.position.y
    factory.outside_door_x = factory.outside_x + layout.outside_door_x
    factory.outside_door_y = factory.outside_y + layout.outside_door_y
    factory.outside_surface = building.surface

    storage.surface_factories[surface.index] = storage.surface_factories[surface.index] or {}
    storage.surface_factories[surface.index][n + 1] = factory

    local highest_currently_used_id = 0
    for id in pairs(storage.factories) do
        if id > highest_currently_used_id then
            highest_currently_used_id = id
        end
    end
    factory.id = highest_currently_used_id + 1
    storage.factories[factory.id] = factory

    return factory
end

local function add_tile_rect(tiles, tile_name, xmin, ymin, xmax, ymax) -- tiles is rw
    local i = #tiles
    for x = xmin, xmax - 1 do
        for y = ymin, ymax - 1 do
            i = i + 1
            tiles[i] = {name = tile_name, position = {x, y}}
        end
    end
end

local function add_hidden_tile_rect(factory)
    local surface = factory.inside_surface
    local xmin = factory.inside_x - 64
    local ymin = factory.inside_y - 64
    local xmax = factory.inside_x + 64
    local ymax = factory.inside_y + 64

    local position = {0, 0}
    for x = xmin, xmax - 1 do
        for y = ymin, ymax - 1 do
            position[1] = x
            position[2] = y
            surface.set_hidden_tile(position, "water")
        end
    end
end

local function add_tile_mosaic(tiles, tile_name, xmin, ymin, xmax, ymax, pattern) -- tiles is rw
    local i = #tiles
    for x = 0, xmax - xmin - 1 do
        for y = 0, ymax - ymin - 1 do
            if (string.sub(pattern[y + 1], x + 1, x + 1) == "+") then
                i = i + 1
                tiles[i] = {name = tile_name, position = {x + xmin, y + ymin}}
            end
        end
    end
end

local function create_factory_interior(layout, building)
    local force = building.force

    local factory = create_factory_position(layout, building)
    factory.building = building
    factory.layout = layout
    factory.force = force
    factory.quality = building.quality
    factory.inside_door_x = layout.inside_door_x + factory.inside_x
    factory.inside_door_y = layout.inside_door_y + factory.inside_y

    local tile_name_mapping = {}
    if factory.inside_surface.name == "se-spaceship-factory-floor" then
        tile_name_mapping["space-factory-floor"] = "se-spaceship-factory-floor"
        tile_name_mapping["space-factory-entrance"] = "se-spaceship-factory-entrance"
    end

    local tiles = {}
    for _, rect in pairs(layout.rectangles) do
        local tile_name = tile_name_mapping[rect.tile] or rect.tile
        add_tile_rect(tiles, tile_name, rect.x1 + factory.inside_x, rect.y1 + factory.inside_y, rect.x2 + factory.inside_x, rect.y2 + factory.inside_y)
    end
    for _, mosaic in pairs(layout.mosaics) do
        local tile_name = tile_name_mapping[mosaic.tile] or mosaic.tile
        add_tile_mosaic(tiles, tile_name, mosaic.x1 + factory.inside_x, mosaic.y1 + factory.inside_y, mosaic.x2 + factory.inside_x, mosaic.y2 + factory.inside_y, mosaic.pattern)
    end
    for _, cpos in pairs(layout.connections) do
        local tile_name = tile_name_mapping[layout.connection_tile] or layout.connection_tile
        table.insert(tiles, {name = tile_name, position = {factory.inside_x + cpos.inside_x, factory.inside_y + cpos.inside_y}})
    end
    factory.inside_surface.set_tiles(tiles)
    add_hidden_tile_rect(factory)

    factorissimo.get_or_create_inside_power_pole(factory)
    factorissimo.spawn_cerys_entities(factory)

    local radar = factory.inside_surface.create_entity {
        name = "factory-hidden-radar",
        position = {factory.inside_x, factory.inside_y},
        force = force,
    }
    radar.destructible = false
    factory.radar = radar
    factory.inside_overlay_controllers = {}

    factory.connections = {}
    factory.connection_settings = {}
    factory.connection_indicators = {}

    return factory
end

local function create_factory_exterior(factory, building)
    local layout = factory.layout
    local force = factory.force
    factory.outside_x = building.position.x
    factory.outside_y = building.position.y
    factory.outside_door_x = factory.outside_x + layout.outside_door_x
    factory.outside_door_y = factory.outside_y + layout.outside_door_y
    factory.outside_surface = building.surface

    local oer = factory.outside_surface.create_entity {name = layout.outside_energy_receiver_type, position = {factory.outside_x, factory.outside_y}, force = force}
    oer.destructible = false
    oer.operable = false
    oer.rotatable = false
    factory.outside_energy_receiver = oer

    if factory.outside_surface.has_global_electric_network then
        local genp = factory.outside_surface.create_entity {name = "factory-global-electric-network-pole", position = {factory.outside_x, factory.outside_y}, force = force}
        genp.destructible = false
        genp.operable = false
        genp.rotatable = false
        factory.global_electric_network_pole = genp
    end

    factory.outside_overlay_displays = {}
    factory.outside_port_markers = {}

    storage.factories_by_entity[building.unit_number] = factory
    factory.building = building
    factory.built = true

    factorissimo.recheck_factory_connections(factory)
    factorissimo.update_power_connection(factory)
    factorissimo.update_overlay(factory)
    build_factory_upgrades(factory)
    return factory
end

-- FACTORY MINING AND DECONSTRUCTION --

local function cleanup_factory_exterior(factory, building)
    factorissimo.cleanup_outside_energy_receiver(factory)
    factorissimo.cleanup_factory_roboport_exterior_chest(factory)

    factorissimo.disconnect_factory_connections(factory)
    for _, render_id in pairs(factory.outside_overlay_displays) do
        local object = rendering.get_object_by_id(render_id)
        if object then object.destroy() end
    end
    factory.outside_overlay_displays = {}
    for _, render_id in pairs(factory.outside_port_markers) do
        local object = rendering.get_object_by_id(render_id)
        if object then object.destroy() end
    end
    factory.outside_port_markers = {}
    factory.building = nil
    factory.built = false
end

local sprite_path_translation = {
    virtual = "virtual-signal",
}
local function generate_factory_item_description(factory)
    local bound_to = {"item-description.bound-to", surface_localised_name(factory.inside_surface)}

    local overlay = factory.inside_overlay_controller
    local params = {}
    if overlay and overlay.valid then
        for _, section in pairs(overlay.get_or_create_control_behavior().sections) do
            for _, filter in pairs(section.filters) do
                if filter.value and filter.value.name then
                    local sprite_type = sprite_path_translation[filter.value.type] or filter.value.type
                    table.insert(params, "[" .. sprite_type .. "=" .. filter.value.name .. "]")
                end
            end
        end
    end
    local params = table.concat(params, "\n")
    if params == "" then
        return bound_to
    else
        return {"", bound_to, "\n[font=heading-2]" .. params .. "[/font]"}
    end
end

local function is_completely_empty(factory)
    local roboport_upgrade = factory.roboport_upgrade
    if roboport_upgrade then
        for _, entity in pairs {roboport_upgrade.storage, roboport_upgrade.roboport} do
            if entity and entity.valid then
                for i = 1, entity.get_max_inventory_index() do
                    local inventory = entity.get_inventory(i)
                    if not inventory.is_empty() then return false end
                end
            end
        end
    end

    local x, y = factory.inside_x, factory.inside_y
    local D = (factory.layout.inside_size + 8) / 2
    local area = {{x - D, y - D}, {x + D, y + D}}

    local interior_entities = factory.inside_surface.find_entities_filtered {area = area}
    for _, entity in pairs(interior_entities) do
        local collision_mask = entity.prototype.collision_mask.layers
        local is_hidden_entity = (not collision_mask) or table_size(collision_mask) == 0
        if not is_hidden_entity then return false end
    end
    return true
end

local function cleanup_factory_interior(factory)
    local x, y = factory.inside_x, factory.inside_y
    local D = (factory.layout.inside_size + 8) / 2
    local area = {{x - D, y - D}, {x + D, y + D}}

    for _, e in pairs(factory.inside_surface.find_entities_filtered {area = area}) do
        e.destroy()
    end

    local out_of_map_tiles = {}
    for xx = math.floor(x - D), math.ceil(x + D) do
        for yy = math.floor(y - D), math.ceil(y + D) do
            out_of_map_tiles[#out_of_map_tiles + 1] = {position = {xx, yy}, name = "out-of-map"}
        end
    end
    factory.inside_surface.set_tiles(out_of_map_tiles)

    local factory_lists = {storage.factories, storage.saved_factories, storage.factories_by_entity}
    for _, factory_list in pairs(storage.surface_factories) do
        factory_lists[#factory_lists + 1] = factory_list
    end

    for _, factory_list in pairs(factory_lists) do
        for k, f in pairs(factory_list) do
            if f == factory then
                factory_list[k] = nil
            end
        end
    end

    for _, force in pairs(game.forces) do
        force.rechart(factory.inside_surface)
    end

    -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/211
    storage.was_deleted = storage.was_deleted or {}
    storage.was_deleted[factory.id] = true

    for k in pairs(factory) do factory[k] = nil end
end

-- How players pick up factories
-- Working factory buildings don't return items, so we have to manually give the player an item
factorissimo.on_event({
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_space_platform_mined_entity
}, function(event)
    local entity = event.entity
    if not has_layout(entity.name) then return end

    local factory = get_factory_by_building(entity)
    if not factory then return end
    cleanup_factory_exterior(factory, entity)

    if is_completely_empty(factory) then
        local buffer = event.buffer
        buffer.clear()
        buffer.insert {
            name = factory.layout.name,
            count = 1,
            quality = entity.quality,
            health = entity.health / entity.max_health
        }
        cleanup_factory_interior(factory)
        return
    end

    storage.saved_factories[factory.id] = factory
    local buffer = event.buffer
    buffer.clear()
    buffer.insert {
        name = factory.layout.name .. "-instantiated",
        count = 1,
        tags = {id = factory.id},
        custom_description = generate_factory_item_description(factory),
        quality = entity.quality,
        health = entity.health / entity.max_health
    }
    local item_stack = buffer[1]
    assert(item_stack.valid_for_read and item_stack.is_item_with_tags)
    local item = item_stack.item
    assert(item and item.valid)
    factory.item = item
end)

local function prevent_factory_mining(entity)
    local factory = get_factory_by_building(entity)
    if not factory then return end
    storage.factories_by_entity[entity.unit_number] = nil
    local entity = entity.surface.create_entity {
        name = entity.name,
        position = entity.position,
        force = entity.force,
        raise_built = false,
        create_build_effect_smoke = false,
        player = entity.last_user
    }
    storage.factories_by_entity[entity.unit_number] = factory
    factory.building = entity
    factorissimo.update_overlay(factory)
    if #factory.outside_port_markers ~= 0 then
        factory.outside_port_markers = {}
        factorissimo.toggle_port_markers(factory)
    end
    factorissimo.create_flying_text {position = entity.position, text = {"factory-cant-be-mined"}}
end

local fake_robots = {["repair-block-robot"] = true} -- Modded construction robots with heavy control scripting
factorissimo.on_event(defines.events.on_robot_pre_mined, function(event)
    local entity = event.entity
    if has_layout(entity.name) and fake_robots[event.robot.name] then
        prevent_factory_mining(entity)
        entity.destroy()
    elseif entity.type == "item-entity" and entity.stack.valid_for_read and has_layout(entity.stack.name) then
        event.robot.destructible = false
    end
end)

-- How biters pick up factories
-- Too bad they don't have hands
factorissimo.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if not has_layout(entity.name) then return end
    local factory = get_factory_by_building(entity)
    if not factory then return end

    storage.saved_factories[factory.id] = factory
    cleanup_factory_exterior(factory, entity)

    local items = entity.surface.spill_item_stack {
        position = entity.position,
        stack = {
            name = factory.layout.name .. "-instantiated",
            tags = {id = factory.id},
            quality = entity.quality.name,
            count = 1,
            custom_description = generate_factory_item_description(factory)
        },
        enable_looted = false,
        force = nil,
        allow_belts = false,
        max_radius = 0,
        use_start_position_on_failure = true
    }
    assert(table_size(items) == 1, "Failed to generate factory item. Are you using the quantum-fabricator mod? See https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/203")
    local item = items[1].stack.item
    assert(item and item.valid)
    factory.item = item
    entity.force.print {"factory-killed-by-biters", items[1].gps_tag}
end)

factorissimo.on_event(defines.events.on_post_entity_died, function(event)
    if not has_layout(event.prototype.name) or not event.ghost then return end
    local factory = storage.factories_by_entity[event.unit_number]
    if not factory then return end
    event.ghost.tags = {id = factory.id}
end)

-- Just rebuild the factory in this case
factorissimo.on_event(defines.events.script_raised_destroy, function(event)
    local entity = event.entity
    if has_layout(entity.name) then
        prevent_factory_mining(entity)
    end
end)

local function on_delete_surface(surface)
    storage.surface_factories[surface.index] = nil

    local childen_surfaces_to_delete = {}
    for _, factory in pairs(storage.factories) do
        local inside_surface = factory.inside_surface
        local outside_surface = factory.outside_surface
        if inside_surface.valid and outside_surface.valid and factory.outside_surface == surface then
            childen_surfaces_to_delete[inside_surface.index] = inside_surface
        end
    end

    for _, factory_list in pairs {storage.factories, storage.saved_factories, storage.factories_by_entity} do
        for k, factory in pairs(factory_list) do
            local inside_surface = factory.inside_surface
            if not inside_surface.valid or childen_surfaces_to_delete[inside_surface.index] then
                factory_list[k] = nil
            end
        end
    end

    for _, child_surface in pairs(childen_surfaces_to_delete) do
        on_delete_surface(child_surface)
        game.delete_surface(child_surface)
    end
end

-- Delete all children surfaces in this case.
factorissimo.on_event(defines.events.on_pre_surface_cleared, function(event)
    on_delete_surface(game.get_surface(event.surface_index))
end)

-- FACTORY PLACEMENT AND INITALIZATION --

local function create_fresh_factory(entity)
    local layout = remote_api.create_layout(entity.name, entity.quality)
    local factory = create_factory_interior(layout, entity)
    create_factory_exterior(factory, entity)
    set_factory_active_or_inactive(factory)
    return factory
end

-- It's possible that the item used to build this factory is not the same as the one that was saved.
-- In this case, clear tags and description of the saved item such that there is only 1 copy of the factory item.
-- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/155
local function handle_factory_control_xed(factory)
    local item = factory.item
    if not item or not item.valid then return end
    factory.item.tags = {}
    factory.item.custom_description = factory.item.prototype.localised_description

    -- We should also attempt to swapped the packed factory item with an unpacked.
    -- If this fails, whatever. It's just to avoid confusion. A packed factory with no tags is equal to an unpacked factory.
    local item_stack = item.item_stack
    if not item_stack or not item_stack.valid_for_read then return end

    item_stack.set_stack {
        name = item.name:gsub("%-instantiated$", ""),
        count = item_stack.count,
        quality = item_stack.quality,
        health = item_stack.health,
    }
end

local function handle_factory_placed(entity, tags)
    if not tags or not tags.id then
        create_fresh_factory(entity)
        return
    end

    local factory = storage.saved_factories[tags.id]
    storage.saved_factories[tags.id] = nil
    if factory and factory.inside_surface and factory.inside_surface.valid then
        -- This is a saved factory, we need to unpack it
        factory.quality = entity.quality
        create_factory_exterior(factory, entity)
        set_factory_active_or_inactive(factory)
        handle_factory_control_xed(factory)
        return
    end

    if not factory and storage.factories[tags.id] then
        -- This factory was copied from somewhere else. Clone all contained entities
        local factory = create_fresh_factory(entity)
        factorissimo.copy_entity_ghosts(storage.factories[tags.id], factory)
        factorissimo.update_overlay(factory)
        return
    end

    -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/211
    if storage.was_deleted and storage.was_deleted[tags.id] then
        create_fresh_factory(entity)
        return
    end

    factorissimo.create_flying_text {position = entity.position, text = {"factory-connection-text.invalid-factory-data"}}
    entity.destroy()
end

-- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/259
local function try_randomly_tag_an_itemized_factory_from_space_platform_hub(entity_ghost, player_index)
    if not player_index then return end
    if entity_ghost.tags then return end
    local player = game.get_player(player_index)
    if not player then return end
    local space_platform = entity_ghost.surface.platform
    if not space_platform then return end
    local hub = space_platform.hub
    if not hub then return end
    local cursor_ghost = player.cursor_ghost
    if not cursor_ghost then return end
    local cursor_ghost_name = player.cursor_ghost.name.name
    if not has_layout(cursor_ghost_name) then return end
    if not cursor_ghost_name:ends_with("-instantiated") then return end
    local inventory = hub.get_inventory(defines.inventory.hub_main)
    if not inventory then return end
    if inventory.is_empty() or inventory.get_item_count(cursor_ghost_name) == 0 then return end

    local random_indicies = {}
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack and stack.valid_for_read and stack.name == cursor_ghost_name and stack.quality.name == cursor_ghost.quality.name then
            if stack.type == "item-with-tags" and stack.tags and stack.tags.id then
                local factory = storage.saved_factories[stack.tags.id]
                if factory and factory.inside_surface.name == "space-factory-floor" then
                    random_indicies[#random_indicies + 1] = i
                end
            end
        end
    end

    if #random_indicies == 0 then return end
    local index = random_indicies[math.random(1, #random_indicies)]
    local stack = inventory[index]
    entity_ghost.tags = stack.tags
    local factory = storage.saved_factories[entity_ghost.tags.id]

    if #random_indicies > 1 then
        local certainty = string.format("%.2f", 100 / #random_indicies)
        local gps_1 = entity_ghost.gps_tag
        local gps_2 = string.format("[gps=%s,%s,%s]", factory.inside_x, factory.inside_y, factory.inside_surface.name)
        game.print {"command-help-message.could-not-determine-with-certainty", gps_1, gps_2, certainty}
    end
end

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    local entity_name = entity.name

    if has_layout(entity_name) then
        local inventory = event.consumed_items
        local tags = event.tags or (inventory and not inventory.is_empty() and inventory[1].valid_for_read and inventory[1].is_item_with_tags and inventory[1].tags) or nil
        handle_factory_placed(entity, tags)
        return
    end

    if entity.type ~= "entity-ghost" then return end
    local ghost_name = entity.ghost_name
    if not has_layout(ghost_name) then return end

    try_randomly_tag_an_itemized_factory_from_space_platform_hub(entity, event.player_index)

    if entity.tags then
        local copied_from_factory = storage.factories[entity.tags.id]
        if copied_from_factory then
            factorissimo.update_overlay(copied_from_factory, entity)
        end
    end
end)

-- How to clone your factory
-- This implementation will not actually clone factory buildings, but move them to where they were cloned.
local clone_forbidden_prefixes = {
    "factory-1-",
    "factory-2-",
    "factory-3-",
    "space-factory-1-",
    "space-factory-2-",
    "space-factory-3-",
    "factory-power-input-",
    "factory-connection-indicator-",
    "factory-power-pole",
    "factory-overlay-controller",
    "factory-port-marker",
    "factory-blueprint-anchor",
    "factory-fluid-dummy-connector-",
    "factory-linked-",
    "factory-requester-chest-",
    "factory-eject-chest-",
    "factory-construction-chest",
    "factory-construction-roboport",
    "factory-hidden-construction-robot",
    "factory-hidden-construction-roboport",
    "factory-hidden-radar-",
    "factory-heat-dummy-connector",
    "factory-inside-pump-input",
    "factory-inside-pump-output",
    "factory-outside-pump-input",
    "factory-outside-pump-output",
}

local function is_entity_clone_forbidden(name)
    for _, prefix in pairs(clone_forbidden_prefixes) do
        if name:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

factorissimo.on_event(defines.events.on_entity_cloned, function(event)
    local src_entity = event.source
    local dst_entity = event.destination
    if is_entity_clone_forbidden(dst_entity.name) then
        dst_entity.destroy()
    elseif has_layout(src_entity.name) then
        local factory = get_factory_by_building(src_entity)
        cleanup_factory_exterior(factory, src_entity)
        if src_entity.valid then src_entity.destroy() end
        create_factory_exterior(factory, dst_entity)
        set_factory_active_or_inactive(factory)
    end
end)

-- MISC --

commands.add_command("give-lost-factory-buildings", {"command-help-message.give-lost-factory-buildings"}, function(event)
    local player = game.get_player(event.player_index)
    if not (player and player.connected and player.admin) then return end
    local inventory = player.get_main_inventory()
    if not inventory then return end
    for id, factory in pairs(storage.saved_factories) do
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read and stack.name == factory.layout.name and stack.type == "item-with-tags" and stack.tags.id == id then goto found end
        end
        player.insert {name = factory.layout.name .. "-instantiated", count = 1, tags = {id = id}}
        ::found::
    end
end)

factorissimo.on_event(defines.events.on_forces_merging, function(event)
    for _, factory in pairs(storage.factories) do
        if not factory.force.valid then
            factory.force = game.forces["player"]
        end
        if factory.force.name == event.source.name then
            factory.force = event.destination
        end
    end
end)
