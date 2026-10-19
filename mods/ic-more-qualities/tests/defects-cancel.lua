-- Cancelled handcraft: a prerequisite crafted without a roll gets it when a cancel returns it.
-- Pure Lua mocks, no engine: event timing and the real inventory are not verified.
local directory = assert(arg[0]:match("^(.*[/\\])"))
local root = directory .. "../"
package.path = root .. "?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local cancel = require("scripts.defects.cancel")

local finished = {["stone-furnace"] = true, ["burner-mining-drill"] = true, ["small-pump"] = true,
    ["automation-science-pack"] = true, ["modular-armor"] = true, ["car"] = true}
local no_defect = {["small-pump"] = true, ["car"] = true}
local kinds = {["automation-science-pack"] = "tool", ["modular-armor"] = "armor", car = "item-with-entity-data"}

local function make_stack(payload)
    local stack = {}
    local methods = {}
    local function get(key)
        local p = rawget(stack, "_p")
        if key == "valid_for_read" then return p ~= nil end
        if not p then error("read of an empty stack: " .. key) end
        if key == "quality" then return {name = p.quality or "normal"} end
        if key == "prototype" then return {type = kinds[p.name] or "item",
            get_durability = function(q) return q == "normal" and 30 or 10 end} end
        return p[key]
    end
    methods.set_stack = function(definition)
        local p = {}
        for k, v in pairs(definition) do p[k] = v end
        p.quality = p.quality or "normal"
        rawset(stack, "_p", p)
        return true
    end
    rawset(stack, "_p", payload)
    return setmetatable(stack, {
        __index = function(_, key) return methods[key] or get(key) end,
        __newindex = function(_, key, value)
            assert(key == "count", "only count is written")
            stack._p.count = value
            if value == 0 then rawset(stack, "_p", nil) end
        end,
    })
end

local function make_inventory(size, contents)
    local inventory = {valid = true}
    for index = 1, size do inventory[index] = make_stack(contents[index]) end
    inventory.insert = function(definition)
        for index = 1, size do
            if not inventory[index].valid_for_read then
                inventory[index].set_stack(definition)
                return definition.count
            end
        end
        return 0
    end
    return inventory
end

local function total(inventory, name, quality)
    local sum = 0
    for index = 1, #inventory do
        local stack = inventory[index]
        if stack.valid_for_read and stack.name == name and stack.quality.name == quality then sum = sum + stack.count end
    end
    return sum
end

