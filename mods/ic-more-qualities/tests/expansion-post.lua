-- Control post on mocks: order validation, routing to three outputs, counting, completion,
-- repeat, blocked outputs, belt lane choice, rotation and exported settings. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
storage = {}
game = {tick = 0}
script = {register_on_object_destroyed = function() end}
local drawn = 0
rendering = {
    draw_sprite = function() drawn = drawn + 1; return {id = drawn} end,
    get_object_by_id = function() return nil end,
}
local quality_levels = {normal = 0, uncommon = 2, rare = 3, ["ic-defect-3"] = 0}
prototypes = {item = {gear = {}, plate = {}}, quality = {}}
for name, level in pairs(quality_levels) do prototypes.quality[name] = {name = name, level = level} end
local post = require("scripts.expansion.post")

local function stack(name, quality, count)
    local s = {valid_for_read = true, name = name, count = count, health = 1, is_tool = false, is_ammo = false,
        quality = prototypes.quality[quality]}
    function s.clear() s.valid_for_read, s.count = false, 0 end
    return s
end
local function chest(capacity)
    local target = {valid = true, type = "container", stored = 0, capacity = capacity, received = {}}
    function target.can_insert() return target.stored < target.capacity end
    function target.insert(item)
        local n = math.min(item.count, target.capacity - target.stored)
        target.stored = target.stored + n
        target.received[#target.received + 1] = {name = item.name, quality = type(item.quality) == "table" and item.quality.name or item.quality, count = n}
        return n
    end
    return target
end

local slots = {}
local bar = "none"
local entity = {
    valid = true, name = "ic-control-post", unit_number = 3, position = {x = 0.5, y = 0.5},
    force = {index = 1, players = {}}, surface = {index = 1, name = "nauvis"},
}
local targets = {}
-- Building over an output removes the old building there (it becomes invalid, as in the game).
local function place(direction, target)
    if targets[direction] then targets[direction].valid = false end
    targets[direction] = target
end
local searches = 0
entity.surface.find_entities_filtered = function(filter)
    searches = searches + 1
    local area = filter.area
    local x, y = (area[1][1] + area[2][1]) / 2 - 0.5, (area[1][2] + area[2][2]) / 2 - 0.5
    local direction = y < -1 and 0 or x > 1 and 1 or y > 1 and 2 or 3
    return {targets[direction]}
end
-- Plain array view (in Factorio LuaInventory is userdata with a length operator).
entity.get_inventory = function()
    local view = {
        set_bar = function(value) bar = value or "none" end,
        is_empty = function()
            for _, s in ipairs(slots) do if s.valid_for_read then return false end end
            return true
        end,
    }
    for index, s in ipairs(slots) do view[index] = s end
    return view
end
local function len(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end

local record = post.track(entity)
assert(record and record.facing == 0 and drawn == 3, "three arrows")
-- Validation: unknown item rejected, defect quality not allowed as requirement, amount clamped.
post.set_order(record, {item = "nonexistent", required = -5, quality = "ic-defect-3", condition = "?"})
assert(record.order.item == nil and record.order.required == 1 and record.order.quality == "normal")
assert(record.order.condition == "strict")
assert(not post.start(record), "no item, no start")
post.set_order(record, {item = "gear", required = 5, condition = "strict"})
assert(post.start(record) and record.state == "active")

-- Facing north: forward (good) = north, left (refine) = west, right (other) = east.
place(0, chest(100)) place(3, chest(100)) place(1, chest(100))
slots = {stack("gear", "normal", 3), stack("gear", "ic-defect-3", 2), stack("plate", "normal", 4),
    stack("gear", "rare", 1), stack("gear", "normal", 4)}
post.step(record, 1)
assert(bar == "none", "active order opens the inventory")
assert(targets[0].stored == 5 and record.accepted == 5 and record.batches == 1, "5 accepted -> batch done")
assert(record.state == "done")
assert(targets[3].stored == 3, "2 defects + 1 rare (strict) to refinement")
assert(targets[1].stored == 4 and slots[5].count == 2, "plates out; the surplus waits for the next step")
local before_searches = searches
post.step(record, 2)
assert(bar == 1, "a finished order closes the inventory")
assert(targets[1].stored == 6, "2 surplus gears beyond the order go to other")
assert(searches == before_searches, "a found output target is reused")

-- Repeat: counting restarts after each batch.
post.set_order(record, {repeating = true, required = 2})
post.start(record)
slots = {stack("gear", "normal", 5)}
place(0, chest(100))
post.step(record, 3)
assert(record.batches == 2 and record.accepted == 0 and slots[1].count == 3, "batch of 2, surplus waits")
post.step(record, 3)
post.step(record, 3)
assert(record.state == "active" and record.batches == 3 and record.accepted == 1 and targets[0].stored == 5)

-- "At least rare": uncommon goes to other, rare and better to accepted, defects to refinement.
post.set_order(record, {condition = "at-least", quality = "rare", required = 10, repeating = false})
post.start(record)
place(0, chest(100)) place(3, chest(100)) place(1, chest(100))
slots = {stack("gear", "uncommon", 1), stack("gear", "rare", 2), stack("gear", "ic-defect-3", 1), stack("gear", "normal", 1)}
post.step(record, 4)
assert(targets[0].stored == 2 and targets[3].stored == 1 and targets[1].stored == 2 and record.accepted == 2)

-- Blocked refinement output: the post waits on that output only and reports the waiting count.
place(3, chest(0))
slots = {stack("gear", "ic-defect-3", 4), stack("gear", "rare", 1)}
post.step(record, 5)
assert(record.waiting_refine == 4 and slots[1].count == 4 and record.accepted == 3)
assert(record.blocked[3] and not record.blocked[0])

-- Belts: one item per tick on the far lane, like an inserter.
local inserted = {}
local belt = {valid = true, type = "transport-belt", direction = defines.direction.east}
belt.get_transport_line = function(lane)
    return {can_insert_at_back = function() return true end,
        insert_at_back = function(item) inserted[#inserted + 1] = {lane = lane, item = item}; return true end}
end
place(1, belt)
slots = {stack("plate", "normal", 3)}
post.step(record, 6)
assert(#inserted == 1 and slots[1].count == 2)
-- East-moving belt north of nothing: the post is west of it -> output east -> far lane is the right lane.
assert(inserted[1].lane == defines.transport_line.right_line and inserted[1].item.count == 1)

-- Rotation moves all three outputs; the picture is not touched (arrows are redrawn).
local before = drawn
post.rotate(record, 1)
assert(record.facing == 1 and drawn == before + 3)
place(1, chest(100)) place(0, chest(100)) place(2, chest(100))
slots = {stack("gear", "rare", 1), stack("gear", "ic-defect-3", 1), stack("plate", "normal", 1)}
post.step(record, 7)
assert(targets[1].stored == 1 and targets[0].stored == 1 and targets[2].stored == 1, "forward east, left north, right south")

-- No building in front of an output: searched again only after TARGET_RETRY ticks.
place(2, nil)
slots = {stack("plate", "normal", 1)}
post.step(record, 8)
before_searches = searches
post.step(record, 9)
assert(searches == before_searches and slots[1].count == 1, "a missing target is not searched every tick")
place(2, chest(100))
post.step(record, 8 + post.TARGET_RETRY)
assert(targets[2].stored == 1, "a new building is found after the retry delay")
-- An active post without items looks again after EMPTY_LOOK ticks, a busy one every tick.
assert(record.state == "active" and record.next_tick == 8 + post.TARGET_RETRY + post.EMPTY_LOOK)

-- Items inside, but no output takes anything: a short pause instead of a look every tick.
place(2, chest(0))
slots = {stack("plate", "normal", 3)}
post.step(record, 500)
assert(slots[1].count == 3 and record.next_tick == 500 + post.BLOCKED_LOOK, "blocked: " .. record.next_tick)
place(2, chest(100))
slots = {}

-- Looks come from the timer wheel (scripts/wheel.lua): nothing is walked before the due tick; start, pause
-- and cancel bring the look forward to the next tick.
local s = storage.ic_posts
local wheel = require("scripts.wheel")
local calls, original_step = 0, post.step
post.step = function(r, tick) calls = calls + 1; r.next_tick = tick + 7 end
s.buckets = {}
wheel.add(s.buckets, record, 900)
post.on_tick(899)
assert(calls == 0)
post.on_tick(900)
assert(calls == 1 and record.due == 907 and s.buckets[907] and s.buckets[900] == nil)
game.tick = 901
post.cancel(record)
assert(record.due == 902 and s.buckets[902][1] == record.id)
post.on_tick(902)
post.on_tick(907) -- the stale entry of the earlier schedule is skipped
assert(calls == 2 and record.due == 909)
post.step = original_step
-- An older storage without buckets: every post is scheduled on the next tick.
s.buckets = nil
game.tick = 1000
assert(post.state().buckets[1001][1] == record.id)

-- Exported settings restore order, facing and circuit flag.
local settings = post.export_settings(record)
assert(settings.facing == 1 and settings.order.item == "gear" and settings.order.condition == "at-least")
assert(len(settings.order) == 5)
print("PASS: order validation, strict / at-least routing, counting with surplus to other, batch")
print("completion and repeat, closed inventory when not active, blocked output waits alone, belt")
print("far lane one item per tick, blocked outputs back off, timer wheel, rotation of outputs, exported settings.")
print("Mocks only.")
