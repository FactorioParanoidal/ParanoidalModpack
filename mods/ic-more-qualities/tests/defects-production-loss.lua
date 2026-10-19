local directory = assert(arg[0]:match("^(.*[/\\])"))
local root = directory .. "../"
package.path = root .. "?.lua;" .. package.path
local model = require("scripts.defects.model")
local loss = require("scripts.defects.production-loss")
-- Finished-product set of the data-stage classification (buildings and science are finished).
local catalog = {building = true, science = true}
local mock = dofile(directory .. "mock.lua")
local function player(level)
    local p = {valid = true, force = {technologies = {}}}
    for i = 1, level do p.force.technologies[model.research_prefix .. i] = {researched = true} end
    return p
end
local function stack(name, finished, quality)
    local s = {valid_for_read = true, name = name, count = 7,
        quality = {name = quality or "normal"},
        prototype = {name = name, type = "item", place_result = finished and {} or nil}}
    s.clear = function() s.valid_for_read = false; s.count = 0 end
    return s
end
local function no_rng() error("Unexpected random draw") end
for level = 0, 10 do
    local probability = model.loss_probability(level)
    assert(math.abs(probability - .033 * (10 - level)) < 1e-12) -- default 33%, minus 3.3 points per level
    assert(not model.production_failed(level, probability))
    if level < 10 then assert(model.production_failed(level, probability - 1e-9)) end
    local lost = 0
    for i = 0, 1999 do
        if model.production_failed(level, (i + .5) / 2000) then lost = lost + 1 end
    end
    assert(lost == (10 - level) * 66)
end
for _, bad in ipairs({-1, 11, .5, "1"}) do
    assert(not pcall(model.loss_probability, bad))
end
assert(not pcall(model.production_failed, 0, 1))
assert(not pcall(model.production_failed, 0, 0/0))

for _, finished in ipairs({false, true}) do
    for _, quality in ipairs({"normal", "ic-defect-5", "legendary"}) do
        local s = stack("test", finished, quality)
        assert(loss.handle({item_stack = s}, player(0), function() return .32 end, catalog, false) == "empty-result")
        assert(not s.valid_for_read and s.count == 0)
        s = stack("test", finished, quality)
        assert(loss.handle({item_stack = s}, player(0), function() return .33 end, catalog, false) == "survived")
        assert(s.count == 7 and s.quality.name == quality)
    end
end
local finished = stack("building", true)
assert(loss.handle({item_stack = finished}, player(0), no_rng, catalog, true) == "protected-finished")
local science = stack("science", false)
assert(loss.handle({item_stack = science}, player(0), no_rng, catalog, true) == "protected-finished")
local intermediate = stack("gear", false)
assert(loss.handle({item_stack = intermediate}, player(0), function() return 0 end, catalog, true) == "empty-result")
local final_force = player(10)
local s = stack("gear", false)
assert(loss.handle({item_stack = s}, final_force, no_rng, catalog, false) == "loss-free")
final_force.force.technologies[model.research_prefix .. 1].researched = false
assert(loss.handle({item_stack = s}, final_force, function() return 0 end, catalog, false) == "empty-result")
assert(loss.handle({}, player(0), no_rng, catalog, false) == "ignored")
assert(loss.handle({item_stack = finished}, {valid = false}, no_rng, catalog, false) == "ignored")

-- Actual control entry point: ordering, setting changes and zero quality draws
-- after loss. No Factorio objects; deliberately no player inventory API.
local callbacks = {}
defines = mock.defines({on_force_created = 1, on_force_reset = 2, on_player_crafted_item = 3,
    on_built_entity = 4, on_robot_built_entity = 5, script_raised_built = 6,
    script_raised_revive = 7, on_entity_cloned = 8, on_chunk_generated = 9, on_tick = 10})
local configuration
script = {on_init = function() end, on_configuration_changed = function(fn) configuration = fn end,
    on_event = function(id, fn) callbacks[id] = fn end}
