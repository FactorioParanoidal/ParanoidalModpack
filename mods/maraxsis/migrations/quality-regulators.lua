local function place_regulator(pressure_dome_data)
    local surface = pressure_dome_data.surface
    if not surface.valid then return end
    local position = pressure_dome_data.position
    local x, y = position.x, position.y
    local force = pressure_dome_data.force_index
    local quality = pressure_dome_data.quality

    if not quality and pressure_dome_data.regulator and pressure_dome_data.regulator.valid then
        quality = pressure_dome_data.regulator.quality
    end

    if not quality then
        game.print("ERROR: quality is nil for pressure dome at [gps=" .. x .. "," .. y .. "," .. surface.name .. "]")
        return
    end

    if type(quality) == "string" then
        quality = prototypes.quality[quality]
    end

    local regulator = pressure_dome_data.regulator
    if not regulator or not regulator.valid then
        storage.script_placing_the_regulator = true
        regulator = surface.create_entity {
            name = "maraxsis-regulator",
            position = {x, y},
            quality = quality,
            force = force,
            create_build_effect_smoke = false,
            raise_built = true,
        }
        storage.script_placing_the_regulator = false
    end

    regulator.minable_flag = false
    regulator.destructible = false
    regulator.operable = true

    pressure_dome_data.regulator = regulator

    local regulator_fluidbox = pressure_dome_data.regulator_fluidbox
    if not regulator_fluidbox or not regulator_fluidbox.valid then
        regulator_fluidbox = surface.create_entity {
            name = "maraxsis-regulator-fluidbox-" .. quality.name,
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

for _, dome_data in pairs(storage.pressure_domes or {}) do
    place_regulator(dome_data)
end
