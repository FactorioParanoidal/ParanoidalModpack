local find_surrounding_factory = remote_api.find_surrounding_factory
local get_factory_by_building = remote_api.get_factory_by_building

local function draw_planet_icon_on_inside_power_pole(factory)
    local sprite_path
    local scale = 1

    if factory.inside_surface.name == "se-spaceship-factory-floor" then
        sprite_path = "technology/se-spaceship"
        scale = 0.4
    elseif factory.inside_surface.name == "space-factory-floor" then
        sprite_path = "factory-floor-space"
        scale = 0.5
    elseif factory.inside_surface.planet then
        local planet_name = factory.inside_surface.planet.name
        local parent_planet = game.planets[planet_name:gsub("%-factory%-floor", "")]
        if parent_planet then
            sprite_path = "space-location/" .. parent_planet.name
        end
    end

    if not sprite_path then return end

    local sprite_data = {
        sprite = sprite_path,
        surface = factory.inside_surface,
        target = {
            entity = factory._inside_power_pole
        },
        only_in_alt_mode = true,
        render_layer = "entity-info-icon",
        x_scale = scale,
        y_scale = scale,
    }
    -- Fake shadows
    local shadow_radius = 0.12 * scale
    for _, shadow_offset in pairs {{0, shadow_radius}, {0, -shadow_radius}, {shadow_radius, 0}, {-shadow_radius, 0}} do
        sprite_data.tint = {0, 0, 0, 0.5} -- Transparent black
        sprite_data.target.offset = shadow_offset
        rendering.draw_sprite(sprite_data)
    end
    -- Proper sprite
    sprite_data.tint = nil
    sprite_data.target.offset = nil
    rendering.draw_sprite(sprite_data)
end

local function get_or_create_inside_power_pole(factory)
    if factory._inside_power_pole and factory._inside_power_pole.valid then
        return factory._inside_power_pole
    end

    local layout = factory.layout
    local power_pole = factory.inside_surface.create_entity {
        name = "factory-power-pole",
        position = {factory.inside_x + layout.inside_energy_x, factory.inside_y + layout.inside_energy_y},
        force = factory.force,
        quality = factory.quality
    }
    power_pole.destructible = false
    factory._inside_power_pole = power_pole

    draw_planet_icon_on_inside_power_pole(factory)
    return factory._inside_power_pole
end
factorissimo.get_or_create_inside_power_pole = get_or_create_inside_power_pole

local function connect_power(factory, outside_power_pole)
    if not (factory.inside_surface and factory.inside_surface.valid and outside_power_pole.valid) then return end
    local inside_power_pole = get_or_create_inside_power_pole(factory)
    local outside_power_pole_wire_connector = outside_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper)
    local inside_power_pole_wire_connector = inside_power_pole.get_wire_connector(defines.wire_connector_id.pole_copper)
    inside_power_pole_wire_connector.connect_to(outside_power_pole_wire_connector, false, defines.wire_origin.script)
end

