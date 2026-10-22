-- Refinement workshop runtime, simulated tick by tick on mocks: resource streaming, holding
-- without packs, power gating, one attempt per item (the item always leaves), reset/pass, mining fix-up.
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
    entity.get_inventory = function()
        return {machine.source or {valid_for_read = false}, is_empty = function() return machine.source == nil end}
    end
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
    -- Put an item into the input slot: the furnace takes it on its next update unless disabled.
    function machine.insert(item, quality, seconds)
        machine.source = {valid_for_read = true, name = item, quality = {name = quality}, count = 1, seconds = seconds}
    end
    -- Native update after on_tick: start from the input slot, progress, completion.
    function machine.update()
        if entity.disabled_by_script then return end
        if not machine.crafting and machine.source then
            local source = machine.source
            machine.source = nil
            machine.start(source.name, source.quality.name, source.seconds)
        end
        if not machine.crafting then return end
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
-- Held at the paid share: the furnace is disabled by script, so it no longer runs ahead between
-- looks and gets rewound (the progress bar jittered); idle power while waiting.
assert(machine.entity.crafting_progress <= 0.4 + 1e-9 and machine.entity.crafting_progress > 0.35)
assert(not machine.fuel[1].valid_for_read, "both packs fully used")
assert(record.status_key == "no-resource" and machine.entity.custom_status.diode == "red")
assert(workshop.available(machine.entity) == 0)
assert(record.held and machine.entity.disabled_by_script, "held without packs")
near(machine.interface.power_usage, 1250 / 30)
local held_at = machine.entity.crafting_progress
for _ = 1, 60 do
    tick = run(machine, record, 1, mock.sequence({.95}), tick)
    assert(machine.entity.crafting_progress == held_at, "progress must not move while held")
end
-- Turning circuit control off keeps a held workshop stopped.
workshop.set_circuit(record, false)
assert(machine.entity.disabled_by_script)

