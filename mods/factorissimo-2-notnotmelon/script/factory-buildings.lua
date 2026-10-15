local get_factory_by_building = remote_api.get_factory_by_building
local find_surrounding_factory = remote_api.find_surrounding_factory

local has_layout = has_layout
local floor, ceil = math.floor, math.ceil

local is_inside_sandbox, destroy_factory_with_interior -- defined below

-- Active mods cannot change during a session.
local skip_factory_surface_check = script.active_mods["warptorio-space-age"] or script.active_mods["Warp-Drive-Machine"] or script.active_mods["warptorio2"]
local space_exploration_active = script.active_mods["space-exploration"] ~= nil

local building_filters = factorissimo.entity_filters {BUILDING_TYPE}

-- Paranoidal: factories are immune to quality and defects. The quality of the building does not change
-- its ports or the quality of its internal entities (fluid ports, power pole, indicators, roboport).
-- Factories placed before keep their ports and internal entities until they are moved.
local function factory_quality()
    return prototypes.quality.normal
end

-- INITIALIZATION --

local function highest_factory_id()
    local highest = storage.last_factory_id or 0
    for id in pairs(storage.factories) do
        if id > highest then highest = id end
    end
    for id in pairs(storage.was_deleted) do
        if id > highest then highest = id end
    end
    return highest
end

factorissimo.on_event(factorissimo.events.on_init(), function()
    -- List of all factories
    storage.factories = storage.factories or {}
    -- Map: Id from item-with-tags -> Factory
    storage.saved_factories = storage.saved_factories or {}
    -- Map: Entity unit number -> Factory it is a part of
    storage.factories_by_entity = storage.factories_by_entity or {}
    -- Map: Surface index -> list of factories on it
    storage.surface_factories = storage.surface_factories or {}
    -- Ids of deleted factories. https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/211
    storage.was_deleted = storage.was_deleted or {}
    -- Factory ids are never reused: blueprints and stale items may still carry the id of a deleted factory.
    storage.last_factory_id = highest_factory_id()

    -- Live buildings are registered so that their binding is dropped in on_object_destroyed;
    -- bindings of buildings that no longer exist are removed here.
    local by_entity = storage.factories_by_entity
    for unit_number, factory in pairs(by_entity) do
        local building = factory.building
        if not (factory.built and building and building.valid and building.unit_number == unit_number) then
            by_entity[unit_number] = nil
        end
    end
    for _, factory in pairs(storage.factories) do
        local building = factory.building
        if factory.built and building and building.valid then
            by_entity[building.unit_number] = factory
            script.register_on_object_destroyed(building)
        end
    end
end)

-- RECURSION TECHNOLOGY --

local function was_this_placed_on_a_space_exploration_spaceship(layout, building)
    if not space_exploration_active then
        return false
    end

    if layout.surface_override ~= "space-factory-floor" then
        return false
    end

    local surface = building.surface
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

--- Returns a message when the factory cannot work at the place of its building, nil otherwise.
local function placement_problem(factory, building)
    local surface = building.surface
    local inside_surface = factory.inside_surface

    -- Check if a player is trying to cheat by moving factories between surfaces.
    if not skip_factory_surface_check and inside_surface and inside_surface.valid then
        -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/268
        local surface_name = inside_surface.name:gsub("%-factory%-floor%-factory%-floor", "-factory-floor")
        if surface_name ~= which_surface_should_this_new_factory_be_placed_on(factory.layout, building) and not is_legacy_factory_floor(surface_name) then
            return {"factory-connection-text.invalid-placement-surface", surface_localised_name(inside_surface), surface_localised_name(surface)}
        end
    end

    if settings.global["Factorissimo2-free-recursion"].value then
        return nil
    end

    local surrounding_factory = find_surrounding_factory(surface, building.position)
    if not surrounding_factory or not surrounding_factory.layout then
        return nil
    end

    local force = surrounding_factory.force
    if not (force and force.valid) then force = building.force end
    local technologies = force.technologies
    local has_tech_t2 = technologies["factory-recursion-t2"].researched
    local has_tech_t1 = has_tech_t2 or technologies["factory-recursion-t1"].researched

    local inner_tier = factory.layout.tier or 0
    local outer_tier = surrounding_factory.layout.tier or 0
    if not has_tech_t2 and inner_tier >= outer_tier then
        return {"factory-connection-text.invalid-placement-recursion-2"}
    end

    if not has_tech_t1 then -- cannot do any recursion
        return {"factory-connection-text.invalid-placement-recursion-1"}
    end

    return nil
