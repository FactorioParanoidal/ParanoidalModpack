-- Defect scheduler rewritten 2026-10-29 (scripts/defects/automation.lua, crafter.lua, drill.lua,
-- compiled.lua, scripts/wheel.lua): relevance of machines, one decision per craft at its first look, sleeping
-- machines, recyclers, defective drills slowed by rewinding ahead, level cache and wake, migration of the
-- older storage layout. Mocks only, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
defines.gui_type = {entity = 1}
storage = {}
game = {tick = 0, forces = {}, surfaces = {}, connected_players = {}}
log = function() end

-- Prototypes: a classification and a few recipes -------------------------------------------------------
local finished = {chest = true, belt = true, assembler = true, pack = true}
local no_defect = {belt = true}
local recipe_prototypes = {
    chest = {name = "chest", energy = 0.5, category = "crafting", products = {{type = "item", name = "chest"}},
        ingredients = {{type = "item", name = "plate", amount = 8}}},
    belt = {name = "belt", energy = 0.5, category = "crafting", products = {{type = "item", name = "belt"}},
        ingredients = {{type = "item", name = "plate", amount = 1}}},
    gear = {name = "gear", energy = 0.5, category = "crafting", products = {{type = "item", name = "gear"}},
        ingredients = {{type = "item", name = "plate", amount = 2}}},
    lamp_frame = {name = "lamp_frame", energy = 1, category = "crafting", products = {{type = "item", name = "frame"}},
        ingredients = {{type = "item", name = "chest", amount = 1}}},
    plate = {name = "plate", energy = 3.2, category = "smelting", products = {{type = "item", name = "plate"}},
        ingredients = {{type = "item", name = "ore", amount = 1}}},
    acid = {name = "acid", energy = 1, category = "chemistry", products = {{type = "fluid", name = "acid"}},
        ingredients = {{type = "item", name = "chest", amount = 1}}},
    ["chest-recycling"] = {name = "chest-recycling", energy = 0.0625, category = "recycling",
        products = {{type = "item", name = "plate"}}, ingredients = {{type = "item", name = "chest", amount = 1}}},
    ["ammo-recycling"] = {name = "ammo-recycling", energy = 0.00625, category = "recycling",
        products = {{type = "item", name = "plate"}}, ingredients = {{type = "item", name = "ammo", amount = 1}}},
}
prototypes = {
    recipe = recipe_prototypes,
    mod_data = {["ic-defects-classification"] = {data = {finished = finished, no_defect = no_defect}}},
    get_recipe_filtered = function(filters)
        local result = {}
        for name, recipe in pairs(recipe_prototypes) do
            if recipe.category == filters[1].category then result[name] = recipe end
        end
        return result
    end,
}
local compiled = require("scripts.defects.compiled")
local crafter = require("scripts.defects.crafter")
local drill = require("scripts.defects.drill")
local automation = require("scripts.defects.automation")
local model = require("scripts.defects.model")
local wheel = require("scripts.wheel")

-- compiled ---------------------------------------------------------------------------------------------
local chest = compiled.recipe("chest")
assert(chest.roll and chest.all_finished and not chest.exempt and not chest.defect_input and chest.watched)
assert(compiled.recipe("belt").exempt and not compiled.recipe("belt").roll and not compiled.recipe("belt").watched,
    "an exempt product of standard ingredients needs nothing")
assert(not compiled.recipe("gear").watched and not compiled.recipe("plate").watched, "materials of materials")
assert(compiled.recipe("lamp_frame").defect_input and compiled.recipe("lamp_frame").watched, "finished ingredient")
assert(not compiled.recipe("acid").watched, "fluid-only product: nothing to decide")
assert(compiled.recipe("chest-recycling").watched_recycling and not compiled.recipe("ammo-recycling").watched_recycling)
assert(compiled.recipe("unknown") == nil)
local function machine_prototype(categories, extra)
    local result = {crafting_categories = categories, items_to_place_this = {{name = "x"}}}
    for key, value in pairs(extra or {}) do result[key] = value end
    return result
