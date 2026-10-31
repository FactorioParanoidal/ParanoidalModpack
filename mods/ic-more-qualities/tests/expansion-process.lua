-- Post-processing of the control post on mocks: chance and outcome rules, 5 -> 1 operations, the
-- result without a slot (waits, never drops), completion, items it does not take, settings and timing. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
storage = {}
game = {tick = 0}
script = {register_on_object_destroyed = function() end}
rendering = {draw_sprite = function() return {id = 1} end, get_object_by_id = function() return nil end}

-- Quality chain: normal -> uncommon -> rare -> epic (probabilities as in Paranoidal, epic the last).
local chain = {{"normal", 0, 0.204}, {"uncommon", 2, 0.2}, {"rare", 3, 0.1}, {"epic", 4, 0}}
prototypes = {quality = {["ic-defect-3"] = {name = "ic-defect-3", level = 0}}, recipe = {}, item = {
    gear = {type = "item", get_spoil_ticks = function() return 0 end},
    fish = {type = "item", get_spoil_ticks = function() return 600 end},
    box = {type = "item-with-inventory", get_spoil_ticks = function() return 0 end},
}}
local previous
for _, q in ipairs(chain) do
    local quality = {name = q[1], level = q[2], next_probability = q[3]}
    prototypes.quality[q[1]] = quality
    if previous then previous.next = quality end
    previous = quality
end
local rules = require("scripts.expansion.rules")
local post = require("scripts.expansion.post")

-- Rules: chance = 6 x next_probability, at most 1; the last quality cannot go up.
local Q = prototypes.quality
assert(rules.PROCESS_TAKE == 5 and rules.PROCESS_EFFECT == 6)
assert(rules.process_chance(Q.normal) == 1 and rules.process_chance(Q.uncommon) == 1)
assert(math.abs(rules.process_chance(Q.rare) - 0.6) < 1e-9 and rules.process_chance(Q.epic) == 0)
local function sequence(values)
    local index = 0
    return function() index = index + 1; return values[index] or 0.999 end
end
assert(rules.process_outcome(Q.rare, sequence({0.7})) == Q.rare, "failed roll keeps the quality")
assert(rules.process_outcome(Q.normal, sequence({0.5, 0.9})) == Q.uncommon, "one step")
assert(rules.process_outcome(Q.normal, sequence({0.5, 0.1, 0.05})) == Q.epic, "several steps, stops at the end")
assert(rules.process_outcome(Q.epic, sequence({0})) == Q.epic)

-- Costs per product of the target: one sure step costs 5; from standard the step is sure and lands on
-- uncommon (80%, worth 1/5) or jumps straight to rare (20%): 5 / (0.8 / 5 + 0.2) = 13.9. On the Paranoidal curve
-- (41 tiers, next probability 0.204 - 0.004 per tier) the same numbers as review/quality-loops-step0-20261031.
local costs = rules.process_costs({Q.normal, Q.uncommon, Q.rare, Q.epic}, 3)
assert(math.abs(costs[2] - 5) < 1e-9 and math.abs(costs[1] - 5 / (0.8 / 5 + 0.2)) < 1e-9, costs[1])
local curve = {}
for k = 0, 40 do curve[k + 1] = {next_probability = k < 40 and 0.204 - 0.004 * k or 0} end
for k = 1, 40 do curve[k].next = curve[k + 1] end
local c15 = rules.process_costs(curve, 16)
assert(c15[1] > 2.1e7 and c15[1] < 2.3e7 and c15[11] > 500 and c15[11] < 560, c15[1] .. " " .. c15[11])

-- Inventory of 8 slots.
local SLOTS = 8
local inventory = {}
local function empty_slot()
    local s = {valid_for_read = false, count = 0, health = 1, is_tool = false, is_ammo = false}
    function s.clear() s.valid_for_read, s.count, s.name, s.quality = false, 0, nil, nil end
    return s
end
for i = 1, SLOTS do inventory[i] = empty_slot() end
local function fill(list)
    for i = 1, SLOTS do inventory[i].clear() end
    for i, entry in ipairs(list) do
        local s = inventory[i]
        s.valid_for_read, s.name, s.quality, s.count = true, entry[1], Q[entry[2]], entry[3]
    end
