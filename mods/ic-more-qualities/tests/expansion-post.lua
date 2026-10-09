-- Control post on mocks: order validation, routing to three outputs, counting, completion,
-- repeat, blocked outputs, belt lane choice, rotation and exported settings. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
storage = {}
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
entity.surface.find_entities_filtered = function(filter)
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
targets[0], targets[3], targets[1] = chest(100), chest(100), chest(100)
slots = {stack("gear", "normal", 3), stack("gear", "ic-defect-3", 2), stack("plate", "normal", 4),
    stack("gear", "rare", 1), stack("gear", "normal", 4)}
post.step(record, 1)
assert(bar == "none", "active order opens the inventory")
assert(targets[0].stored == 5 and record.accepted == 5 and record.batches == 1, "5 accepted -> batch done")
assert(record.state == "done")
assert(targets[3].stored == 3, "2 defects + 1 rare (strict) to refinement")
assert(targets[1].stored == 4 and slots[5].count == 2, "plates out; the surplus waits for the next step")
post.step(record, 2)
assert(bar == 1, "a finished order closes the inventory")
assert(targets[1].stored == 6, "2 surplus gears beyond the order go to other")

-- Repeat: counting restarts after each batch.
post.set_order(record, {repeating = true, required = 2})
post.start(record)
slots = {stack("gear", "normal", 5)}
targets[0] = chest(100)
post.step(record, 3)
assert(record.batches == 2 and record.accepted == 0 and slots[1].count == 3, "batch of 2, surplus waits")
post.step(record, 3)
post.step(record, 3)
assert(record.state == "active" and record.batches == 3 and record.accepted == 1 and targets[0].stored == 5)

-- "At least rare": uncommon goes to other, rare and better to accepted, defects to refinement.
post.set_order(record, {condition = "at-least", quality = "rare", required = 10, repeating = false})
post.start(record)
targets[0], targets[3], targets[1] = chest(100), chest(100), chest(100)
slots = {stack("gear", "uncommon", 1), stack("gear", "rare", 2), stack("gear", "ic-defect-3", 1), stack("gear", "normal", 1)}
post.step(record, 4)
assert(targets[0].stored == 2 and targets[3].stored == 1 and targets[1].stored == 2 and record.accepted == 2)

-- Blocked refinement output: the post waits on that output only and reports the waiting count.
targets[3] = chest(0)
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
targets[1] = belt
slots = {stack("plate", "normal", 3)}
post.step(record, 6)
assert(#inserted == 1 and slots[1].count == 2)
-- East-moving belt north of nothing: the post is west of it -> output east -> far lane is the right lane.
assert(inserted[1].lane == defines.transport_line.right_line and inserted[1].item.count == 1)

-- Rotation moves all three outputs; the picture is not touched (arrows are redrawn).
local before = drawn
post.rotate(record, 1)
assert(record.facing == 1 and drawn == before + 3)
targets[1], targets[0], targets[2] = chest(100), chest(100), chest(100)
slots = {stack("gear", "rare", 1), stack("gear", "ic-defect-3", 1), stack("plate", "normal", 1)}
post.step(record, 7)
assert(targets[1].stored == 1 and targets[0].stored == 1 and targets[2].stored == 1, "forward east, left north, right south")

-- Exported settings restore order, facing and circuit flag.
local settings = post.export_settings(record)
assert(settings.facing == 1 and settings.order.item == "gear" and settings.order.condition == "at-least")
assert(len(settings.order) == 5)
print("PASS: order validation, strict / at-least routing, counting with surplus to other, batch")
print("completion and repeat, closed inventory when not active, blocked output waits alone, belt")
print("far lane one item per tick, rotation of outputs, exported settings. Mocks only.")