end
local assembler_info = compiled.machine({prototype = machine_prototype({crafting = true})}, "assembler-1")
assert(assembler_info.relevant and not assembler_info.recycler and assembler_info.min_energy == 0.5)
local furnace_info = compiled.machine({prototype = machine_prototype({smelting = true})}, "stone-furnace")
assert(not furnace_info.relevant, "smelting never needs a look")
assert(not compiled.machine({prototype = machine_prototype({chemistry = true})}, "chemical-plant").relevant)
local recycler_info = compiled.machine({prototype = machine_prototype({recycling = true})}, "recycler-1")
assert(recycler_info.relevant and recycler_info.recycler and recycler_info.watched_min == 0.0625
    and recycler_info.min_energy == 0.00625)
assert(compiled.machine({prototype = machine_prototype({smelting = true},
    {type = "assembling-machine", fixed_recipe = "chest"})}, "fixed").relevant, "a fixed recipe decides")
assert(not compiled.machine({prototype = machine_prototype({smelting = true},
    {type = "furnace", fixed_recipe = "chest"})}, "furnace-without-fixed").relevant, "furnaces have no fixed recipe")

-- Machine mock: result_quality accepts a name (as the engine does) and counts writes.
local function machine(options)
    local quality = options.quality or "normal"
    local result = {name = options.result or quality}
    local entity = {
        valid = true, unit_number = options.id or 1, name = options.name or "assembler-1",
        type = options.type or "assembling-machine", crafting_speed = options.speed or 1,
        crafting_progress = options.progress or 0, bonus_progress = 0, products_finished = 0,
        force = {index = 1}, quality = {name = "normal"}, writes = 0,
        recipe = options.recipe, recipe_quality = quality, crafting = options.crafting ~= false and options.recipe ~= nil,
        effects = options.effects,
    }
    entity.get_recipe = function()
        if not entity.recipe then return nil end
        return {name = entity.recipe}, {name = entity.recipe_quality, next = {name = "uncommon"}, next_probability = 0.1}
    end
    entity.is_crafting = function() return entity.crafting end
    entity.get_control_behavior = function() return entity.behavior end
    return setmetatable(entity, {
        __index = function(_, key) if key == "result_quality" then return result end end,
        __newindex = function(t, key, value)
            if key == "result_quality" then
                result = type(value) == "string" and {name = value} or value
                rawset(t, "writes", rawget(t, "writes") + 1)
            else
                rawset(t, key, value)
            end
        end,
    })
end
local function record_of(entity)
    return {id = entity.unit_number, entity = entity, kind = "crafter", name = entity.name, type = entity.type,
        force_index = 1}
end
local draws = 0
local function context(options)
    options = options or {}
    local infos = options.infos or {["assembler-1"] = assembler_info, ["stone-furnace"] = furnace_info,
        ["recycler-1"] = recycler_info}
    return {
        machine = function(record) return assert(infos[record.name], record.name) end,
        recipe = compiled.recipe,
        random = options.random or function() draws = draws + 1 return 0 end,
        quality_everywhere = options.everywhere ~= false,
        no_quality = {},
        modes = options.modes,
        release_power = options.release_power or function() end,
        mode_power = options.mode_power or function() return 1 end,
        mode_boost = options.mode_boost,
        stat = options.stat,
    }
end

