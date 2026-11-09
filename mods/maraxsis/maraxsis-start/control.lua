local function fix_non_collideable_cliffs(surface)
    if game.tick ~= 0 then return end
    if storage.cliffs_fixed then return end
    storage.cliffs_fixed = true

    local cliffs = surface.find_entities_filtered {type = "cliff", name = "cliff-maraxsis-collisionless"}
    for _, cliff in pairs(cliffs) do
        local position = cliff.position
        local cliff_orientation = cliff.cliff_orientation
        cliff.destroy()
        surface.create_entity {
            name = "cliff-maraxsis",
            position = position,
            cliff_orientation = cliff_orientation,
        }
    end
end

local function fix_duplicate_water_shaders(surface)
    if game.tick ~= 0 then return end
    if storage.water_shaders_fixed then return end
    storage.water_shaders_fixed = true

    local shaders = surface.find_entities_filtered {type = "simple-entity", name = "maraxsis-water-shader"}
    for _, shader in pairs(shaders) do
        local position = shader.position
        shader.destroy()
    end
end

maraxsis.on_event(defines.events.on_player_created, function(event)
    if not remote.interfaces["freeplay"] then return end
    local player = game.get_player(event.player_index)
    local surface = player.surface
    if surface.name ~= "maraxsis" then return end
    fix_non_collideable_cliffs(surface)
    fix_duplicate_water_shaders(surface)
    pcall(player.exit_cutscene)
    player.insert {name = "light-armor", count = 1}
    player.insert {name = "maraxsis-diesel-submarine", count = 1}
    player.insert {name = "rocket-fuel", count = 80}
end)

maraxsis.on_event(maraxsis.events.on_init(), function()
    if not remote.interfaces["freeplay"] then return end
    remote.call("freeplay", "set_created_items", {})
    remote.call("freeplay", "set_ship_items", {
        ["maraxsis-a-breath-of-fresh-air"] = 1,
        ["foundry"] = 5,
        ["crusher"] = 1,
        ["maraxsis-geothermal-generator"] = 1,
        ["medium-electric-pole"] = 20,
    })
    remote.call("freeplay", "set_debris_items", {
        ["iron-plate"] = 100,
        ["tungsten-plate"] = 100,
    })
end)

maraxsis.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id ~= "on_built_a_breath_of_fresh_air" then return end
    local entity = event.source_entity
    entity.destructible = false
    storage.fresh_air_infinity_pipes = storage.fresh_air_infinity_pipes or {}
    local infinity_pipe = entity.surface.create_entity {
        name = "maraxsis-a-breath-of-fresh-air-infinity-pipe",
        position = entity.position,
        force = entity.force,
        create_build_effect_smoke = false,
    }
    infinity_pipe.destructible = false
    infinity_pipe.operable = false
    infinity_pipe.set_infinity_pipe_filter{
        name = "maraxsis-atmosphere",
        percentage = 1,
        temperature = 25,
        mode = "add"
    }
    local registration_number = script.register_on_object_destroyed(entity)
    storage.fresh_air_infinity_pipes[registration_number] = infinity_pipe
end)

maraxsis.on_event(defines.events.on_object_destroyed, function(event)
    if not storage.fresh_air_infinity_pipes then return end
    local infinity_pipe = storage.fresh_air_infinity_pipes[event.registration_number]
    if not infinity_pipe then return end
    infinity_pipe.destroy()
    storage.fresh_air_infinity_pipes[event.registration_number] = nil
end)
