---
--- Tests for scripts/wind_speed.lua
---
local Require = require("test.require")
require = Require.replace(require)

-- SUT
local wind_speed = require("scripts.wind_speed")

-- Provide the global storage used by wind_speed.lua.
_G.storage = _G.storage or {}

describe("wind_speed", function()
    local orig_random

    before_each(function()
        -- Fresh storage for each test.
        _G.storage.wind_speed_on_surface = {}

        -- Keep original math.random to restore later.
        orig_random = math.random
    end)

    after_each(function()
        -- Restore math.random.
        math.random = orig_random
    end)

    it("init returns values in expected ranges", function()
        -- Ensure init produces values in expected ranges.
        local init_state = wind_speed.init()

        assert.is_number(init_state.v)
        assert.is_number(init_state.delta_v)
        assert.is_true(init_state.v >= 0 and init_state.v <= 1, "v should be in [0,1]")
        assert.is_true(init_state.delta_v >= -0.05 and init_state.delta_v <= 0.05, "delta_v should be in [-0.05,0.05]")
    end)

    it("windspeed initializes storage when missing", function()
        -- When there is no state for a surface, windspeed() should initialize it.
        local idx = 1

        assert.is_nil(_G.storage.wind_speed_on_surface[idx])

        local v = wind_speed.windspeed(idx)

        assert.is_number(v)
        assert.is_true(v >= 0 and v <= 1, "returned v should be in [0,1]")

        local ws = _G.storage.wind_speed_on_surface[idx]

        assert.is_not_nil(ws, "state should be stored for surface index")
        assert.is_number(ws.v)
        assert.is_number(ws.delta_v)
        assert.is_true(ws.v >= 0 and ws.v <= 1, "stored v should be in [0,1]")
        assert.is_true(ws.delta_v >= -0.05 and ws.delta_v <= 0.05, "stored delta_v should be in [-0.05,0.05]")
    end)

    -- this test should only run without coverage, as this slows it down dramatically
    it("#no_coverage windspeed updates and clamps values over multiple steps", function()
        -- Calls should update the state and keep values within bounds.
        local idx = 2
        local sum = 0
        local max = 100000

        local min_v = math.huge
        local max_v = -math.huge
        local min_stored_v = math.huge
        local max_stored_v = -math.huge
        local min_delta_v = math.huge
        local max_delta_v = -math.huge
        local mmin = math.min
        local mmax = math.max

        for _ = 1, max do
            local v = wind_speed.windspeed(idx)
            local ws = _G.storage.wind_speed_on_surface[idx]

            sum = sum + v

            min_v = mmin(min_v, v)
            max_v = mmax(max_v, v)
            min_stored_v = mmin(min_stored_v, ws.v)
            max_stored_v = mmax(max_stored_v, ws.v)
            min_delta_v = mmin(min_delta_v, ws.delta_v)
            max_delta_v = mmax(max_delta_v, ws.delta_v)
        end

        assert.is_true(min_v >= 0, "v should stay >= 0")
        assert.is_true(max_v <= 1, "v should stay <= 1")
        assert.is_true(min_stored_v >= 0, "stored v should stay >= 0")
        assert.is_true(max_stored_v <= 1, "stored v should stay <= 1")
        assert.is_true(min_delta_v >= -0.05, "delta_v should stay >= -0.05")
        assert.is_true(max_delta_v <= 0.05, "delta_v should stay <= 0.05")
        assert.near(max * 0.5, sum, max * 0.05)
    end)

    it("handles delta logic when negative", function()
        -- If delta_v is negative, min is adjusted upward:
        -- min = -0.01 - delta_v/5, so with delta_v = -0.05 -> min = 0.
        local idx = 3

        _G.storage.wind_speed_on_surface[idx] = { v = 0.5, delta_v = -0.05 }

        -- Force math.random() to return 0 to select the lower edge of the range.
        math.random = function()
            return 0
        end

        local v = wind_speed.windspeed(idx)

        assert.is_true(v >= 0 and v <= 1, "v should be clamped to [0,1]")

        local ws = _G.storage.wind_speed_on_surface[idx]

        assert.are.near(v, ws.v, 1e-12)
        -- With min=0 and random=0, delta increment is 0; in_range keeps -0.05.
        assert.are.near(-0.05, ws.delta_v, 1e-12)
    end)

    it("handles delta logic when positive", function()
        -- If delta_v is positive, max is adjusted downward:
        -- max = 0.01 - delta_v/5, so with delta_v = 0.05 -> max = 0.
        local idx = 4

        _G.storage.wind_speed_on_surface[idx] = { v = 0.5, delta_v = 0.05 }

        -- Force math.random() to return 1 to select the upper edge of the range.
        math.random = function()
            return 1
        end

        local v = wind_speed.windspeed(idx)

        assert.is_true(v >= 0 and v <= 1, "v should be clamped to [0,1]")

        local ws = _G.storage.wind_speed_on_surface[idx]

        assert.are.near(v, ws.v, 1e-12)
        -- With max=0 and random=1, delta increment is 0; in_range keeps 0.05.
        assert.are.near(0.05, ws.delta_v, 1e-12)
    end)

    it("clamps v even with a large existing delta", function()
        -- Even if an existing stored delta_v is out of range, v should be clamped on update.
        local idx = 5

        _G.storage.wind_speed_on_surface[idx] = { v = 0.95, delta_v = 1.0 } -- Intentionally out of normal range.

        -- Force no additional delta change effect for determinism.
        math.random = function()
            return 0.5
        end

        local v = wind_speed.windspeed(idx)

        assert.is_true(v <= 1 and v >= 0, "v must be clamped to [0,1]")
        assert.are.near(v, _G.storage.wind_speed_on_surface[idx].v, 1e-12)

        -- New delta_v is always clamped within [-0.05, 0.05].
        assert.is_true(_G.storage.wind_speed_on_surface[idx].delta_v >= -0.05)
        assert.is_true(_G.storage.wind_speed_on_surface[idx].delta_v <= 0.05)
    end)
end)