-- crafter: decisions at the first look -------------------------------------------------------------------
-- Level 0, a finished product of standard ingredients: rolled at once (random 0 -> worst grade), next
-- look right after the end (half done: 15 ticks left at 0.5 s and speed 1).
draws = 0
local entity = machine({recipe = "chest", progress = 0.5})
local record = record_of(entity)
local stats = {}
local delay = crafter.step(record, 0, context({stat = function(_, key) stats[key] = (stats[key] or 0) + 1 end}))
assert(entity.result_quality.name == "ic-defect-5" and draws == 1 and delay == 16, "rolled, delay " .. delay)
assert(stats["grade.-5"] == 1)
-- The same craft is not rolled again.
entity.crafting_progress = 0.9
assert(crafter.step(record, 0, context()) == 4 and draws == 1 and entity.writes == 1)
-- The next craft (products_finished changed) is rolled once more.
-- (the engine fixes a new standard result when the next craft starts)
local function engine_result(e, name) getmetatable(e).__newindex(e, "result_quality", {name = name}) end
entity.products_finished, entity.crafting_progress = 1, 0.05
engine_result(entity, "normal")
crafter.step(record, 0, context())
assert(draws == 2 and entity.writes == 3 and entity.result_quality.name == "ic-defect-5")
-- A craft restarted (progress went back, same count) is a new craft.
entity.crafting_progress = 0.01
crafter.step(record, 0, context())
assert(draws == 3)
-- Level 8: the distribution of the level is used (random 0.95 -> standard), not written.
entity = machine({recipe = "chest", progress = 0.1})
crafter.step(record_of(entity), 8, context({random = function() return 0.95 end}))
assert(entity.result_quality.name == "normal" and entity.writes == 0)

-- Research 10: a standard craft of a finished product needs nothing: the machine sleeps.
draws = 0
entity = machine({recipe = "chest", progress = 0.1})
record = record_of(entity)
assert(crafter.step(record, 10, context()) == crafter.DORMANT and record.craft == nil and draws == 0)
-- Defective ingredients at research 10: the result is capped at their grade (a quality module upgrade to
-- standard is taken back); no roll.
entity = machine({recipe = "chest", quality = "ic-defect-2", result = "normal", progress = 0.1})
crafter.step(record_of(entity), 10, context())
assert(entity.result_quality.name == "ic-defect-2" and draws == 0)
-- Before research 10 a roll may only make it worse.
entity = machine({recipe = "chest", quality = "ic-defect-2", progress = 0.1})
crafter.step(record_of(entity), 0, context())
assert(entity.result_quality.name == "ic-defect-5" and draws == 1)
entity = machine({recipe = "chest", quality = "ic-defect-2", progress = 0.1})
crafter.step(record_of(entity), 0, context({random = function() return 0.999999 end}))
assert(entity.result_quality.name == "ic-defect-2", "never better than the ingredients")
-- Exempt product of defective ingredients: standard.
entity = machine({recipe = "belt", quality = "ic-defect-4", progress = 0.1})
crafter.step(record_of(entity), 3, context())
assert(entity.result_quality.name == "normal")
-- Material of defective ingredients: standard; a positive material result stays with quality everywhere.
entity = machine({recipe = "gear", quality = "ic-defect-1", progress = 0.1})
crafter.step(record_of(entity), 3, context())
assert(entity.result_quality.name == "normal")
entity = machine({recipe = "lamp_frame", quality = "normal", result = "rare", progress = 0.1})
assert(crafter.step(record_of(entity), 3, context()) == crafter.DORMANT and entity.result_quality.name == "rare",
    "standard ingredients of a material recipe: nothing to do")
entity = machine({recipe = "lamp_frame", quality = "ic-defect-1", result = "normal", progress = 0.1})
crafter.step(record_of(entity), 3, context())
assert(entity.result_quality.name == "normal" and entity.writes == 0)
-- A positive result of a quality module on standard ingredients stays, no roll.
draws = 0
entity = machine({recipe = "chest", result = "uncommon", progress = 0.1})
crafter.step(record_of(entity), 0, context())
assert(entity.result_quality.name == "uncommon" and draws == 0)