local function make_player(index, level, inventory, queue_size)
    local technologies = {}
    for i = 1, level do technologies["ic-defect-control-" .. i] = {researched = true} end
    local spilled = {}
    return {index = index, valid = true, character = {}, crafting_queue_size = queue_size or 1,
        force = {technologies = technologies}, position = {x = 0, y = 0}, spilled = spilled,
        surface = {spill_item_stack = function(params) spilled[#spilled + 1] = params.stack end},
        get_main_inventory = function() return inventory end}
end

local function no_rng() error("unexpected defect roll") end

-- 1. Only defect-capable finished products are remembered: materials, raw and exempt items are not.
storage = {}
for _, name in ipairs({"iron-plate", "stone", "iron-gear-wheel", "small-pump", "car", "unknown"}) do
    cancel.remember(1, name, finished, no_defect)
end
assert(storage.ic_cancel == nil or next(storage.ic_cancel.skipped) == nil, "nothing to remember")
cancel.remember(1, "stone-furnace", finished, no_defect)
assert(storage.ic_cancel.skipped[1]["stone-furnace"])

-- 2. Cancel: only standard items of remembered names that can be defective are queued.
-- (A remembered name that later became exempt, e.g. after a mod update, is filtered again.)
storage.ic_cancel.skipped[1]["small-pump"] = true
local returned = make_inventory(7, {
    {name = "stone-furnace", count = 3},
    {name = "stone-furnace", count = 2, quality = "ic-defect-2"},
    {name = "stone-furnace", count = 1, quality = "uncommon"},
    {name = "stone", count = 5},
    {name = "iron-plate", count = 9},
    {name = "small-pump", count = 1},
})
assert(cancel.on_cancelled({player_index = 1, items = returned, tick = 100}, finished, no_defect) == 3)
assert(#storage.ic_cancel.pending == 1 and storage.ic_cancel.pending[1].count == 3)
-- Another player without remembered prerequisites: nothing.
assert(cancel.on_cancelled({player_index = 2, items = returned, tick = 100}, finished, no_defect) == 0)

-- 3. Processed one tick later in the main inventory; one roll per item; other stacks untouched.
local main = make_inventory(8, {
    {name = "stone-furnace", count = 4, health = 0.5},
    {name = "stone", count = 50},
    {name = "stone-furnace", count = 1, quality = "ic-defect-1"},
    {name = "small-pump", count = 2},
})
local player = make_player(1, 0, main, 0)
local players = {player}
local get_player = function(index) return players[index] end
assert(cancel.process(100, get_player, no_rng, finished, no_defect) == 0, "same tick: wait")
assert(#storage.ic_cancel.pending == 1)
-- Rolls: -5 (sample 0), standard (0.999), -5.
local made = cancel.process(101, get_player, mock.sequence({0, 0.9999999, 0}), finished, no_defect)
assert(made == 2 and #storage.ic_cancel.pending == 0)
assert(total(main, "stone-furnace", "normal") == 2)
assert(total(main, "stone-furnace", "ic-defect-5") == 2)
assert(total(main, "stone-furnace", "ic-defect-1") == 1, "an existing defect is kept")
assert(total(main, "stone", "normal") == 50 and total(main, "small-pump", "normal") == 2)
for index = 1, #main do
    local stack = main[index]
    if stack.valid_for_read and stack.quality.name == "ic-defect-5" then mock.near(stack.health, 0.5) end
end
assert(storage.ic_cancel.skipped[1] == nil, "queue empty after the cancel: forgotten")

-- 4. Not remembered any more: a later cancel returns items unchanged.
assert(cancel.on_cancelled({player_index = 1, items = returned, tick = 200}, finished, no_defect) == 0)

-- 5. Control level 10: no roll at all.
cancel.remember(1, "stone-furnace", finished, no_defect)
cancel.on_cancelled({player_index = 1, items = returned, tick = 300}, finished, no_defect)
local main10 = make_inventory(2, {{name = "stone-furnace", count = 3}})
players[1] = make_player(1, 10, main10, 1)
assert(cancel.process(301, get_player, no_rng, finished, no_defect) == 0)
assert(total(main10, "stone-furnace", "normal") == 3 and storage.ic_cancel.skipped[1], "queue not empty: kept")

-- 6. Whole stack converted in place (full inventory); a partial one spills what does not fit.
local full = make_inventory(1, {{name = "stone-furnace", count = 1}})
players[1] = make_player(1, 0, full, 1)
storage.ic_cancel.pending = {{player = 1, name = "stone-furnace", count = 1, tick = 1}}
assert(cancel.process(2, get_player, function() return 0 end, finished, no_defect) == 1)
assert(total(full, "stone-furnace", "ic-defect-5") == 1)
local partial = make_inventory(1, {{name = "stone-furnace", count = 5}})
players[1] = make_player(1, 0, partial, 1)
storage.ic_cancel.pending = {{player = 1, name = "stone-furnace", count = 2, tick = 1}}
assert(cancel.process(2, get_player, function() return 0 end, finished, no_defect) == 2)
assert(total(partial, "stone-furnace", "normal") == 3 and #players[1].spilled == 1)
assert(players[1].spilled[1].quality == "ic-defect-5" and players[1].spilled[1].count == 2)

-- 7. Durability keeps its share; armor with equipment and labelled vehicles are not rebuilt.
cancel.remember(1, "automation-science-pack", finished, no_defect)
local packs = make_inventory(2, {{name = "automation-science-pack", count = 1, durability = 15}})
players[1] = make_player(1, 0, packs, 1)
storage.ic_cancel.pending = {{player = 1, name = "automation-science-pack", count = 1, tick = 1}}
assert(cancel.process(2, get_player, function() return 0 end, finished, no_defect) == 1)
mock.near(packs[1].durability, 5)
local armor = make_inventory(1, {{name = "modular-armor", count = 1, grid = {equipment = {{name = "battery"}}}}})
players[1] = make_player(1, 0, armor, 1)
storage.ic_cancel.pending = {{player = 1, name = "modular-armor", count = 1, tick = 1}}
assert(cancel.process(2, get_player, function() return 0 end, finished, no_defect) == 0)
assert(armor[1].quality.name == "normal")

-- 8. Pending of an exempt or material name (stale entry) is never rolled.
storage.ic_cancel.pending = {{player = 1, name = "iron-plate", count = 3, tick = 1},
    {player = 1, name = "small-pump", count = 1, tick = 1}}
assert(cancel.process(2, get_player, no_rng, finished, no_defect) == 0)

-- 9. Removed player: memory and pending dropped.
storage.ic_cancel.pending = {{player = 1, name = "stone-furnace", count = 1, tick = 1}}
cancel.remove_player(1)
assert(storage.ic_cancel.skipped[1] == nil and #storage.ic_cancel.pending == 0 and not cancel.has_pending())

-- 10. Control wiring: an auto-crafted prerequisite is remembered, cancel queues, on_tick converts.
storage = {}
local callbacks = {}
defines = mock.defines({on_force_created = 1, on_force_reset = 2, on_player_crafted_item = 3, on_tick = 4,
    on_player_cancelled_crafting = 5, on_pre_player_crafted_item = 6})
script = {on_init = function() end, on_configuration_changed = function() end,
    on_event = function(id, fn) callbacks[id] = fn end}
settings = {startup = {["ic-more-qualities-defects-preview"] = {value = true}},
    global = {["ic-more-qualities-loss-exclude-finished"] = {value = true},
        ["ic-more-qualities-initial-loss-percent"] = {value = 0}}}
prototypes = {entity = {}, recipe = {
        ["burner-mining-drill"] = {ingredients = {{type = "item", name = "stone-furnace", amount = 1}}}},
    mod_data = {["ic-defects-classification"] = {data = {finished = finished, no_defect = no_defect}}}}
local wired_main = make_inventory(4, {})
local wired = make_player(1, 0, wired_main, 2)
wired.crafting_queue = {{recipe = "stone-furnace", count = 1, prerequisite = true},
    {recipe = "burner-mining-drill", count = 1}}
game = {get_player = function() return wired end, tick = 0}
dofile(root .. "control.lua")
local furnace = make_stack({name = "stone-furnace", count = 1})
callbacks[3]({player_index = 1, item_stack = furnace, recipe = {name = "stone-furnace"}})
assert(furnace.quality.name == "normal", "prerequisite: no roll at craft")
assert(storage.ic_cancel.skipped[1]["stone-furnace"])
wired_main.insert({name = "stone-furnace", count = 1})
local back = make_inventory(2, {{name = "stone-furnace", count = 1}, {name = "stone", count = 3}})
callbacks[5]({player_index = 1, items = back, recipe = {name = "burner-mining-drill"}, cancel_count = 1, tick = 11})
wired.crafting_queue, wired.crafting_queue_size = {}, 0
local original_random = math.random
math.random = function() return 0 end
callbacks[4]({tick = 11})
assert(total(wired_main, "stone-furnace", "normal") == 1, "same tick: not yet")
callbacks[4]({tick = 12})
math.random = original_random
assert(total(wired_main, "stone-furnace", "ic-defect-5") == 1 and not cancel.has_pending())
assert(storage.ic_cancel.skipped[1] == nil)
-- Queueing with an empty queue forgets stale memory.
storage.ic_cancel.skipped[1] = {["stone-furnace"] = true}
callbacks[6]({player_index = 1})
assert(storage.ic_cancel.skipped[1] == nil)

print("PASS: cancelled prerequisites roll one defect per returned standard item one tick later;")
print("materials, raw, exempt, defective/positive returned items and level 10 untouched; forget on empty queue;")
print("durability share, protected grids, in-place/spill conversion; control wiring of the 4 events.")
print("Mocks only: NOT engine event timing, real inventories, multiplayer or the crafting queue.")
