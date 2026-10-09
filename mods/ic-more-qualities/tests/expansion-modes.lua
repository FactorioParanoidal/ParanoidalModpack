-- Production modes through the real crafter handler, simulated tick by tick on mocks:
-- slowdown, loss factor, defect level shift, "no defects" of precise mode, boosted quality roll,
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
    local removed = 0
    local entity = {
        valid = true, crafting_speed = 1, crafting_progress = 0, bonus_progress = 0, productivity_bonus = 0,
        products_finished = 0, result_quality = {name = "normal"}, force = {index = 1, technologies = {}},
        fluidbox = {},
    }
    machine.recipe = {name = "widget", energy = full_ticks / 60, products = {{type = "item", name = "widget"}},
        ingredients = {{type = "item", name = "plate", amount = 1}}}
    entity.get_recipe = function()
        if machine.crafting then return machine.recipe, {name = "normal"} end
    end
    entity.is_crafting = function() return machine.crafting end
    entity.get_inventory = function()
        return {remove = function(spec) removed = removed + spec.count; return spec.count end}
    end
    function machine.update()
        if not machine.crafting then return end
        entity.crafting_progress = entity.crafting_progress + 1 / full_ticks
        if entity.crafting_progress >= 1 - 1e-12 then
            machine.outputs[#machine.outputs + 1] = entity.result_quality.name or entity.result_quality
            entity.products_finished = entity.products_finished + 1
            entity.crafting_progress = 0
            entity.result_quality = {name = "normal"}
            machine.crafting = false
        end
    end
    machine.entity = entity
    machine.removed = function() return removed end
    return machine
end

local function context(mode, random, counters)
    return {
        random = random, finished = {widget = true}, exclude_finished = false, initial_loss_percent = 33,
        min_energy = function() return 1 end,
        stat = function(_, key) counters[key] = (counters[key] or 0) + 1 end,
        mode_definition = function() return mode end,
        mode_power = function() return 1 end,
    }
end

local function craft(mode, level, random, full_ticks)
    local machine = make_machine(full_ticks or 100)
    local record = {entity = machine.entity}
    local counters = {}
    local ctx = context(mode, random, counters)
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

-- Normal: about 100 ticks, defect draw at level 0 with r=0 -> -5 (the existing behaviour).
local machine, ticks, counters = craft(nil, 0, mock.sequence({.9, 0}))
assert(machine.outputs[1] == "ic-defect-5" and ticks <= 102, ticks)
assert(counters["machine.ops"] == 1 and counters["grade.-5"] == 1)

-- Careful: 5x slower; loss chance 33% / 10 = 3.3%; defects as with +4 levels (worst -3 at level 0).
machine, ticks = craft(rules.modes.careful, 0, mock.sequence({.04, 0}))
assert(machine.outputs[1] == "ic-defect-3", tostring(machine.outputs[1]))
assert(ticks > 480 and ticks < 520, ticks)
machine, ticks, counters = craft(rules.modes.careful, 0, mock.sequence({.03, .9, 0}))
assert(counters["machine.loss"] == 1 and machine.removed() == 1, "3% < 3.3%: one failed attempt, one extra ingredient set")
assert(#machine.outputs == 1)

-- Precise: 20x slower, never a loss (RNG 0 would lose), never a defect even from a defect roll.
machine, ticks, counters = craft(rules.modes.precise, 0, mock.sequence({0}))
assert(machine.outputs[1] == "normal" and not counters["machine.loss"])
assert(ticks > 1950 and ticks < 2050, ticks)
assert(counters["grade.0"] == 1)
-- Research 10 + careful: standard, no loss roll needed.
machine = craft(rules.modes.careful, 10, mock.sequence({0}))
assert(machine.outputs[1] == "normal")

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
    surface = {index = 1, create_entity = function() return interface end},
    prototype = {items_to_place_this = {{name = "assembler"}}, get_max_energy_usage = function() return 1000 end,
        electric_energy_source_prototype = {}, collision_box = {left_top = {x = -1.2, y = -1.2}, right_bottom = {x = 1.2, y = 1.2}},
        selection_box = {left_top = {x = -1.5, y = -1.5}, right_bottom = {x = 1.5, y = 1.5}}},
}
rendering = {draw_sprite = function() return {id = 1} end, get_object_by_id = function() return nil end}
assert(modes.set(moded, "precise"))
assert(modes.definition(moded) == rules.modes.precise and modes.mode_name(moded) == "precise")
assert(modes.draw_power(moded, rules.modes.precise, true, 1) == 1)
near(interface.power_usage, 4000)
modes.draw_power(moded, rules.modes.careful, true, 2)
near(interface.power_usage, 1000)
modes.draw_power(moded, nil, false, 3)
near(interface.power_usage, 0)
assert(modes.set(moded, "normal") and modes.definition(moded) == nil and interface.valid == false)
print("PASS: careful x5 / precise x20 time through the real crafter, loss /10 and none, defects")
print("+4 levels and none, boosted module roll equals n independent rolls, extra power +1x/+4x.")
print("Mocks only: no engine timing, power network or GUI verification.")