-- Waiting, sleeping, irrelevant -----------------------------------------------------------------------------
-- Waiting with a roll recipe: half of that recipe at the current speed (0.5 s, speed 0.5 -> 30 ticks).
entity = machine({recipe = "chest", crafting = false, speed = 0.5})
assert(crafter.step(record_of(entity), 0, context()) == 30)
-- Waiting with a recipe that needs nothing: asleep.
entity = machine({recipe = "gear", crafting = false})
assert(crafter.step(record_of(entity), 0, context()) == crafter.DORMANT)
-- No recipe: asleep, unless the circuit network sets the recipe.
entity = machine({})
assert(crafter.step(record_of(entity), 0, context()) == crafter.DORMANT)
entity.behavior = {circuit_set_recipe = true}
assert(crafter.step(record_of(entity), 0, context()) == 15, "circuit recipe: half of the fastest recipe")
-- A machine that can never need anything is dropped (it was tracked for a mode that is gone).
entity = machine({name = "stone-furnace", type = "furnace", recipe = "plate"})
assert(crafter.step(record_of(entity), 0, context()) == false)
-- Unsupported speed.
entity = machine({recipe = "chest", speed = 20, progress = 0.1})
local _, warning = crafter.step(record_of(entity), 0, context())
assert(warning == "unsupported-speed")

-- Production modes ------------------------------------------------------------------------------------------
-- A flawless craft (no_defect, time 20): never defective, progress slowed on every look, power drawn.
local power_calls, released, boosts = 0, 0, 0
local modes_state = {[1] = {mode = "precise"}}
local function mode_context(options)
    options = options or {}
    options.modes = modes_state
    options.mode_power = function(_, definition, working) power_calls = power_calls + 1 return 1 end
    options.release_power = function() released = released + 1 end
    options.mode_boost = function() boosts = boosts + 1 return false end
    return context(options)
end
draws = 0
entity = machine({recipe = "chest", progress = 0})
record = record_of(entity)
delay = crafter.step(record, 0, mode_context())
assert(record.craft.mode == "precise" and entity.result_quality.name == "normal" and draws == 0 and boosts == 1)
assert(delay == 29, "one full-speed tick before the engine would complete: " .. delay)
entity.crafting_progress = 0.5 -- the engine made 0.5 at full speed
crafter.step(record, 0, mode_context())
mock.near(entity.crafting_progress, 0.5 / 20)
assert(power_calls == 2)
-- The mode is switched to normal during the craft: the craft keeps it; the next craft is normal and the
-- extra power is released.
modes_state[1].mode = "normal"
entity.crafting_progress = entity.crafting_progress + 0.1
crafter.step(record, 0, mode_context())
assert(record.craft.mode == "precise")
entity.products_finished, entity.crafting_progress = 1, 0.05
crafter.step(record, 0, mode_context())
assert(record.craft.mode == nil and released >= 1)
modes_state[1].mode = "precise"
-- A slowed craft simulated tick by tick takes about 20 times as long and needs far fewer looks than ticks.
entity = machine({recipe = "chest", progress = 0})
record = record_of(entity)
local looks, next_look, done_tick = 0, 1, nil
for tick = 1, 2000 do
    if tick >= next_look then
        looks = looks + 1
        next_look = tick + crafter.step(record, 0, mode_context())
    end
    entity.crafting_progress = entity.crafting_progress + 1 / 30
    if entity.crafting_progress >= 1 then done_tick = tick break end
end
assert(done_tick and done_tick >= 560 and done_tick <= 640, "slowed craft: " .. tostring(done_tick))
assert(looks < 120, "looks for a flawless craft of 600 ticks: " .. looks)

