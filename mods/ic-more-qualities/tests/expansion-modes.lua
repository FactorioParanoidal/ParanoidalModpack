-- Production modes through the real crafter handler, simulated tick by tick on mocks:
-- slowdown, defect level shift, "no defects" of precise mode, boosted quality roll,
-- extra power demand. The machine model is a mock, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local near = mock.near

defines = mock.defines()
storage = {}
script = {register_on_object_destroyed = function() end}
local rules = require("scripts.expansion.rules")
local crafter = require("scripts.defects.crafter")

local function make_machine(full_ticks)
    local machine = {outputs = {}, crafting = true}
    local entity = {
        valid = true, unit_number = 1, name = "assembler", crafting_speed = 1, crafting_progress = 0,
        bonus_progress = 0, productivity_bonus = 0, products_finished = 0, result_quality = {name = "normal"},
        force = {index = 1, technologies = {}}, fluidbox = {},
    }
    machine.recipe = {name = "widget"}
    -- Compiled recipe data (scripts/defects/compiled.lua) of a finished, defect-capable product.
    machine.info = {energy = full_ticks / 60, any_item = true, all_finished = true, roll = true, exempt = false,
        recycling = false, watched = true}
    entity.get_recipe = function()
        if machine.crafting then return machine.recipe, machine.recipe_quality or {name = "normal"} end
    end
    entity.is_crafting = function() return machine.crafting end
    machine.rate = 1 -- native speed multiplier (beacons, modules)
    function machine.update()
        if not machine.crafting or machine.stopped then return end
        entity.crafting_progress = entity.crafting_progress + machine.rate / full_ticks
        if entity.crafting_progress >= 1 - 1e-12 then
            machine.outputs[#machine.outputs + 1] = entity.result_quality.name or entity.result_quality
            entity.products_finished = entity.products_finished + 1
            entity.crafting_progress = 0
            entity.result_quality = {name = "normal"}
            machine.crafting = false
        end
    end
    machine.entity = entity
    return machine
end

-- Scheduler context of scripts/defects/crafter.lua. mode: definition of the machine's selected mode.
local function context(machine, mode, random, counters)
    return {
        machine = function() return {relevant = true, recycler = machine.recycler, min_energy = 1, watched_min = 1} end,
        recipe = function() return machine.info end,
        random = random, quality_everywhere = false, no_quality = {},
        stat = function(_, key) counters[key] = (counters[key] or 0) + 1 end,
        modes = mode and {[machine.entity.unit_number] = {mode = mode.name}} or nil,
        mode_power = function() return 1 end,
        release_power = function() end,
    }
end
local function record_of(entity) return {id = entity.unit_number, entity = entity, name = entity.name, force_index = 1} end

local function craft(mode, level, random, full_ticks)
    local machine = make_machine(full_ticks or 100)
    local record = record_of(machine.entity)
    local counters = {}
    local ctx = context(machine, mode, random, counters)
    local tick, next_look = 0, 1
    while machine.crafting and tick < 100000 do
        tick = tick + 1
        if tick >= next_look then
            local delay = crafter.step(record, level, ctx)
            next_look = tick + math.max(1, math.floor(delay or 30))
        end
        machine.update()
    end
    return machine, tick, counters
end

-- Normal: about 100 ticks, defect draw at level 0 with r=0 -> -5.
local machine, ticks, counters = craft(nil, 0, mock.sequence({0}))
assert(machine.outputs[1] == "ic-defect-5" and ticks <= 102, ticks)
assert(counters["grade.-5"] == 1)

-- Careful: 5x slower; defects as with +4 levels (worst -3 at level 0).
machine, ticks = craft(rules.modes.careful, 0, mock.sequence({0}))
assert(machine.outputs[1] == "ic-defect-3", tostring(machine.outputs[1]))
assert(ticks > 480 and ticks < 520, ticks)

-- Precise: 20x slower, never a defect even from a defect roll.
machine, ticks, counters = craft(rules.modes.precise, 0, mock.sequence({0}))
assert(machine.outputs[1] == "normal")
assert(ticks > 1950 and ticks < 2050, ticks)
assert(counters["grade.0"] == 1)
-- Research 10 + careful: standard.
machine = craft(rules.modes.careful, 10, mock.sequence({0}))
assert(machine.outputs[1] == "normal")

-- Paranoidal decision 2026-10-14: never better than the ingredients. The recipe quality is the quality
-- of all item ingredients (the engine result starts there); a worse roll still wins.
local function craft_from(quality_name, mode, levels, random, exempt)
    local m = make_machine(100)
    m.recipe_quality = {name = quality_name}
    m.entity.result_quality = {name = quality_name}
    if exempt then m.info.exempt, m.info.roll = true, false end
    local record, counters = record_of(m.entity), {}
    local ctx = context(m, mode, random, counters)
    local tick, next_look = 0, 1
    while m.crafting and tick < 100000 do
        tick = tick + 1
        if tick >= next_look then
            local level = type(levels) == "function" and levels(record) or levels
            next_look = tick + math.max(1, math.floor(crafter.step(record, level, ctx) or 30))
        end
        m.update()
    end
    return m.outputs[1], counters
end
assert(craft_from("ic-defect-3", nil, 10, mock.sequence({0})) == "ic-defect-3", "research 10 does not repair")
assert(craft_from("ic-defect-3", rules.modes.precise, 0, mock.sequence({0})) == "ic-defect-3", "maximum mode does not repair")
assert(craft_from("ic-defect-3", nil, 0, mock.sequence({0})) == "ic-defect-5", "a worse roll wins")
assert(craft_from("ic-defect-3", nil, 9, mock.sequence({.99})) == "ic-defect-3", "a standard roll is capped")
assert(craft_from("ic-defect-3", nil, 0, mock.sequence({.9}), true) == "normal", "exempt products")
assert(craft_from("normal", nil, 10, mock.sequence({0})) == "normal")
-- The result is decided at the first look of a craft (the engine keeps it to the end): research 10 finished
-- during the craft does not change a grade rolled before (careful at level 0 rolls -3, below -2 ingredients).
local output = craft_from("ic-defect-2", rules.modes.careful, function(record)
    return record.craft and 10 or 0
end, mock.sequence({0}))
assert(output == "ic-defect-3", tostring(output))

-- Recycling keeps the native result quality (input quality or a module upgrade); no defect draw,
-- only defect results become standard. RNG 0 would draw -5.
for _, case in ipairs({{"rare", "rare"}, {"normal", "normal"}, {"ic-defect-3", "normal"}}) do
    local recycler = make_machine(100)
    recycler.recycler = true
    recycler.info = {energy = 100 / 60, any_item = true, all_finished = false, roll = false, exempt = false,
        recycling = true, watched = true}
    recycler.recipe_quality = {name = case[1]}
    recycler.entity.result_quality = {name = case[1]}
    local record, counters = record_of(recycler.entity), {}
    local ctx = context(recycler, nil, mock.sequence({0}), counters)
    local tick, next_look = 0, 1
    while recycler.crafting and tick < 1000 do
        tick = tick + 1
        if tick >= next_look then next_look = tick + math.max(1, math.floor(crafter.step(record, 0, ctx) or 30)) end
        recycler.update()
    end
    assert(recycler.outputs[1] == case[2], case[1] .. " -> " .. tostring(recycler.outputs[1]))
    assert(not counters["grade.-5"], "no defect draw for recycling")
end

-- Boosted quality-module roll (precise = 10 rolls): p = 0.2 * 0.1 = 2%, extra = 1 - 0.98^9.
local modes = require("scripts.expansion.modes")
local qualities = {}
qualities.rare = {name = "rare", next_probability = 0.1}
qualities.uncommon = {name = "uncommon", next = qualities.rare, next_probability = 0.1}
qualities.normal = {name = "normal", next = qualities.uncommon, next_probability = 0.1}
local function module_machine()
    return {effects = {quality = 0.2}, result_quality = qualities.normal,
        force = {index = 1, is_quality_unlocked = function() return true end}}
end
local extra = rules.extra_chance(0.02, 10)
near(extra, 1 - 0.98 ^ 9)
local entity = module_machine()
assert(modes.boost(entity, qualities.normal, rules.modes.precise, mock.sequence({extra - 1e-6, .5})))
assert(entity.result_quality == qualities.uncommon)
entity = module_machine()
assert(not modes.boost(entity, qualities.normal, rules.modes.precise, mock.sequence({extra + 1e-6})))
entity = module_machine()
assert(modes.boost(entity, qualities.normal, rules.modes.careful, mock.sequence({0, .05, .5})))
assert(entity.result_quality == qualities.rare, "chain continues with next_probability")
entity = module_machine()
entity.result_quality = qualities.uncommon -- native roll already upgraded: nothing extra
assert(not modes.boost(entity, qualities.normal, rules.modes.precise, mock.sequence({0})))
entity = module_machine()
entity.effects = {quality = 0}
assert(not modes.boost(entity, qualities.normal, rules.modes.precise, mock.sequence({0})), "no module, no quality")
entity = module_machine()
entity.force.is_quality_unlocked = function() return false end
assert(not modes.boost(entity, qualities.normal, rules.modes.precise, mock.sequence({0})), "locked qualities stay locked")

-- Extra power: careful draws +1x, precise +4x the machine power through a hidden interface.
local interface = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 1e9}
interface.destroy = function() interface.valid = false end
prototypes = {entity = {["ic-mode-power-3x3"] = {}}}
local moded = {
    valid = true, type = "assembling-machine", name = "assembler", unit_number = 11, position = {x = 0, y = 0},
    direction = 0, quality = {name = "normal"}, consumption_bonus = 0, force = {index = 1},
    is_crafting = function() return false end,
    surface = {index = 1, create_entity = function() return interface end},
    prototype = {items_to_place_this = {{name = "assembler"}}, get_max_energy_usage = function() return 1000 end,
        electric_energy_source_prototype = {}, collision_box = {left_top = {x = -1.2, y = -1.2}, right_bottom = {x = 1.2, y = 1.2}},
        selection_box = {left_top = {x = -1.5, y = -1.5}, right_bottom = {x = 1.5, y = 1.5}}},
}
rendering = {draw_sprite = function() return {id = 1} end, get_object_by_id = function() return nil end}
assert(modes.set(moded, "precise"))
assert(modes.mode_name(moded) == "precise")
assert(modes.draw_power(moded, rules.modes.precise, true, 1) == 1)
near(interface.power_usage, 19000)
modes.draw_power(moded, rules.modes.careful, true, 2)
near(interface.power_usage, 4000)
modes.draw_power(moded, nil, false, 3)
near(interface.power_usage, 0)
assert(modes.set(moded, "normal") and modes.mode_name(moded) == "normal" and interface.valid == false)
assert(storage.ic_modes.records[11] == nil, "idle machine: normal drops the record at once")

