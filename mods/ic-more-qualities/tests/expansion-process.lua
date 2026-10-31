-- Post-processing of the control post on mocks: chance and outcome rules, 5 -> 1 operations, the
-- fallback of a full post, completion, items it does not take, settings and timing. Not Factorio.
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

-- Routing: below the order stays ("process"), the order quality and better is accepted, defects go left,
-- items it does not take go right, nothing stays once the order is complete.
local order = {item = "gear", condition = "process", rank = 3}
local info = function(name) return {grade = name:find("ic%-defect") and -3 or 0, rank = Q[name].level, normal = name == "normal"} end
assert(rules.route(order, "gear", info("uncommon"), 5, true, true) == "process")
assert(rules.route(order, "gear", info("rare"), 5, true, true) == "good")
assert(rules.route(order, "gear", info("ic-defect-3"), 5, true, true) == "refine")
assert(rules.route(order, "gear", info("normal"), 5, true, false) == "other")
assert(rules.route(order, "gear", info("normal"), 0, true, true) == "other")
assert(rules.route(order, "plate", info("normal"), 5, true, true) == "other")

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
post.set_order(record, {item = "gear", condition = "process", quality = "rare", required = 2})
assert(record.order.condition == "process" and record.order.rank == 3)
assert(post.export_settings(record).order.condition == "process", "blueprints keep the mode")
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

-- After completion the copies below the order are not kept: they go right.
fill({{"gear", "normal", 3}})
post.step(record, 300, always_up)
assert(targets[1].stored == 3 and count("gear", "normal") == 0)

-- A full post with single copies of different qualities: the 5 lowest are taken, the result starts
-- from the worst of them.
post.set_order(record, {item = "gear", condition = "process", quality = "epic", required = 10})
post.start(record)
fill({{"gear", "normal", 2}, {"gear", "uncommon", 2}, {"gear", "rare", 1}, {"gear", "normal", 1},
    {"gear", "uncommon", 1}, {"gear", "rare", 1}, {"gear", "rare", 1}, {"gear", "rare", 1}})
-- The chance from standard is 1, so the result is uncommon.
post.step(record, 400, sequence({0.999}))
assert(count("gear", "normal") == 0 and count("gear", "uncommon") == 2 and count("gear", "rare") == 4,
    "3 standard + 2 uncommon -> 1 uncommon")
assert(record.processed.raised == 4 and record.processed.operations == 4)

-- Items it does not take: below the order they go right; a different item always goes right.
post.set_order(record, {item = "fish", condition = "process", quality = "rare", required = 10})
post.start(record)
local before = targets[1].stored
fill({{"fish", "normal", 6}, {"gear", "normal", 1}})
post.step(record, 500, always_up)
assert(targets[1].stored == before + 7 and record.processed.operations == 4, "spoiling items are not processed")
assert(post.is_processable("gear") and not post.is_processable("fish") and not post.is_processable("box"))

-- Paused: nothing is processed.
post.set_order(record, {item = "gear", condition = "process", quality = "rare", required = 10})
post.start(record)
post.pause(record)
fill({{"gear", "normal", 5}})
post.step(record, 600, always_up)
assert(count("gear", "normal") == 5 and record.processed.operations == 4)
assert(#spilled == 0)

print("PASS: post-processing chance (6 x next probability, capped) and outcome, routing, 5 -> 1 operations")
print("one per PROCESS_TICKS, waiting for copies, accepted copies counted, completion sends the rest right,")
print("full post takes the 5 lowest, items with spoil timers or inventories are not taken, pause, settings.")
print("Mocks only.")