-- Simulation: a fed assembler of a finished product gets one look and one roll per craft ---------------------
local function simulate(level, ticks, speed, insert_gap)
    draws = 0
    local sim = machine({recipe = "chest", speed = speed, progress = 0})
    local sim_record = record_of(sim)
    local outputs, sim_looks, next_tick, idle = {}, 0, 1, 0
    local energy = 0.5
    for tick = 1, ticks do
        if tick >= next_tick then
            sim_looks = sim_looks + 1
            next_tick = tick + crafter.step(sim_record, level, context())
        end
        if sim.crafting then
            sim.crafting_progress = sim.crafting_progress + speed / (energy * 60)
            if sim.crafting_progress >= 1 then
                outputs[#outputs + 1] = sim.result_quality.name
                rawset(sim, "products_finished", sim.products_finished + 1)
                sim.crafting_progress = 0
                -- the engine fixes the next result when the next craft starts
                local engine = {name = "normal"}
                getmetatable(sim).__newindex(sim, "result_quality", engine)
                rawset(sim, "writes", 0)
                if insert_gap then sim.crafting, idle = false, 0 end
            end
        elseif insert_gap then
            idle = idle + 1
            if idle >= insert_gap then sim.crafting = true end
        end
    end
    return outputs, sim_looks
end
local outputs, sim_looks = simulate(0, 3000, 1, nil)
-- (the craft still running at the end is rolled too)
assert(#outputs >= 95 and (draws == #outputs or draws == #outputs + 1), "crafts " .. #outputs .. ", rolls " .. draws)
for _, output in ipairs(outputs) do assert(output == "ic-defect-5", "every craft rolled: " .. output) end
assert(sim_looks <= #outputs + 2, "one look per craft: " .. sim_looks)
-- Starved machine (ingredients arrive after a pause of any length): every craft is still rolled.
for gap = 1, 40, 3 do
    outputs = simulate(0, 3000, 0.75, gap)
    for _, output in ipairs(outputs) do assert(output == "ic-defect-5", "gap " .. gap .. ": " .. output) end
    assert(draws == #outputs or draws == #outputs + 1, "gap " .. gap)
end
-- Research 10: the same machine sleeps.
outputs, sim_looks = simulate(10, 3000, 1, nil)
assert(draws == 0 and sim_looks <= 3000 / crafter.DORMANT + 1, "looks at research 10: " .. sim_looks)

-- Recyclers -------------------------------------------------------------------------------------------------
-- Idle: half of the shortest recycling of an item that can be defective (0.0625 s at speed 0.125 = 30 ticks).
entity = machine({name = "recycler-1", type = "furnace", speed = 0.125})
assert(crafter.step(record_of(entity), 10, context()) == 15)
assert(crafter.step(record_of(entity), 3, context()) == 15)
-- With a production mode every recycling counts (ammo: 3 ticks at speed 0.125 -> 1).
assert(crafter.step(record_of(entity), 3, mode_context()) == 1)
-- A defective item: the result becomes standard at the first look.
entity = machine({name = "recycler-1", type = "furnace", speed = 0.125, recipe = "chest-recycling",
    quality = "ic-defect-3", progress = 0.1})
crafter.step(record_of(entity), 10, context())
assert(entity.result_quality.name == "normal")
-- A standard item: the next look within the idle rhythm or right after the end, whichever comes first.
entity = machine({name = "recycler-1", type = "furnace", speed = 0.125, recipe = "chest-recycling", progress = 0.5})
assert(crafter.step(record_of(entity), 10, context()) == 15)
-- Simulation: a defective item put into an idle recycler on any tick gives standard results.
for _, speed in ipairs({0.125, 0.25, 0.375, 0.5}) do
    for insert = 1, 40 do
        local sim = machine({name = "recycler-1", type = "furnace", speed = speed})
        local sim_record = record_of(sim)
        local result, next_tick = nil, 1
        for tick = 1, insert + 200 do
            if tick >= next_tick then next_tick = tick + crafter.step(sim_record, 10, context()) end
            if tick == insert then
                sim.recipe, sim.recipe_quality, sim.crafting, sim.crafting_progress = "chest-recycling", "ic-defect-3", true, 0
                getmetatable(sim).__newindex(sim, "result_quality", {name = "ic-defect-3"})
            end
            if sim.crafting then
                sim.crafting_progress = sim.crafting_progress + speed / (0.0625 * 60)
                if sim.crafting_progress >= 1 then
                    result = sim.result_quality.name
                    sim.crafting, sim.recipe = false, nil
                    rawset(sim, "products_finished", sim.products_finished + 1)
                end
            end
        end
        assert(result == "normal", "speed " .. speed .. ", put in on tick " .. insert .. ": " .. tostring(result))
    end
end

-- Drills: slowed by rewinding ahead ---------------------------------------------------------------------------
local function drill_mock(quality, speed_bonus)
    local target = {valid = true, name = "ore", amount = 1e6, prototype = {mineable_properties = {mining_time = 1}}}
    return {
        valid = true, unit_number = 50, name = "drill", type = "mining-drill", quality = {name = quality},
        speed_bonus = speed_bonus or 0, consumption_bonus = 0, pollution_bonus = 0, mining_progress = 0,
        bonus_mining_progress = 0, force = {index = 1}, mining_target = target, status = 1,
        prototype = {mining_speed = 0.5, resource_drain_rate_percent = 100, energy_usage = 1},
        surface = {pollutant_type = nil},
    }
end
for tier = 1, 5 do
    local quality = "ic-defect-" .. tier
    local multiplier = model.quality_multiplier(quality)
    local sim = drill_mock(quality)
    local sim_record = {id = 50, entity = sim, kind = "drill", force_index = 1}
    local cycles, sim_looks, next_tick, ticks = 0, 0, 1, 12000
    for tick = 1, ticks do
        if tick >= next_tick then
            sim_looks = sim_looks + 1
            local step_delay = drill.step(sim_record, 0, {random = function() return 0.5 end})
            next_tick = tick + step_delay
        end
        sim.mining_progress = sim.mining_progress + 0.5 / 60
        if sim.mining_progress >= 1 - 1e-12 then
            sim.mining_progress = sim.mining_progress - 1
            cycles = cycles + 1
            sim.mining_target.amount = sim.mining_target.amount - 1
        end
    end
    -- Native cycle 120 ticks; slowed 120 / m.
    local expected = ticks / (120 / multiplier)
    assert(math.abs(cycles - expected) <= 1.5, quality .. ": cycles " .. cycles .. ", expected " .. expected)
    -- Extra drain (k - 1 units) once per completed cycle (the committed one may not have completed yet).
    local extra = 1e6 - sim.mining_target.amount - cycles
    assert(extra == tier * cycles or extra == tier * (cycles + 1), quality .. ": extra drain " .. extra)
    assert(sim_looks / cycles <= 1 / multiplier + 2.5, quality .. ": looks per cycle " .. sim_looks / cycles)
end
-- Standard and positive drills are not handled.
assert(drill.step({id = 51, entity = drill_mock("normal")}, 0, {}) == false)
assert(drill.step({id = 52, entity = drill_mock("legendary")}, 0, {}) == false)

-- automation: tracking, levels, wake, migration -----------------------------------------------------------------
local technologies = {}
for level = 1, 10 do technologies["ic-defect-control-" .. level] = {researched = true} end
local force = {index = 1, valid = true, name = "player", technologies = technologies}
game.forces = {[1] = force}
local function placed(options)
    return {valid = true, unit_number = options.id, name = options.name, type = options.type, force = force,
        quality = {name = options.quality or "normal"},
        prototype = machine_prototype(options.categories or {}, {items_to_place_this = {{name = options.name}}})}
end
local assembler = placed({id = 1, name = "assembler-1", type = "assembling-machine", categories = {crafting = true}})
local smelter = placed({id = 2, name = "stone-furnace", type = "furnace", categories = {smelting = true}})
local standard_drill = placed({id = 3, name = "drill", type = "mining-drill"})
local defective_drill = placed({id = 4, name = "drill", type = "mining-drill", quality = "ic-defect-2"})
local relic = placed({id = 5, name = "pd-relic-daedalus-workshop", type = "assembling-machine", categories = {crafting = true}})
game.tick = 100
for _, e in ipairs({assembler, smelter, standard_drill, defective_drill, relic}) do automation.track(e) end
local s = storage.ic_defects
assert(s.records[1] and not s.records[2] and not s.records[3] and s.records[4] and not s.records[5],
    "only an assembler of finished products and the defective drill are tracked")
assert(s.records[1].due == 101 and s.records[1].name == "assembler-1" and s.records[1].force_index == 1)
-- A production mode makes any eligible machine tracked.
storage.ic_modes = {records = {[2] = {mode = "careful", entity = smelter}}}
automation.track(smelter)
assert(s.records[2], "moded furnace tracked")
storage.ic_modes = nil
s.records[2] = nil
-- Waking moves a far look forward; the old bucket entry is skipped.
s.buckets = {}
wheel.add(s.buckets, s.records[1], 700)
automation.wake(assembler)
assert(s.records[1].due == 101 and s.buckets[101][1] == 1 and s.buckets[700][1] == 1)
-- Level cache: kept until refreshed; a lost research 10 spreads every record over one second.
assert(automation.level(force) == 10 and s.levels[1] == 10)
technologies["ic-defect-control-10"].researched = false
assert(automation.level(force) == 10, "cached until refreshed")
s.buckets = {}
wheel.add(s.buckets, s.records[1], 900)
automation.refresh_levels()
assert(s.levels[1] == 9 and s.records[1].due > 100 and s.records[1].due <= 100 + 1 + automation.SPREAD)
wheel.add(s.buckets, s.records[1], 900)
automation.refresh_levels()
assert(s.records[1].due == 900, "no wake without a drop from 10")
-- on_tick: a due record is looked at and rescheduled; an invalid one dropped; a stale entry skipped.
local stepped = {}
local original_step = crafter.step
crafter.step = function(r) stepped[#stepped + 1] = r.id return 50 end
s.buckets = {}
wheel.add(s.buckets, s.records[1], 200)
s.records[9] = {id = 9, entity = {valid = false}, kind = "crafter", force_index = 1}
wheel.add(s.buckets, s.records[9], 200)
s.buckets[200][#s.buckets[200] + 1] = 77 -- stale id of a forgotten record
automation.on_tick(200, function() return {} end)
assert(#stepped == 1 and stepped[1] == 1 and s.records[1].due == 250 and s.records[9] == nil and s.buckets[200] == nil)
crafter.step = original_step

-- Migration of layout 1: every record is rebuilt by the new rules, warnings of the removed look are dropped.
storage.ic_defects = {
    records = {
        [1] = {id = 1, entity = assembler, kind = "crafter", craft = {key = "chest|normal|3", decided = true},
            debt = {{type = "item", name = "plate", amount = 2}}},
        [2] = {id = 2, entity = smelter, kind = "crafter"},
        [3] = {id = 3, entity = standard_drill, kind = "drill", cycle = {progress = 0.5}},
        [4] = {id = 4, entity = defective_drill, kind = "drill", cycle = {progress = 0.5, decided = true}},
    },
    buckets = {[150] = {1, 2, 3, 4}},
    levels = {[1] = 3},
    warnings = {["1:missed-craft:assembler-1"] = true, ["1:unsupported-speed:assembler-1"] = true},
}
game.tick = 300
automation.on_tick(300, function() return {} end)
s = storage.ic_defects
assert(s.version == automation.VERSION and s.records[1] and not s.records[2] and not s.records[3] and s.records[4])
assert(s.records[1].craft == nil and s.records[1].debt == nil and s.records[4].cycle == nil)
assert(s.records[1].due > 300 and s.records[1].due <= 300 + 1 + automation.SPREAD and s.buckets[150] == nil)
assert(s.warnings["1:missed-craft:assembler-1"] == nil and s.warnings["1:unsupported-speed:assembler-1"])
assert(s.levels == nil, "levels counted again")

print("PASS: relevance of machines (finished products, finished ingredients, recycling; smelting/chemistry")
print("never), one roll per craft at its first look (simulated: one roll and one look per craft; starved")
print("machine), caps of defective ingredients, exempt/material results, sleeping and circuit recipes, modes")
print("(slowed, released), recyclers catch every defective item, defective drills slowed by rewinding ahead")
print("(cycle time, extra drain, looks per cycle), tracking filter, wake, level cache, on_tick, layout migration.")
print("Mocks only, not Factorio.")