-- Bug report: maximum selected, craft started, then normal selected. The running craft keeps its
-- mode (20x time) and must keep paying the extra power until it ends; the next craft is normal.
local function power_interface()
    local object = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 1e9}
    object.destroy = function() object.valid = false end
    return object
end
local switched = make_machine(100)
local sw = switched.entity
local sw_interface = power_interface()
sw.type, sw.name, sw.unit_number, sw.position, sw.direction = "assembling-machine", "assembler", 21, {x = 0, y = 0}, 0
sw.quality, sw.consumption_bonus = {name = "normal"}, 0
sw.surface = {index = 1, create_entity = function() return sw_interface end}
sw.prototype = moded.prototype
assert(modes.set(sw, "precise"))
local sw_record, sw_counters = record_of(sw), {}
local sw_ctx = context(switched, nil, mock.sequence({.9}), sw_counters)
local sw_tick, sw_look = 0, 1
-- As control.lua: the mode records of storage, the real extra power and its release.
local function live(ctx, tick_of)
    ctx.modes = storage.ic_modes and next(storage.ic_modes.records) and storage.ic_modes.records or nil
    ctx.mode_power = function(entity, definition, working) return modes.draw_power(entity, definition, working, tick_of()) end
    ctx.release_power = function(entity) modes.draw_power(entity, nil, false, tick_of()) end
    return ctx