end
local function count(name, quality)
    local n = 0
    for i = 1, SLOTS do
        local s = inventory[i]
        if s.valid_for_read and s.name == name and s.quality.name == quality then n = n + s.count end
    end
    return n
end
function inventory.is_empty()
    for i = 1, SLOTS do if inventory[i].valid_for_read then return false end end
    return true
end
function inventory.set_bar() end
function inventory.count_empty_stacks()
    local n = 0
    for i = 1, SLOTS do if not inventory[i].valid_for_read then n = n + 1 end end
    return n
end
function inventory.get_contents()
    local list, index = {}, {}
    for i = 1, SLOTS do
        local s = inventory[i]
        if s.valid_for_read then
            local key = s.name .. "/" .. s.quality.name
            if not index[key] then
                index[key] = {name = s.name, quality = s.quality.name, count = 0}
                list[#list + 1] = index[key]
            end
            index[key].count = index[key].count + s.count
        end
    end
    return list
end
function inventory.remove(item)
    local left = item.count
    for i = SLOTS, 1, -1 do
        local s = inventory[i]
        if left > 0 and s.valid_for_read and s.name == item.name and s.quality.name == item.quality then
            local n = math.min(left, s.count)
            s.count = s.count - n
            left = left - n
            if s.count == 0 then s.clear() end
        end
    end
    return item.count - left
end
function inventory.insert(item)
    for i = 1, SLOTS do
        local s = inventory[i]
        if s.valid_for_read and s.name == item.name and s.quality.name == item.quality then
            s.count = s.count + item.count
            return item.count
        end
    end
    for i = 1, SLOTS do
        local s = inventory[i]
        if not s.valid_for_read then
            s.valid_for_read, s.name, s.quality, s.count = true, item.name, Q[item.quality], item.count
            return item.count
        end
    end
    return 0
end

function inventory.can_insert(item)
    for i = 1, SLOTS do
        local s = inventory[i]
        if not s.valid_for_read or (s.name == item.name and s.quality.name == item.quality) then return true end
    end
    return false
end

local spilled = {}
local entity = {
    valid = true, name = "ic-control-post", unit_number = 7, position = {x = 0.5, y = 0.5},
    force = {index = 1, players = {}},
    surface = {index = 1, name = "nauvis",
        spill_item_stack = function(args) spilled[#spilled + 1] = args.stack end},
}
entity.get_inventory = function() return inventory end
local targets = {}
local function chest()
    local target = {valid = true, type = "container", stored = 0, received = {}}
    function target.can_insert() return true end
    function target.insert(item)
        target.stored = target.stored + item.count
        target.received[#target.received + 1] = {quality = type(item.quality) == "table" and item.quality.name or item.quality,
            count = item.count}
        return item.count
    end
    return target
end
for d = 0, 3 do targets[d] = chest() end
entity.surface.find_entities_filtered = function(filter)
    local area = filter.area
    local x, y = (area[1][1] + area[2][1]) / 2 - 0.5, (area[1][2] + area[2][2]) / 2 - 0.5
    return {targets[y < -1 and 0 or x > 1 and 1 or y > 1 and 2 or 3]}
end

local record = post.track(entity)
post.set_order(record, {item = "gear", quality = "rare", required = 2})
assert(record.order.rank == 3 and post.export_settings(record).order.quality == "rare", "blueprints keep the target")
post.start(record)

-- 12 standard gears: one operation per PROCESS_TICKS; a sure step up from standard (chance 1).
fill({{"gear", "normal", 12}})
local always_up = sequence({0, 0.9, 0, 0.9, 0, 0.9, 0, 0.9})
post.step(record, 10, always_up)
assert(count("gear", "normal") == 7 and count("gear", "uncommon") == 1, "5 standard -> 1 uncommon")
assert(record.processed.operations == 1 and record.processed.used == 5 and record.processed.raised == 1)
assert(record.waiting_process == 12 and record.next_tick == 10 + rules.PROCESS_TICKS)
post.step(record, 11, always_up)
assert(record.processed.operations == 1, "no second operation before PROCESS_TICKS")
post.step(record, 25, always_up)
assert(count("gear", "normal") == 2 and count("gear", "uncommon") == 2)
-- Not enough copies of any quality and free slots: wait for more, like an empty post.
post.step(record, 40, always_up)
assert(record.processed.operations == 2 and record.next_tick == 40 + post.EMPTY_LOOK)

-- Accepted copies go forward and count; the result of an operation is routed on a later look.
fill({{"gear", "uncommon", 5}, {"gear", "rare", 1}})
post.step(record, 100, always_up)
assert(targets[0].stored == 1 and record.accepted == 1 and count("gear", "rare") == 1)
post.step(record, 200, always_up)
assert(targets[0].stored == 2 and record.state == "done", "order complete")

-- After completion leftovers stay inside and nothing is processed; the only output is forward.
fill({{"gear", "normal", 3}})
post.step(record, 300, always_up)
assert(count("gear", "normal") == 3 and targets[1].stored == 0 and targets[3].stored == 0)
assert(record.next_tick == nil, "a finished post without circuit control sleeps")

-- Every slot full of standard copies (inserters filled the post): the uncommon result has no slot, so nothing
-- is taken, nothing is dropped and the window names the missing tier.
post.set_order(record, {item = "gear", quality = "epic", required = 10})
post.start(record)
local full = {}
for i = 1, SLOTS do full[i] = {"gear", "normal", 50} end
fill(full)
post.step(record, 400, always_up)
assert(count("gear", "normal") == 50 * SLOTS and record.no_room == "uncommon" and #spilled == 0, "waits, drops nothing")
assert(record.processed.operations == 3)
-- A free slot appears: the operation runs.
inventory[SLOTS].clear()
post.step(record, 420, always_up)
assert(count("gear", "uncommon") == 1 and record.no_room == nil and record.processed.operations == 4)
fill({{"gear", "normal", 5}})
post.step(record, 440, sequence({0.999}))
assert(count("gear", "uncommon") == 1 and record.processed.raised == 5 and record.processed.operations == 5)

-- Items it does not take: such an order does not start.
post.set_order(record, {item = "fish", quality = "rare", required = 10})
assert(not post.start(record) and record.state == "idle", "spoiling items are not processed")
assert(post.is_processable("gear") and not post.is_processable("fish") and not post.is_processable("box"))
-- Strays (another item, defects) stay inside, are counted and block nothing.
post.set_order(record, {item = "gear", quality = "rare", required = 10})
post.start(record)
local before = targets[0].stored
fill({{"fish", "normal", 6}, {"gear", "ic-defect-3", 2}, {"gear", "rare", 1}})
post.step(record, 500, always_up)
assert(record.stray == 8 and count("fish", "normal") == 6 and count("gear", "ic-defect-3") == 2)
assert(targets[0].stored == before + 1 and record.processed.operations == 5)
-- Orders of the routing post: "at least X" becomes "up to X", "strictly standard" an empty order.
record.order = {item = "gear", condition = "at-least", quality = "rare", required = 7, repeating = false, rank = 3}
post.migrate(record)
assert(record.order.condition == nil and record.order.item == "gear" and record.order.quality == "rare")
record.order = {item = "gear", condition = "strict", quality = "normal", required = 7, repeating = false, rank = 0}
record.sent = {good = 4, refine = 2, other = 1}
post.migrate(record)
assert(record.order.item == nil and record.state == "idle" and record.sent.good == 4 and record.sent.refine == nil)
post.apply_settings(record, {order = {item = "gear", condition = "strict", quality = "normal"}})
assert(record.order.item == nil, "an old strict blueprint gives an empty order")

-- Paused: nothing is processed.
post.set_order(record, {item = "gear", quality = "rare", required = 10})
post.start(record)
post.pause(record)
fill({{"gear", "normal", 5}})
post.step(record, 600, always_up)
assert(count("gear", "normal") == 5 and record.processed.operations == 5)
assert(#spilled == 0)

-- Payment: with the small alien artifact in the game, one artifact pays for the operations of the map setting
-- (4 by default); without it the post waits and takes nothing.
local A = "bob-small-alien-artifact"
prototypes.item[A] = {type = "item", stack_size = 500, get_spoil_ticks = function() return 0 end}
settings = nil
assert(post.operations_per_material() == 4, "default without settings")
settings = {global = {[post.OPERATIONS_SETTING] = {value = 4}}}
post.set_order(record, {item = "gear", quality = "rare", required = 100})
post.start(record)
record.charge = 0
local ops = record.processed.operations
fill({{"gear", "normal", 25}})
post.step(record, 1000, always_up)
assert(record.no_material and record.processed.operations == ops and count("gear", "normal") == 25, "no artifact, no work")
fill({{"gear", "normal", 25}, {A, "normal", 2}})
for i = 0, 3 do post.step(record, 1100 + 15 * i, always_up) end
assert(record.processed.operations == ops + 4 and count(A, "normal") == 1 and record.charge == 0, "4 operations per artifact")
assert(record.stray == 0 and record.processed.material == 1, "the artifact is payment, not a stray")
post.step(record, 1160, always_up)
assert(count(A, "normal") == 0 and record.charge == 3 and record.processed.material == 2)
local stock, charge = post.material_stock(record, inventory)
assert(stock == 0 and charge == 3)
settings.global[post.OPERATIONS_SETTING].value = 1
record.charge = 0
post.step(record, 1200, always_up)
assert(record.no_material, "setting 1: every operation needs an artifact")
-- Layout: the last slot of the input row takes the artifact.
local with_material = post.layout({item = "gear", quality = "epic"}, 20)
assert(with_material[post.INPUT_SLOTS].name == A and with_material[post.INPUT_SLOTS - 1].name == "gear")
prototypes.item[A] = nil
settings = nil

-- Slot layout: input row of standard copies, one slot per tier below the goal, the rest for the goal and
-- better; a comparator filter the engine refuses falls back to the item name; no order clears them.
local filters = {}
inventory.supports_filters = function() return true end
inventory.set_filter = function(index, filter)
    if type(filter) == "table" and refuse_comparator then error("comparator refused") end
    filters[index] = filter
    return true
end
post.INPUT_SLOTS = 3
post.set_order(record, {item = "gear", quality = "epic"})
assert(filters[1].quality == "normal" and filters[1].comparator == "=" and filters[3].quality == "normal")
assert(filters[4].quality == "uncommon" and filters[4].comparator == "=" and filters[5].quality == "rare")
assert(filters[6].quality == "epic" and filters[6].comparator == ">=" and filters[SLOTS].quality == "epic")
assert(record.layout_pending == nil)
-- A slot that refuses its filter (copies of another quality inside) is set again later.
inventory.set_filter = function(index, filter) filters[index] = filter return index ~= 4 end
post.set_order(record, {item = "gear", quality = "epic"})
assert(record.layout_pending)
inventory.set_filter = function(index, filter) filters[index] = filter return true end
post.step(record, 700, always_up)
assert(record.layout_pending == nil)
refuse_comparator = true
inventory.set_filter = function(index, filter)
    if type(filter) == "table" then error("comparator refused") end
    filters[index] = filter
    return true
end
post.set_order(record, {item = "gear"})
assert(filters[1] == "gear" and filters[SLOTS] == "gear")
post.set_order(record, {item = false})
assert(filters[1] == nil and filters[SLOTS] == nil)
-- Items with a stack smaller than one operation are not taken.
prototypes.item.anchor = {type = "item", stack_size = 1, get_spoil_ticks = function() return 0 end}
assert(not post.is_processable("anchor"))

print("PASS: post-processing chance (6 x next probability, capped), outcome and costs, 5 -> 1 operations")
print("one per PROCESS_TICKS, waiting for copies, accepted copies counted, leftovers stay after completion,")
print("no slot for the result: waits and drops nothing, strays counted, items it does not take refused, old orders converted,")
print("pause, settings, slot layout per tier with fallback and retry, small stacks refused,")
print("payment by small alien artifacts per the map setting, waits without them.")
print("Mocks only.")
