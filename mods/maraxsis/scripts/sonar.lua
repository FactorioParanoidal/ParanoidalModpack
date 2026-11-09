local composite_entity_creation = {
    ["maraxsis-sonar"] = function(entity)
        local surface = entity.surface
        local position = entity.position
        local x, y = position.x, position.y
        local force = entity.force_index

        local light_1 = surface.create_entity {
            name = "maraxsis-sonar-light-1",
            position = {x, y + 1},
            force = force,
        }

        local light_2 = surface.create_entity {
            name = "maraxsis-sonar-light-2",
            position = {x, y - 1},
            force = force,
        }

        return {light_1, light_2}
    end,
}

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.composite_entities = storage.composite_entities or {}
end)

local function on_built(event)
    local entity = event.created_entity or event.entity
    if not entity.valid then return end
    local f = composite_entity_creation[entity.name]
    if not f then return end
    local sub_entities = f(entity)
    if not entity.valid then return end
    for _, sub_entity in pairs(sub_entities) do
        if type(sub_entity) == "table" then
            sub_entity.destructible = false
            sub_entity.operable = false
            sub_entity.minable_flag = false
            sub_entity.rotatable = false
        end
    end
    storage.composite_entities[entity.unit_number] = sub_entities
end
maraxsis.on_event(maraxsis.events.on_built(), on_built)

local function on_destroyed(event)
    local entity = event.entity
    if not entity.valid or not composite_entity_creation[entity.name] then return end
    local sub_entities = storage.composite_entities[entity.unit_number]
    if not sub_entities then return end
    for _, sub_entity in pairs(sub_entities) do
        if type(sub_entity) == "number" then
            rendering.destroy(sub_entity)
        elseif sub_entity.valid then
            sub_entity.destroy()
        end
    end
    storage.composite_entities[entity.unit_number] = nil
end

maraxsis.on_event(maraxsis.events.on_destroyed(), on_destroyed)

maraxsis.on_event(defines.events.on_entity_cloned, function(event)
    local source = event.source
    if not composite_entity_creation[source.name] then return end
    on_destroyed {entity = source}
    on_built {entity = event.destination}
    if source.valid then source.destroy() end
end)