end
local function run_switched(limit, stop)
    while switched.crafting and sw_tick < limit do
        sw_tick = sw_tick + 1
        if sw_tick >= sw_look then
            live(sw_ctx, function() return sw_tick end)
            sw_look = sw_tick + math.max(1, math.floor(crafter.step(sw_record, 0, sw_ctx) or 30))
        end
        switched.update()
        if stop and stop() then return end
    end
end
run_switched(1000) -- half of the 20x craft
-- The slowed progress (the raw mock progress also holds the full-speed gain since the last look).
assert(switched.crafting and sw_record.craft.progress > 0.4 and sw_record.craft.progress < 0.6, sw_record.craft.progress)
assert(sw.crafting_progress < 1)
near(sw_interface.power_usage, 19000)
assert(modes.set(sw, "normal"))
assert(modes.mode_name(sw) == "normal", "the GUI shows normal at once")
assert(sw_interface.valid and storage.ic_modes.records[21], "the running craft keeps its consumer")
local paid_after_switch = 0
run_switched(100000, function()
    if sw_interface.valid and sw_interface.power_usage > 0 then paid_after_switch = paid_after_switch + 1 end
end)
assert(sw_tick > 1950 and sw_tick < 2050, "the moded craft keeps 20x time: " .. sw_tick)
assert(paid_after_switch > 950, "extra power is drawn until the moded craft ends: " .. paid_after_switch)
assert(switched.outputs[1] == "normal" and sw_counters["mode.precise"] == 1)
-- Idle look after the craft: the record and its consumer are gone; the next craft is normal.
sw_tick = sw_tick + 1
crafter.step(sw_record, 0, live(sw_ctx, function() return sw_tick end))
assert(storage.ic_modes.records[21] == nil and not sw_interface.valid)
switched.crafting = true
local second_start = sw_tick
sw_look = sw_tick + 1
run_switched(100000)
assert(sw_tick - second_start <= 102, "next craft at normal speed: " .. (sw_tick - second_start))