local base_pole_reach_cache
--- Largest supply distance of the electric poles players can build (hidden poles, such as the
--- factory's own inside pole, would make every search area huge).
local function base_pole_reach()
    if not base_pole_reach_cache then
        local reach = 0
        for _, prototype in pairs(prototypes.get_entity_filtered {{filter = "type", type = "electric-pole"}}) do
            if not prototype.hidden then
                local distance = prototype.get_supply_area_distance()
                if distance > reach then reach = distance end
            end
        end
        base_pole_reach_cache = reach
    end
    return base_pole_reach_cache
end

local quality_pole_bonus_cache
local function quality_pole_bonus()
    if not quality_pole_bonus_cache then
        local bonus = 0
        for _, quality in pairs(prototypes.quality) do
            if not quality.hidden and quality.electric_pole_supply_area_distance_bonus > bonus then
                bonus = quality.electric_pole_supply_area_distance_bonus
            end
        end
        quality_pole_bonus_cache = bonus
    end
    return quality_pole_bonus_cache
end

local function find_connected_poles(surface, x, y, D, electric_network, excluded_pole)
    local area = {{x - D, y - D}, {x + D, y + D}}
    local candidates = {}
    for _, entity in pairs(surface.find_entities_filtered {type = "electric-pole", area = area, limit = 100}) do
        if entity.electric_network_id == electric_network and entity ~= excluded_pole and not entity.prototype.hidden then
            candidates[#candidates + 1] = entity
        end
    end
    return candidates
end

local function update_power_connection(factory, pole) -- pole parameter is optional
    if not factory.outside_energy_receiver or not factory.outside_energy_receiver.valid then return end
    local electric_network = factory.outside_energy_receiver.electric_network_id
    if electric_network == nil then return end

    local genp = factory.global_electric_network_pole
    if genp and genp.valid then
        connect_power(factory, genp)
    end

    local surface = factory.outside_surface
    local x = factory.outside_x
    local y = factory.outside_y

    if storage.surface_factories[surface.index] then
        local surrounding = find_surrounding_factory(surface, {x = x, y = y})
        if surrounding then
            connect_power(factory, get_or_create_inside_power_pole(surrounding))
            return
        end
    end

    -- find the nearest connected power pole
    local half_size = factory.layout.outside_size / 2
    local candidates = find_connected_poles(surface, x, y, base_pole_reach() + half_size, electric_network, pole)
    if #candidates == 0 then
        -- Only a far-reaching (for example high quality) pole powers the factory.
        candidates = find_connected_poles(surface, x, y, base_pole_reach() + quality_pole_bonus() + half_size, electric_network, pole)
    end

    if #candidates == 0 then return end
    connect_power(factory, surface.get_closest({x, y}, candidates))
end
factorissimo.update_power_connection = update_power_connection
local function get_factories_near_pole(pole)
    local surface = pole.surface

    local D = pole.prototype.get_supply_area_distance(pole.quality)
    if D == 0 then return {} end
    D = D + 1
    local position = pole.position
    local x = position.x
    local y = position.y
    local area = {{x - D, y - D}, {x + D, y + D}}

    local by_entity = storage.factories_by_entity
    local result = {}
    for _, candidate in pairs(surface.find_entities_filtered {type = BUILDING_TYPE, area = area}) do
        local factory = by_entity[candidate.unit_number]
        if factory and factory.built then result[#result + 1] = factory end
    end
    return result
end

local pole_filters = {{filter = "type", type = "electric-pole"}}

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local pole = event.entity
    if not pole.valid or pole.type ~= "electric-pole" then return end

    for _, factory in pairs(get_factories_near_pole(pole)) do
        local receiver = factory.outside_energy_receiver
        if receiver and receiver.valid then
            local electric_network = receiver.electric_network_id
            if electric_network and electric_network == pole.electric_network_id then
                connect_power(factory, pole)
            end
        end
    end
end, pole_filters)

factorissimo.on_event(factorissimo.events.on_destroyed(), function(event)
    local pole = event.entity
    if not pole.valid or pole.type ~= "electric-pole" then return end

    local wire_connector = pole.get_wire_connector(defines.wire_connector_id.pole_copper)

    local old_connections = wire_connector.connections
    factorissimo.disconnect_all_copper_connections(pole)

    for _, factory in pairs(get_factories_near_pole(pole)) do
        update_power_connection(factory, pole)
    end

    for _, connection in pairs(old_connections) do
        local origin = connection.origin or defines.wire_origin.player
        if origin ~= defines.wire_origin.radars and connection.target.valid then
            wire_connector.connect_to(connection.target, false, origin)
        end
    end
end, pole_filters)

factorissimo.on_event(defines.events.on_player_selected_area, function(event)
    if event.item == "power-grid-comb" then
        for _, building in pairs(event.entities) do
            if has_layout(building.name) then
                local factory = get_factory_by_building(building)
                if factory then update_power_connection(factory) end
            end
        end
    end
end)

-- The wires between a factory and the outside are created with defines.wire_origin.script,
-- which players cannot remove (SHIFT+CLICK on a pole only removes player wires).

function factorissimo.cleanup_outside_energy_receiver(factory)
    local receiver = factory.outside_energy_receiver
    if receiver and receiver.valid then receiver.destroy() end
    if factory.inside_surface and factory.inside_surface.valid then
        local pole = factorissimo.get_or_create_inside_power_pole(factory)
        factorissimo.disconnect_all_copper_connections(pole)
    end

    local genp = factory.global_electric_network_pole
    if genp then
        if genp.valid then genp.destroy() end
        factory.global_electric_network_pole = nil
    end

    if not (factory.inside_surface and factory.inside_surface.valid) then return end

    local recursive_children = remote_api.find_factories_by_area {
        surface = factory.inside_surface,
        area = {
            {factory.inside_x - 128, factory.inside_y - 128},
            {factory.inside_x + 128, factory.inside_y + 128}
        }
    }

    for _, child in pairs(recursive_children) do
        if child ~= factory then
            factorissimo.update_power_connection(child)
        end
    end
end

function factorissimo.disconnect_all_copper_connections(pole)
    local wire_connector = pole.get_wire_connector(defines.wire_connector_id.pole_copper)
    wire_connector.disconnect_all(defines.wire_origin.player)
    wire_connector.disconnect_all(defines.wire_origin.script)
end
