-- Control post (since 2026-10-31 only post-processing): accepts the order item, upgrades copies below the
-- ordered quality by itself and puts accepted copies (the ordered quality or better) out of its one output
-- in front of it, like an inserter, until the ordered quantity is reached.
--   Post-processing: every 5 copies of one quality become one copy rolled by rules.process_outcome.
--   Slots are filtered to the order item (standard or better), so other items and, if the engine compares
--   defects that way, defects cannot be put in. What still gets in (an older save, a changed order) stays
--   inside until a player takes it; the window warns about it. Leftovers below the order stay as well.
-- Only the output arrow rotates; the picture of the building stays.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local emitter = require("scripts.expansion.emitter")
local stats = require("scripts.stats")
local wheel = require("scripts.wheel")

local M = {}
local S = names.signals
M.routes = {"good"}
M.TARGET_TTL = 300  -- a found output target is trusted this long (a building moved by a script)
M.TARGET_RETRY = 30 -- no target in front of the output: search again after this many ticks
M.EMPTY_LOOK = 10   -- an active post without work looks for new items this often
M.BLOCKED_LOOK = 4  -- accepted items inside but the output took nothing: look again after this many ticks
M.IDLE_LOOK = 15    -- an idle or paused post with circuit control (a start command may come)
-- An idle, paused or finished post without circuit control sleeps: it is not looked at until start, pause,
-- cancel, a new order or new settings wake it.

local belt_types = {
    ["transport-belt"] = true, ["underground-belt"] = true, splitter = true,
    loader = true, ["loader-1x1"] = true, ["linked-belt"] = true, ["lane-splitter"] = true,
}
M.target_types = {
    "transport-belt", "underground-belt", "splitter", "loader", "loader-1x1", "linked-belt",
    "container", "logistic-container", "infinity-container", "linked-container", "cargo-wagon",
    "assembling-machine", "furnace", "lab", "car", "spider-vehicle", "roboport", "ammo-turret",
}

-- buckets: timer wheel of the looks (scripts/wheel.lua); record.next_tick is the tick of the next look.
function M.state()
    local s = storage.ic_posts
    if not s then
        s = {records = {}, buckets = {}}
        storage.ic_posts = s
    elseif not s.buckets then
        -- Older layout (every record walked every tick): every post is looked at on the next tick.
        s.buckets = {}
        for _, record in pairs(s.records) do wheel.add(s.buckets, record, game.tick + 1) end
    end
    return s
end

-- Brings the next look of a post forward to the next tick (order or settings changed).
function M.wake(record)
    record.next_tick = game.tick + 1
    local s = M.state()
    if s.records[record.id] == record then wheel.advance(s.buckets, record, record.next_tick) end
end

function M.new_order()
    return {item = nil, quality = "normal", required = 100, repeating = false}
end

function M.get(entity)
    if not (entity and entity.valid and entity.unit_number) then return nil end
    local s = storage.ic_posts
    return s and s.records[entity.unit_number]
end

---------------------------------------------------------------------------------------------------
-- Arrow
---------------------------------------------------------------------------------------------------
local function destroy_arrows(record)
    for _, id in pairs(record.arrows or {}) do
        local object = rendering.get_object_by_id(id)
        if object and object.valid then object.destroy() end
    end
    record.arrows = {}
end

function M.draw_arrows(record)
    destroy_arrows(record)
    local entity = record.entity
    local direction = rules.output_direction(record.facing, "good")
    local vector = rules.direction_vectors[direction]
    local object = rendering.draw_sprite({
        sprite = "ic-post-arrow-good",
        target = {entity = entity, offset = {vector[1] * 1.08, vector[2] * 1.08}},
        surface = entity.surface,
        orientation = direction / 4,
        x_scale = 0.55, y_scale = 0.55,
        render_layer = "higher-object-under",
    })
    if object then record.arrows.good = object.id end
end

function M.rotate(record, step)
    record.facing = (record.facing + step) % 4
    record.blocked = nil
    M.draw_arrows(record)
    M.wake(record)
end

---------------------------------------------------------------------------------------------------
-- Registry and settings
---------------------------------------------------------------------------------------------------
local function quality_rank(name)
    local quality = name and prototypes.quality[name]
    return quality and quality.level or 0
end