-- Switching back to a mode during the pending craft keeps one record and restores the indicator.
switched.crafting, sw.crafting_progress = true, 0
sw_interface = power_interface()
assert(modes.set(sw, "careful"))
sw_record.craft = nil
crafter.step(sw_record, 0, live(sw_ctx, function() return sw_tick end))
assert(modes.set(sw, "normal") and storage.ic_modes.records[21])
assert(modes.set(sw, "precise") and modes.mode_name(sw) == "precise")
modes.forget(21)

-- Mode boost at the decision, once per craft, at its first look (the engine keeps the written result to the
-- end, test-runs/ic-h1b-20261029); a sharp speed-up during the craft changes nothing.
local function boosted_craft(speed_up_at)
    local m = make_machine(100)
    local boosts, progress_at_boost = 0, nil
    local record = record_of(m.entity)
    local ctx = context(m, rules.modes.precise, mock.sequence({.9}), {})
    ctx.quality_everywhere = true
    ctx.mode_boost = function()
        boosts = boosts + 1
        progress_at_boost = m.entity.crafting_progress
    end
    local tick, next_look = 0, 1
    while m.crafting and tick < 100000 do
        tick = tick + 1
        if speed_up_at and tick == speed_up_at then m.rate = 10 end
        if tick >= next_look then
            local delay = crafter.step(record, 0, ctx)
            next_look = tick + math.max(1, math.floor(delay or 30))
        end
        m.update()
    end
    return boosts, progress_at_boost
