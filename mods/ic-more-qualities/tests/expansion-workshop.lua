-- Refinement workshop runtime (rewritten 2026-10-29), simulated tick by tick on mocks: the whole cost paid and
-- the outcome rolled when an attempt starts, holding without packs or power, one attempt per item (the item
-- always leaves), reset/pass, modes, rare looks, script refinement of used packs, timer wheel, adoption of an
-- attempt of the older layout. The "machine" below only advances progress like a furnace would; not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local near = mock.near

defines = mock.defines()
storage = {}
game = {tick = 0}
script = {register_on_object_destroyed = function() end}
prototypes = {
    -- Refinable items (finished products); "plate" is a material without an entry.
    mod_data = {["ic-quality-expansion"] = {data = {costs = {gear = {cost = 1500, seconds = 10},
        ["automation-science-pack"] = {cost = 750, seconds = 10}, ["firearm-magazine"] = {cost = 750, seconds = 10}}}}},
    entity = {["ic-refine-workshop-power"] = {}, ["ic-signal-emitter"] = {}},
}
local workshop = require("scripts.expansion.workshop")
local EMPTY = {valid_for_read = false}

local function pack_stack(count, durability)
    local stack = {valid_for_read = true, is_tool = true, name = "repair-pack", count = count, durability = durability,
        quality = {name = "normal"}, prototype = {get_durability = function() return 300 end}}
    function stack.clear() stack.valid_for_read, stack.count = false, 0 end
    return stack
end

-- The workshop keeps its inventories on the record: the fuel inventory is changed in place.
local function set_fuel(machine, first, second)
    machine.fuel[1], machine.fuel[2] = first or {valid_for_read = false}, second or {valid_for_read = false}
end

local function make_machine(unit)
    local machine = {crafting = false, outputs = {}}
    local interface = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 0}
    interface.destroy = function() interface.valid = false end
    machine.interface = interface
    machine.fuel = {pack_stack(2, 300), {valid_for_read = false}}
    local entity = {
        valid = true, name = "ic-refine-workshop", unit_number = unit or 7, position = {x = 0, y = 0},
        surface = {index = 1, create_entity = function() return interface end},
        force = {index = 1, players = {}}, burner = {}, crafting_speed = 1, crafting_progress = 0,
        products_finished = 0, disabled_by_script = false, quality = {name = "normal"}, status = "working",
        prototype = {get_max_energy_usage = function() return 1250 end},
    }
    entity.get_fuel_inventory = function() return machine.fuel end
    -- A live view of the input slot (the real LuaInventory reflects its content).
    local source = setmetatable({is_empty = function() return not (machine.source and machine.source.valid_for_read) end},
        {__index = function(_, key) if key == 1 then return machine.source or EMPTY end end})
    entity.get_inventory = function() return source end
    entity.is_crafting = function() return machine.crafting end
    entity.get_recipe = function()
        if not machine.crafting then return nil end
        return {name = "ic-refine-item-" .. machine.item}, {name = machine.input}
    end
    machine.entity = entity
    -- The furnace starts a craft with recipe quality = item quality.
    function machine.start(item, quality, seconds)
        machine.crafting, machine.item, machine.input = true, item, quality
        machine.rate, machine.seconds = entity.crafting_speed / (seconds * 60), seconds
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
            local item = machine.source
            machine.source = nil
            machine.start(item.name, item.quality.name, item.seconds)
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

local looks = 0
local function run(machine, record, ticks, random, from_tick, energy)
    local tick = from_tick or 0
    for _ = 1, ticks do
        tick = tick + 1
        machine.interface.energy = machine.interface.electric_buffer_size * (energy or 1)
        if record.next_tick <= tick then
            looks = looks + 1
            workshop.step(record, {tick = tick, random = random})
        end
        machine.update()
    end
    return tick
end