end

--- Updates factory.inactive. Returns true when an inactive factory became active again.
--- An inactive factory loses all its connections. The warning is shown when the factory becomes
--- inactive, or always when `announce` is set (a building was just placed).
local function set_factory_active_or_inactive(factory, announce)
    local was_inactive = factory.inactive
    local building = factory.building
    if not building or not building.valid then
        factory.inactive = false
        return false
    end

    local msg = placement_problem(factory, building)
    factory.inactive = msg ~= nil
    if not msg then return was_inactive == true end

    -- TODO: vanilla bug; `player.mine_entity` does not respect event.buffer
    if announce or not was_inactive then
        factorissimo.create_flying_text {position = building.position, text = msg}
    end

    factorissimo.disconnect_factory_connections(factory)
    return false
end

local DEFAULT_FACTORY_UPGRADES = {
    {"factorissimo", "build_lights_upgrade"},
    {"factorissimo", "build_greenhouse_upgrade"},
    {"factorissimo", "build_display_upgrade"},
    {"factorissimo", "build_roboport_upgrade"}
}

--- Runs the upgrade functions of a factory. `custom_only` limits this to factories whose layout
--- (added by another mod) defines its own upgrades.
local function build_factory_upgrades(factory, custom_only)
    local layout = factory.layout
    if not layout then return end
    local upgrades = layout.upgrades
    if custom_only and not upgrades then return end
    for _, upgrade in pairs(upgrades or DEFAULT_FACTORY_UPGRADES) do
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
--- With `recheck`, reactivated factories immediately restore their connections.
local function activate_factories(recheck)
    for _, factory in pairs(storage.factories) do
        local reactivated = set_factory_active_or_inactive(factory)
        if reactivated and recheck and factory.built then
            factorissimo.recheck_factory_connections(factory)
        end
        build_factory_upgrades(factory)
    end
end
-- Connections of all built factories are rechecked by connections.lua in the same on_init/on_configuration_changed.
factorissimo.on_event(factorissimo.events.on_init(), function() activate_factories(false) end)

local RECURSION_TECHNOLOGIES = {
    ["factory-recursion-t1"] = true,
    ["factory-recursion-t2"] = true,
}
local UPGRADE_TECHNOLOGIES = {
    ["factory-interior-upgrade-lights"] = true,
    ["factory-upgrade-greenhouse"] = true,
    ["factory-interior-upgrade-display"] = true,
    ["factory-interior-upgrade-roboport"] = true,
}

factorissimo.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    if not storage.factories then return end -- In case any mod or scenario script calls LuaForce.research_all_technologies() during its on_init
    local research = event.research
    local name = research.name
    if RECURSION_TECHNOLOGIES[name] then
        activate_factories(true)
    elseif UPGRADE_TECHNOLOGIES[name] then
        local force_index = research.force.index
        for _, factory in pairs(storage.factories) do
            local force = factory.force
            if force and force.valid and force.index == force_index then build_factory_upgrades(factory) end
        end
    else
        -- Upgrades added by other mods through custom layouts may depend on any technology.
        for _, factory in pairs(storage.factories) do build_factory_upgrades(factory, true) end
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

local RECURSION_SETTINGS = {
    ["Factorissimo2-free-recursion"] = true,
    ["Factorissimo2-hide-recursion"] = true,
    ["Factorissimo2-hide-recursion-2"] = true,
}