end
local boosts, at = boosted_craft(nil)
assert(boosts == 1 and at < 0.05, "one boost, at the first look")
boosts = boosted_craft(2)
assert(boosts == 1, "a speed-up does not cost the boost")

-- A stopped moded machine (circuit) demands no extra power; after it resumes the progress made
-- before the next look is not counted, then the extra power is demanded again.
local halted = make_machine(100)
local ht = halted.entity
local ht_interface = power_interface()
ht.type, ht.name, ht.unit_number, ht.position, ht.direction = "assembling-machine", "assembler", 41, {x = 0, y = 0}, 0
ht.quality, ht.consumption_bonus = {name = "normal"}, 0
ht.surface = {index = 1, create_entity = function() return ht_interface end}
ht.prototype = moded.prototype
assert(modes.set(ht, "precise"))
local ht_record = record_of(ht)
local ht_ctx = context(halted, nil, mock.sequence({.9}), {})
local ht_tick, ht_look = 0, 1
local function run_halted(limit)
    while halted.crafting and ht_tick < limit do
        ht_tick = ht_tick + 1
        if ht_tick >= ht_look then
            live(ht_ctx, function() return ht_tick end)
            ht_look = ht_tick + math.max(1, math.floor(crafter.step(ht_record, 0, ht_ctx) or 30))
        end
        halted.update()
    end
end
run_halted(500)
near(ht_interface.power_usage, 19000)
halted.stopped = true
run_halted(800)
assert(ht_interface.power_usage == 0, "stopped: no extra power")
assert(ht_look - ht_tick <= crafter.STALL_LOOK, "stopped: looked at often")
halted.stopped = false
run_halted(800 + crafter.STALL_LOOK + 1)
near(ht_interface.power_usage, 19000)
run_halted(100000)
assert(not halted.crafting)
local _, plain_ticks = craft(rules.modes.precise, 0, mock.sequence({.9}))
local extra_ticks = ht_tick - plain_ticks
assert(extra_ticks >= 295 and extra_ticks <= 300 + crafter.STALL_LOOK + 5,
    "300 stopped ticks + at most one uncounted look: " .. extra_ticks)
modes.forget(41)

-- Burner machine: the extra energy of the past interval is burnt from the burning fuel, then from
-- whole fuel items (their change is kept); without fuel the supply drops.
local function fuel_stack(count, value)
    local stack = {valid_for_read = count > 0, count = count, name = "coal", quality = {name = "normal"},
        prototype = {fuel_value = value}}
    stack.clear = function() stack.count = 0; stack.valid_for_read = false end
    return stack