-- 1. Not enough packs: what is there is taken, the attempt waits at its start; nothing is lost.
local machine = make_machine()
local record = workshop.track(machine.entity)
assert(record and machine.entity.burner.currently_burning.name == "ic-refine-workshop-drive")
machine.start("gear", "ic-defect-3", 10)
local tick = run(machine, record, 900, mock.sequence({.95}))
assert(machine.crafting and #machine.outputs == 0)
near(record.craft.paid, 600 / 1500)
assert(not record.craft.final, "not rolled before it is paid")
-- Held by script at its start: the progress bar does not move; idle power while waiting.
assert(machine.entity.crafting_progress < 0.01)
assert(not machine.fuel[1].valid_for_read, "both packs fully used")
assert(record.status_key == "no-resource" and machine.entity.custom_status.diode == "red")
assert(workshop.available(machine.entity) == 0)
assert(record.held and machine.entity.disabled_by_script, "held without packs")
near(machine.interface.power_usage, 1250 / 30)
assert(record.next_tick - tick <= workshop.IDLE_LOOK, "waiting for packs: looked at every IDLE_LOOK ticks")
local held_at = machine.entity.crafting_progress
for _ = 1, 60 do
    tick = run(machine, record, 1, mock.sequence({.95}), tick)
    assert(machine.entity.crafting_progress == held_at, "progress must not move while held")
end
-- Turning circuit control off keeps a held workshop stopped.
workshop.set_circuit(record, false)
assert(machine.entity.disabled_by_script)

-- 2. Packs arrive: the rest is paid and the outcome rolled at once; the attempt finishes. One attempt per
-- item, the item always leaves. Failed attempt: the same item leaves unchanged.
set_fuel(machine, pack_stack(100, 150)) -- a partially used pack on top
local before = workshop.available(machine.entity)
near(before, 99 * 300 + 150)
tick = run(machine, record, 1000, mock.sequence({.95}), tick)
assert(not record.held, "released when packs arrive")
-- Idle with an empty input slot the furnace stays stopped until a look sees the next item.
assert(machine.entity.disabled_by_script and record.status_key == "waiting")
assert(#machine.outputs == 1 and machine.outputs[1] == "ic-defect-3", tostring(machine.outputs[1]))
assert(not machine.crafting, "no further attempt inside the machine")
-- Fed again: the whole cost is drained and the outcome written at the first look of the attempt.
machine.start("gear", "ic-defect-3", 10)
local available_before = workshop.available(machine.entity)
local start_tick = tick
looks = 0
while not (record.craft and record.craft.final) do tick = run(machine, record, 1, mock.sequence({.5, .5}), tick) end
assert(tick - start_tick <= workshop.IDLE_LOOK + 1, "seen by the next idle look")
near(available_before - workshop.available(machine.entity), 1500)
assert(machine.entity.result_quality == "ic-defect-2", "outcome written at the start")
assert(record.status == "working|-3", "the status shows the grade the item came with: " .. tostring(record.status))
tick = run(machine, record, 1000, mock.sequence({.5, .5}), tick)
assert(#machine.outputs == 2 and machine.outputs[2] == "ic-defect-2", tostring(machine.outputs[2]))
assert(looks <= 600 / workshop.WORK_LOOK + 6 + 1000 / workshop.IDLE_LOOK + 2, "rare looks: " .. looks)
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

-- 3. Power gating. Without electricity the attempt is held (the furnace is disabled, so the bar does not run
-- ahead); the full power stays requested. Partial power slows the attempt; power back releases it.
machine.start("gear", "ic-defect-1", 10)
record.next_tick = tick + 1
tick = run(machine, record, 1, mock.sequence({.5}), tick)
assert(record.craft and record.craft.final)
local waited = 0
while not record.held do
    tick = run(machine, record, 1, mock.sequence({.5}), tick, 0)
    waited = waited + 1
    assert(waited <= workshop.WORK_LOOK + 1, "the next look stops it")
end
local progress = machine.entity.crafting_progress
assert(progress < 0.01, "the unpowered interval does not count: " .. progress)
for _ = 1, 60 do
    tick = run(machine, record, 1, mock.sequence({.5}), tick, 0)
    assert(machine.entity.crafting_progress == progress, "progress must not move without electricity")
end
assert(record.held and machine.entity.disabled_by_script, "held without electricity")
assert(record.status_key == "no-power" and machine.entity.custom_status.diode == "red")
near(machine.interface.power_usage, 1250, 1e-9) -- full power requested: the buffer refills when power is back
assert(record.starved_since == nil, "no repair-pack alert without electricity")
-- Half supply: released, slowed (looks often enough that the bar stays near the slowed progress).
local virtual_before = record.craft.progress
local half_ticks = 0
for _ = 1, 90 do
    tick = run(machine, record, 1, mock.sequence({.5}), tick, 0.25)
    if not record.held then half_ticks = half_ticks + 1 end
    assert(machine.entity.crafting_progress - record.craft.progress <= workshop.JUMP + 2 / 600 + 1e-9, "bar jump")
end
assert(not record.held and not machine.entity.disabled_by_script, "released with some electricity")
assert(record.status_key == "low-power")
local slowed = record.craft.progress - virtual_before
assert(slowed > 0.25 * half_ticks / 600 and slowed < 0.75 * half_ticks / 600,
    "half supply: about half speed, got " .. slowed .. " for " .. half_ticks .. " ticks")
tick = run(machine, record, 1200, mock.sequence({.5}), tick)
assert(machine.outputs[#machine.outputs] == "normal")
-- Idle without electricity: the status says so (red), not "waiting".
tick = run(machine, record, workshop.IDLE_LOOK + 2, mock.sequence({.5}), tick, 0)
assert(record.status_key == "no-power" and not machine.crafting)

-- 4. Standard quality passes for free; positive quality passes unchanged or is reset.
local available = workshop.available(machine.entity)
local produced = #machine.outputs
machine.start("gear", "normal", 10)
tick = run(machine, record, workshop.IDLE_LOOK + 5, mock.sequence({.5}), tick)
assert(#machine.outputs == produced + 1 and machine.outputs[#machine.outputs] == "normal")
assert(workshop.available(machine.entity) == available, "passing costs no packs")
machine.start("gear", "rare", 10)
tick = run(machine, record, workshop.IDLE_LOOK + 5, mock.sequence({.5}), tick)
assert(machine.outputs[#machine.outputs] == "rare", "positive quality unchanged without the setting")
workshop.apply_settings(record, {reset_positive = true})
record.next_tick = tick + 1
machine.start("gear", "rare", 10)
tick = run(machine, record, 50, mock.sequence({.5}), tick)
assert(machine.crafting, "reset of a 600-tick attempt is capped at 60 ticks")
tick = run(machine, record, 15, mock.sequence({.5}), tick)
assert(not machine.crafting, "reset takes at most one second after the workshop sees the item")
assert(machine.outputs[#machine.outputs] == "normal" and workshop.available(machine.entity) == available)
assert(storage.ic_stats[1]["refine.resets"] == 1 and storage.ic_stats[1]["refine.passed"] == 2)
-- A quality reset stops without electricity as well and finishes once power is back.
machine.start("gear", "rare", 10)
waited = 0
while not record.held do
    tick = run(machine, record, 1, mock.sequence({.5}), tick, 0)
    waited = waited + 1
    assert(waited <= workshop.IDLE_LOOK + workshop.WORK_LOOK + 2)
end
local reset_at = machine.entity.crafting_progress
for _ = 1, 30 do tick = run(machine, record, 1, mock.sequence({.5}), tick, 0) end
assert(machine.crafting and machine.entity.crafting_progress == reset_at, "reset held without electricity")
assert(record.status_key == "no-power")
tick = run(machine, record, 100, mock.sequence({.5}), tick)
assert(not machine.crafting and machine.outputs[#machine.outputs] == "normal" and not record.held)

-- 5. Unknown items cost like an average item and are not refinable.
local cost, seconds = workshop.cost_of("unknown")
assert(cost == 750 and seconds == 10)
assert(workshop.refinable("gear") and not workshop.refinable("unknown"))

-- 6. The working status is written once per attempt, not on every look (the label key used to contain a
-- fresh table address). A fast workshop (15-tick attempt) still sees it before the end.
machine = make_machine(8)
machine.entity.crafting_speed = 40 -- 10 s attempt -> 15 ticks
set_fuel(machine, pack_stack(100, 300))
record = workshop.track(machine.entity)
tick = run(machine, record, 5, mock.sequence({.5}), tick)
machine.start("gear", "ic-defect-2", 10)
record.next_tick = tick + 1
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
assert(machine.outputs[1] == "ic-defect-1", tostring(machine.outputs[1]))
assert(writes <= 3, "status writes: " .. writes)

-- 7. Modes (user decision 2026-10-15): precise 5x / flawless 20x the time, the same packs, +2 grades /
-- standard for sure; a switch applies from the next attempt; settings copy the mode. The engine runs ahead
-- between looks at most JUMP of the attempt.
machine = make_machine(9)
set_fuel(machine, pack_stack(100, 300))
record = workshop.track(machine.entity)
assert(workshop.mode_name(record) == "normal")
local max_ahead = 0
local function attempt_ticks(item_quality, budget)
    machine.start("gear", item_quality, 10)
    record.next_tick = tick + 1
    local outputs, start = #machine.outputs, tick
    local packs_before = workshop.available(machine.entity)
    looks = 0
    for _ = 1, budget do
        tick = tick + 1
        machine.interface.energy = machine.interface.electric_buffer_size
        if record.next_tick <= tick then
            looks = looks + 1
            workshop.step(record, {tick = tick, random = mock.sequence({.99})})
        end
        machine.update()
        if #machine.outputs > outputs then break end
        -- Normal mode is never set back: only the slowed modes count.
        if record.craft and record.craft.mode ~= "normal" then
            max_ahead = math.max(max_ahead, machine.entity.crafting_progress - record.craft.progress)
        end
    end
    assert(#machine.outputs == outputs + 1, "attempt did not finish")
    return tick - start, packs_before - workshop.available(machine.entity), machine.outputs[#machine.outputs]
end
local stats_before = storage.ic_stats[1]["refine.attempts"]
local t1, p1, r1 = attempt_ticks("ic-defect-5", 2000)
assert(r1 == "ic-defect-5", "normal mode: the .99 roll fails")
assert(looks <= 600 / workshop.WORK_LOOK + 6, "normal mode: looks per 10 s attempt " .. looks)
workshop.set_mode(record, "careful")
local t2, p2, r2 = attempt_ticks("ic-defect-5", 6000)
assert(r2 == "ic-defect-3", r2)
workshop.set_mode(record, "precise")
local t3, p3, r3 = attempt_ticks("ic-defect-5", 20000)
assert(r3 == "normal", r3)
assert(looks <= 12000 / math.floor(workshop.JUMP * 600) + 120, "flawless mode: looks " .. looks)
near(p1, 1500, 1e-6); near(p2, 1500, 1e-6); near(p3, 1500, 1e-6)
assert(math.abs(t2 / t1 - 5) < 0.1 and math.abs(t3 / t1 - 20) < 0.3, t1 .. " " .. t2 .. " " .. t3)
assert(max_ahead <= workshop.JUMP + 2 / 600 + 1e-9, "the bar runs ahead at most JUMP: " .. max_ahead)
workshop.set_mode(record, "careful")
local _, _, r4 = attempt_ticks("ic-defect-1", 6000)
assert(r4 == "normal", "never above standard")
local s = storage.ic_stats[1]
assert(s["refine.attempts"] == stats_before + 1 and s["refine.mode.careful"] == 2 and s["refine.mode.precise"] == 1)
-- A switch during an attempt applies from the next one.
machine.start("gear", "ic-defect-5", 10)
record.next_tick = tick + 1
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

-- 8. Without packs an inserted defective item stays in the input slot (it used to be taken into an attempt at
-- once and seemed to vanish); standard items still pass; packs release the workshop.
machine = make_machine(10)
set_fuel(machine)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
assert(record.held and machine.entity.disabled_by_script, "idle without packs: stopped in advance")
assert(record.status_key == "waiting")
machine.insert("gear", "normal", 10)
tick = run(machine, record, workshop.IDLE_LOOK + 5, mock.sequence({.5}), tick)
assert(machine.outputs[1] == "normal" and not machine.source, "standard item passes without packs")
assert(record.held and machine.entity.disabled_by_script, "stopped again after the pass")
machine.insert("gear", "ic-defect-3", 10)
tick = run(machine, record, 400, mock.sequence({.5}), tick)
assert(machine.source and not machine.crafting and #machine.outputs == 1, "defective item stays in the slot")
assert(record.status_key == "no-resource" and machine.entity.custom_status.diode == "red")
assert(record.starved_since, "alert timer runs while the item waits")
set_fuel(machine, pack_stack(10, 300))
tick = run(machine, record, 1000, mock.sequence({.5, .5}), tick)
assert(not machine.source and machine.outputs[2] == "ic-defect-2", tostring(machine.outputs[2]))
assert(not record.starved_since)

-- 8b. A material left in the input slot by a save before 2026-10-29 (no refinement recipe any more) is never
-- taken: the workshop stays stopped with its own status and is looked at every IDLE_LOOK ticks, not every tick.
machine = make_machine(18)
record = workshop.track(machine.entity)
machine.insert("plate", "uncommon", 10)
looks = 0
tick = run(machine, record, 300, mock.sequence({.5}), tick)
assert(machine.source and not machine.crafting and machine.entity.disabled_by_script)
assert(record.status_key == "not-refinable" and machine.entity.custom_status.diode == "red")
assert(looks <= 300 / workshop.IDLE_LOOK + 1, "looks: " .. looks)

-- 9. An attempt of the older layout (string key, partly paid) is adopted: the rest is paid, nothing twice.
machine = make_machine(17)
set_fuel(machine, pack_stack(100, 300))
record = workshop.track(machine.entity)
machine.start("gear", "ic-defect-3", 10)
machine.entity.crafting_progress, machine.entity.products_finished = 0.5, 4
record.craft = {key = "ic-refine-item-gear|4", kind = "refine", item = "gear", from = "ic-defect-3", grade = -3,
    start_grade = -3, paid = 0.5, cost = 1500, seconds = 10, progress = 0.5, mode = "normal", attempts = 0}
local packs_before = workshop.available(machine.entity)
record.next_tick = tick + 1
start_tick = tick
tick = run(machine, record, 400, mock.sequence({.5, .5}), tick)
near(packs_before - workshop.available(machine.entity), 750)
assert(machine.outputs[1] == "ic-defect-2" and tick - start_tick >= 300, tostring(machine.outputs[1]))

-- 10. Partly used science packs and magazines (per-item durability / rounds) are never taken by the furnace:
-- its recipe output is a fresh full item, so a used pack came back full (endless science). The script refines
-- them from the input slot with the same cost and time and keeps the share of durability. Whole packs and full
-- magazines are taken by the furnace like other items (fresh full = whole input).
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
    local machine = make_machine(unit)
    local entity = machine.entity
    set_fuel(machine, pack_stack(100, 300))
    machine.result = {}
    local source_inventory = {is_empty = function() return not (machine.source and machine.source.valid_for_read) end}
    setmetatable(source_inventory, {__index = function(_, key)
        if key == 1 then return machine.source or EMPTY end
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
                local _, item_seconds = workshop.cost_of(source.name)
                machine.taken = (machine.taken or 0) + 1
                if source.count > 1 then source.count = source.count - 1 else machine.source = nil end
                machine.start(source.name, source.quality.name, item_seconds)
            end
        end
        update()
    end
    return machine
end

-- 10a. A used standard pack passes unchanged by script; the whole packs below it go to the furnace and pass
-- there; no packs spent.
machine = make_pack_machine(11)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("tool", "automation-science-pack", "normal", 3, 40)
packs_before = workshop.available(machine.entity)
tick = run(machine, record, workshop.IDLE_LOOK + 10, mock.sequence({.5}), tick)
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
start_tick = tick
local random10 = mock.sequence({.5, .5})
while #machine.result == 0 and tick - start_tick < 2000 do tick = run(machine, record, 1, random10, tick) end
assert(#machine.result == 1 and machine.result[1].quality == "ic-defect-2", tostring(machine.result[1] and machine.result[1].quality))
near(machine.result[1].durability, 0.5 * 75)
local took = tick - start_tick
assert(took >= 599 and took <= 600 + workshop.IDLE_LOOK + 2, "same time as the furnace (and the idle look): " .. took)
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
tick = run(machine, record, workshop.IDLE_LOOK + 10, mock.sequence({.5}), tick)
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
tick = run(machine, record, workshop.WORK_LOOK + 5, mock.sequence({.5}), tick)
assert(not machine.source and machine.result[1].durability == 40)
set_fuel(machine)
machine.source = typed_stack("tool", "automation-science-pack", "ic-defect-3", 1, 30)
tick = run(machine, record, 400, mock.sequence({.5}), tick)
assert(machine.source and machine.source.durability == 30 and record.status_key == "no-resource")
set_fuel(machine, pack_stack(10, 300))
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
tick = run(machine, record, workshop.WORK_LOOK + 5, mock.sequence({.5, .5}), tick)
assert(not machine.source and machine.result[1].durability == 40 and machine.crafting)
assert(machine.entity.crafting_progress >= held_progress, "the attempt of the furnace is kept")
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(machine.outputs[1] == "ic-defect-2", tostring(machine.outputs[1]))

-- 10f. A whole defective pack is refined by the furnace: the building is not stopped by script, the script
-- result slot stays untouched, packs are spent as for any item.
machine = make_pack_machine(16)
record = workshop.track(machine.entity)
tick = run(machine, record, 10, mock.sequence({.5}), tick)
machine.source = typed_stack("tool", "automation-science-pack", "ic-defect-3", 1, 60)
packs_before = workshop.available(machine.entity)
tick = run(machine, record, workshop.IDLE_LOOK + 5, mock.sequence({.5, .5}), tick)
assert(machine.crafting and not machine.entity.disabled_by_script and not record.sc, "the furnace refines the whole pack")
tick = run(machine, record, 700, mock.sequence({.5, .5}), tick)
assert(machine.taken == 1 and machine.outputs[1] == "ic-defect-2" and #machine.result == 0)
near(packs_before - workshop.available(machine.entity), (workshop.cost_of("automation-science-pack")), 1e-6)

-- 11. Timer wheel (scripts/wheel.lua): a workshop is looked at only on its tick; a settings change brings the
-- look forward; an older storage without buckets schedules every workshop on the next tick.
do
    local wheel = require("scripts.wheel")
    local state = storage.ic_workshops
    local calls, original_step = 0, workshop.step
    workshop.step = function(r, ctx) calls = calls + 1; r.next_tick = ctx.tick + 5 end
    state.buckets = {}
    wheel.add(state.buckets, record, 5000)
    workshop.on_tick({tick = 4999})
    assert(calls == 0)
    workshop.on_tick({tick = 5000})
    assert(calls == 1 and record.due == 5005 and state.buckets[5000] == nil)
    game.tick = 5001
    workshop.set_circuit(record, false)
    assert(record.due == 5002 and state.buckets[5002][1] == record.id)
    workshop.on_tick({tick = 5002})
    workshop.on_tick({tick = 5005}) -- stale entry skipped
    assert(calls == 2 and record.due == 5007)
    workshop.step = original_step
    state.buckets = nil
    game.tick = 6000
    local bucket, found = workshop.state().buckets[6001], 0
    for _, id in ipairs(bucket) do if id == record.id then found = found + 1 end end
    local count = 0
    for _ in pairs(state.records) do count = count + 1 end
    assert(found == 1 and #bucket == count, "every workshop scheduled once")
end

print("PASS: the whole cost is paid and the outcome rolled when an attempt starts (written at once, the status")
print("keeps the grade the item came with); short of packs the attempt waits at its start, nothing is lost; one")
print("attempt per item (90% + 10% chain, capped at standard), the item always leaves; power gating and slowing;")
print("pass and reset; modes 5x/20x the time for the same packs with the bar at most JUMP ahead; rare looks;")
print("adoption of an older attempt; used science packs and magazines refined by script with their share of")
print("durability / rounds, never by the furnace; timer wheel. Mocks only.")
