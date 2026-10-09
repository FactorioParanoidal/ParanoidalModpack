-- Refinement workshop runtime, simulated tick by tick on mocks: resource streaming, holding
-- without packs, power gating, repeated attempts until standard, reset/pass, mining fix-up.
-- The "machine" below only advances progress like a furnace would; it is not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local near = mock.near

defines = mock.defines()
storage = {}
script = {register_on_object_destroyed = function() end}
prototypes = {
    mod_data = {["ic-quality-expansion"] = {data = {costs = {gear = {cost = 1500, seconds = 10}}}}},
    entity = {["ic-refine-workshop-power"] = {}, ["ic-signal-emitter"] = {}},
}
local workshop = require("scripts.expansion.workshop")

local function pack_stack(count, durability)
    local stack = {valid_for_read = true, is_tool = true, name = "repair-pack", count = count, durability = durability,
        quality = {name = "normal"}, prototype = {get_durability = function() return 300 end}}
    function stack.clear() stack.valid_for_read, stack.count = false, 0 end
    return stack
end

local function make_machine()
    local machine = {crafting = false, outputs = {}}
    local interface = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 0}
    interface.destroy = function() interface.valid = false end
    machine.interface = interface
    machine.fuel = {pack_stack(2, 300), {valid_for_read = false}}
    local entity = {
        valid = true, name = "ic-refine-workshop", unit_number = 7, position = {x = 0, y = 0},
        surface = {index = 1, create_entity = function() return interface end},
        force = {index = 1, players = {}}, burner = {}, crafting_speed = 1, crafting_progress = 0,
        products_finished = 0, disabled_by_script = false, quality = {name = "normal"}, status = "working",
        prototype = {get_max_energy_usage = function() return 1250 end},
    }
    entity.get_fuel_inventory = function() return machine.fuel end
    entity.get_inventory = function() return {is_empty = function() return not machine.crafting end} end
    entity.is_crafting = function() return machine.crafting end
    entity.get_recipe = function()
        if not machine.crafting then return nil end
        return {name = "ic-refine-item-" .. machine.item, products = {{name = machine.item}}}, {name = machine.input}
    end
    machine.entity = entity
    -- Insert an item: the furnace starts a craft with recipe quality = item quality.
    function machine.start(item, quality, seconds)
        machine.crafting, machine.item, machine.input = true, item, quality
        machine.rate = 1 / (seconds * 60)
        entity.crafting_progress = 0
        entity.result_quality = {name = quality}
    end
    -- Native update after on_tick: progress, completion.
    function machine.update()
        if not machine.crafting or entity.disabled_by_script then return end
        entity.crafting_progress = math.min(1, entity.crafting_progress + machine.rate)
        if entity.crafting_progress >= 1 then
            local result = entity.result_quality
            machine.outputs[#machine.outputs + 1] = type(result) == "table" and result.name or result
            entity.products_finished = entity.products_finished + 1
            machine.crafting = false
            entity.crafting_progress = 0
        end
    end
    return machine
end

local function run(machine, record, ticks, random, from_tick)
    local tick = from_tick or 0
    for _ = 1, ticks do
        tick = tick + 1
        machine.interface.energy = machine.interface.electric_buffer_size -- fully supplied network
        if record.next_tick <= tick then workshop.step(record, {tick = tick, random = random}) end
        machine.update()
    end
    return tick
end

-- 1. Without enough packs the attempt waits at the paid share; nothing is lost.
local machine = make_machine()
local record = workshop.track(machine.entity)
assert(record and machine.entity.burner.currently_burning.name == "ic-refine-workshop-drive")
machine.start("gear", "ic-defect-3", 10)
local tick = run(machine, record, 900, mock.sequence({.95}))
assert(machine.crafting and #machine.outputs == 0)
near(record.craft.paid, 600 / 1500)
-- Held at the paid share; the machine may run one tick ahead before the next look rewinds it.
assert(machine.entity.crafting_progress <= 0.4 + machine.rate + 1e-9 and machine.entity.crafting_progress > 0.35)
assert(not machine.fuel[1].valid_for_read, "both packs fully used")
assert(record.status_key == "no-resource" and machine.entity.custom_status.diode == "red")
assert(workshop.available(machine.entity) == 0)

-- 2. Packs arrive: the series continues. RNG: fail, then success, then success with one jump.
machine.fuel[1] = pack_stack(100, 150) -- a partially used pack on top
local before = workshop.available(machine.entity)
near(before, 99 * 300 + 150)
tick = run(machine, record, 3000, mock.sequence({.95, .5, .5, .5, .05, .5}), tick)
assert(#machine.outputs == 1 and machine.outputs[1] == "normal", tostring(machine.outputs[1]))
assert(record.craft == nil or record.craft.key ~= "ic-refine-item-gear|0")
local used = before - workshop.available(machine.entity)
near(used + 600, 3 * 1500, 1e-6) -- three paid attempts, the first one partly from the old packs
local counters = storage.ic_stats[1]
assert(counters["refine.attempts"] == 3 and counters["refine.fail"] == 1 and counters["refine.success"] == 2)
assert(counters["refine.jump1"] == 1 and counters["refine.jump2"] == 1 and counters["refine.normalized"] == 1)
near(counters["refine.resource"], 3 * 1500, 1e-6)

-- 3. Power gating: an unsupplied interface holds the progress.
machine.start("gear", "ic-defect-1", 10)
workshop.step(record, {tick = tick + 1, random = mock.sequence({.5})})
machine.update()
local progress = machine.entity.crafting_progress
for t = tick + 2, tick + 30 do
    machine.interface.energy = 0
    workshop.step(record, {tick = t, random = mock.sequence({.5})})
    machine.update()
end
assert(machine.entity.crafting_progress - progress < 0.01, "progress held without electricity")
assert(record.status_key == "low-power")
tick = run(machine, record, 700, mock.sequence({.5}), tick + 30)
assert(machine.outputs[#machine.outputs] == "normal")

-- 4. Standard quality passes for free; positive quality passes unchanged or is reset.
local available = workshop.available(machine.entity)
local produced = #machine.outputs
machine.start("gear", "normal", 10)
tick = run(machine, record, 3, mock.sequence({.5}), tick)
assert(#machine.outputs == produced + 1 and machine.outputs[#machine.outputs] == "normal")
assert(workshop.available(machine.entity) == available, "passing costs no packs")
machine.start("gear", "rare", 10)
tick = run(machine, record, 3, mock.sequence({.5}), tick)
assert(machine.outputs[#machine.outputs] == "rare", "positive quality unchanged without the setting")
workshop.apply_settings(record, {reset_positive = true})
machine.start("gear", "rare", 10)
tick = run(machine, record, 100, mock.sequence({.5}), tick)
assert(machine.crafting, "reset takes 1/5 of the 600-tick attempt: 120 ticks")
tick = run(machine, record, 25, mock.sequence({.5}), tick)
assert(not machine.crafting, "reset needs only 1/5 of the attempt time")
assert(machine.outputs[#machine.outputs] == "normal" and workshop.available(machine.entity) == available)
assert(storage.ic_stats[1]["refine.resets"] == 1 and storage.ic_stats[1]["refine.passed"] == 2)

-- 5. Mining in the middle of a series returns the reached grade, not the starting one.
machine.start("gear", "ic-defect-5", 10)
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(record.craft and record.craft.grade == -4 and machine.crafting)
local buffer = {valid = true, items = {["gear|ic-defect-5"] = 1}}
function buffer.remove(spec) local key = spec.name .. "|" .. spec.quality; local n = buffer.items[key] or 0; buffer.items[key] = nil; return n end
function buffer.insert(spec) local key = spec.name .. "|" .. spec.quality; buffer.items[key] = (buffer.items[key] or 0) + spec.count; return spec.count end
workshop.on_mined(machine.entity, buffer)
assert(buffer.items["gear|ic-defect-4"] == 1 and not buffer.items["gear|ic-defect-5"])

-- 6. Unknown items cost like an average item.
local cost, seconds = workshop.cost_of("unknown")
assert(cost == 1500 and seconds == 10)
print("PASS: workshop streams pack durability (partial packs), waits without packs or power,")
print("repeats attempts inside the machine until standard (90% + 10% chain), passes standard,")
print("resets positive quality on request, returns the reached grade when mined. Mocks only.")