-- 2. Packs arrive: the attempt finishes. One attempt per item, the item always leaves.
-- Failed attempt: the same item leaves unchanged; nothing is held inside or lost.
machine.fuel[1] = pack_stack(100, 150) -- a partially used pack on top
local before = workshop.available(machine.entity)
near(before, 99 * 300 + 150)
tick = run(machine, record, 1000, mock.sequence({.95}), tick)
assert(not record.held, "released when packs arrive")
-- Idle with an empty input slot the furnace stays stopped until a look sees the next item.
assert(machine.entity.disabled_by_script and record.status_key == "waiting")
assert(#machine.outputs == 1 and machine.outputs[1] == "ic-defect-3", tostring(machine.outputs[1]))
assert(not machine.crafting, "no further attempt inside the machine")
-- Fed again: success, one grade up, no jump -> -2.
machine.start("gear", "ic-defect-3", 10)
tick = run(machine, record, 1000, mock.sequence({.5, .5}), tick)
assert(#machine.outputs == 2 and machine.outputs[2] == "ic-defect-2", tostring(machine.outputs[2]))
-- Fed again: success with one jump -> -1 (still below standard, but it leaves).
machine.start("gear", "ic-defect-3", 10)
tick = run(machine, record, 1000, mock.sequence({.5, .05, .5}), tick)
assert(#machine.outputs == 3 and machine.outputs[3] == "ic-defect-1", tostring(machine.outputs[3]))
local used = before - workshop.available(machine.entity)
near(used + 600, 3 * 1500, 1e-6) -- three paid attempts, the first one partly from the old packs
local counters = storage.ic_stats[1]
assert(counters["refine.attempts"] == 3 and counters["refine.fail"] == 1 and counters["refine.success"] == 2)
assert(counters["refine.jump1"] == 1 and counters["refine.jump2"] == 1 and (counters["refine.normalized"] or 0) == 0)
near(counters["refine.resource"], 3 * 1500, 1e-6)
-- Never above standard: a -1 item with every jump rolled leaves standard.
machine.start("gear", "ic-defect-1", 10)
tick = run(machine, record, 1000, mock.sequence({.05}), tick)
assert(machine.outputs[4] == "normal" and counters["refine.normalized"] == 1)

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
tick = run(machine, record, 10, mock.sequence({.5}), tick)
assert(#machine.outputs == produced + 1 and machine.outputs[#machine.outputs] == "normal")
assert(workshop.available(machine.entity) == available, "passing costs no packs")
machine.start("gear", "rare", 10)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
assert(machine.outputs[#machine.outputs] == "rare", "positive quality unchanged without the setting")
workshop.apply_settings(record, {reset_positive = true})
machine.start("gear", "rare", 10)
tick = run(machine, record, 50, mock.sequence({.5}), tick)
assert(machine.crafting, "reset of a 600-tick attempt is capped at 60 ticks")
tick = run(machine, record, 10 + workshop.IDLE_LOOK, mock.sequence({.5}), tick)
assert(not machine.crafting, "reset needs at most one second after the workshop sees the item")
assert(machine.outputs[#machine.outputs] == "normal" and workshop.available(machine.entity) == available)
assert(storage.ic_stats[1]["refine.resets"] == 1 and storage.ic_stats[1]["refine.passed"] == 2)

-- 5. Mining after the outcome is decided (before the craft completes) returns the reached grade.
machine.start("gear", "ic-defect-5", 10)
local random5 = mock.sequence({.5, .5})
for _ = 1, 700 do
    tick = tick + 1
    machine.interface.energy = machine.interface.electric_buffer_size
    if record.next_tick <= tick then workshop.step(record, {tick = tick, random = random5}) end
    if record.craft and record.craft.final then break end -- decided; the engine has not finished yet
    machine.update()
end
assert(record.craft and record.craft.final and record.craft.grade == -4 and machine.crafting)
local buffer = {valid = true, items = {["gear|ic-defect-5"] = 1}}
function buffer.remove(spec) local key = spec.name .. "|" .. spec.quality; local n = buffer.items[key] or 0; buffer.items[key] = nil; return n end
function buffer.insert(spec) local key = spec.name .. "|" .. spec.quality; buffer.items[key] = (buffer.items[key] or 0) + spec.count; return spec.count end
workshop.on_mined(machine.entity, buffer)
assert(buffer.items["gear|ic-defect-4"] == 1 and not buffer.items["gear|ic-defect-5"])

-- 6. Unknown items cost like an average item.
local cost, seconds = workshop.cost_of("unknown")
assert(cost == 750 and seconds == 10)
-- 7. The working status is written once per grade, not on every look (the label key used to contain
-- a fresh table address). A fast workshop (15-tick attempt) looks more often and still decides in time.
machine = make_machine()
machine.entity.unit_number = 8
machine.entity.crafting_speed = 40 -- 10 s attempt -> 15 ticks
machine.fuel[1] = pack_stack(100, 300)
record = workshop.track(machine.entity)
tick = run(machine, record, 5, mock.sequence({.5}), tick)
assert(record.idle_look == 5, "idle: three looks during the shortest attempt, got " .. tostring(record.idle_look))
machine.start("gear", "ic-defect-2", 0.25)
local writes, seen = 0, nil
for _ = 1, 30 do
    tick = tick + 1
    machine.interface.energy = machine.interface.electric_buffer_size
    if record.next_tick <= tick then
        workshop.step(record, {tick = tick, random = mock.sequence({.5, .5})})
        if machine.entity.custom_status ~= seen then writes, seen = writes + 1, machine.entity.custom_status end
    end
    machine.update()
end
assert(record.look == 2, "short attempt: look every 2 ticks, got " .. tostring(record.look))
assert(machine.outputs[1] == "ic-defect-1", tostring(machine.outputs[1]))
assert(writes <= 3, "status writes: " .. writes)

-- 8. Modes (user decision 2026-10-15): precise 5x / flawless 20x the time, the same packs,
-- +2 grades / standard for sure; a switch applies from the next attempt; settings copy the mode.
machine = make_machine()
machine.entity.unit_number = 9
machine.fuel[1] = pack_stack(100, 300)
record = workshop.track(machine.entity)
assert(workshop.mode_name(record) == "normal")
local function attempt_ticks(item_quality, budget)
    machine.start("gear", item_quality, 10)
    local outputs, start = #machine.outputs, tick
    local packs_before = workshop.available(machine.entity)
    for _ = 1, budget do
        tick = tick + 1
        machine.interface.energy = machine.interface.electric_buffer_size
        if record.next_tick <= tick then workshop.step(record, {tick = tick, random = mock.sequence({.99})}) end
        machine.update()
        if #machine.outputs > outputs then break end
    end
    assert(#machine.outputs == outputs + 1, "attempt did not finish")
    return tick - start, packs_before - workshop.available(machine.entity), machine.outputs[#machine.outputs]
end
local stats_before = storage.ic_stats[1]["refine.attempts"]
local t1, p1, r1 = attempt_ticks("ic-defect-5", 2000)
assert(r1 == "ic-defect-5", "normal mode: the .99 roll fails")
workshop.set_mode(record, "careful")
local t2, p2, r2 = attempt_ticks("ic-defect-5", 6000)
assert(r2 == "ic-defect-3", r2)
workshop.set_mode(record, "precise")
local t3, p3, r3 = attempt_ticks("ic-defect-5", 20000)
assert(r3 == "normal", r3)
near(p1, 1500, 1e-6); near(p2, 1500, 1e-6); near(p3, 1500, 1e-6)
assert(math.abs(t2 / t1 - 5) < 0.1 and math.abs(t3 / t1 - 20) < 0.3, t1 .. " " .. t2 .. " " .. t3)
workshop.set_mode(record, "careful")
local _, _, r4 = attempt_ticks("ic-defect-1", 6000)
assert(r4 == "normal", "never above standard")
local s = storage.ic_stats[1]
assert(s["refine.attempts"] == stats_before + 1 and s["refine.mode.careful"] == 2 and s["refine.mode.precise"] == 1)
-- A switch during an attempt applies from the next one.
machine.start("gear", "ic-defect-5", 10)
tick = run(machine, record, 100, mock.sequence({.99}), tick)
assert(record.craft.mode == "careful")
workshop.set_mode(record, "precise")
local outputs = #machine.outputs
tick = run(machine, record, 3200, mock.sequence({.99}), tick)
assert(#machine.outputs == outputs + 1 and machine.outputs[#machine.outputs] == "ic-defect-3")
-- Settings: exported and applied with the mode; an unknown or missing mode is normal.
assert(workshop.export_settings(record).mode == "precise")
workshop.apply_settings(record, {mode = "bogus"})
assert(workshop.mode_name(record) == "normal")
workshop.apply_settings(record, {mode = "careful", reset_positive = false})
assert(workshop.mode_name(record) == "careful")
record.settings.mode = nil -- a workshop from an older version
assert(workshop.mode_name(record) == "normal" and workshop.export_settings(record).mode == "normal")

-- 9. Without packs an inserted defective item stays in the input slot (it used to be taken into an
-- attempt at once and seemed to vanish); standard items still pass; packs release the workshop.
machine = make_machine()
machine.entity.unit_number = 10
machine.fuel = {{valid_for_read = false}, {valid_for_read = false}}
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
assert(record.held and machine.entity.disabled_by_script, "idle without packs: stopped in advance")
assert(record.status_key == "waiting")
machine.insert("gear", "normal", 10)
tick = run(machine, record, 30, mock.sequence({.5}), tick)
assert(machine.outputs[1] == "normal" and not machine.source, "standard item passes without packs")
assert(record.held and machine.entity.disabled_by_script, "stopped again after the pass")
machine.insert("gear", "ic-defect-3", 10)
tick = run(machine, record, 400, mock.sequence({.5}), tick)
assert(machine.source and not machine.crafting and #machine.outputs == 1, "defective item stays in the slot")
assert(record.status_key == "no-resource" and machine.entity.custom_status.diode == "red")
assert(record.starved_since, "alert timer runs while the item waits")
machine.fuel[1] = pack_stack(10, 300)
tick = run(machine, record, 1000, mock.sequence({.5, .5}), tick)
assert(not machine.source and machine.outputs[2] == "ic-defect-2", tostring(machine.outputs[2]))
assert(not record.starved_since)

-- 10. Partly used science packs and magazines (per-item durability / rounds) are never taken by the
-- furnace: its recipe output is a fresh full item, so a used pack came back full (endless science). The
-- script refines them from the input slot with the same cost and time and keeps the share of durability.
-- Whole packs and full magazines are taken by the furnace like other items (fresh full = whole input).
local MAX = {normal = 100, ["ic-defect-3"] = 60, ["ic-defect-2"] = 75, rare = 150}
local function qname(q) return type(q) == "table" and q.name or q end
local function typed_stack(kind, name, quality, count, value)
    local stack = {valid_for_read = true, type = kind, name = name, quality = {name = quality}, count = count,
        prototype = {get_durability = function(q) return MAX[qname(q)] end, magazine_size = 10}}
    if kind == "tool" then stack.durability = value else stack.ammo = value end
    function stack.clear() stack.valid_for_read, stack.count = false, 0 end
    return stack
end
local function make_pack_machine(unit)
    local machine = make_machine()
    local entity = machine.entity
    entity.unit_number = unit
    machine.fuel[1] = pack_stack(100, 300)
    machine.result = {}
    local source_inventory = {is_empty = function() return not (machine.source and machine.source.valid_for_read) end}
    setmetatable(source_inventory, {__index = function(_, key)
        if key == 1 then return machine.source or {valid_for_read = false} end
    end})
    local result_inventory = {}
    function result_inventory.can_insert(item)
        local top = machine.result[#machine.result]
        return machine.blocked == nil and (top == nil or (top.name == item.name and top.quality == item.quality))
    end
    function result_inventory.insert(item)
        machine.result[#machine.result + 1] = item
        return item.count
    end
    entity.get_inventory = function(index)
        if index == defines.inventory.furnace_result then return result_inventory end
        return source_inventory
    end
    local update = machine.update
    -- The furnace takes one item of a stack; a pack or magazine it takes must be whole.
    function machine.update()
        if machine.source and not machine.source.valid_for_read then machine.source = nil end
        local source = machine.source
        if not entity.disabled_by_script and not machine.crafting and source then
            if source.type == "tool" then
                assert(source.durability >= MAX[source.quality.name], "the furnace took a used pack")
            elseif source.type == "ammo" then
                assert(source.ammo >= source.prototype.magazine_size, "the furnace took a used magazine")
            end
            if source.type then
                local _, seconds = workshop.cost_of(source.name)
                machine.taken = (machine.taken or 0) + 1
                if source.count > 1 then source.count = source.count - 1 else machine.source = nil end
                machine.start(source.name, source.quality.name, seconds)
            end
        end
        update()
    end
    return machine
end

-- 10a. A used standard pack passes unchanged by script; the whole packs below it go to the furnace and
-- pass there; no packs spent.
machine = make_pack_machine(11)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("tool", "automation-science-pack", "normal", 3, 40)
local packs_before = workshop.available(machine.entity)
tick = run(machine, record, 20, mock.sequence({.5}), tick)
assert(#machine.result == 1 and not machine.source, "one used pack passed by script: " .. #machine.result)
assert(machine.result[1].durability == 40 and machine.result[1].quality == "normal")
assert(workshop.available(machine.entity) == packs_before)
assert(machine.taken == 2 and #machine.outputs == 2 and machine.outputs[1] == "normal" and machine.outputs[2] == "normal",
    "the whole packs passed through the furnace")

-- 10b. A used defective pack is refined for the same cost and time; the share of durability is kept.
machine = make_pack_machine(12)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("tool", "automation-science-pack", "ic-defect-3", 2, 30)
packs_before = workshop.available(machine.entity)
local start_tick = tick
local random10 = mock.sequence({.5, .5})
while #machine.result == 0 and tick - start_tick < 2000 do tick = run(machine, record, 1, random10, tick) end
assert(#machine.result == 1 and machine.result[1].quality == "ic-defect-2", tostring(machine.result[1] and machine.result[1].quality))
near(machine.result[1].durability, 0.5 * 75)
assert(math.abs(tick - start_tick - 600) <= 2 * workshop.LOOK + 1, "same time as the furnace: " .. (tick - start_tick))
near(packs_before - workshop.available(machine.entity), (workshop.cost_of("automation-science-pack")), 1e-6)
-- The furnace takes the whole pack left in the slot right after the used one is delivered.
assert((machine.taken or 0) <= 1)
tick = run(machine, record, 700, random10, tick)
assert(#machine.result == 1 and not machine.source and not machine.crafting)
assert(machine.taken == 1 and machine.outputs[1] == "ic-defect-2", "the whole pack was refined by the furnace")

-- 10c. Ammo keeps its rounds; positive quality is reset with the share of durability on request.
machine = make_pack_machine(13)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("ammo", "firearm-magazine", "normal", 2, 4)
tick = run(machine, record, 20, mock.sequence({.5}), tick)
assert(#machine.result == 1 and machine.result[1].ammo == 4 and not machine.source)
assert(machine.taken == 1 and machine.outputs[1] == "normal", "the full magazine passed through the furnace")
workshop.apply_settings(record, {reset_positive = true})
machine.result = {}
machine.source = typed_stack("tool", "automation-science-pack", "rare", 1, 75)
tick = run(machine, record, 80, mock.sequence({.5}), tick)
assert(#machine.result == 1 and machine.result[1].quality == "normal")
near(machine.result[1].durability, 50)

-- 10d. Output blocked: the pack waits in the input slot; without repair packs it waits too.
machine = make_pack_machine(14)
record = workshop.track(machine.entity)
machine.blocked = true
machine.source = typed_stack("tool", "automation-science-pack", "normal", 1, 40)
tick = run(machine, record, 30, mock.sequence({.5}), tick)
assert(machine.source and machine.source.count == 1 and record.status_key == "output-full")
machine.blocked = nil
tick = run(machine, record, 10, mock.sequence({.5}), tick)
assert(not machine.source and machine.result[1].durability == 40)
machine.fuel = {{valid_for_read = false}, {valid_for_read = false}}
machine.source = typed_stack("tool", "automation-science-pack", "ic-defect-3", 1, 30)
tick = run(machine, record, 400, mock.sequence({.5}), tick)
assert(machine.source and machine.source.durability == 30 and record.status_key == "no-resource")
machine.fuel[1] = pack_stack(10, 300)
machine.result = {} -- the output slot holds one kind: the standard pack was taken out
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(not machine.source and machine.result[1].quality == "ic-defect-2")
near(machine.result[1].durability, 37.5)

-- 10e. A pack put in while the furnace refines another item: the furnace waits, the pack goes first.
machine = make_pack_machine(15)
record = workshop.track(machine.entity)
machine.start("gear", "ic-defect-3", 10)
tick = run(machine, record, 300, mock.sequence({.5, .5}), tick)
local held_progress = machine.entity.crafting_progress
machine.source = typed_stack("tool", "automation-science-pack", "normal", 1, 40)
tick = run(machine, record, 10, mock.sequence({.5, .5}), tick)
assert(not machine.source and machine.result[1].durability == 40 and machine.crafting)
assert(machine.entity.crafting_progress >= held_progress, "the attempt of the furnace is kept")
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(machine.outputs[1] == "ic-defect-2", tostring(machine.outputs[1]))

-- 10f. A whole defective pack is refined by the furnace: the building is not stopped by script, the
-- script result slot stays untouched, packs are spent as for any item.
machine = make_pack_machine(16)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("tool", "automation-science-pack", "ic-defect-3", 1, 60)
packs_before = workshop.available(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5, .5}), tick)
assert(machine.crafting and not machine.entity.disabled_by_script and not record.sc, "the furnace refines the whole pack")
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(machine.taken == 1 and machine.outputs[1] == "ic-defect-2" and #machine.result == 0)
near(packs_before - workshop.available(machine.entity), (workshop.cost_of("automation-science-pack")), 1e-6)

print("PASS: used science packs and magazines are refined by script with the share of durability / rounds")
print("kept, the furnace never takes them; whole ones go through the furnace; same cost and time; blocked")
print("output and missing packs wait.")
print("PASS: workshop streams pack durability (partial packs), waits without packs or power,")
print("makes one attempt per item (90% + 10% chain, capped at standard) and always releases it, passes standard,")
print("resets positive quality on request, returns the reached grade when mined; modes take 5x/20x the")
print("time for the same packs and give +2 grades / standard. Mocks only.")
