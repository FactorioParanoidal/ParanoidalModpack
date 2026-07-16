package.path = "mods/toxicPollution2/?.lua;mods/toxicPollution2/?/init.lua;../?.lua;../?/init.lua;" .. package.path

require("util.class")
require("classes.detector")

local function assert_equals(actual, expected, message)
    if actual ~= expected then
        error((message or "assertion failed") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end

local function make_surface(pollution)
    return {
        name = "nauvis",
        get_pollution = function()
            return pollution
        end,
    }
end

local function make_entity(behavior)
    return {
        type = "constant-combinator",
        unit_number = 42,
        surface = make_surface(123.9),
        position = {x = 1, y = 2},
        get_control_behavior = function()
            return behavior
        end,
    }
end

local function test_registers_factorio_1_parameters()
    storage = {combinators = {}}
    local detector = Detector(1)
    local behavior = {
        valid = true,
        enabled = true,
        parameters = {
            {signal = {type = "virtual", name = "signal-yellow-more-toxin"}},
        },
    }

    detector:CheckEntity(make_entity(behavior))

    assert_equals(storage.combinators[42].idx, 1, "legacy slot should be stored")
    assert_equals(behavior.parameters[1].signal.count, 123, "legacy signal count should be updated")
end

local function test_registers_factorio_2_sections_without_parameters()
    storage = {combinators = {}}
    local detector = Detector(1)
    local written_slot
    local written_filter
    local section = {
        filters_count = 1,
        get_slot = function()
            return {
                value = {type = "virtual", name = "signal-yellow-more-toxin", quality = "normal"},
                min = 1,
            }
        end,
        set_slot = function(slot, filter)
            written_slot = slot
            written_filter = filter
        end,
    }
    local behavior = {
        valid = true,
        enabled = true,
        sections_count = 1,
        get_section = function(index)
            if index == 1 then
                return section
            end
        end,
    }
    setmetatable(behavior, {
        __index = function(_, key)
            if key == "parameters" then
                error("LuaConstantCombinatorControlBehavior doesn't contain key parameters.")
            end
        end,
    })

    detector:CheckEntity(make_entity(behavior))

    assert_equals(storage.combinators[42].section, 1, "section index should be stored")
    assert_equals(storage.combinators[42].idx, 1, "slot index should be stored")
    assert_equals(written_slot, 1, "slot should be updated")
    assert_equals(written_filter.min, 123, "pollution should be written as filter minimum")
end

test_registers_factorio_1_parameters()
test_registers_factorio_2_sections_without_parameters()

print("detector_spec: ok")