settings = {startup = {["ic-more-qualities-defects-preview"] = {value = true}},
    global = {["ic-more-qualities-loss-exclude-finished"] = {value = false},
        ["ic-more-qualities-initial-loss-percent"] = {value = 33}}}
prototypes = {entity = {}, mod_data = {["ic-defects-classification"] = {data = {finished = catalog}}}}
local active_player = player(0)
game = {get_player = function() return active_player end}
storage = {}
dofile(root .. "control.lua")
local original_random = math.random
local draws = 0
math.random = function() draws = draws + 1; return 0 end
local event_stack = stack("gear", false)
callbacks[3]({player_index = 1, item_stack = event_stack})
assert(not event_stack.valid_for_read and draws == 1)
settings.global["ic-more-qualities-loss-exclude-finished"].value = true
callbacks[defines.events.on_runtime_mod_setting_changed]({setting_type = "runtime-global",
    setting = "ic-more-qualities-loss-exclude-finished"})
-- Quality roll still happens for protected finished products. Existing -5
-- avoids needing an inventory mock; protection must not bypass defect handling.
event_stack = stack("building", true, "ic-defect-5")
callbacks[3]({player_index = 1, item_stack = event_stack})
assert(event_stack.valid_for_read and draws == 2)
active_player = player(10)
event_stack = stack("gear", false)
callbacks[3]({player_index = 1, item_stack = event_stack})
assert(event_stack.count == 7 and draws == 2)
settings.startup["ic-more-qualities-defects-preview"].value = false
-- A changed startup setting always comes with a configuration change (cached until then).
game.forces, storage = {}, storage or {}
configuration({})
active_player = player(0)
callbacks[3]({player_index = 1, item_stack = event_stack})
assert(event_stack.count == 7 and draws == 2)
math.random = original_random

-- Handcraft queue: only auto-crafted prerequisites are protected, not a manual batch followed by a
-- consumer (exploit: 50 inserters + 1 fast inserter queued after them skipped all defects).
local recipes = {
    ["fast-inserter"] = {ingredients = {{type = "item", name = "inserter", amount = 1}}},
    ["assembler-2"] = {ingredients = {{type = "item", name = "assembler-1", amount = 1},
        {type = "item", name = "gear", amount = 5}}},
    inserter = {ingredients = {{type = "item", name = "gear", amount = 1}}},
    gear = {ingredients = {{type = "item", name = "plate", amount = 2}}},
}
local function protected(queue, recipe, item)
    return loss.queued_prerequisite(queue, recipe, item or recipe, recipes)
end
assert(not protected({{recipe = "inserter", count = 50}, {recipe = "fast-inserter", count = 1}}, "inserter"),
    "a manual batch is not protected by a consumer queued after it")
assert(not protected({{recipe = "inserter", count = 50}, {recipe = "inserter", count = 1, prerequisite = true},
    {recipe = "fast-inserter", count = 1}}, "inserter"), "the manual entry comes first")
assert(protected({{recipe = "inserter", count = 1, prerequisite = true}, {recipe = "fast-inserter", count = 1},
    {recipe = "inserter", count = 5}}, "inserter"), "auto prerequisite")
assert(protected({{recipe = "fast-inserter", count = 1}, {recipe = "inserter", count = 5}}, "inserter"),
    "own entry already removed: the waiting parent protects its last prerequisite")
assert(protected({{recipe = "gear", count = 4, prerequisite = true}, {recipe = "assembler-2", count = 1}},
    "assembler-1"), "another prerequisite first, then the parent that uses the item")
assert(not protected({{recipe = "inserter", count = 5}}, "inserter") and not protected({}, "inserter")
    and not protected(nil, "inserter"))
print("PASS: 33..0% loss, boundaries, complete new-stack removal, positive quality,")
print("finished/science exemption, force/reset, actual control ordering and settings.")
print("Mock only: NOT machine/mining handling or Factorio handcraft queue verification.")
