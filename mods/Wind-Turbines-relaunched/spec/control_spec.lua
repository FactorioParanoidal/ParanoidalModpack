---
--- Tests for scripts/control.lua
---
local Require = require("test.require")
_G.require = Require.replace(_G.require)

-- Mocks for Factorio APIs.
_G.storage = {}

_G.settings = {
    startup = {
        ["texugo-wind-power"] = { value = 1 },
        ["texugo-wind-extended-collision-area"] = { value = false },
        ["texugo-wind-mode"] = { value = "CLASSICAL" },
    }
}

_G.script = {
    on_event_registered = {},
    on_event = function(type, func)
        _G.script.on_event_registered[type] = func
    end
}

_G.log = function(msg) end

_G.serpent = {
    block = function(data)
        return tostring(data)
    end
}

_G.defines = {
    events = {
        on_built_entity = 100,
        on_robot_built_entity = 101,
        script_raised_revive = 102,
        on_object_destroyed = 103,
        on_entity_damaged = 104,
        on_surface_created = 105,
        on_surface_deleted = 106
    }
}

-- Mock function table_size normally provided by the game runtime.
function _G.table_size(tbl)
    if type(tbl) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

local control = _G.require("scripts.control")

local function mock_turbine(entity, name, position, surface)
    return {
        entity = entity,
        name = name,
        position = position,
        surface = surface
    }
end

local function check_event_registered()
    assert.are.equal(1, table_size(_G.script.on_event_registered))
    assert.are.equal("function", type(_G.script.on_event_registered[_G.defines.events.on_entity_damaged]))
end