factorissimo.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if not RECURSION_SETTINGS[event.setting] then return end
    if not storage.factories then return end

    activate_factories(true)
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
        used_indexes[#used_indexes + 1] = k
    end
    table.sort(used_indexes)

    for i, index in ipairs(used_indexes) do
        if i ~= index then -- found a gap
            return (used_indexes[i - 1] or 0) + 1
        end
    end

    return #used_indexes + 1
end

local function surface_sanity_checks(surface)
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

local function next_factory_id()
    storage.was_deleted = storage.was_deleted or {}
    local id = (storage.last_factory_id or 0) + 1
    while storage.factories[id] or storage.was_deleted[id] do id = id + 1 end
    storage.last_factory_id = id
    return id
end

local function create_factory_position(layout, building)
    local surface_name = which_surface_should_this_new_factory_be_placed_on(layout, building)
    local surface = game.get_surface(surface_name)

    if not surface then
        surface = create_factory_surface(surface_name)
    end

    surface_sanity_checks(surface)

    local n = find_first_unused_position(surface) - 1
    local FACTORISSIMO_CHUNK_SPACING = 16
    local cx = FACTORISSIMO_CHUNK_SPACING * (n % 8)
    local cy = FACTORISSIMO_CHUNK_SPACING * floor(n / 8)
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

    factory.id = next_factory_id()
    storage.factories[factory.id] = factory

    return factory
end

local SE_SPACESHIP_TILE_MAPPING = {
    ["space-factory-floor"] = "se-spaceship-factory-floor",
    ["space-factory-entrance"] = "se-spaceship-factory-entrance",
}
local NO_TILE_MAPPING = {}

local function get_tile_name_mapping(surface)
    if surface.name == "se-spaceship-factory-floor" then return SE_SPACESHIP_TILE_MAPPING end
    return NO_TILE_MAPPING
end

--- Bounds of all tiles a layout places, relative to the factory center.
local function layout_tile_bounds(layout)
    local xmin, ymin, xmax, ymax = 0, 0, 0, 0
    local function include(x1, y1, x2, y2)
        if x1 < xmin then xmin = x1 end
        if y1 < ymin then ymin = y1 end
        if x2 > xmax then xmax = x2 end
        if y2 > ymax then ymax = y2 end
    end
    for _, rect in pairs(layout.rectangles) do include(rect.x1, rect.y1, rect.x2, rect.y2) end
    for _, mosaic in pairs(layout.mosaics or {}) do include(mosaic.x1, mosaic.y1, mosaic.x2, mosaic.y2) end
    for _, cpos in pairs(layout.connections) do include(floor(cpos.inside_x), floor(cpos.inside_y), ceil(cpos.inside_x) + 1, ceil(cpos.inside_y) + 1) end
    return floor(xmin), floor(ymin), ceil(xmax), ceil(ymax)
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

-- Water under every tile of the factory. Tiles outside the layout stay out-of-map forever,
-- so their hidden tile is never visible and is not set.
local function add_hidden_tile_rect(factory)
    local surface = factory.inside_surface
    local xmin, ymin, xmax, ymax = layout_tile_bounds(factory.layout)
    xmin, ymin = factory.inside_x + xmin, factory.inside_y + ymin
    xmax, ymax = factory.inside_x + xmax, factory.inside_y + ymax

    local position = {0, 0}
    local set_hidden_tile = surface.set_hidden_tile
    for x = xmin, xmax - 1 do
        position[1] = x
        for y = ymin, ymax - 1 do
            position[2] = y
            set_hidden_tile(position, "water")
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
    factory.quality = factory_quality()
    factory.inside_door_x = layout.inside_door_x + factory.inside_x
    factory.inside_door_y = layout.inside_door_y + factory.inside_y

    local tile_name_mapping = get_tile_name_mapping(factory.inside_surface)

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
    factory.overlay_signature = nil

    storage.factories_by_entity[building.unit_number] = factory
    script.register_on_object_destroyed(building)
    factory.building = building
    factory.building_quality = building.quality.name -- only to return the same item if the building vanishes
    factory.built = true

    -- Decide first whether the factory may work here, so that an invalid placement never connects.
    set_factory_active_or_inactive(factory, true)
    factorissimo.recheck_factory_connections(factory)
    factorissimo.update_power_connection(factory)
    factorissimo.update_overlay(factory)
    build_factory_upgrades(factory)
    return factory
end

-- FACTORY MINING AND DECONSTRUCTION --

local function destroy_render_objects(ids)
    for _, render_id in pairs(ids or {}) do
        local object = rendering.get_object_by_id(render_id)
        if object then object.destroy() end
    end
end

local function cleanup_factory_exterior(factory)
    factorissimo.cleanup_outside_energy_receiver(factory)
    factorissimo.cleanup_factory_roboport_exterior_chest(factory)

    factorissimo.disconnect_factory_connections(factory)
    destroy_render_objects(factory.outside_overlay_displays)
    factory.outside_overlay_displays = {}
    factory.overlay_signature = nil
    destroy_render_objects(factory.outside_port_markers)
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

local function interior_area(factory)
    local x, y = factory.inside_x, factory.inside_y
    local D = (factory.layout.inside_size + 8) / 2
    return {{x - D, y - D}, {x + D, y + D}}, x, y, D
end

--- Names of the tiles the layout itself places (and their frozen variants).
local function layout_tile_names(factory)
    local layout = factory.layout
    local mapping = get_tile_name_mapping(factory.inside_surface)
    local seen, names = {}, {}
    local tiles = prototypes.tile
    local function add(name)
        name = mapping[name] or name
        for _, candidate in pairs {name, name .. "-frozen"} do
            if not seen[candidate] and tiles[candidate] then
                seen[candidate] = true
                names[#names + 1] = candidate
            end
        end
    end
    add("out-of-map")
    for _, rect in pairs(layout.rectangles) do add(rect.tile) end
    for _, mosaic in pairs(layout.mosaics or {}) do add(mosaic.tile) end
    add(layout.connection_tile)
    return names
end

local function is_completely_empty(factory)
    local roboport_upgrade = factory.roboport_upgrade
    if roboport_upgrade then
        for _, entity in pairs {roboport_upgrade.storage, roboport_upgrade.roboport} do
            if entity and entity.valid then
                for i = 1, entity.get_max_inventory_index() do
                    local inventory = entity.get_inventory(i)
                    if inventory and not inventory.is_empty() then return false end
                end
            end
        end
    end

    local surface = factory.inside_surface
    local area = interior_area(factory)

    for _, entity in pairs(surface.find_entities_filtered {area = area}) do
        local layers = entity.prototype.collision_mask.layers
        local is_hidden_entity = (not layers) or next(layers) == nil
        if not is_hidden_entity then return false end
    end

    -- Tiles placed by players (concrete etc.) would be lost together with the interior.
    if surface.count_tiles_filtered {area = area, name = layout_tile_names(factory), invert = true, limit = 1} > 0 then
        return false
    end
    return true
end

--- Removes every reference to the factory, remembers its id as deleted and clears the table.
local function forget_factory(factory)
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

    -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/211
    if factory.id then
        storage.was_deleted = storage.was_deleted or {}
        storage.was_deleted[factory.id] = true
    end

    for k in pairs(factory) do factory[k] = nil end
end

local function cleanup_factory_interior(factory)
    local surface = factory.inside_surface
    if surface and surface.valid then
        local area, x, y, D = interior_area(factory)

        for _, e in pairs(surface.find_entities_filtered {area = area}) do
            if e.valid then e.destroy() end
        end

        local out_of_map_tiles = {}
        for xx = floor(x - D), ceil(x + D) do
            for yy = floor(y - D), ceil(y + D) do
                out_of_map_tiles[#out_of_map_tiles + 1] = {position = {xx, yy}, name = "out-of-map"}
            end
        end
        surface.set_tiles(out_of_map_tiles)

        -- Forget the chart of this factory's chunks only, instead of recharting the whole floor.
        local cx, cy = floor(x / 32), floor(y / 32)
        for _, force in pairs(game.forces) do
            for dx = -2, 2 do
                for dy = -2, 2 do
                    force.unchart_chunk({cx + dx, cy + dy}, surface)
                end
            end
        end
    end

    forget_factory(factory)
end

--- Drops the packed factory item on the ground. Returns the spill result of the item.
local function spill_packed_factory(factory, surface, position, quality)
    local items = surface.spill_item_stack {
        position = position,
        stack = {
            name = factory.layout.name .. "-instantiated",
            tags = {id = factory.id},
            quality = quality,
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
    return items[1]
end

-- How players pick up factories
-- Working factory buildings don't return items, so we have to manually give the player an item
factorissimo.on_event({
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_space_platform_mined_entity
}, function(event)
    local entity = event.entity
    if not entity.valid or not has_layout(entity.name) then return end

    local factory = get_factory_by_building(entity)
    if not factory then return end
    cleanup_factory_exterior(factory)

    local buffer = event.buffer
    buffer.clear()
    if is_completely_empty(factory) then
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
end, building_filters)

local function prevent_factory_mining(entity)
    local factory = storage.factories_by_entity[entity.unit_number]
    if not factory then return end
    local replacement = entity.surface.create_entity {
        name = entity.name,
        position = entity.position,
        force = entity.force,
        quality = entity.quality,
        raise_built = false,
        create_build_effect_smoke = false,
        player = entity.last_user
    }
    if not replacement then return end
    replacement.health = entity.health
    storage.factories_by_entity[entity.unit_number] = nil
    storage.factories_by_entity[replacement.unit_number] = factory
    script.register_on_object_destroyed(replacement)
    factory.building = replacement
    factory.overlay_signature = nil
    factorissimo.update_overlay(factory)
    if #factory.outside_port_markers ~= 0 then
        factory.outside_port_markers = {}
        factorissimo.toggle_port_markers(factory)
    end
    factorissimo.create_flying_text {position = replacement.position, text = {"factory-cant-be-mined"}}
end

local fake_robots = {["repair-block-robot"] = true} -- Modded construction robots with heavy control scripting
factorissimo.on_event(defines.events.on_robot_pre_mined, function(event)
    local entity = event.entity
    if not entity.valid then return end
    if has_layout(entity.name) and fake_robots[event.robot.name] then
        prevent_factory_mining(entity)
        entity.destroy()
    elseif entity.type == "item-entity" and entity.stack.valid_for_read and has_layout(entity.stack.name) then
        event.robot.destructible = false
    end
end, factorissimo.entity_filters {BUILDING_TYPE, "item-entity"})

-- How biters pick up factories
-- Too bad they don't have hands
factorissimo.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if not entity.valid or not has_layout(entity.name) then return end
    local factory = get_factory_by_building(entity)
    if not factory then return end

    storage.saved_factories[factory.id] = factory
    cleanup_factory_exterior(factory)

    local spilled = spill_packed_factory(factory, entity.surface, entity.position, entity.quality.name)
    entity.force.print {"factory-killed-by-biters", spilled.gps_tag}
end, building_filters)

-- The binding of the dead building is kept until here; it is dropped in on_object_destroyed afterwards.
factorissimo.on_event(defines.events.on_post_entity_died, function(event)
    if not event.ghost or not event.unit_number or not has_layout(event.prototype.name) then return end
    local factory = storage.factories_by_entity[event.unit_number]
    if not factory or not factory.id then return end
    event.ghost.tags = {id = factory.id}
end, {{filter = "type", type = BUILDING_TYPE}})

-- A factory building vanished without any event (another mod destroyed it silently).
-- Keep the interior and drop the packed item where the building stood.
local function rescue_orphaned_factory(factory)
    local surface = factory.outside_surface
    if not (factory.inside_surface and factory.inside_surface.valid) then
        -- Nothing is left to keep.
        cleanup_factory_exterior(factory)
        forget_factory(factory)
        return
    end
    storage.saved_factories[factory.id] = factory
    cleanup_factory_exterior(factory)
    if not (surface and surface.valid) then return end -- recoverable with /give-lost-factory-buildings
    local quality = factory.building_quality
    if quality and not prototypes.quality[quality] then quality = nil end
    local spilled = spill_packed_factory(factory, surface, {factory.outside_x, factory.outside_y}, quality)
    if factory.force and factory.force.valid then
        factory.force.print {"factory-killed-by-biters", spilled.gps_tag}
    end
end

factorissimo.on_event(defines.events.on_object_destroyed, function(event)
    if event.type ~= defines.target_type.entity then return end
    local by_entity = storage.factories_by_entity
    if not by_entity then return end
    local unit_number = event.useful_id
    local factory = by_entity[unit_number]
    if not factory then return end
    by_entity[unit_number] = nil
    if factory.built and factory.layout and not (factory.building and factory.building.valid) then
        rescue_orphaned_factory(factory)
    end
end)

factorissimo.on_event(factorissimo.events.on_init(), function()
    for _, factory in pairs(storage.factories) do
        if factory.built and factory.layout and factory.id and not (factory.building and factory.building.valid) then
            storage.saved_factories[factory.id] = factory
            cleanup_factory_exterior(factory)
        end
    end
end)

-- SURFACE CLEARING AND DELETION --

-- Blueprint Sandboxes labs are surfaces named "bpsb-lab-..."; the factory floors of factories built
-- there are named after the lab, so they carry the same prefix.
local SANDBOX_PREFIX = "bpsb-lab-"
local sandboxes_active = script.active_mods["blueprint-sandboxes"] ~= nil

local function is_sandbox_surface(surface)
    return sandboxes_active and surface.name:sub(1, #SANDBOX_PREFIX) == SANDBOX_PREFIX
end

--- Whether the position is in a sandbox, also through factories built inside factories.
function is_inside_sandbox(surface, position)
    if not sandboxes_active then return false end
    for _ = 1, 100 do -- a factory can contain itself
        if is_sandbox_surface(surface) then return true end
        local factory = find_surrounding_factory(surface, position)
        local outside_surface = factory and factory.built and factory.outside_surface
        if not (outside_surface and outside_surface.valid) then return false end
        surface, position = outside_surface, {x = factory.outside_x, y = factory.outside_y}
    end
    return false
end

local CONTAINER_TYPES = {"container", "logistic-container", "infinity-container", "linked-container", "item-entity"}

--- Ids of packed factories whose items lie on the ground or in chests in the area (whole surface without area).
local function packed_factory_ids(surface, area)
    local ids = {}
    local saved = storage.saved_factories
    local function note(stack)
        if stack and stack.valid_for_read and stack.is_item_with_tags and has_layout(stack.name) then
            local tags = stack.tags
            if tags and tags.id and saved[tags.id] then ids[#ids + 1] = tags.id end
        end
    end
    for _, entity in pairs(surface.find_entities_filtered {area = area, type = CONTAINER_TYPES}) do
        if entity.type == "item-entity" then
            note(entity.stack)
        else
            local inventory = entity.get_inventory(defines.inventory.chest)
            if inventory and not inventory.is_empty() then
                for i = 1, #inventory do note(inventory[i]) end
            end
        end
    end
    return ids
end

local function factories_snapshot()
    local list = {}
    for _, factory in pairs(storage.factories) do list[#list + 1] = factory end
    return list
end

local function same_surface(surface, index)
    return surface and surface.valid and surface.index == index
end

--- Factories whose buildings stand inside the interior of `factory`.
local function child_factories(factory)
    local children = {}
    local inside_surface = factory.inside_surface
    if not (inside_surface and inside_surface.valid) then return children end
    local inside_index = inside_surface.index
    for _, child in pairs(storage.factories) do
        if child ~= factory and child.built and same_surface(child.outside_surface, inside_index)
            and find_surrounding_factory(inside_surface, {x = child.outside_x, y = child.outside_y}) == factory then
            children[#children + 1] = child
        end
    end
    return children
end

--- The building of the factory is gone for good: wipe its interior, including factories built inside.
--- With `purge_packed` packed factories whose items lie inside are deleted too (sandboxes).
function destroy_factory_with_interior(factory, purge_packed)
    if factory.removing or not factory.layout then return end
    factory.removing = true
    for _, child in pairs(child_factories(factory)) do
        destroy_factory_with_interior(child, purge_packed)
    end
    local packed = {}
    local inside_surface = factory.inside_surface
    if purge_packed and inside_surface and inside_surface.valid then
        packed = packed_factory_ids(inside_surface, (interior_area(factory)))
    end
    if factory.built then cleanup_factory_exterior(factory) end
    cleanup_factory_interior(factory)
    for _, id in pairs(packed) do
        local saved = storage.saved_factories[id]
        if saved then destroy_factory_with_interior(saved, true) end
    end
end

--- Called before `surface` is cleared or deleted.
local function on_surface_removal(surface)
    if not storage.factories then return end
    local index = surface.index
    local sandbox = is_sandbox_surface(surface)

    -- Packed factories left on the floor of a sandbox lab are deleted with it.
    if sandbox then
        for _, id in pairs(packed_factory_ids(surface)) do
            local saved = storage.saved_factories[id]
            if saved then destroy_factory_with_interior(saved, true) end
        end
    end

    -- Interiors on this surface are lost. Buildings elsewhere become plain factory items again.
    if storage.surface_factories[index] then
        for _, factory in pairs(factories_snapshot()) do
            if factory.layout and same_surface(factory.inside_surface, index) then
                local building = factory.building
                local outside_surface = factory.outside_surface
                if factory.built then
                    cleanup_factory_exterior(factory)
                    if building and building.valid and outside_surface and outside_surface.valid and outside_surface.index ~= index then
                        local position, quality = building.position, building.quality
                        building.destroy()
                        outside_surface.spill_item_stack {
                            position = position,
                            stack = {name = factory.layout.name, count = 1, quality = quality.name},
                            enable_looted = true,
                            allow_belts = false,
                            use_start_position_on_failure = true,
                        }
                    end
                end
                forget_factory(factory)
            end
        end
        storage.surface_factories[index] = nil
    end

    -- Buildings standing on this surface vanish with it, and so do their interiors. Outside sandboxes packed
    -- factories are kept (their items may be anywhere; /give-lost-factory-buildings returns lost ones).
    local touched_floors = {}
    for _, factory in pairs(factories_snapshot()) do
        if factory.layout and factory.built and same_surface(factory.outside_surface, index) then
            local inside_surface = factory.inside_surface
            if inside_surface and inside_surface.valid then touched_floors[inside_surface.index] = inside_surface end
            destroy_factory_with_interior(factory, sandbox)
        end
    end

    -- Floors that are left without any factory (for example of a removed sandbox) are deleted.
    for floor_index, floor_surface in pairs(touched_floors) do
        local factories = storage.surface_factories[floor_index]
        if floor_index ~= index and floor_surface.valid and not (factories and next(factories)) then
            storage.surface_factories[floor_index] = nil
            game.delete_surface(floor_surface)
        end
    end
end

factorissimo.on_event({defines.events.on_pre_surface_cleared, defines.events.on_pre_surface_deleted}, function(event)
    local surface = game.get_surface(event.surface_index)
    if surface then on_surface_removal(surface) end
end)

-- A script destroyed the building. Deconstruction by script (god mode of Blueprint Sandboxes and similar)
-- removes it like a pickup and drops the packed item if the factory is not empty. Inside a sandbox the
-- factory is deleted completely, with the factories built inside it. Any other destruction by script is
-- undone by rebuilding the factory building.
factorissimo.on_event(defines.events.script_raised_destroy, function(event)
    local entity = event.entity
    if not entity.valid or not has_layout(entity.name) then return end
    local factory = storage.factories_by_entity[entity.unit_number]
    if not factory or not factory.layout then return end

    if not entity.to_be_deconstructed() then
        prevent_factory_mining(entity)
        return
    end

    if is_inside_sandbox(entity.surface, entity.position) then
        destroy_factory_with_interior(factory, true)
        return
    end

    cleanup_factory_exterior(factory)
    if is_completely_empty(factory) then
        cleanup_factory_interior(factory)
    else
        storage.saved_factories[factory.id] = factory
        spill_packed_factory(factory, entity.surface, entity.position, entity.quality.name)
    end
end, building_filters)

-- FACTORY PLACEMENT AND INITALIZATION --

local function create_fresh_factory(entity)
    local layout = remote_api.create_layout(entity.name, factory_quality())
    local factory = create_factory_interior(layout, entity)
    create_factory_exterior(factory, entity)
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
        factory.quality = factory_quality()
        create_factory_exterior(factory, entity)
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
                if factory and factory.inside_surface and factory.inside_surface.valid and factory.inside_surface.name == "space-factory-floor" then
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

local function tags_of_stack(stack)
    if stack and stack.valid_for_read and stack.is_item_with_tags then
        local tags = stack.tags
        if tags and tags.id then return tags end
    end
    return nil
end

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    local entity_type = entity.type

    if entity_type == BUILDING_TYPE then
        if not has_layout(entity.name) then return end
        -- The tags come from the ghost, from the item a player used, or from the item a robot/platform used.
        local inventory = event.consumed_items
        local tags = event.tags
            or (inventory and not inventory.is_empty() and tags_of_stack(inventory[1]))
            or tags_of_stack(event.stack)
            or nil
        handle_factory_placed(entity, tags)
        return
    end

    if entity_type ~= "entity-ghost" then return end
    local ghost_name = entity.ghost_name
    if not has_layout(ghost_name) then return end

    try_randomly_tag_an_itemized_factory_from_space_platform_hub(entity, event.player_index)

    local tags = entity.tags
    if tags and tags.id then
        local copied_from_factory = storage.factories[tags.id]
        if copied_from_factory and copied_from_factory.built then
            factorissimo.update_overlay(copied_from_factory, entity)
        end
    end
end, factorissimo.join_filters(building_filters, factorissimo.ghost_filters {BUILDING_TYPE}))

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

local clone_forbidden_cache = {}
local function is_entity_clone_forbidden(name)
    local cached = clone_forbidden_cache[name]
    if cached ~= nil then return cached end
    local forbidden = false
    for _, prefix in pairs(clone_forbidden_prefixes) do
        if name:sub(1, #prefix) == prefix then
            forbidden = true
            break
        end
    end
    clone_forbidden_cache[name] = forbidden
    return forbidden
end

factorissimo.on_event(defines.events.on_entity_cloned, function(event)
    local src_entity = event.source
    local dst_entity = event.destination
    if not dst_entity.valid then return end
    if is_entity_clone_forbidden(dst_entity.name) then
        dst_entity.destroy()
    elseif src_entity.valid and has_layout(src_entity.name) then
        local factory = get_factory_by_building(src_entity)
        if not factory then return end
        cleanup_factory_exterior(factory)
        if src_entity.valid then src_entity.destroy() end
        create_factory_exterior(factory, dst_entity)
    end
end)

-- MISC --

commands.add_command("give-lost-factory-buildings", {"command-help-message.give-lost-factory-buildings"}, function(event)
    local player = game.get_player(event.player_index)
    if not (player and player.connected and player.admin) then return end
    local inventory = player.get_main_inventory()
    if not inventory then return end

    local held = {}
    local function note(stack)
        local tags = tags_of_stack(stack)
        if tags then held[tags.id] = true end
    end
    for i = 1, #inventory do note(inventory[i]) end
    note(player.cursor_stack)

    for id, factory in pairs(storage.saved_factories) do
        local item_name = factory.layout and (factory.layout.name .. "-instantiated")
        if not held[id] and item_name and prototypes.item[item_name] then
            local quality = factory.building_quality
            if quality and not prototypes.quality[quality] then quality = nil end
            local inserted = player.insert {
                name = item_name,
                count = 1,
                tags = {id = id},
                quality = quality,
                custom_description = generate_factory_item_description(factory),
            }
            if inserted > 0 then
                -- Bind the new item so that unpacking another stale copy clears it (see handle_factory_control_xed).
                for i = 1, #inventory do
                    local tags = tags_of_stack(inventory[i])
                    if tags and tags.id == id then
                        factory.item = inventory[i].item
                        break
                    end
                end
            end
        end
    end
end)

factorissimo.on_event(defines.events.on_forces_merging, function(event)
    for _, factory in pairs(storage.factories) do
        if not (factory.force and factory.force.valid) then
            factory.force = game.forces["player"]
        end
        if factory.force.name == event.source.name then
            factory.force = event.destination
        end
    end
end)
