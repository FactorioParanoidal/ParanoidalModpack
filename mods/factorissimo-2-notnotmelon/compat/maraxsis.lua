local function spawn_maraxsis_water_shader(surface, chunk_position)
    local x = chunk_position.x * 32 + 16
    local y = chunk_position.y * 32 + 16

    local fancy_water = surface.create_entity {
        name = "maraxsis-water-shader",
        position = {x, y},
        create_build_effect_smoke = false
    }
    fancy_water.active = false
    fancy_water.destructible = false
    fancy_water.minable_flag = false
end

function factorissimo.spawn_maraxsis_water_shaders(surface, chunk_position)
    if not script.active_mods["maraxsis"] then return end
    if surface.name ~= "maraxsis-factory-floor" and surface.name ~= "maraxsis-trench-factory-floor" then return end

    for x = -7, 8 do
        for y = -7, 8 do
            spawn_maraxsis_water_shader(surface, {
                x = chunk_position.x + x,
                y = chunk_position.y + y
            })
        end
    end
end
