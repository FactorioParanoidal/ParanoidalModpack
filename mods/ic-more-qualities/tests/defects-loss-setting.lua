-- Narrow regression: configurable loss and reversed prerequisite. No engine.
local directory = assert(arg[0]:match("^(.*[/\\])"))
local root = directory .. "../"
package.path = root .. "?.lua;" .. package.path
local model = require("scripts.defects.model")
local hand_loss = require("scripts.defects.production-loss")
local mining = require("scripts.defects.mining")
local builder = require("prototypes.defects-preview")
local function no_rng() error("Unexpected loss roll") end
assert(model.default_loss_percent == 33)
for _, percent in ipairs({0, 10, 33, 50, 66.6, 100}) do
    for level = 0, 10 do
        local expected = percent * (10 - level) / 1000
        assert(model.loss_probability(level, percent) == expected)
        if expected < 1 then assert(not model.production_failed(level, expected, percent)) end
        if expected > 0 then assert(model.production_failed(level, expected / 2, percent)) end
    end
    assert(not model.roll_loss(10, no_rng, percent))
end
assert(model.loss_probability(0) == .33 and model.loss_probability(9) == .033)
assert(not model.roll_loss(0, no_rng, 0))
for _, bad in ipairs({-1, 101, "33", math.huge, 0/0}) do
    assert(not pcall(model.loss_probability, 0, bad))
end
local force = {technologies = {}}
local player = {valid = true, force = force}
local cleared = 0
local stack = {valid_for_read = true, name = "gear", clear = function() cleared = cleared + 1 end}
assert(hand_loss.handle({item_stack = stack}, player, function() return .4 end, {}, false) == "survived")
assert(hand_loss.handle({item_stack = stack}, player, function() return .4 end, {}, false, 50) == "empty-result")
assert(hand_loss.handle({item_stack = stack}, player, no_rng, {}, false, 0) == "survived")
assert(hand_loss.handle({item_stack = stack}, player, no_rng, {gear = true}, true, 100) == "protected-finished")
local buffer = {valid = true, is_empty = function() return false end,
    clear = function() cleared = cleared + 1 end}
local ore = {valid = true, type = "resource"}
assert(mining.handle(ore, buffer, force, function() return .4 end) == "survived")
assert(mining.handle(ore, buffer, force, function() return .4 end, 50) == "lost")
assert(mining.handle(ore, buffer, force, no_rng, 0) == "survived")
assert(cleared == 2)

local raw = {quality = {normal = {level = 0}}, technology = {
    ["quality-module"] = {prerequisites = {"modules"}}, modules = {}}}
local prototypes_list = builder.prepare(raw)
local total = 0
for _, prototype in ipairs(prototypes_list) do
    if prototype.type == "technology" then
        local level = tonumber(prototype.name:match("(%d+)$"))
        assert(#prototype.prerequisites == (level == 1 and 0 or 1))
        if level > 1 then assert(prototype.prerequisites[1] == "ic-defect-control-" .. (level - 1)) end
        total = total + prototype.unit.count
    end
end
assert(total == 550)
local parents = raw.technology["quality-module"].prerequisites
assert(#parents == 2 and parents[1] == "modules" and parents[2] == "ic-defect-control-10")

-- Actual control wiring: setting reaches both event adapters and the shared
-- machine/drill context. No engine object/inventory simulation.
local events = {on_force_created = 1, on_force_reset = 2, on_player_crafted_item = 3,
    on_player_mined_entity = 4, on_robot_mined_entity = 5}
local callbacks, context = {}, nil
defines = dofile(directory .. "mock.lua").defines(events)
script = {on_init = function() end, on_configuration_changed = function() end,
    on_event = function(event, fn) callbacks[event] = fn end}
require("scripts.defects.automation").register = function(_, factory) context = factory end
local passed = {}
hand_loss.handle = function(_, _, _, _, _, percent) passed.hand = percent; return "empty-result" end
mining.handle = function(_, _, _, _, percent) passed.mining = percent end
settings = {startup = {["ic-more-qualities-defects-preview"] = {value = true}}, global = {
    ["ic-more-qualities-loss-exclude-finished"] = {value = false},
    ["ic-more-qualities-initial-loss-percent"] = {value = 33}}}
prototypes = {recipe = {}, mod_data = {["ic-defects-classification"] = {data = {finished = {}}}}}
game = {get_player = function() return player end}
dofile(root .. "control.lua")
for _, percent in ipairs({33, 0, 100, 25.5}) do
    settings.global["ic-more-qualities-initial-loss-percent"].value = percent
    callbacks[3]({player_index = 1, item_stack = stack})
    assert(passed.hand == percent)
    callbacks[4]({player_index = 1, entity = ore, buffer = buffer})
    assert(passed.mining == percent)
    passed.mining = nil
    callbacks[5]({robot = {valid = true, force = force}, entity = ore, buffer = buffer})
    assert(passed.mining == percent and context().initial_loss_percent == percent)
end
print("PASS: 33% default, configurable 0..100%, all 11 research levels, zero-loss RNG guard,")
print("hand/mining adapters and live setting routing; control 10 precedes quality-module; cost 550.")
print("Pure Lua/mocks only. No engine, inserter-energy or turret-range verification.")