-- Items that post-processing cannot take: they carry an inventory, an equipment grid, tags, entity data
-- or a spoil timer (their contents or freshness would be lost or reset when 5 become 1).
local processable = {}
local unprocessable_types = {
    ["item-with-inventory"] = true, ["item-with-tags"] = true, ["item-with-label"] = true,
    ["item-with-entity-data"] = true, blueprint = true, ["blueprint-book"] = true,
    ["deconstruction-item"] = true, ["upgrade-item"] = true, ["selection-tool"] = true,
    ["copy-paste-tool"] = true, ["spidertron-remote"] = true,
}
function M.is_processable(item)
    local result = processable[item]
    if result == nil then
        local prototype = prototypes.item[item]
        result = prototype ~= nil and not unprocessable_types[prototype.type]
            and not (prototype.type == "armor" and prototype.equipment_grid)
            and not (prototype.get_spoil_ticks and prototype.get_spoil_ticks() > 0)
            -- One slot per tier must hold the copies of one operation.
            and (prototype.stack_size or rules.PROCESS_TAKE) >= rules.PROCESS_TAKE
        processable[item] = result
    end
    return result
end

-- Orders of the routing post (before 2026-10-31) and their blueprints: "at least X" becomes "up to X",
-- "strictly standard" has nothing to upgrade to and becomes an empty order.
local function convert_order(order)
    if order.condition == "strict" then
        order.item, order.quality = nil, "normal"
    end
    order.condition = nil
end

-- Slot layout (2026-10-31: with every slot open to standard copies, inserters filled the whole post and the
-- improved copies had no slot): the first INPUT_SLOTS slots take standard copies (the inserter input), then
-- one slot per tier between standard and the goal, the rest take the goal and better (they wait there when
-- the output is blocked). Every slot is filtered, so inserters can put only standard copies into the input row.
M.INPUT_SLOTS = 10

-- Payment (user decision 2026-10-31): the post works only with the small alien artifact; one artifact pays
-- for the number of operations of the map setting (default 4). Its slot is the last one of the input row.
-- Without the item in the game (another mod set) the post works for free.
M.MATERIAL = "bob-small-alien-artifact"
M.OPERATIONS_SETTING = "ic-more-qualities-post-operations-per-material"
M.DEFAULT_OPERATIONS = 4

function M.material()
    return prototypes.item[M.MATERIAL] and M.MATERIAL or nil
end

function M.operations_per_material()
    local setting = settings and settings.global and settings.global[M.OPERATIONS_SETTING]
    local value = setting and tonumber(setting.value)
    return value and value >= 1 and math.floor(value) or M.DEFAULT_OPERATIONS
end

-- Artifacts inside (any quality) and the operations still paid.
function M.material_stock(record, inventory)
    local material = M.material()
    if not material then return nil end
    inventory = inventory or (record.entity.valid and record.entity.get_inventory(defines.inventory.chest))
    local count = 0
    if inventory then
        for _, entry in pairs(inventory.get_contents()) do
            if entry.name == material then count = count + entry.count end
        end
    end
    return count, record.charge or 0
end

local function inventory_of(record)
    local entity = record.entity
    return entity and entity.valid and entity.get_inventory and entity.get_inventory(defines.inventory.chest)
end

