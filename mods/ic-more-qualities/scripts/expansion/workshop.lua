-- Refinement workshop runtime (rewritten 2026-10-29 for performance: review/ic-perf-audit-20261029).
-- The furnace recognises an inserted finished product and runs its hidden 1 -> 1 recipe; its burner keeps an
-- internal drive, so the two burner slots only store repair packs. One attempt per item, then it leaves:
--   * a defect is refined: the whole cost of the attempt is drained from the packs (partly used ones first)
--     and the outcome rolled when the attempt starts (90% one grade up, then 10% per extra grade, never
--     above standard; modes: +2 grades / standard for sure). The engine keeps the result quality written by
--     script to the end of the craft (engine check test-runs/ic-h1b-20261029). Without enough packs the
--     attempt is stopped by script until the rest arrives; an idle workshop without packs keeps a defective
--     item in its input slot. Mining the workshop during an attempt returns the item as it was (the packs
--     are spent);
--   * positive quality is reset (optional, 1/5 of the time, at most one second, no packs); standard passes;
--   * the hidden electric consumer must be supplied: partial supply slows the attempt, none stops it (the
--     consumer shows the engine's "no power" / "no network" icon over the building);
--   * modes take 5/20 times longer at the same power and packs. The engine runs at full speed between looks,
--     so its progress is set back to the slowed progress on every look.
-- Looks (scripts/wheel.lua): every WORK_LOOK ticks while an attempt runs (more often while its progress is
-- slowed, so the bar does not jump far ahead), one a tick before the engine can complete it (a used science
-- pack put into the input slot meanwhile must be taken by the script first) and every IDLE_LOOK ticks while
-- idle. An idle workshop with an empty input slot is stopped, so an inserted item waits for that look.
-- Partly used science packs and other tools (durability) and magazines (rounds) are never crafted by the
-- furnace: its output is a fresh full item (endless science). The script refines them in the input slot by
-- the same rules and writes the result with the same share of durability (rounds unchanged); the furnace
-- stays stopped meanwhile. Whole packs and full magazines go through the furnace like other items.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local power = require("scripts.expansion.power")
local emitter = require("scripts.expansion.emitter")
local stats = require("scripts.stats")
local wheel = require("scripts.wheel")

local M = {}
local S = names.signals
local NO_RESOURCE_ALERT_TICKS = 300
-- A held attempt never goes back to exactly 0: the engine treats a started craft at 0 progress as not
-- started, and the item already taken from the source slot was lost.
local MIN_HELD_PROGRESS = 1e-4
-- Supply below this share counts as no electricity at all: the attempt is held, not slowed.
local NO_POWER = 1e-3
local FULL_POWER = 0.999
M.WORK_LOOK = 30
M.IDLE_LOOK = 30
-- A slowed attempt (mode, low power) is looked at so often that the furnace bar runs at most this share of
-- the attempt ahead of the slowed progress before the next look sets it back.
M.JUMP = 0.03

-- buckets: timer wheel of the looks (scripts/wheel.lua); record.next_tick is the tick of the next look.
function M.state()
    local s = storage.ic_workshops
    if not s then
        s = {records = {}, buckets = {}}
        storage.ic_workshops = s
    elseif not s.buckets then
        -- Older layout (every record walked every tick): every workshop is looked at on the next tick.
        s.buckets = {}
        for _, record in pairs(s.records) do wheel.add(s.buckets, record, game.tick + 1) end
    end
    return s
end

-- Brings the next look of a workshop forward to the next tick (settings changed).
function M.wake(record)
    record.next_tick = game.tick + 1
    wheel.advance(M.state().buckets, record, record.next_tick)
end

local costs_cache
function M.reset_cache() costs_cache = nil end

-- Cost entries of the refinable items (finished products), prototype data from mod-data.
function M.costs()
    if not costs_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        costs_cache = mod_data and mod_data.data.costs or {}
    end
    return costs_cache
end

function M.refinable(item)
    return M.costs()[item] ~= nil
end

-- Durability units and seconds of one attempt for an item (fallback: an average item).
function M.cost_of(item)
    local entry = M.costs()[item]
    if entry then return entry.cost, entry.seconds end
    return rules.attempt(nil, nil)
end

---------------------------------------------------------------------------------------------------
-- Repair resource
---------------------------------------------------------------------------------------------------
local function stack_resource(stack)
    if not (stack.valid_for_read and stack.is_tool) then return 0 end
    local maximum = stack.prototype.get_durability(stack.quality)
    if not maximum or maximum <= 0 then return 0 end
    return (stack.count - 1) * maximum + stack.durability
end

local function resource(inventory)
    local total = 0
    if inventory then
        for index = 1, #inventory do total = total + stack_resource(inventory[index]) end
    end
    return total
end

function M.available(entity)
    return resource(entity.get_fuel_inventory())
end

-- Removes up to `need` durability units, partially used packs first. Returns what was drained.
local function drain(inventory, need)
    local drained = 0
    if not inventory or need <= 0 then return 0 end
    for index = 1, #inventory do
        local stack = inventory[index]
        while need - drained > 1e-9 and stack.valid_for_read and stack.is_tool do
            local maximum = stack.prototype.get_durability(stack.quality)
            local current = stack.durability
            local take = math.min(current, need - drained)
            if current - take <= 1e-9 then
                drained = drained + current
                if stack.count > 1 then
                    stack.count = stack.count - 1
                    stack.durability = maximum
                else
                    stack.clear()
                end
            else
                stack.durability = current - take
                drained = drained + take
            end
        end
    end
    return drained
end

---------------------------------------------------------------------------------------------------
-- Registry
---------------------------------------------------------------------------------------------------
local function ensure_drive(entity)
    local burner = entity.burner
    if not burner then return end
    local current = burner.currently_burning
    local name = current and current.name
    if type(name) ~= "string" then name = name and name.name end
    if name ~= names.drive then burner.currently_burning = {name = names.drive, quality = "normal"} end
    -- Writing currently_burning keeps the old remaining fuel (0 on a new building). Without a full drive
    -- the native burner takes repair packs from the fuel slots as fuel: packs vanished even on resets.
    local drive = prototypes.item and prototypes.item[names.drive]
    local full = drive and drive.fuel_value
    if full and full > 0 and (burner.remaining_burning_fuel or 0) < full / 2 then
        burner.remaining_burning_fuel = full
    end
end

-- The building's inventories, kept on the record (valid while the building is; reset by rescan).
local function inventories(record)
    local inv = record.inventories
    if not inv then
        local entity = record.entity
        inv = {source = entity.get_inventory(defines.inventory.furnace_source),
            result = entity.get_inventory(defines.inventory.furnace_result), fuel = entity.get_fuel_inventory()}
        record.inventories = inv
    end
    return inv
end

function M.apply_settings(record, settings)
    if type(settings) ~= "table" then return end
    record.settings.reset_positive = settings.reset_positive == true
    M.set_mode(record, settings.mode)
    M.set_circuit(record, settings.circuit == true)
end

function M.export_settings(record)
    return {reset_positive = record.settings.reset_positive, circuit = record.settings.circuit,
        mode = M.mode_name(record)}
end

-- Workshops from older versions have no mode: normal.
function M.mode_name(record)
    local mode = record.settings.mode
    return rules.workshop_modes[mode] and mode or "normal"
end

function M.set_mode(record, name)
    record.settings.mode = rules.workshop_modes[name] and name or "normal"
end

function M.set_circuit(record, enabled)
    record.settings.circuit = enabled
    if enabled then
        if not (record.emitter and record.emitter.valid) then record.emitter = emitter.create(record.entity) end
    else
        emitter.destroy(record.emitter)
        record.emitter, record.emitted = nil, nil
    end
    -- The building keeps its state; the next tick's look decides whether it may run.
    if storage.ic_workshops and storage.ic_workshops.records[record.id] == record then M.wake(record) end
end

function M.track(entity, settings)
    if not (entity and entity.valid and entity.name == names.workshop) then return nil end
    local s = M.state()
    local record = s.records[entity.unit_number]
    if record and record.entity.valid then return record end
    record = {
        id = entity.unit_number, entity = entity, next_tick = 0, status = nil,
        settings = {reset_positive = false, circuit = false, mode = "normal"},
        surface_index = entity.surface.index, position = {x = entity.position.x, y = entity.position.y},
    }
    s.records[record.id] = record
    wheel.add(s.buckets, record, game.tick + 1)
    -- Stopped until its first look: an item put in on the tick it was built must be seen by the script first.
    entity.disabled_by_script = true
    ensure_drive(entity)
    record.interface = power.create(entity, names.workshop_power)
    script.register_on_object_destroyed(entity)
    M.apply_settings(record, settings)
    return record
end

function M.get(entity)
    if not (entity and entity.valid and entity.unit_number) then return nil end
    local s = storage.ic_workshops
    return s and s.records[entity.unit_number]
end

function M.forget(id)
    local s = storage.ic_workshops
    local record = s and s.records[id]
    if not record then return end
    power.destroy(record.interface)
    emitter.destroy(record.emitter)
    s.records[id] = nil
end

function M.rescan(entities)
    local s = M.state()
    for id, record in pairs(s.records) do
        if not record.entity.valid then M.forget(id) end
    end
    for _, entity in pairs(entities) do
        if entity.valid and entity.name == names.workshop then
            local record = M.track(entity)
            if record then
                -- Prototypes may have changed with the configuration.
                record.max_power, record.inventories, record.idle_look, record.look = nil, nil, nil, nil
                M.wake(record)
                ensure_drive(entity)
                if not (record.interface and record.interface.valid) then
                    record.interface = power.create(entity, names.workshop_power)
                end
                if record.settings.circuit and not (record.emitter and record.emitter.valid) then
                    record.emitter = emitter.create(entity)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Status, alert, signals
---------------------------------------------------------------------------------------------------
-- Full power of the building (its quality never changes; reset by rescan after a configuration change).
local function machine_power(record)
    local value = record.max_power
    if not value then
        local entity = record.entity
        value = entity.prototype.get_max_energy_usage(entity.quality)
        record.max_power = value
    end
    return value
end

-- grade: optional number shown in the label. The key is built from the number, not from the localised table
-- (a new table every call made the key differ and rewrote the status every tick).
local function set_status(record, key, diode, grade)
    local label_key = grade ~= nil and (key .. "|" .. grade) or key
    if record.status == label_key then return end
    record.status = label_key
    record.status_key = key
    local label = {"ic-quality.workshop-status-" .. key}
    if grade ~= nil then label[2] = {"ic-quality.grade-" .. tostring(-grade)} end
    record.entity.custom_status = {diode = defines.entity_status_diode[diode], label = label}
end

local function alert(record, active)
    local entity = record.entity
    if active then
        if record.alerted then return end
        record.alerted = true
        local players_settings = storage.ic_players or {}
        for _, player in pairs(entity.force.players) do
            local settings = players_settings[player.index]
            if player.connected and not (settings and settings.alerts == false) then
                player.add_custom_alert(entity, {type = "virtual", name = S.ws_no_resource},
                    {"ic-quality.alert-no-resource", entity.localised_name}, true)
            end
        end
    elseif record.alerted then
        record.alerted = nil
        for _, player in pairs(entity.force.players) do
            player.remove_alert({entity = entity, type = defines.alert_type.custom})
        end
    end
end

-- Grade of the item being worked on (the outcome is rolled at the start but shown only when it leaves).
local function shown_grade(attempt)
    return attempt.start_grade or attempt.grade
end

-- Estimated progress of the current attempt now (looks are rare; the GUI and signals interpolate).
function M.progress(record, tick)
    local attempt = record.sc or record.craft
    if not attempt then return 0 end
    local progress = attempt.progress or 0
    if attempt.speed and attempt.look_tick then
        progress = progress + ((tick or game.tick) - attempt.look_tick) * attempt.speed
    end
    return math.max(0, math.min(1, progress))
end

local function publish(record, crafting, tick)
    if not (record.emitter and record.emitter.valid) then return end
    local attempt = record.sc or record.craft
    local refining = crafting and attempt and attempt.kind == "refine"
    emitter.set(record, {
        {S.ws_working, crafting and attempt and attempt.kind ~= "pass" and 1 or 0},
        {S.ws_progress, refining and math.floor(M.progress(record, tick) * 100) or 0},
        {S.ws_grade, refining and shown_grade(attempt) or 0},
        {S.ws_resource, math.floor(record.available or 0)},
        {S.ws_need, refining and math.ceil((1 - attempt.paid) * attempt.cost) or 0},
        {S.ws_no_resource, record.status_key == "no-resource" and 1 or 0},
        {S.ws_no_item, record.status_key == "waiting" and 1 or 0},
        {S.ws_output_full, record.status_key == "output-full" and 1 or 0},
    })
end

-- Status of a running or held attempt.
local function attempt_status(record, attempt, paused, paid, supply, tick)
    if paused then
        set_status(record, "paused", "yellow")
    elseif not paid then
        set_status(record, "no-resource", "red")
    elseif supply < NO_POWER then
        set_status(record, "no-power", "red")
    elseif supply < FULL_POWER then
        set_status(record, "low-power", "yellow")
    elseif attempt.kind == "refine" then
        set_status(record, "working", "green", shown_grade(attempt))
    else
        set_status(record, attempt.kind == "reset" and "reset" or "passing", "green")
    end
    if paid or paused then
        record.starved_since = nil
    else
        record.starved_since = record.starved_since or tick
    end
    alert(record, record.starved_since ~= nil and tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
end

---------------------------------------------------------------------------------------------------
-- Attempts (furnace and script alike)
---------------------------------------------------------------------------------------------------
-- A new attempt for `item` of quality `from`. kind: refine (a defect), reset (positive quality with the
-- reset setting) or pass. grade: the outcome once rolled; start_grade: the grade the item came with.
local function new_attempt(record, item, from, force_index)
    local attempt = {item = item, from = from, grade = model.grade_of(from), paid = 0, progress = 0, attempts = 0}
    if attempt.grade < 0 then
        attempt.kind = "refine"
        attempt.cost, attempt.seconds = M.cost_of(item)
        attempt.start_grade = attempt.grade
        attempt.mode = M.mode_name(record)
    elseif from ~= "normal" and record.settings.reset_positive then
        attempt.kind = "reset"
        local _, seconds = M.cost_of(item)
        attempt.seconds = seconds
        stats.add(force_index, "refine.resets")
    else
        attempt.kind = "pass"
        stats.add(force_index, "refine.passed")
    end
    return attempt
end

-- Rolls the single attempt of a refinement and counts it.
local function roll(force_index, attempt, ctx)
    local before = attempt.grade
    local mode = rules.workshop_mode(attempt.mode)
    local after = rules.mode_outcome(before, mode, ctx.random)
    attempt.attempts = attempt.attempts + 1
    if mode.steps then
        -- Guaranteed results are counted apart: the attempt statistics compare with the 90% roll.
        stats.add(force_index, "refine.mode." .. mode.name)
    else
        stats.add(force_index, "refine.attempts")
        if after == before then
            stats.add(force_index, "refine.fail")
        else
            stats.add(force_index, "refine.success")
            stats.add(force_index, "refine.jump" .. math.min(3, after - before))
        end
    end
    attempt.final = true
    attempt.grade = after
    if after == 0 then stats.add(force_index, "refine.normalized") end
end

-- Drains what a refinement still owes; rolls its outcome once it is paid. True: nothing is owed.
local function pay(record, attempt, ctx, force_index)
    if attempt.kind ~= "refine" or attempt.paid >= 1 then return true end
    local need = (1 - attempt.paid) * attempt.cost
    local drained = drain(inventories(record).fuel, need)
    if drained > 0 then
        attempt.paid = math.min(1, attempt.paid + drained / attempt.cost)
        stats.add(force_index, "refine.resource", drained)
    end
    if drained + 1e-9 < need then return false end
    attempt.paid = 1
    if not attempt.final then roll(force_index, attempt, ctx) end
    return true
end

-- Progress share per tick of an attempt at full supply (seconds at speed 1, the mode's slowdown).
local function rate_of(attempt, speed)
    speed = math.max(speed, 0.01)
    if attempt.kind == "refine" then
        return speed / (attempt.seconds * 60) / rules.workshop_mode(attempt.mode).time
    end
    return speed / (attempt.seconds * 60)
end

---------------------------------------------------------------------------------------------------
-- Furnace attempts
---------------------------------------------------------------------------------------------------
local function furnace_step(record, entity, recipe, quality, ctx, paused)
    local tick = ctx.tick
    local force_index = entity.force.index
    local finished = entity.products_finished
    local progress = entity.crafting_progress
    local attempt = record.craft
    local recipe_name = recipe.name
    if attempt and attempt.key then
        -- A craft of the layout before 2026-10-29 (string key): adopted if it is the same craft.
        if attempt.key == recipe_name .. "|" .. finished then
            attempt.recipe, attempt.finished, attempt.engine = recipe_name, finished, progress
            if not attempt.seconds then
                local _, seconds = M.cost_of(attempt.item)
                attempt.seconds = seconds
            end
        end
        attempt.key = nil
    end
    if not (attempt and attempt.recipe == recipe_name and attempt.finished == finished) then
        attempt = new_attempt(record, recipe_name:sub(#names.refine_recipe_prefix + 1), quality.name, force_index)
        attempt.recipe, attempt.finished = recipe_name, finished
        if attempt.kind == "reset" then
            attempt.result = "normal"
            -- 1/5 of the attempt, but never longer than RESET_MAX_SECONDS.
            local ticks = attempt.seconds * 60 / math.max(entity.crafting_speed, 0.01)
            local start = math.max(1 - rules.RESET_SHARE, 1 - rules.RESET_MAX_SECONDS * 60 / math.max(ticks, 1))
            if progress < start then
                entity.crafting_progress = start
                progress = start
            end
        elseif attempt.kind == "pass" then
            entity.crafting_progress = 1
            progress = 1
        end
        -- The engine ran one tick at full speed before this first look: a slowed attempt counts it slowed.
        local slow = attempt.kind == "refine" and rules.workshop_mode(attempt.mode).time or 1
        attempt.progress, attempt.engine = attempt.kind == "refine" and progress / slow or progress, progress
        record.craft = attempt
    end

    if attempt.kind == "pass" then
        if entity.disabled_by_script then entity.disabled_by_script = false end
        record.held, record.starved_since = nil, nil
        power.set(record.interface, machine_power(record))
        set_status(record, "passing", "green")
        publish(record, true, tick)
        record.next_tick = tick + 1
        return
    end

    local paid = attempt.paid >= 1 or attempt.kind ~= "refine" or (not paused and pay(record, attempt, ctx, force_index))
    if attempt.final then attempt.result = model.quality_name(attempt.grade) end
    -- The result quality is written at the first look and checked on every later one (also the last look
    -- before completion): the engine may set it again, e.g. when a released furnace starts its craft.
    local result = attempt.result
    if result then
        local current = entity.result_quality
        if not (current and current.name == result) then entity.result_quality = result end
    end
    local supply = power.satisfaction(record.interface)
    local unpowered = supply < NO_POWER
    local held = paused or not paid or unpowered
    local slow = attempt.kind == "refine" and rules.workshop_mode(attempt.mode).time or 1
    local engine_rate = math.max(entity.crafting_speed, 0.01) / (attempt.seconds * 60)
    -- The engine ran at full speed since the last look: credit the slowed share of it and set the engine
    -- back to the slowed progress (never forward).
    local gained = progress - attempt.engine
    if gained > 1e-12 then
        attempt.progress = math.min(1, attempt.progress + gained * math.min(1, supply) / slow)
    end
    local target = math.max(MIN_HELD_PROGRESS, attempt.progress)
    if target < progress - 1e-9 or progress < MIN_HELD_PROGRESS then
        entity.crafting_progress = target
        progress = target
    end
    attempt.engine = progress

    local full = machine_power(record)
    -- Waiting for packs or paused: idle power. Without electricity the full power stays requested, so the
    -- buffer refills as soon as the network has power again.
    power.set(record.interface, (held and not unpowered) and full / 30 or full)
    attempt_status(record, attempt, paused, paid, supply, tick)
    if entity.disabled_by_script ~= held then entity.disabled_by_script = held end
    record.held = held or nil

    local look
    if held then
        look = paid and M.WORK_LOOK or M.IDLE_LOOK
        attempt.speed = nil
    else
        look = M.WORK_LOOK
        if slow > 1 or supply < FULL_POWER then look = math.max(1, math.min(look, math.floor(M.JUMP / engine_rate))) end
        -- The engine completes the craft after `left` ticks at full speed: the last look one tick before.
        local left = (1 - progress) / engine_rate
        look = math.min(look, math.max(1, math.floor(left) - 1))
        attempt.speed = engine_rate * math.min(1, supply) / slow
    end
    attempt.look_tick = tick
    publish(record, true, tick)
    record.next_tick = tick + look
end

---------------------------------------------------------------------------------------------------
-- Items with a per-item state (science packs and other tools: durability; ammo: rounds)
---------------------------------------------------------------------------------------------------
-- Only the top item of a stack can be partly used; the items below it are whole.
local USED_EPSILON = 1e-9

local function stateful(stack)
    if not (stack ~= nil and stack.valid_for_read) then return false end
    local kind = stack.type
    if kind == "tool" then
        local maximum = stack.prototype.get_durability(stack.quality)
        return maximum ~= nil and stack.durability < maximum - USED_EPSILON
    elseif kind == "ammo" then
        local size = stack.prototype.magazine_size
        return size ~= nil and stack.ammo < size - USED_EPSILON
    end
    return false
end

-- The leaving item: the top item of the input stack (the partly used one) at the reached quality, with the
-- same share of durability (as in handcraft) or the same rounds.
local function output_of(stack, quality)
    local item = {name = stack.name, quality = quality, count = 1}
    if stack.type == "tool" then
        local prototype = stack.prototype
        local old_max = prototype.get_durability(stack.quality)
        local new_max = prototype.get_durability(quality)
        if old_max and old_max > 0 and new_max then
            item.durability = math.min(1, stack.durability / old_max) * new_max
        else
            item.durability = stack.durability
        end
    elseif stack.type == "ammo" then
        item.ammo = stack.ammo
    end
    return item
end

-- Removes the top item; the items left in the stack are whole ones.
local function take_top(stack)
    if stack.count <= 1 then
        stack.clear()
        return
    end
    local is_tool = stack.type == "tool"
    local maximum = is_tool and stack.prototype.get_durability(stack.quality) or stack.prototype.magazine_size
    stack.count = stack.count - 1
    if maximum and maximum > 0 then
        if is_tool then stack.durability = maximum else stack.ammo = maximum end
    end
end

-- Writes the result into the output slot and removes the item from the input slot. False: no room.
local function deliver(record, stack, quality)
    local result = inventories(record).result
    if not result then return false end
    local item = output_of(stack, quality)
    if not result.can_insert(item) then return false end
    if result.insert(item) < 1 then return false end
    take_top(stack)
    return true
end

-- One look of a script attempt. The item stays in the input slot until it leaves (mining or taking it back
-- returns it as it was; the packs already paid for the attempt are spent). Returns false when nothing is
-- left for the script on this look (the furnace takes over).
local function script_step(record, entity, ctx, stack, paused, stop)
    local tick = ctx.tick
    local attempt = record.sc
    if attempt and not (stack and stack.valid_for_read and stack.name == attempt.item
        and stack.quality.name == attempt.from) then
        record.sc, attempt = nil, nil
    end
    if not attempt and not stateful(stack) then return false end
    -- The furnace never takes these items; an attempt of the furnace itself waits meanwhile.
    if not entity.disabled_by_script then entity.disabled_by_script = true end
    local full = machine_power(record)
    if not attempt and (paused or stop) then
        set_status(record, "paused", "yellow")
        power.set(record.interface, full / 30)
        publish(record, false, tick)
        record.next_tick = tick + M.WORK_LOOK
        return true
    end
    local force_index = entity.force.index
    if not attempt then
        attempt = new_attempt(record, stack.name, stack.quality.name, force_index)
        attempt.last_tick = tick
        if attempt.kind == "pass" then attempt.progress = 1 end
        record.sc = attempt
    end
    local dt = math.max(0, tick - attempt.last_tick)
    attempt.last_tick = tick
    local supply, rate = 1, 0
    if attempt.progress < 1 then
        supply = power.satisfaction(record.interface)
        if attempt.kind == "refine" then
            rate = rate_of(attempt, entity.crafting_speed)
        else
            -- Reset: 1/5 of the attempt, at most RESET_MAX_SECONDS (as in the furnace).
            local ticks = math.min(rules.RESET_SHARE * attempt.seconds * 60 / math.max(entity.crafting_speed, 0.01),
                rules.RESET_MAX_SECONDS * 60)
            rate = 1 / math.max(ticks, 1)
        end
        -- Progress of the interval since the last look, if the attempt was running then.
        if attempt.running then attempt.progress = math.min(1, attempt.progress + dt * rate * math.min(1, supply)) end
    end
    local paid = attempt.paid >= 1 or attempt.kind ~= "refine" or (not paused and pay(record, attempt, ctx, force_index))

    if attempt.progress >= 1 - 1e-9 and paid then
        local quality = attempt.kind == "refine" and model.quality_name(attempt.grade)
            or attempt.kind == "reset" and "normal" or attempt.from
        if deliver(record, stack, quality) then
            record.sc = nil
            record.starved_since = nil
            alert(record, false)
            publish(record, false, tick)
            record.next_tick = tick + 1
            return false
        end
        attempt.running, attempt.speed = false, nil
        set_status(record, "output-full", "yellow")
        power.set(record.interface, full / 30)
        publish(record, true, tick)
        record.next_tick = tick + M.WORK_LOOK
        return true
    end

    local unpowered = supply < NO_POWER
    local held = paused or not paid or unpowered
    attempt.running = not held
    power.set(record.interface, (held and not unpowered) and full / 30 or full)
    attempt_status(record, attempt, paused, paid, supply, tick)
    local look
    if held then
        look = paid and M.WORK_LOOK or M.IDLE_LOOK
        attempt.speed = nil
    else
        -- Lands on the tick the attempt completes at the current supply.
        local per_tick = rate * math.min(1, supply)
        look = math.min(M.WORK_LOOK, math.max(1, math.ceil((1 - attempt.progress) / per_tick - 1e-9)))
        attempt.speed = per_tick
    end
    attempt.look_tick = tick
    publish(record, true, tick)
    record.next_tick = tick + look
    return true
end

---------------------------------------------------------------------------------------------------
-- Idle workshop
---------------------------------------------------------------------------------------------------
local function idle_step(record, entity, tick, inv, disable)
    record.craft = nil
    local stack = inv.source[1]
    local item = stack.valid_for_read
    -- Without packs a defective item stays in the input slot: the furnace would take it into an attempt at
    -- once and it seemed to vanish. Standard and positive items pass without packs.
    local hold = (not item or model.grade_of(stack.quality.name) < 0) and resource(inv.fuel) <= 1e-9
    record.held = hold or nil
    -- An item without a refinement recipe (a material left from a save before 2026-10-29) can never be taken:
    -- the workshop stays stopped and says so, instead of being looked at every tick.
    local stuck = item and not hold and not M.refinable(stack.name)
    -- An idle furnace stays stopped with an empty input slot: an item put in between two looks must not be
    -- taken before the script has seen it (a used pack would come back full).
    local stopped = disable or hold or not item or stuck
    if entity.disabled_by_script ~= stopped then entity.disabled_by_script = stopped end
    local item_waits = hold and item
    if item_waits and not disable then
        record.starved_since = record.starved_since or tick
    else
        record.starved_since = nil
    end
    alert(record, record.starved_since ~= nil and tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
    -- Read before the demand changes (a new consumer demands nothing yet and counts as supplied).
    local unpowered = power.satisfaction(record.interface) < NO_POWER
    power.set(record.interface, machine_power(record) / 30)
    if disable then
        set_status(record, "paused", "yellow")
    elseif item_waits then
        set_status(record, "no-resource", "red")
    elseif stuck then
        set_status(record, "not-refinable", "red")
    elseif unpowered then
        set_status(record, "no-power", "red")
    elseif not item then
        set_status(record, entity.status == defines.entity_status.full_output and "output-full" or "waiting", "yellow")
    elseif entity.status == defines.entity_status.full_output then
        set_status(record, "output-full", "yellow")
    else
        set_status(record, "idle", "yellow")
    end
    publish(record, false, tick)
    -- A released furnace takes the item on its next update: the next look sees the new attempt.
    record.next_tick = tick + (stopped and M.IDLE_LOOK or 1)
end

function M.step(record, ctx)
    local entity = record.entity
    local tick = ctx.tick
    if (record.drive_tick or 0) <= tick then
        ensure_drive(entity)
        record.drive_tick = tick + 600
    end
    local inv = inventories(record)
    local crafting = entity.is_crafting()
    -- Circuit control: pause holds the current attempt; "stop" lets it finish first.
    local paused, stop = false, false
    if record.settings.circuit then
        paused = emitter.read(entity, S.cmd_pause) > 0
        stop = emitter.read(entity, S.cmd_stop) > 0
    end
    -- The resource total is needed only for the circuit signal; the GUI counts it itself.
    record.available = record.emitter and record.emitter.valid and resource(inv.fuel) or nil
    local input = inv.source[1]
    if record.sc or stateful(input) then
        if script_step(record, entity, ctx, input, paused, stop) then return end
        -- Delivered: the next used item is handled on the next look, a whole one by the furnace now.
        if stateful(input) then
            record.next_tick = tick + 1
            return
        end
    end
    local recipe, quality = entity.get_recipe()
    if not (crafting and recipe and quality) then
        idle_step(record, entity, tick, inv, paused or stop)
        return
    end
    furnace_step(record, entity, recipe, quality, ctx, paused)
end

function M.on_tick(ctx)
    local s = storage.ic_workshops
    if not s then return end
    if not s.buckets then s = M.state() end
    local tick = ctx.tick
    local bucket = wheel.take(s.buckets, tick)
    if not bucket then return end
    for index = 1, #bucket do
        local id = bucket[index]
        local record = s.records[id]
        if record and record.due == tick then
            if not record.entity.valid then
                M.forget(id)
            else
                M.step(record, ctx)
                if s.records[id] == record then wheel.add(s.buckets, record, math.max(tick + 1, record.next_tick)) end
            end
        end
    end
    wheel.release(bucket)
end

-- Summary for the GUI: current attempt, probabilities and resource.
function M.describe(record)
    local entity = record.entity
    local attempt = record.sc or record.craft
    local info = {status = record.status_key or "idle", available = M.available(entity), settings = record.settings}
    if attempt then
        local grade = shown_grade(attempt)
        info.kind, info.item, info.grade, info.attempts = attempt.kind, attempt.item, grade, attempt.attempts
        info.progress, info.paid = M.progress(record), attempt.paid
        info.cost, info.seconds = attempt.cost, attempt.seconds
        if attempt.kind == "refine" and grade < 0 then
            local mode = rules.workshop_mode(attempt.mode)
            info.mode = mode.name
            info.distribution = rules.mode_distribution(grade, mode)
            info.expected = rules.mode_attempts(grade, mode)
        end
    end
    return info
end

return M
