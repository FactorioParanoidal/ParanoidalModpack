-- Research 10: machines and drills with nothing to handle are looked at rarely; the level is cached
-- in storage and a lost research 10 brings the normal looks back. Mocks only, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
storage = {}
game = {tick = 0, forces = {}}
local crafter = require("scripts.defects.crafter")
local drill = require("scripts.defects.drill")
local automation = require("scripts.defects.automation")

-- Crafter -------------------------------------------------------------------------------------------
local function machine(recipe_quality)
    local entity = {
        valid = true, crafting_speed = 1, crafting_progress = 0.5, bonus_progress = 0, productivity_bonus = 0,
        products_finished = 0, result_quality = {name = recipe_quality}, force = {index = 1},
    }
    local recipe = {name = "widget", energy = 2, category = "crafting",
        products = {{type = "item", name = "widget"}}, ingredients = {}}
    entity.get_recipe = function() return recipe, {name = recipe_quality} end
    entity.is_crafting = function() return true end
    return entity
end
local power_calls = 0
local function context(mode)
    return {
        random = function() return 0 end, finished = {widget = true}, initial_loss_percent = 33,
        min_energy = function() return 1 end,
        mode_definition = function() return mode end,
        mode_power = function(_, definition) if not definition then power_calls = power_calls + 1 end return 1 end,
    }
end

local record = {entity = machine("normal")}
assert(crafter.step(record, 10, context()) == crafter.RELAXED, "standard recipe at research 10: rare look")
assert(record.craft == nil and power_calls == 1, "craft dropped, extra power released")
assert(crafter.step(record, 9, context()) < crafter.RELAXED, "below research 10: normal looks")

record = {entity = machine("rare")}
assert(crafter.step(record, 10, context()) == crafter.RELAXED, "positive recipe: nothing to handle")

record = {entity = machine("ic-defect-2")}
assert(crafter.step(record, 10, context()) < crafter.RELAXED, "defective recipe: result must be capped")
assert(record.craft)

record = {entity = machine("normal")}
assert(crafter.step(record, 10, context({name = "careful", time = 5, loss = 0.1, level_bonus = 4, boost = 3}))
    < crafter.RELAXED, "production mode: normal looks")
record = {entity = machine("normal"), debt = {{type = "item", name = "plate", amount = 1}}, debt_key = "x"}
assert(crafter.step(record, 10, context()) < crafter.RELAXED, "owed ingredients: normal looks")
record = {entity = machine("normal"), craft = {key = "widget|normal|0", defect = true, decided = true, progress = 0.4}}
assert(crafter.step(record, 10, context()) < crafter.RELAXED, "defect of an earlier decision is fixed first")

-- Drill ---------------------------------------------------------------------------------------------
local function drill_entity(quality)
    return {
        valid = true, name = "drill", quality = {name = quality}, speed_bonus = 0, mining_progress = 0, bonus_mining_progress = 0,
        force = {index = 1},
        prototype = {mining_speed = 0.5},
        mining_target = {valid = true, name = "ore", position = {x = 0.5, y = 0.5},
            prototype = {mineable_properties = {mining_time = 1}}},
    }
end
record = {entity = drill_entity("normal")}
assert(drill.step(record, 10, {}) == drill.RELAXED and record.multiplier == 1, "standard drill at research 10")
record = {entity = drill_entity("uncommon")}
assert(drill.step(record, 10, {}) == drill.RELAXED, "positive drill at research 10")
record = {entity = drill_entity("ic-defect-1")}
assert(drill.step(record, 10, {}) < drill.RELAXED, "defective drill is still slowed")
assert(record.multiplier < 1)
record = {entity = drill_entity("normal")}
assert(drill.step(record, 9, {random = function() return .99 end}) < drill.RELAXED, "below research 10")

-- Level cache and wake ------------------------------------------------------------------------------
local technologies = {}
for level = 1, 10 do technologies["ic-defect-control-" .. level] = {researched = true} end
local force = {index = 1, valid = true, technologies = technologies}
game.forces = {[1] = force}
assert(automation.level(force) == 10 and storage.ic_defects.levels[1] == 10)
technologies["ic-defect-control-10"].researched = false
assert(automation.level(force) == 10, "cached until refreshed")

-- A rarely watched machine is brought back within one second when research 10 is lost.
local entity = {valid = true, unit_number = 7, type = "assembling-machine", name = "m",
    prototype = {items_to_place_this = {{name = "m"}}}}
game.tick = 100
automation.track(entity)
local s = storage.ic_defects
assert(s.records[7].due == 101)
s.buckets = {}
s.records[7].due = 700
s.buckets[700] = {7}
-- A new mode (track again) moves the look forward; the old bucket entry stays and is skipped.
automation.track(entity)
assert(s.records[7].due == 101 and s.buckets[101][1] == 7)
s.records[7].due = 700
s.buckets = {[700] = {7}}
automation.refresh_levels()
assert(s.levels[1] == 9, "level recounted")
assert(s.records[7].due > 100 and s.records[7].due <= 160, "woken: " .. s.records[7].due)
-- No wake when the level does not drop from 10.
s.records[7].due = 700
s.buckets = {[700] = {7}}
automation.refresh_levels()
assert(s.records[7].due == 700)

-- Looks per operation (any level) --------------------------------------------------------------
for _, left in ipairs({3.5, 10, 100, 1000.25}) do
    local after = left - crafter.approach(left)
    assert(after >= 2 - 1e-9 and after < 3, "lands inside the decision window: " .. left .. " -> " .. after)
end
-- A machine waiting for ingredients with a set recipe: half of that recipe, not of the fastest one.
local idle = machine("normal")
idle.is_crafting = function() return false end
local fast_category = context()
fast_category.min_energy = function() return 0.1 end
assert(crafter.step({entity = idle}, 0, fast_category) == 60, "2 s recipe at speed 1 -> 60 ticks")
idle.get_recipe = function() return nil end
assert(crafter.step({entity = idle}, 0, fast_category) == 3, "no recipe: fastest recipe of the category")
-- A 60-tick craft observed from its start is decided in two looks (was five).
local looks, craft_entity = 0, machine("normal")
craft_entity.crafting_progress = 0
local craft_recipe = {name = "widget", energy = 1, category = "crafting", products = {{type = "item", name = "widget"}},
    ingredients = {}}
craft_entity.get_recipe = function() return craft_recipe, {name = "normal"} end
local craft_record = {entity = craft_entity}
local tick, next_look = 0, 1
local craft_ctx = context()
craft_ctx.random = function() return 0.99 end
while tick < 60 do
    tick = tick + 1
    if tick >= next_look then
        looks = looks + 1
        next_look = tick + crafter.step(craft_record, 0, craft_ctx)
    end
    craft_entity.crafting_progress = craft_entity.crafting_progress + 1 / 60
end
assert(craft_record.craft.decided and looks == 2, "looks: " .. looks)

print("PASS: research 10 - standard/positive machines and drills looked at every " .. crafter.RELAXED .. " ticks;")
print("modes, debts, earlier defects, defective recipes and defective drills keep normal looks; level cached")
print("in storage, re-counted, and a lost research 10 wakes every machine; one look lands in the decision")
print("window, idle machines wait by their own recipe. Mocks only, not Factorio.")
