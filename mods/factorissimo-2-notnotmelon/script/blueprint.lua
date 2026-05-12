local has_layout = has_layout

local function setup_blueprint_tags(blueprint, mapping)
    for i, entity in pairs(mapping) do
        local factory = storage.factories_by_entity[entity.unit_number]
        if factory and has_layout(entity.name) then
            blueprint.set_blueprint_entity_tag(i, "id", factory.id)
        elseif factorissimo.connection_indicator_names[entity.name] then
            local factory = remote_api.find_surrounding_factory(entity.surface, entity.position)
            if factory then
                for cid, indicator in pairs(factory.connection_indicators) do
                    if indicator.valid and indicator.unit_number == entity.unit_number then
                        local ctype = factorissimo.connection_indicator_names[entity.name]
                        local settings = factorissimo.get_connection_settings(factory, cid, ctype)
                        for k, v in pairs(settings) do
                            blueprint.set_blueprint_entity_tag(i, k, v)
                        end
                    end
                end
            end
        end
    end
end

local function paste_blueprint(inventory, destination)
    if not inventory.valid then return end
    if destination.inside_surface and destination.inside_surface.valid and destination.force.valid then
        local stack = inventory[1]
        stack.build_blueprint {
            surface = destination.inside_surface,
            force = destination.force,
            position = {destination.inside_x - 1, destination.inside_y - 1},
            build_mode = defines.build_mode.forced,
            skip_fog_of_war = true,
            raise_built = true
        }
        stack.clear()
    end
    inventory.destroy()
end
factorissimo.register_delayed_function("paste_blueprint", paste_blueprint)

function factorissimo.copy_entity_ghosts(source, destination)
    if not source.inside_surface.valid or not destination.inside_surface.valid then return end

    local j = 60
    local first_anchor = source.inside_surface.create_entity {name = "factory-blueprint-anchor", position = {source.inside_x - j, source.inside_y - j}, force = source.force}
    local second_anchor = source.inside_surface.create_entity {name = "factory-blueprint-anchor", position = {source.inside_x + j, source.inside_y + j}, force = source.force}

    local inventory = game.create_inventory(1)
    inventory.insert {name = "blueprint", count = 1}
    local stack = inventory[1]
    local area = {first_anchor.position, second_anchor.position}
    local mapping = stack.create_blueprint {
        surface = source.inside_surface,
        force = source.force,
        area = area,
        always_include_tiles = true,
        include_trains = true,
        include_station_names = true
    }
    setup_blueprint_tags(stack, mapping)
    script.raise_event("on_script_setup_blueprint", {
        surface = source.inside_surface,
        area = area,
        stack = stack,
        alt = false,
        item = stack.name,
        quality = stack.quality.name,
        name = "on_script_setup_blueprint",
        tick = game.tick,
        mapping = mapping
    })

    factorissimo.copy_overlay_between_factory_buildings(source, destination)

    -- Delay this function a bit to give the radars a chance to scan the area
    factorissimo.execute_later("paste_blueprint", 240, inventory, destination)

    first_anchor.destroy()
    second_anchor.destroy()
end

-- setup ghost tags for factory components
factorissimo.on_event(defines.events.on_player_setup_blueprint, function(event)
    local player = game.get_player(event.player_index)
    local blueprint = player.blueprint_to_setup
    if not blueprint.valid_for_read then blueprint = player.cursor_stack end
    if not blueprint or not blueprint.valid_for_read then return end

    local entities = blueprint.get_blueprint_entities()
    if not entities then return end
    local mapping = event.mapping.get()
    for i, entity in ipairs(entities) do
        local map = mapping[i]
        if not map or map.name ~= entity.name then return end -- Another mod has broken the mapping, abort
    end

    setup_blueprint_tags(blueprint, mapping)
end)

local function get_cpos(factory, position)
    local x, y = position.x or position[1], position.y or position[2]
    for _, cpos in pairs(factory.layout.connections) do
        if cpos.inside_x + factory.inside_x + cpos.indicator_dx == x and cpos.inside_y + factory.inside_y + cpos.indicator_dy == y then
            return cpos
        end
    end
end

local function unpack_connection_settings_from_blueprint(entity)
    if not entity.tags or not next(entity.tags) then return end
    local surface = entity.surface
    local position = entity.position
    local factory = remote_api.find_surrounding_factory(surface, position)
    if not factory then return end

    local ctype = factorissimo.connection_indicator_names[entity.ghost_name]
    local cpos = get_cpos(factory, position)
    if cpos then
        local cid = cpos.id
        local settings = factorissimo.get_connection_settings(factory, cid, ctype)
        for k, v in pairs(entity.tags) do
            settings[k] = v
        end
        local conn = factory.connections[cid]
        if conn then
            factorissimo.destroy_connection(conn)
            factorissimo.init_connection(factory, cid, cpos)
        end
        return
    end
end

local BLUEPRINTABLE_FACTORY_PERIPHERALS = {
    ["factory-construction-roboport"] = true,
    ["factory-construction-chest"] = true,
    ["factory-overlay-controller"] = true,
    ["factory-blueprint-anchor"] = true,
}

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    local entity_name, entity_type = entity.name, entity.type

    local is_ghost = entity_name == "entity-ghost"
    if is_ghost then entity_name = entity.ghost_name end

    if is_ghost and factorissimo.connection_indicator_names[entity_name] then
        unpack_connection_settings_from_blueprint(entity)
        entity.destroy()
        return
    end

    if BLUEPRINTABLE_FACTORY_PERIPHERALS[entity_name] then
        entity.destroy()
    end
end)