end
local coal = fuel_stack(2, 4e6)
local burner = {currently_burning = {name = "coal"}, remaining_burning_fuel = 1e6, inventory = {coal}}
local furnace = {
    valid = true, type = "furnace", name = "stone-furnace", unit_number = 31, position = {x = 0, y = 0},
    direction = 0, quality = {name = "normal"}, consumption_bonus = 0, force = {index = 1}, burner = burner,
    is_crafting = function() return true end,
    prototype = {items_to_place_this = {{name = "stone-furnace"}}, get_max_energy_usage = function() return 1000 end,
        burner_prototype = {effectivity = 1},
        collision_box = {left_top = {x = -0.7, y = -0.7}, right_bottom = {x = 0.7, y = 0.7}},
        selection_box = {left_top = {x = -1, y = -1}, right_bottom = {x = 1, y = 1}}},
}
furnace.surface = {index = 1}
assert(modes.set(furnace, "precise"))
assert(modes.draw_power(furnace, rules.modes.precise, true, 0) == 1, "no demand before the first look")
-- 100 ticks at 19 kJ/tick = 1.9 MJ: 1 MJ from the burning coal, one whole coal item (2.1 MJ change).
near(modes.draw_power(furnace, rules.modes.precise, true, 100), 1)
near(burner.remaining_burning_fuel, 0)
assert(coal.count == 1)
near(storage.ic_modes.records[31].fuel_change, 3.1e6, 1e-3)
-- Next 300 ticks = 5.7 MJ: 3.1 MJ change + the last coal item (1.4 MJ change left).
near(modes.draw_power(furnace, rules.modes.precise, true, 400), 1)
assert(coal.count == 0 and not coal.valid_for_read)
near(storage.ic_modes.records[31].fuel_change, 1.4e6, 1e-3)
-- Next 100 ticks = 1.9 MJ, only 1.4 MJ left: the craft progress of that interval is scaled.
near(modes.draw_power(furnace, rules.modes.precise, true, 500), 1.4 / 1.9, 1e-9)
-- Effectivity 0.5: the same interval costs twice the fuel.
furnace.prototype.burner_prototype.effectivity = 0.5
burner.remaining_burning_fuel = 1e6
near(modes.draw_power(furnace, rules.modes.precise, true, 550), 1e6 / 1.9e6, 1e-9)
-- Normal selected during the craft: it keeps paying; the end of the moded craft drops the record.
assert(modes.set(furnace, "normal") and storage.ic_modes.records[31])
burner.remaining_burning_fuel = 1e7
modes.draw_power(furnace, rules.modes.precise, true, 560)
near(burner.remaining_burning_fuel, 1e7 - 19000 * 10 / 0.5, 1e-3)
modes.draw_power(furnace, nil, false, 570)
assert(storage.ic_modes.records[31] == nil)

-- Machines without item results (copper lamp, fluid-only, voiding) and construction sites have no modes
-- (mod-data no_mode). A mode saved before the update is dropped by rescan, the running craft too.
local kept = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 1e9}
kept.destroy = function() kept.valid = false end
local function placed(name, id)
    return {valid = true, type = "assembling-machine", name = name, unit_number = id, position = {x = 0, y = 0},
        direction = 0, quality = {name = "normal"}, consumption_bonus = 0, force = {index = 1},
        is_crafting = function() return true end,
        surface = {index = 1, create_entity = function() return kept end},
        prototype = moded.prototype}
end
local lamp, old = placed("deadlock-copper-lamp", 51), placed("angels-separator", 52)
assert(modes.eligible(old), "no mod-data yet: eligible")
assert(modes.set(old, "precise") and storage.ic_modes.records[52])
modes.draw_power(old, rules.modes.precise, true, 600)
assert(kept.valid and kept.power_usage > 0)
storage.ic_defects = {records = {[52] = {id = 52, craft = {key = "x", mode = rules.modes.precise}}}}
prototypes = {entity = prototypes.entity, mod_data = {["ic-quality-expansion"] = {data = {no_mode = {
    ["deadlock-copper-lamp"] = true, ["angels-separator"] = true}}}}}
modes.reset_cache()
assert(not modes.eligible(lamp) and not modes.set(lamp, "careful") and not storage.ic_modes.records[51], "lamp: no mode")
assert(modes.eligible(moded), "an assembler keeps its modes")
modes.rescan()
assert(storage.ic_modes.records[52] == nil and not kept.valid, "saved mode and extra power dropped")
assert(storage.ic_defects.records[52].craft.mode == nil, "running craft continues without the mode")
assert(modes.mode_name(old) == "normal")
storage.ic_defects = nil
print("PASS: careful x5 / precise x20 time through the real crafter, defects")
print("+4 levels and none, boosted module roll equals n independent rolls, extra power +1x/+4x;")
print("normal during a moded craft keeps its time and extra power until it ends, then drops the record;")
print("burner extra energy from burning fuel and whole fuel items with change, effectivity, low fuel;")
print("machines in mod-data no_mode get no mode, a saved one is dropped with its extra power and craft mode.")
print("Mocks only: no engine timing, power network or GUI verification.")
