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
-- 2026-10-18: a standard/positive drill at research 10 is dropped from the scheduler (false).
assert(drill.step(record, 10, {}) == false and record.multiplier == 1, "standard drill at research 10")
record = {entity = drill_entity("uncommon")}
assert(drill.step(record, 10, {}) == false, "positive drill at research 10")
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

-- A standard drill built at research 10 is not tracked; it is found again when research 10 is lost.
local standard_drill = {valid = true, unit_number = 8, type = "mining-drill", name = "d", quality = {name = "normal"},
    force = force, prototype = {items_to_place_this = {{name = "d"}}}}
game.surfaces = {{find_entities_filtered = function(filter)
    assert(filter.type == "mining-drill")
    return {standard_drill}
end}}
automation.track(standard_drill)
assert(storage.ic_defects.records[8] == nil, "standard drill at research 10 is not tracked")
local defective_drill = {valid = true, unit_number = 9, type = "mining-drill", name = "d",
    quality = {name = "ic-defect-2"}, force = force, prototype = {items_to_place_this = {{name = "d"}}}}
automation.track(defective_drill)
assert(storage.ic_defects.records[9], "defective drill is tracked at research 10")
storage.ic_defects.records[9] = nil
storage.ic_defects.buckets = {}

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
assert(s.records[8] and s.records[8].due <= 160, "untracked standard drill found again")
s.records[8] = nil
-- No wake when the level does not drop from 10.
s.records[7].due = 700
s.buckets = {[700] = {7}}
automation.refresh_levels()
assert(s.records[7].due == 700)
-- A tracked standard drill is dropped at its next look once research 10 is complete.
technologies["ic-defect-control-10"].researched = true
s.levels = nil
s.records[8] = {id = 8, entity = standard_drill, kind = "drill", due = 800}
s.buckets = {[800] = {8}}
automation.on_tick(800, function() return {} end)
assert(s.records[8] == nil, "standard drill dropped at research 10")
technologies["ic-defect-control-10"].researched = false
s.levels = nil

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

-- Recyclers at research 10 (bug 2026-10-19) -------------------------------------------------------
-- An idle recycler got the rare look: a defective item put in was recycled unobserved and its
-- components kept the defect. Now: idle -> half of the shortest watched recycling at its speed;
-- standard craft -> one look right after it ends; defective craft -> normal path, result standard.
local function recycler(speed)
    local entity = {
        valid = true, name = "recycler-1", crafting_speed = speed, crafting_progress = 0, bonus_progress = 0,
        productivity_bonus = 0, products_finished = 0, force = {index = 1},
    }
    local sim = {crafting = false, outputs = {}, entity = entity}
    local recipe = {name = "assembler-recycling", energy = 0.0625, category = "recycling",
        products = {{type = "item", name = "iron-gear-wheel"}}, ingredients = {{type = "item", name = "assembler", amount = 1}}}
    entity.get_recipe = function()
        if sim.crafting then return recipe, {name = sim.quality} end
        return nil
    end
    entity.is_crafting = function() return sim.crafting end
    function sim.start(quality)
        sim.crafting, sim.quality = true, quality
        entity.crafting_progress, entity.result_quality = 0, {name = quality}
    end
    function sim.update()
        if not sim.crafting then return end
        entity.crafting_progress = entity.crafting_progress + speed / (recipe.energy * 60)
        if entity.crafting_progress >= 1 - 1e-9 then
            local result = entity.result_quality
            sim.outputs[#sim.outputs + 1] = type(result) == "table" and result.name or result
            sim.crafting, entity.crafting_progress = false, 0
            entity.products_finished = entity.products_finished + 1
        end
    end
    return sim
end
local watched_calls = {}
local function recycler_context(loss, mode)
    local ctx = context(mode)
    ctx.initial_loss_percent = loss or 0
    ctx.finished = {}
    ctx.is_recycler = function(entity) return entity.name == "recycler-1" end
    ctx.min_energy = function(_, watched)
        watched_calls[#watched_calls + 1] = watched == true
        return watched and 0.0625 or 0.00625
    end
    return ctx
end

-- Idle: 0.0625 s at speed 0.125 = 30 ticks -> look every 15 ticks (was 600).
local idle_recycler = recycler(0.125)
assert(crafter.step({entity = idle_recycler.entity}, 10, recycler_context()) == 15, "idle recycler at research 10")
assert(watched_calls[#watched_calls] == true, "watched recipes only")
-- Before research 10: watched only without losses and without a production mode.
assert(crafter.step({entity = idle_recycler.entity}, 3, recycler_context(0)) == 15)
assert(crafter.step({entity = idle_recycler.entity}, 3, recycler_context(10)) == 1, "losses: every recycling counts")
assert(watched_calls[#watched_calls] == false)
assert(crafter.step({entity = idle_recycler.entity}, 3,
    recycler_context(0, {name = "careful", time = 5, loss = 0.1, level_bonus = 4, boost = 3})) == 1, "mode: every recycling")
-- Other furnaces keep the rare look.
local furnace = recycler(0.125)
furnace.entity.name = "stone-furnace"
assert(crafter.step({entity = furnace.entity}, 10, recycler_context()) == crafter.RELAXED, "other furnace: rare look")
-- Standard craft: one look right after it ends (half done, 15 ticks left).
local busy = recycler(0.125)
busy.start("normal")
busy.entity.crafting_progress = 0.5
assert(crafter.step({entity = busy.entity}, 10, recycler_context()) == 16, "standard craft: look after its end")

-- Simulation: a defective item put into an idle recycler on any tick gives standard components; a fed
-- recycler (standard and defective items alternating) gets about one look per standard craft.
for _, speed in ipairs({0.125, 0.25, 0.375, 0.5}) do
    for insert = 1, 40 do
        local sim = recycler(speed)
        local record, ctx = {entity = sim.entity}, recycler_context()
        local next_look = 1
        for tick = 1, insert + 200 do
            if tick >= next_look then next_look = tick + math.max(1, math.floor(crafter.step(record, 10, ctx))) end
            if tick == insert then sim.start("ic-defect-3") end
            sim.update()
        end
        assert(#sim.outputs == 1 and sim.outputs[1] == "normal",
            "speed " .. speed .. ", put in on tick " .. insert .. ": " .. tostring(sim.outputs[1]))
    end
end
local fed = recycler(0.125)
local fed_record, fed_ctx = {entity = fed.entity}, recycler_context()
local next_look, fed_looks, queue = 1, 0, {}
for index = 1, 40 do queue[index] = index % 4 == 0 and "ic-defect-1" or "normal" end
for tick = 1, 40 * 30 + 100 do
    if tick >= next_look then
        fed_looks = fed_looks + 1
        next_look = tick + math.max(1, math.floor(crafter.step(fed_record, 10, fed_ctx)))
    end
    if not fed.crafting and #queue > 0 then fed.start(table.remove(queue, 1)) end
    fed.update()
end
assert(#fed.outputs == 40, "all crafted")
for _, output in ipairs(fed.outputs) do assert(output == "normal", "fed recycler output " .. output) end
assert(fed_looks <= 30 * 1 + 10 * 3 + 10, "looks for 40 crafts: " .. fed_looks)

print("PASS: research 10 - standard/positive machines looked at every " .. crafter.RELAXED .. " ticks, such drills not tracked;")
print("modes, debts, earlier defects, defective recipes and defective drills keep normal looks; level cached")
print("in storage, re-counted, and a lost research 10 wakes every machine; one look lands in the decision")
print("window, idle machines wait by their own recipe; recyclers look once per craft and catch every defective")
print("item put in. Mocks only, not Factorio.")
