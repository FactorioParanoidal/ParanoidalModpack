-- Control post: accepts a production order (item, quality condition, quantity, repeat) and routes
-- every incoming item to one of three outputs placed around the building:
--   forward - accepted products of the order (counted),
--   left    - products that need the refinement workshop (defects; positive for "strict"),
--   right   - everything else (other items, too low quality, surplus after completion).
-- The post writes into the belt / building in front of each output like an inserter and waits
-- when that output is blocked. Only the arrows rotate; the picture of the building stays.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local emitter = require("scripts.expansion.emitter")
local stats = require("scripts.stats")
local wheel = require("scripts.wheel")

local M = {}
local S = names.signals
M.routes = {"good", "refine", "other"}
M.TARGET_TTL = 300  -- a found output target is trusted this long (a building moved by a script)
M.TARGET_RETRY = 30 -- no target in front of an output: search again after this many ticks
M.EMPTY_LOOK = 10   -- an active but empty post looks for new items this often
M.BLOCKED_LOOK = 4  -- items inside but no output took anything: look again after this many ticks
M.IDLE_LOOK = 15    -- an idle or paused post with circuit control (a start command may come)
-- An idle, paused or finished post without circuit control and without items sleeps: it is not looked at
-- until start, pause, cancel, a new order or new settings wake it.

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
    return {item = nil, condition = "strict", quality = "normal", required = 100, repeating = false}
end

function M.get(entity)
    if not (entity and entity.valid and entity.unit_number) then return nil end
    local s = storage.ic_posts
    return s and s.records[entity.unit_number]
end

---------------------------------------------------------------------------------------------------
-- Arrows
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
    for _, route in ipairs(M.routes) do
        local direction = rules.output_direction(record.facing, route)
        local vector = rules.direction_vectors[direction]
        local object = rendering.draw_sprite({
            sprite = "ic-post-arrow-" .. route,
            target = {entity = entity, offset = {vector[1] * 1.08, vector[2] * 1.08}},
            surface = entity.surface,
            orientation = direction / 4,
            x_scale = 0.55, y_scale = 0.55,
            render_layer = "higher-object-under",
        })
        if object then record.arrows[route] = object.id end
    end
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

function M.set_order(record, order)
    local current = record.order
    for _, key in ipairs({"item", "condition", "quality", "required", "repeating"}) do
        if order[key] ~= nil then current[key] = order[key] end
    end
    if current.item and not prototypes.item[current.item] then current.item = nil end
    if current.condition ~= "strict" and current.condition ~= "at-least" then current.condition = "strict" end
    if not prototypes.quality[current.quality or ""] or model.is_defect(current.quality) then current.quality = "normal" end
    current.rank = quality_rank(current.quality)
    current.required = math.max(1, math.min(1000000, math.floor(tonumber(current.required) or 1)))
    current.repeating = current.repeating == true
    -- Changing the order restarts its count; nothing in the post is destroyed.
    record.accepted = 0
    if not current.item and record.state ~= "idle" then record.state = "idle" end
    M.wake(record)
end

function M.export_settings(record)
    local order = record.order
    return {facing = record.facing, circuit = record.circuit, order = {
        item = order.item, condition = order.condition, quality = order.quality,
        required = order.required, repeating = order.repeating}}
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

function M.track(entity, settings, facing)
    if not (entity and entity.valid and entity.name == names.post) then return nil end
    local s = M.state()
    local record = s.records[entity.unit_number]
    if record and record.entity.valid then return record end
    record = {
        id = entity.unit_number, entity = entity, facing = facing or 0, order = M.new_order(),
        state = "idle", accepted = 0, batches = 0, sent = {good = 0, refine = 0, other = 0},
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
function M.start(record)
    if not record.order.item then return false end
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
-- Routing
---------------------------------------------------------------------------------------------------
-- Routing view of a quality, kept per name (prototype data, the same on every peer).
local quality_infos, refinable = {}, {}
function M.reset_cache() quality_infos, refinable = {}, {} end

-- The workshop takes only items with a refinement recipe (finished products).
local function is_refinable(item)
    local result = refinable[item]
    if result == nil then
        result = prototypes.recipe[names.refine_recipe_prefix .. item] ~= nil
        refinable[item] = result
    end
    return result
end

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

-- The target in front of an output is remembered per absolute direction (rotation keeps it valid):
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

-- Returns the number of items moved.
local function route_items(record, inventory, tick)
    local blocked = {}
    local waiting, total = 0, 0
    for index = 1, #inventory do
        local stack = inventory[index]
        if stack.valid_for_read then
            local remaining = M.remaining(record)
            local name = stack.name
            local route = rules.route(record.order, name, M.quality_info(stack.quality), remaining,
                name == record.order.item and is_refinable(name))
            local direction = rules.output_direction(record.facing, route)
            local moved = 0
            if not blocked[direction] then
                local limit = route == "good" and remaining or stack.count
                moved = deliver(record, direction, stack, limit, tick)
                if moved == 0 then blocked[direction] = true end
            end
            if moved > 0 then
                total = total + moved
                record.sent[route] = (record.sent[route] or 0) + moved
                if route == "good" then accept(record, moved, tick) end
            end
            if route == "refine" and stack.valid_for_read then waiting = waiting + stack.count end
        end
    end
    record.blocked = blocked
    record.waiting_refine = waiting
    return total
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
        {S.order_to_refine, record.waiting_refine or 0},
        {S.order_done, (record.state == "done" or done_pulse) and 1 or 0},
        {S.order_batches, record.batches},
    })
end

function M.step(record, tick)
    local entity = record.entity
    record.last_tick = tick
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
    local open = record.state == "active" and not record.paused_by_circuit
    if record.open ~= open then
        record.open = open
        if open then inventory.set_bar() else inventory.set_bar(1) end
    end
    local busy, moved = false, 0
    if record.state ~= "paused" and not record.paused_by_circuit and not inventory.is_empty() then
        moved = route_items(record, inventory, tick)
        busy = not inventory.is_empty()
    else
        record.waiting_refine = 0
    end
    publish(record)
    -- Moving items: every tick (a belt takes one item per tick and output). Items left but every output
    -- blocked: a short pause instead of walking the slots every tick.
    local look
    if busy then look = moved > 0 and 1 or M.BLOCKED_LOOK
    elseif open then look = M.EMPTY_LOOK
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