-- Qualities from standard by `next`: chain[1] = normal (tier 0).
local chain_cache
local function quality_chain()
    if not chain_cache then
        chain_cache = {}
        local seen, quality = {}, prototypes.quality.normal
        while quality and not seen[quality.name] do
            seen[quality.name] = true
            chain_cache[#chain_cache + 1] = quality
            quality = quality.next
        end
    end
    return chain_cache
end

-- Filter of every slot for an order: {name, quality, comparator} or nil (no order).
function M.layout(order, size)
    local slots = {}
    local item = order.item
    if not item then return slots end
    local chain = quality_chain()
    local target = 0
    for index, quality in ipairs(chain) do
        if quality.name == order.quality then target = index - 1 end
    end
    local input = math.min(M.INPUT_SLOTS, size - 1)
    local middle = math.max(0, math.min(target - 1, size - input - 1))
    local material = M.material()
    for index = 1, size do
        if material and index == input then
            slots[index] = {name = material, quality = "normal", comparator = ">="}
        elseif index <= input then
            slots[index] = {name = item, quality = "normal", comparator = "="}
        elseif index <= input + middle then
            slots[index] = {name = item, quality = chain[index - input + 1].name, comparator = "="}
        else
            slots[index] = {name = item, quality = order.quality, comparator = ">="}
        end
    end
    return slots
end

-- Sets the layout. A slot that holds copies of another quality (an older layout) refuses its filter and is
-- set again on a later look when it is empty (record.layout_pending). A comparator filter that the engine
-- refuses falls back to the item name.
function M.apply_filters(record)
    local inventory = inventory_of(record)
    if not (inventory and inventory.supports_filters and inventory.supports_filters()) then return end
    local slots = M.layout(record.order, #inventory)
    local pending = false
    for index = 1, #inventory do
        local filter = slots[index]
        local ok, set = pcall(inventory.set_filter, index, filter)
        if not ok and filter then ok, set = pcall(inventory.set_filter, index, filter.name) end
        if not ok or set == false then pending = true end
    end
    record.layout_pending = pending or nil
end

function M.set_order(record, order)
    local current = record.order
    for _, key in ipairs({"item", "quality", "required", "repeating"}) do
        if order[key] ~= nil then current[key] = order[key] end
    end
    if order.condition == "strict" then current.item = nil end
    current.condition = nil
    if current.item and not prototypes.item[current.item] then current.item = nil end
    if not prototypes.quality[current.quality or ""] or model.is_defect(current.quality) then current.quality = "normal" end
    current.rank = quality_rank(current.quality)
    current.required = math.max(1, math.min(1000000, math.floor(tonumber(current.required) or 1)))
    current.repeating = current.repeating == true
    -- Changing the order restarts its count; nothing in the post is destroyed.
    record.accepted = 0
    if not M.ready(record) and record.state ~= "idle" then record.state = "idle" end
    M.apply_filters(record)
    M.wake(record)
end

-- An order can run: an item that post-processing takes and a quality above standard.
function M.ready(record)
    local order = record.order
    return order.item ~= nil and (order.rank or 0) > 0 and M.is_processable(order.item)
end

function M.export_settings(record)
    local order = record.order
    return {facing = record.facing, circuit = record.circuit, order = {
        item = order.item, quality = order.quality, required = order.required, repeating = order.repeating}}
end

function M.set_circuit(record, enabled)
    record.circuit = enabled
    if enabled then
        if not (record.emitter and record.emitter.valid) then record.emitter = emitter.create(record.entity) end
    else
        emitter.destroy(record.emitter)
        record.emitter, record.emitted = nil, nil
    end
    M.wake(record)
end

function M.apply_settings(record, settings)
    if type(settings) ~= "table" then return end
    if type(settings.facing) == "number" then record.facing = math.floor(settings.facing) % 4 end
    if type(settings.order) == "table" then M.set_order(record, settings.order) end
    M.set_circuit(record, settings.circuit == true)
    M.draw_arrows(record)
end

local function new_counters()
    return {operations = 0, used = 0, raised = 0}
end

-- Records of the routing post: order converted, counters of the removed outputs dropped.
function M.migrate(record)
    if record.order.condition ~= nil then
        convert_order(record.order)
        record.order.rank = quality_rank(record.order.quality)
        record.accepted = 0
        if not M.ready(record) then record.state = "idle" end
        M.apply_filters(record)
    end
    record.sent = {good = record.sent and record.sent.good or 0}
    record.processed = record.processed or new_counters()
    record.waiting_refine = nil
end

function M.track(entity, settings, facing)
    if not (entity and entity.valid and entity.name == names.post) then return nil end
    local s = M.state()
    local record = s.records[entity.unit_number]
    if record and record.entity.valid then return record end
    record = {
        id = entity.unit_number, entity = entity, facing = facing or 0, order = M.new_order(),
        state = "idle", accepted = 0, batches = 0, sent = {good = 0}, processed = new_counters(),
        circuit = false, next_tick = 0, arrows = {},
        surface_index = entity.surface.index, position = {x = entity.position.x, y = entity.position.y},
    }
    record.order.rank = 0
    s.records[record.id] = record
    wheel.add(s.buckets, record, game.tick + 1)
    script.register_on_object_destroyed(entity)
    M.draw_arrows(record)
    M.apply_settings(record, settings)
    return record
end

function M.forget(id)
    local s = storage.ic_posts
    local record = s and s.records[id]
    if not record then return end
    destroy_arrows(record)
    emitter.destroy(record.emitter)
    s.records[id] = nil
end

function M.rescan()
    local s = M.state()
    for id, record in pairs(s.records) do
        if not record.entity.valid then M.forget(id) end
    end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({name = names.post})) do
            local record = M.track(entity)
            if record then
                M.migrate(record)
                M.apply_filters(record)
                M.draw_arrows(record)
                M.wake(record)
                if record.circuit and not (record.emitter and record.emitter.valid) then
                    record.emitter = emitter.create(entity)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Order control
---------------------------------------------------------------------------------------------------
-- Returns false when the order cannot run (no item, no quality above standard, an item it does not take).
function M.start(record)
    if not M.ready(record) then return false end
    record.accepted = 0
    record.state = "active"
    M.wake(record)
    return true
end

function M.pause(record)
    if record.state == "active" then record.state = "paused"
    elseif record.state == "paused" then record.state = "active" end
    M.wake(record)
end

function M.cancel(record)
    record.state = "idle"
    record.accepted = 0
    M.wake(record)
end

local function notify(record)
    local entity = record.entity
    local players_settings = storage.ic_players or {}
    local position = entity.position
    for _, player in pairs(entity.force.players) do
        local settings = players_settings[player.index]
        if player.connected and not (settings and settings.notify == false) then
            player.print({"ic-quality.order-done", "[item=" .. record.order.item .. "]", record.order.required,
                string.format("[gps=%s,%s,%s]", position.x, position.y, entity.surface.name)})
        end
    end
end

local function accept(record, count, tick)
    record.accepted = record.accepted + count
    stats.add(record.entity.force.index, "order.accepted", count)
    if record.accepted >= record.order.required then
        record.batches = record.batches + 1
        record.done_tick = tick
        stats.add(record.entity.force.index, "order.batches")
        notify(record)
        if record.order.repeating and not record.stop_after then
            record.accepted = 0
        else
            record.state = "done"
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Output
---------------------------------------------------------------------------------------------------
-- Quality view kept per name (prototype data, the same on every peer).
local quality_infos = {}
function M.reset_cache() quality_infos, processable, chain_cache = {}, {}, nil end

function M.quality_info(quality)
    local name = quality.name
    local info = quality_infos[name]
    if not info then
        local grade = model.grade_of(name)
        info = {grade = grade, rank = grade < 0 and -1 or quality.level, normal = name == "normal"}
        quality_infos[name] = info
    end
    return info
end

function M.remaining(record)
    if record.state ~= "active" then return 0 end
    return math.max(0, record.order.required - record.accepted)
end

local function definition(stack, count)
    local result = {name = stack.name, quality = stack.quality.name, count = count, health = stack.health}
    if stack.is_tool then result.durability = stack.durability end
    if stack.is_ammo then result.ammo = stack.ammo end
    return result
end

local function take(stack, count)
    if stack.count > count then stack.count = stack.count - count else stack.clear() end
end

local direction_vectors
-- Like an inserter: the far lane of the belt as seen from the post.
local function belt_lane(belt, outward)
    direction_vectors = direction_vectors or {
        [defines.direction.north] = {0, -1}, [defines.direction.east] = {1, 0},
        [defines.direction.south] = {0, 1}, [defines.direction.west] = {-1, 0},
    }
    local vector = direction_vectors[belt.direction] or {0, -1}
    local left = {vector[2], -vector[1]}
    local dot = outward[1] * left[1] + outward[2] * left[2]
    return dot > 0 and defines.transport_line.left_line or defines.transport_line.right_line
end

-- The target in front of the output is remembered per absolute direction (rotation keeps it valid):
-- a valid one is reused for TARGET_TTL ticks, a missing one is searched again after TARGET_RETRY.
local function find_target(record, direction, tick)
    local vector = rules.direction_vectors[direction]
    local cache = record.targets
    if not cache then
        cache = {}
        record.targets = cache
    end
    local entry = cache[direction]
    if entry and tick and entry.until_tick > tick then
        local target = entry.target
        if not target then return nil end
        if target.valid then return target, vector end
    end
    local entity = record.entity
    local x, y = entity.position.x + vector[1] * 2, entity.position.y + vector[2] * 2
    local found = entity.surface.find_entities_filtered({
        area = {{x - 0.1, y - 0.1}, {x + 0.1, y + 0.1}}, type = M.target_types, force = entity.force,
    })
    local result
    for _, target in pairs(found) do
        if target.valid and target ~= entity then
            result = target
            break
        end
    end
    cache[direction] = {target = result or false,
        until_tick = (tick or 0) + (result and M.TARGET_TTL or M.TARGET_RETRY)}
    if result then return result, vector end
end

-- Moves up to `limit` items of the stack out of the post. Returns the moved count.
local function deliver(record, direction, stack, limit, tick)
    local target, vector = find_target(record, direction, tick)
    if not target then return 0 end
    if belt_types[target.type] then
        local line = target.get_transport_line(belt_lane(target, vector))
        if not (line and line.can_insert_at_back()) then return 0 end
        if line.insert_at_back(definition(stack, 1)) then
            take(stack, 1)
            return 1
        end
        return 0
    end
    local count = math.min(limit, stack.count)
    local item = count >= stack.count and stack or definition(stack, count)
    if not target.can_insert(item) then return 0 end
    local inserted = target.insert(item)
    if inserted > 0 then take(stack, inserted) end
    return inserted
end

-- Walks the slots: accepted copies go out while the order needs them, copies below the order are counted
-- for post-processing, everything else is counted as stray. Returns moved and accepted copies left inside.
local function sort_items(record, inventory, tick)
    local order = record.order
    local direction = rules.output_direction(record.facing, "good")
    local takes = M.is_processable(order.item or "")
    local moved, left, waiting, stray = 0, 0, 0, 0
    local blocked = false
    for index = 1, #inventory do
        local stack = inventory[index]
        if stack.valid_for_read then
            local info = stack.name == order.item and M.quality_info(stack.quality)
            if stack.name == M.MATERIAL then
                -- payment, not a stray
            elseif not info or info.grade < 0 then
                stray = stray + stack.count
            elseif info.rank >= (order.rank or 0) then
                local remaining = M.remaining(record)
                if remaining > 0 and not blocked then
                    local n = deliver(record, direction, stack, remaining, tick)
                    if n == 0 then blocked = true end
                    if n > 0 then
                        moved = moved + n
                        record.sent.good = (record.sent.good or 0) + n
                        accept(record, n, tick)
                    end
                end
                if stack.valid_for_read and M.remaining(record) > 0 then left = left + stack.count end
            elseif takes then
                waiting = waiting + stack.count
            else
                stray = stray + stack.count
            end
        end
    end
    record.blocked = blocked and {[direction] = true} or nil
    record.waiting_process = waiting
    record.stray = stray
    return moved, left
end

---------------------------------------------------------------------------------------------------
-- Post-processing
---------------------------------------------------------------------------------------------------
-- Picks the items of one operation: the highest quality below the order with TAKE copies; when the
-- inventory is full and no quality has TAKE copies, the TAKE lowest copies (the result starts from the
-- lowest of them), so that a post filled with single copies of many qualities does not stall.
-- Returns {quality name = count} and the starting quality prototype, or nil.
local function pick_operation(record, inventory)
    local order = record.order
    local list = {}
    for _, entry in pairs(inventory.get_contents()) do
        if entry.name == order.item then
            local quality = prototypes.quality[entry.quality or "normal"]
            local info = quality and M.quality_info(quality)
            if info and info.grade >= 0 and info.rank < (order.rank or 0) then
                list[#list + 1] = {quality = quality, rank = info.rank, count = entry.count}
            end
        end
    end
    if #list == 0 then return nil end
    table.sort(list, function(a, b) return a.rank > b.rank end)
    local take_count = rules.PROCESS_TAKE
    for _, entry in ipairs(list) do
        if entry.count >= take_count then return {[entry.quality.name] = take_count}, entry.quality end
    end
    return nil
end

-- One operation. Returns true when items were turned. Nothing is ever dropped: when the result has no
-- slot, nothing is taken and the post waits (record.no_room = quality of the result).
local function process_once(record, inventory, random)
    local parts, start = pick_operation(record, inventory)
    if not parts then
        record.no_room, record.no_material = nil, nil
        return false
    end
    -- Payment: an operation needs one paid operation or an artifact to pay the next ones.
    local material = M.material()
    local stock
    if material and (record.charge or 0) < 1 then
        stock = M.material_stock(record, inventory)
        if stock < 1 then
            record.no_material = true
            return false
        end
    end
    record.no_material = nil
    local item = record.order.item
    local result = rules.process_outcome(start, random or math.random)
    local made = {name = item, quality = result.name, count = 1}
    if not inventory.can_insert(made) then
        record.no_room = result.name
        return false
    end
    record.no_room = nil
    for quality, count in pairs(parts) do
        inventory.remove({name = item, quality = quality, count = count})
    end
    if inventory.insert(made) == 0 then
        -- Not expected after can_insert; give the copies back rather than drop anything.
        for quality, count in pairs(parts) do inventory.insert({name = item, quality = quality, count = count}) end
        record.no_room = result.name
        return false
    end
    if material then
        if (record.charge or 0) < 1 then
            for _, entry in pairs(inventory.get_contents()) do
                if entry.name == material then
                    inventory.remove({name = material, quality = entry.quality, count = 1})
                    break
                end
            end
            record.charge = (record.charge or 0) + M.operations_per_material()
            record.processed.material = (record.processed.material or 0) + 1
        end
        record.charge = record.charge - 1
    end
    local counters = record.processed
    counters.operations = counters.operations + 1
    counters.used = counters.used + rules.PROCESS_TAKE
    if result ~= start then counters.raised = counters.raised + 1 end
    stats.add(record.entity.force.index, "post.processed")
    return true
end

local function publish(record)
    if not (record.emitter and record.emitter.valid) then return end
    local active = record.state == "active" and not record.paused_by_circuit
    local done_pulse = record.done_tick and record.order.repeating and record.last_tick
        and record.last_tick - record.done_tick < 60
    emitter.set(record, {
        {S.order_active, active and 1 or 0},
        {S.order_required, record.order.item and record.order.required or 0},
        {S.order_accepted, record.accepted},
        {S.order_remaining, record.order.item and math.max(0, record.order.required - record.accepted) or 0},
        {S.order_to_process, record.waiting_process or 0},
        {S.order_done, (record.state == "done" or done_pulse) and 1 or 0},
        {S.order_batches, record.batches},
    })
end

function M.step(record, tick, random)
    local entity = record.entity
    record.last_tick = tick
    if record.order.condition ~= nil or not record.processed then M.migrate(record) end
    if record.circuit then
        local start = emitter.read(entity, S.cmd_start) > 0
        if start and not record.start_high then M.start(record) end
        record.start_high = start
        record.paused_by_circuit = emitter.read(entity, S.cmd_pause) > 0
        record.stop_after = emitter.read(entity, S.cmd_stop) > 0
    else
        record.paused_by_circuit, record.stop_after = false, false
    end
    local inventory = entity.get_inventory(defines.inventory.chest)
    -- Slots of an older layout get their filter once they are empty.
    if record.layout_pending and tick >= (record.layout_tick or 0) then
        record.layout_tick = tick + 60
        M.apply_filters(record)
    end
    local open = record.state == "active" and not record.paused_by_circuit
    if record.open ~= open then
        record.open = open
        if open then inventory.set_bar() else inventory.set_bar(1) end
    end
    local moved, left, processed = 0, 0, false
    if record.state ~= "paused" and not record.paused_by_circuit and not inventory.is_empty() then
        moved, left = sort_items(record, inventory, tick)
        if open and record.state == "active" and (record.waiting_process or 0) > 0
            and tick >= (record.process_tick or 0) then
            processed = process_once(record, inventory, random)
            if processed then record.process_tick = tick + rules.PROCESS_TICKS end
        end
    else
        record.waiting_process = 0
        if inventory.is_empty() then record.stray = 0 end
    end
    publish(record)
    -- Moving items: every tick (a belt takes one item per tick). Accepted items left but the output
    -- blocked: a short pause. Post-processing: the next operation after PROCESS_TICKS.
    local look
    if left > 0 then look = moved > 0 and 1 or M.BLOCKED_LOOK
    elseif processed then look = math.max(1, record.process_tick - tick)
    elseif open and record.state == "active" then look = M.EMPTY_LOOK
    elseif record.circuit then look = M.IDLE_LOOK end
    record.next_tick = look and tick + look or nil
end

function M.on_tick(tick)
    local s = storage.ic_posts
    if not s then return end
    if not s.buckets then s = M.state() end
    local bucket = wheel.take(s.buckets, tick)
    if not bucket then return end
    for index = 1, #bucket do
        local id = bucket[index]
        local record = s.records[id]
        if record and record.due == tick then
            if not record.entity.valid then
                M.forget(id)
            else
                M.step(record, tick)
                if s.records[id] == record then
                    if record.next_tick then
                        wheel.add(s.buckets, record, math.max(tick + 1, record.next_tick))
                    else
                        record.due = nil -- asleep until M.wake
                    end
                end
            end
        end
    end
    wheel.release(bucket)
end

return M
