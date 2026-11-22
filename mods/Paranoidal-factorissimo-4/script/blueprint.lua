local has_layout = has_layout

local function setup_blueprint_tags(blueprint, mapping, cuts)
    for _, planned in ipairs(blueprint.get_blueprint_entities() or {}) do
        local i = planned.entity_number
        local entity = mapping[i]
        local matches = entity and entity.valid and (entity.name == planned.name
            or (entity.type == "entity-ghost" and entity.ghost_name == planned.name))
        if has_layout(planned.name) then
            local factory = matches and entity.type ~= "entity-ghost" and entity.unit_number
                and storage.factories_by_entity[entity.unit_number]
            local tags = planned.tags or {}
            local action, ticket = "copy", nil
            if factory and factory.id then
                tags.id = factory.id
                if cuts then
                    factory.cut_sequence = (factory.cut_sequence or 0) + 1
                    factory.cut_ticket = factory.cut_sequence
                    action, ticket = "cut", factory.cut_ticket
                end
            elseif not matches then
                -- The mapping can be stale after another mod edits the blueprint.
                tags.id = nil
            end
            -- A blueprint of an existing ghost is a copy, not a new recovery/cut authorization.
            tags.factorissimo_action = (tags.id or not matches) and action or nil
            tags.factorissimo_ticket = ticket
            blueprint.set_blueprint_entity_tags(i, tags)
        elseif matches and factorissimo.connection_indicator_names[entity.name] then
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

local function paste_blueprint(inventory, destination, source_force)
    if not inventory.valid then return end
    local stack = inventory[1]
    if stack.valid_for_read and stack.is_blueprint and destination.id and storage.factories[destination.id] == destination
        and destination.inside_surface and destination.inside_surface.valid
        and destination.force and destination.force.valid and (not source_force or source_force == destination.force) then
        -- Includes saves with a paste already queued before tags acquired an action.
        for _, entity in ipairs(stack.get_blueprint_entities() or {}) do
            if has_layout(entity.name) and entity.tags and entity.tags.id then
                stack.set_blueprint_entity_tag(entity.entity_number, "factorissimo_action", "copy")
                stack.set_blueprint_entity_tag(entity.entity_number, "factorissimo_ticket", nil)
            end
        end
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
    if not (source.inside_surface and source.inside_surface.valid and destination.inside_surface
        and destination.inside_surface.valid and source.force and source.force.valid
        and source.force == destination.force) then return false end

    local j = 60
    local first_anchor = source.inside_surface.create_entity {name = "factory-blueprint-anchor", position = {source.inside_x - j, source.inside_y - j}, force = source.force}
    local second_anchor = source.inside_surface.create_entity {name = "factory-blueprint-anchor", position = {source.inside_x + j, source.inside_y + j}, force = source.force}
    if not (first_anchor and second_anchor) then
        if first_anchor then first_anchor.destroy() end
        if second_anchor then second_anchor.destroy() end
        return false
    end

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
    factorissimo.execute_later("paste_blueprint", 240, inventory, destination, source.force)

    first_anchor.destroy()
    second_anchor.destroy()
    return true
end

-- setup ghost tags for factory components
factorissimo.on_event(defines.events.on_player_setup_blueprint, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local blueprint = event.record
    if blueprint then
        if not (blueprint.valid and blueprint.type == "blueprint") then return end
    else
        blueprint = player.blueprint_to_setup
        if not (blueprint and blueprint.valid_for_read) then blueprint = player.cursor_stack end
        if not (blueprint and blueprint.valid_for_read and blueprint.is_blueprint) then return end
    end

    local tool = prototypes.item[event.item]
    local cuts = tool and tool.type == "copy-paste-tool" and tool.cuts
    setup_blueprint_tags(blueprint, event.mapping.get(), cuts)
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
    local tags = entity.tags
    if not tags or not next(tags) then return end
    local surface = entity.surface
    local position = entity.position
    local factory = remote_api.find_surrounding_factory(surface, position)
    if not factory then return end

    local ctype = factorissimo.connection_indicator_names[entity.ghost_name]
    if not factory.layout then return end
    local cpos = get_cpos(factory, position)
    if cpos then
        local cid = cpos.id
        local settings = factorissimo.get_connection_settings(factory, cid, ctype)
        local conn = factory.connections[cid]
        if ctype == "fluid" and conn and conn._type == "fluid" then
            local input = tags.input_mode
            if input == nil then input = settings.input_mode end
            if factorissimo.apply_fluid_blueprint(factory, conn, not not input) then return end
        end
        for k, v in pairs(tags) do
            settings[k] = v
        end
        if conn then
            factorissimo.connection_settings_changed(factory, cid)
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

local peripheral_names = {}
for name in pairs(BLUEPRINTABLE_FACTORY_PERIPHERALS) do peripheral_names[#peripheral_names + 1] = name end

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    local entity_name = entity.name

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
-- Connection indicators are storage tanks; their ghosts come from blueprints.
end, factorissimo.join_filters(factorissimo.entity_filters({}, peripheral_names), factorissimo.ghost_filters({BUILDING_TYPE}, peripheral_names)))
