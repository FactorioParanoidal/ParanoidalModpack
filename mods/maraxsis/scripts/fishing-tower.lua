maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.fishing_tower_spawners = storage.fishing_tower_spawners or {}
    storage.quality_plants = storage.quality_plants or {}
end)

maraxsis.on_event(defines.events.on_script_trigger_effect, function(event)
    local effect_id = event.effect_id
    if effect_id ~= "maraxsis-fishing-plant-created" then return end
    local entity = event.target_entity

    rendering.draw_animation {
        animation = "maraxsis-fishing-plant-animation",
        target = entity,
        surface = entity.surface_index,
        render_layer = "lower-object",
        animation_speed = 0.5,
    }
end)

maraxsis.on_event(maraxsis.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid or entity.name ~= "maraxsis-fishing-tower" then return end

    local fish_spawner = entity.surface.create_entity {
        name = "maraxsis-fish-spawner",
        position = entity.position,
        force = "neutral",
    }

    fish_spawner.destructible = false
    fish_spawner.disabled_by_script = false
    fish_spawner.operable = false
    fish_spawner.minable_flag = false

    local registration_number = script.register_on_object_destroyed(entity)
    storage.fishing_tower_spawners[registration_number] = fish_spawner
end)

maraxsis.on_event(defines.events.on_object_destroyed, function(event)
    local spawner = storage.fishing_tower_spawners[event.registration_number]
    if spawner then spawner.destroy() end
end)

-- https://mods.factorio.com/mod/quality-trees

local function hash_string(x, y, surface_name)
  -- 2D Spatial hash grid to store tree data. 
  -- Using strings as keys as its likely neglible over hashing ints performance wise.
  -- And we have no collisions, and per surface control.
  return surface_name .. ":" .. math.floor(x / 2) .. "," .. math.floor(y / 2)
end

local function register_plant(plant, quality)
    -- no need to store normal quality
    if quality and quality.level > 0 then
        local key = hash_string(plant.position.x, plant.position.y, plant.surface.name)
        storage.quality_plants[key] = quality

        rendering.draw_sprite {
            sprite = "quality." .. quality.name,
            target = {entity = plant, offset = {-0.5, 0.5}},
            surface = plant.surface,
            x_scale = 0.5,
            y_scale = 0.5,
            render_layer = "light-effect"
        }
    end
end

local function harvest_plant(plant, inv_buffer)
    local key = hash_string(plant.position.x, plant.position.y, plant.surface.name)
    local harvest_quality = storage.quality_plants[key]
    if not harvest_quality then return end
    storage.quality_plants[key] = nil

    for i = 1, #inv_buffer do
        local stack = inv_buffer[i]
        if stack and stack.valid_for_read then
        local count = stack.count
        local name = stack.name
        stack.clear()  -- remove the original
        inv_buffer.insert{
            name = name,
            count = count,
            quality = harvest_quality
        }
        end
    end
end

maraxsis.on_event(defines.events.on_tower_mined_plant, function(event)
    harvest_plant(event.plant, event.buffer)
end)

maraxsis.on_event(defines.events.on_player_mined_entity, function(event)
    local entity = event.entity
    if entity and entity.valid and entity.type == "plant" then
        harvest_plant(entity, event.buffer)
    end
end)

maraxsis.on_event(defines.events.on_robot_mined_entity, function(event)
    local entity = event.entity
    if entity and entity.valid and entity.type == "plant" then
        harvest_plant(entity, event.buffer)
    end
end)

maraxsis.on_event(defines.events.on_tower_planted_seed, function(event)
    local quality = event.seed.quality
    local plant = event.plant
    if plant.name == "maraxsis-fishing-plant" then
        register_plant(plant, quality)
    end
end)