describe("control", function()
    before_each(function()
        _G.prototypes = {
            space_location = {
                nauvis = { type = "planet", surface_properties = { pressure = 1000 } },
                vulcanus = { type = "planet", surface_properties = { pressure = 4000 } },
                fulgora = { type = "planet", surface_properties = { pressure = 800 } }
            }
        }

        _G.storage.wind_turbines = {}
        _G.storage.wind = 0

        -- register events
        control.on_load()
    end)

    it("exports the expected module members", function()
        assert.is_not_nil(control)
        assert.are.equal("table", type(control))
        assert.is_not_nil(control.on_init)
        assert.is_not_nil(control.on_load)
        assert.is_not_nil(control.on_configuration_changed)
        assert.is_not_nil(control.on_nth_tick)
        assert.are.equal(2, table_size(control.on_nth_tick))
        assert.are.equal(6, table_size(control.events))
    end)

    it("initializes storage and registers events", function()
        control.on_init()

        assert.are.equal(0, _G.storage.wind)
        assert.are.same({}, _G.storage.wind_turbines)
        assert.are.same({}, _G.storage.wind_speed_on_surface)
        assert.are.same({ fulgora = 800, nauvis = 1000, vulcanus = 4000 }, _G.storage.pressures)

        check_event_registered()
    end)

    it("events should be registered", function()
        check_event_registered()
    end)

    it("updates configuration state", function()
        -- Test initial setup.
        _G.storage.old_extended_collision_area = nil

        control.on_configuration_changed()

        -- The stored value should match the current setting.
        assert.are.equal(false, _G.storage.old_extended_collision_area)
    end)

    it("resets wind count when the threshold is reached", function()
        _G.storage.wind = 1800
        control.on_nth_tick[6000]()
        assert.are.equal(0, _G.storage.wind)

        _G.storage.wind = 1799
        control.on_nth_tick[6000]()
        assert.are.equal(1799, _G.storage.wind)
    end)

    it("updates wind and turbine power", function()
        -- Initialize storage objects before the test.
        control.on_init()

        -- Test wind increment.
        control.on_nth_tick[120]()
        assert.are.equal(0.02, _G.storage.wind)

        -- Test with a mock turbine.
        local mock_entity = {
            valid = true,
            type = "electric-energy-interface",
            quality = { level = 0 },
            power_production = 0,
            electric_buffer_size = 0
        }

        _G.storage.wind_turbines[1] = mock_turbine(
            mock_entity,
            "texugo-wind-turbine",
            { x = 0, y = 0 },
            { index = 1, name = "nauvis" }
        )

        control.on_nth_tick[120]()

        assert.is_true(mock_entity.power_production > 0)
        assert.is_true(mock_entity.electric_buffer_size > 0)
    end)

    it("registers a built wind turbine", function()
        local mock_entity = {
            name = "texugo-wind-turbine",
            position = { x = 0, y = 0 },
            surface = {
                create_entity = function(params)
                    return {
                        minable = true,
                        health = 100
                    }
                end
            },
            force = "player",
            health = 100
        }

        _G.script.register_on_object_destroyed = function(entity)
            -- Mock registration number.
            return 123
        end

        local event = { created_entity = mock_entity }

        control.events[_G.defines.events.on_built_entity](event)

        assert.is_not_nil(_G.storage.wind_turbines[123])
        assert.are.equal("texugo-wind-turbine", _G.storage.wind_turbines[123].name)
    end)

    it("removes destroyed turbine objects", function()
        -- Setup mock turbine.
        local mock_surface = {
            valid = true,
            find_entities_filtered = function(params)
                return {
                    {
                        destroy = function()
                        end
                    }
                }
            end
        }

        _G.storage.wind_turbines[456] = {
            { name = "texugo-wind-turbine" },
            "texugo-wind-turbine",
            { x = 0, y = 0 },
            mock_surface
        }

        local event = { registration_number = 456 }

        control.events[_G.defines.events.on_object_destroyed](event)

        assert.is_nil(_G.storage.wind_turbines[456])
    end)

    it("updates pressures on surface events", function()
        -- Test surface created event.
        _G.storage.pressures = { fulgora = 800, nauvis = 1000, vulcanus = 4000 }
        _G.prototypes.space_location.new_planet = {
            type = "planet",
            surface_properties = { pressure = 1500 }
        }

        control.events[_G.defines.events.on_surface_created]()

        assert.are.equal(1500, _G.storage.pressures.new_planet)

        -- Test surface deleted event.
        _G.prototypes.space_location.new_planet = nil

        control.events[_G.defines.events.on_surface_deleted]()

        assert.is_nil(_G.storage.pressures.new_planet)
    end)

    it("applies quality factors", function()
        _G.storage.wind = 1
        _G.storage.wind_turbines = {}

        -- Test different quality levels, including a level higher than 4.
        local qualities = { 0, 1, 2, 3, 4, 5 }

        for _, quality_level in ipairs(qualities) do
            local mock_entity = {
                valid = true,
                type = "electric-energy-interface",
                quality = { level = quality_level },
                power_production = 0,
                electric_buffer_size = 0
            }

            _G.storage.wind_turbines[quality_level] = mock_turbine(
                mock_entity,
                "texugo-wind-turbine",
                { x = 0, y = 0 },
                { index = 1, name = "nauvis" }
            )
        end

        control.on_nth_tick[120]()

        -- Higher quality levels should produce more power.
        assert.is_true(_G.storage.wind_turbines[1].entity.power_production > _G.storage.wind_turbines[0].entity.power_production)
        assert.is_true(_G.storage.wind_turbines[4].entity.power_production > _G.storage.wind_turbines[3].entity.power_production)
        assert.is_true(_G.storage.wind_turbines[5].entity.power_production > _G.storage.wind_turbines[4].entity.power_production)
    end)

    it("applies different turbine type factors", function()
        _G.storage.wind = 1
        _G.storage.wind_turbines = {}

        local turbine_types = {
            "texugo-wind-turbine",
            "texugo-wind-turbine2",
            "texugo-wind-turbine3",
            "texugo-wind-turbine4"
        }

        for i, turbine_type in ipairs(turbine_types) do
            local mock_entity = {
                valid = true,
                type = "electric-energy-interface",
                quality = { level = 0 },
                power_production = 0,
                electric_buffer_size = 0
            }

            _G.storage.wind_turbines[i] = mock_turbine(
                mock_entity,
                turbine_type,
                { x = 0, y = 0 },
                { index = 1, name = "nauvis" }
            )
        end

        control.on_nth_tick[120]()

        -- Higher tier turbines should produce more power.
        assert.is_true(_G.storage.wind_turbines[2].entity.power_production > _G.storage.wind_turbines[1].entity.power_production)
        assert.is_true(_G.storage.wind_turbines[4].entity.power_production > _G.storage.wind_turbines[3].entity.power_production)
    end)

    it("handles entity damage events", function()
        -- Mock setup for the entity damage event.
        local damaged_entity = {
            name = "twt-collision-rect",
            surface = {
                find_entities_filtered = function(params)
                    return {
                        {
                            damage = function(amount, force, damage_type, cause)
                                -- Mock damage function.
                            end,
                            valid = true,
                            health = 50
                        }
                    }
                end
            },
            position = { x = 0, y = 0 }
        }

        local event = {
            entity = damaged_entity,
            original_damage_amount = 25,
            force = "enemy",
            damage_type = { name = "physical" },
            cause = nil
        }

        -- This should not throw an error.
        assert.has_no.errors(function()
            _G.script.on_event_registered[_G.defines.events.on_entity_damaged](event)
        end)
    end)

-- Test that different planets with different pressures affect power output
-- Vulcanus has higher pressure (4000) than Nauvis (1000), so should produce more power
-- (This test assumes wind_scale_with_pressure is enabled and use_surface_wind_speed is enabled)
    it("scales power output by pressure", function()
        -- Backup original globals and module state.
        local original_settings = _G.settings

        -- Mock settings to enable pressure scaling.
        _G.settings = {
            startup = {
                ["texugo-wind-power"] = { value = 1 },
                ["texugo-wind-extended-collision-area"] = { value = false },
                ["texugo-wind-mode"] = { value = "SURFACE+PRESSURE" },
            }
        }

        -- Mock the wind speed module for deterministic output.
        local mock_wind_speed = {
            windspeed = function(surface_index)
                -- sqrt(0.25) is 0.5, which keeps the test deterministic.
                return 0.25
            end
        }

        -- Temporarily replace require for wind_speed.
        local original_require = _G.require
        _G.require = function(module_name)
            if module_name == "scripts/wind_speed" then
                return mock_wind_speed
            end

            return original_require(module_name)
        end

        -- Reload control module with new settings
        package.loaded["scripts/control"] = nil
        local control_test = _G.require("scripts/control")

        -- Test setup
        _G.storage.wind = 1
        _G.storage.wind_turbines = {}
        _G.storage.pressures = { nauvis = 1000, vulcanus = 4000 }

        local nauvis_entity = {
            valid = true,
            type = "electric-energy-interface",
            quality = { level = 0 },
            power_production = 0,
            electric_buffer_size = 0
        }

        local vulcanus_entity = {
            valid = true,
            type = "electric-energy-interface",
            quality = { level = 0 },
            power_production = 0,
            electric_buffer_size = 0
        }

        _G.storage.wind_turbines[1] = mock_turbine(
            nauvis_entity,
            "texugo-wind-turbine",
            { x = 0, y = 0 },
            { index = 1, name = "nauvis" }
        )
        _G.storage.wind_turbines[2] = mock_turbine(
            vulcanus_entity,
            "texugo-wind-turbine",
            { x = 0, y = 0 },
            { index = 2, name = "vulcanus" }
        )

        control_test.on_nth_tick[120]()

        -- Vulcanus has 4x the pressure of Nauvis (4000/1000), so should produce 4x the power
        assert.is_true(vulcanus_entity.power_production > nauvis_entity.power_production)
        local ratio = vulcanus_entity.power_production / nauvis_entity.power_production
        assert.are.near(4, ratio, 1e-6) -- avoid failures due to rounding issues

        -- Restore original settings and require function
        _G.settings = original_settings
        _G.require = original_require
        package.loaded["scripts/control"] = nil -- Force reload for subsequent tests
    end)
end)
