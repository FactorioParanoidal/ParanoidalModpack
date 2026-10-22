-- Refinement workshop runtime.
-- The furnace recognises the inserted item and runs one hidden 1 -> 1 recipe per item; its burner
-- keeps an internal drive, so the two burner slots only store repair packs. This module:
--   * drains the durability of the stored packs while an attempt progresses (paid ahead by two
--     ticks; without resource the attempt is held: the furnace is disabled by script at the paid
--     share and draws idle power until packs arrive, nothing is lost); an idle workshop without
--     packs stays stopped, so a defective item waits in the input slot instead of being taken in,
--   * scales progress by the supply of the hidden electric consumer,
--   * decides the single attempt shortly before completion: 10% unchanged, 90% one grade up, then
--     10% per extra grade, never above standard; the item always leaves after one attempt,
--   * resets positive quality (optional, 1/5 time, no packs) and passes standard items through.
-- Modes (rules.workshop_modes): an attempt in the precise/flawless mode takes 5/20 times longer at
-- the same power and the same packs and gains 2 grades / reaches standard for sure. The mode is
-- taken when the attempt starts; a switch applies from the next attempt.
-- Partly used science packs and other tools (durability) and magazines (rounds) are never crafted by the
-- furnace: its recipe output is a fresh full item, so a used pack came back full (endless science). The
-- script refines them in place from the input slot with the same cost, time, modes and outcome and
-- writes the result with the same share of durability (rounds unchanged); the furnace stays stopped
-- meanwhile. Whole packs and full magazines go through the furnace like other items: its fresh full
-- output equals the whole input, and the building shows its recipe, animation and status.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local power = require("scripts.expansion.power")
local emitter = require("scripts.expansion.emitter")
local stats = require("scripts.stats")

local M = {}
local S = names.signals
local NO_RESOURCE_ALERT_TICKS = 300
-- A held attempt never goes back to exactly 0: the engine treats a started craft at 0 progress as
-- not started, and the item already taken from the source slot was lost without repair packs.
local MIN_HELD_PROGRESS = 1e-4
-- Ticks between looks. A working attempt is paid look + 1 ticks ahead and decided or held at least
-- look + 0.5 ticks before completion, so the engine cannot finish it between two looks; the look
-- shrinks for very short attempts (fast high-quality workshops). An idle workshop must see a new
-- attempt early: it looks at least three times during the shortest attempt at its speed.
M.LOOK = 3
M.IDLE_LOOK = 6

function M.state()
    local s = storage.ic_workshops
    if not s then
        s = {records = {}}
        storage.ic_workshops = s
    end
    return s
end

local costs_cache
local shortest_cache
function M.reset_cache() costs_cache, shortest_cache = nil, nil end

function M.costs()
    if not costs_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        costs_cache = mod_data and mod_data.data.costs or {}
    end
    return costs_cache
end

-- Seconds of the shortest attempt of any item at speed 1 (prototype data, same on every peer).
function M.shortest_seconds()
    if not shortest_cache then
        local _, shortest = rules.attempt(nil, nil)
        for _, entry in pairs(M.costs()) do
            if entry.seconds and entry.seconds > 0 and entry.seconds < shortest then shortest = entry.seconds end
        end
        shortest_cache = shortest
    end
    return shortest_cache
end

local function idle_look(record, entity)
    local look = record.idle_look
    if not look then
        local ticks = M.shortest_seconds() * 60 / math.max(entity.crafting_speed, 0.01)
        look = math.max(1, math.min(M.IDLE_LOOK, math.floor(ticks / 3)))
        record.idle_look = look
    end
    return look
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
    if not (stack and stack.valid_for_read and stack.is_tool) then return 0 end
    local maximum = stack.prototype.get_durability(stack.quality)
    if not maximum or maximum <= 0 then return 0 end
    return (stack.count - 1) * maximum + stack.durability
end

function M.available(entity)
    local inventory = entity.get_fuel_inventory()
    local total = 0
    if inventory then
        for index = 1, #inventory do total = total + stack_resource(inventory[index]) end
    end
    return total
end

-- Removes up to `need` durability units, partially used packs first. Returns what was drained.
function M.drain(entity, need)
    local inventory = entity.get_fuel_inventory()
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
        -- The building keeps its state; the next tick's look decides whether it may run (a workshop held
        -- without packs, idle with an empty slot or refining a pack by script stays stopped).
        record.next_tick = 0
    end
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
                record.idle_look = nil -- attempt durations may have changed with the configuration
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
-- Work cycle
---------------------------------------------------------------------------------------------------
local function machine_power(entity)
    return entity.prototype.get_max_energy_usage(entity.quality)
end

local function grade_text(grade)
    return {"ic-quality.grade-" .. tostring(-grade)}
end

-- grade: optional number shown in the label. The key is built from the number, not from the
-- localised table (a new table every call made the key differ and rewrote the status every tick).
local function set_status(record, key, diode, grade)
    local label_key = grade ~= nil and (key .. "|" .. grade) or key
    if record.status == label_key then return end
    record.status = label_key
    record.status_key = key
    local label = {"ic-quality.workshop-status-" .. key}
    if grade ~= nil then label[2] = grade_text(grade) end
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

local function publish(record, crafting)
    if not (record.emitter and record.emitter.valid) then return end
    local craft = record.sc or record.craft
    local refining = crafting and craft and craft.kind == "refine"
    local need = refining and math.ceil((1 - craft.paid) * craft.cost) or 0
    emitter.set(record, {
        {S.ws_working, crafting and craft and craft.kind ~= "pass" and 1 or 0},
        {S.ws_progress, refining and math.floor((craft.progress or 0) * 100) or 0},
        {S.ws_grade, refining and craft.grade or 0},
        {S.ws_resource, math.floor(record.available or 0)},
        {S.ws_need, need},
        {S.ws_no_resource, record.status_key == "no-resource" and 1 or 0},
        {S.ws_no_item, record.status_key == "waiting" and 1 or 0},
        {S.ws_output_full, record.status_key == "output-full" and 1 or 0},
    })
end

local function begin_craft(record, entity, recipe, quality, key, progress)
    local product = recipe.products[1]
    local craft = {key = key, item = product and product.name, from = quality.name,
        grade = model.grade_of(quality.name), paid = 0, progress = progress, attempts = 0}
    local force_index = entity.force.index
    if craft.grade < 0 then
        craft.kind = "refine"
        craft.cost, craft.seconds = M.cost_of(craft.item)
        craft.start_grade = craft.grade
        craft.mode = M.mode_name(record)
    elseif quality.name ~= "normal" and record.settings.reset_positive then
        craft.kind = "reset"
        entity.result_quality = "normal"
        -- 1/5 of the attempt, but never longer than RESET_MAX_SECONDS.
        local _, seconds = M.cost_of(craft.item)
        local ticks = seconds * 60 / math.max(entity.crafting_speed, 0.01)
        local start = math.max(1 - rules.RESET_SHARE, 1 - rules.RESET_MAX_SECONDS * 60 / math.max(ticks, 1))
        if progress < start then
            entity.crafting_progress = start
            craft.progress = start
        end
        stats.add(force_index, "refine.resets")
    else
        craft.kind = "pass"
        entity.crafting_progress = 1
        stats.add(force_index, "refine.passed")
    end
    record.craft = craft
    return craft
end

-- Rolls one attempt of a refinement (engine or script) and counts it. Returns the reached grade.
local function roll(force_index, craft, ctx)
    local before = craft.grade
    local mode = rules.workshop_mode(craft.mode)
    local after = rules.mode_outcome(before, mode, ctx.random)
    craft.attempts = craft.attempts + 1
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
    -- One attempt per item: the same item leaves with the reached (or unchanged) grade.
    craft.final = true
    craft.grade = after
    if after == 0 then stats.add(force_index, "refine.normalized") end
    return after
end

local function attempt(record, entity, craft, ctx)
    entity.result_quality = model.quality_name(roll(entity.force.index, craft, ctx))
end

local function refine_step(record, entity, craft, progress, ctx)
    local rate = entity.crafting_speed / (craft.seconds * 60)
    local look = math.max(1, math.min(M.LOOK, math.floor(1 / rate / 6)))
    record.look = look
    local supply = power.satisfaction(record.interface)
    local previous = craft.progress or 0
    -- Mode: the engine progress since the last look counts 1/time (power and packs per attempt stay).
    local slow = rules.workshop_mode(craft.mode).time
    if progress > previous and (supply < 1 or slow > 1) then
        progress = previous + (progress - previous) * supply / slow
    end
    -- Pay ahead of the progress; without resource the attempt waits (nothing is lost).
    local need = rules.prepay(craft.cost, craft.paid, progress, (look + 1) * rate)
    local starved = false
    if need > 0 then
        local drained = M.drain(entity, need)
        if drained > 0 then
            craft.paid = math.min(1, craft.paid + drained / craft.cost)
            stats.add(entity.force.index, "refine.resource", drained)
        end
        starved = drained + 1e-9 < need and craft.paid < 1
    end
    if progress > craft.paid then progress = craft.paid end
    if progress < MIN_HELD_PROGRESS then progress = MIN_HELD_PROGRESS end
    local margin = (look + 0.5) * rate
    if craft.paid < 1 - 1e-9 then progress = math.min(progress, math.max(0, 1 - margin)) end
    if progress < entity.crafting_progress - 1e-9 then entity.crafting_progress = progress end
    craft.progress = progress

    if not craft.final and craft.paid >= 1 - 1e-9 and progress + margin >= 1 then
        attempt(record, entity, craft, ctx)
    end

    -- Without packs the furnace is stopped (M.step disables it) instead of running ahead between
    -- looks and being rewound on every look: the progress bar jittered and full power was drawn.
    -- The paid share stays credited; a look with packs drains them and releases the furnace.
    record.held = starved or nil
    power.set(record.interface, starved and machine_power(entity) / 30 or machine_power(entity))

    if starved then
        set_status(record, "no-resource", "red")
        record.starved_since = record.starved_since or ctx.tick
    else
        record.starved_since = nil
        if supply < 0.999 then
            set_status(record, "low-power", "yellow")
        else
            set_status(record, "working", "green", craft.grade)
        end
    end
    alert(record, record.starved_since ~= nil and ctx.tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
end

-- An idle workshop without packs stays stopped while its input slot is empty or holds a defective
-- item: the furnace takes an inserted item into an attempt at once, so without packs the item left
-- the slot and seemed to vanish (held inside at 0%). Standard and positive items pass without packs:
-- they release the workshop on the next idle look.
local function hold_input(entity, source)
    if M.available(entity) > 1e-9 then return false end
    local stack = source and source[1]
    if not (stack and stack.valid_for_read) then return true end
    return model.grade_of(stack.quality.name) < 0
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

-- The leaving item: the top item of the input stack (the partly used one) at the reached quality,
-- with the same share of durability (as in handcraft) or the same rounds.
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
local function deliver(entity, stack, quality)
    local result = entity.get_inventory(defines.inventory.furnace_result)
    if not result then return false end
    local item = output_of(stack, quality)
    if not result.can_insert(item) then return false end
    if result.insert(item) < 1 then return false end
    take_top(stack)
    return true
end

local function start_item(record, entity, stack, tick)
    local from = stack.quality.name
    local sc = {item = stack.name, from = from, grade = model.grade_of(from), paid = 0, progress = 0,
        attempts = 0, last_tick = tick}
    local force_index = entity.force.index
    if sc.grade < 0 then
        sc.kind = "refine"
        sc.cost, sc.seconds = M.cost_of(sc.item)
        sc.start_grade = sc.grade
        sc.mode = M.mode_name(record)
    elseif from ~= "normal" and record.settings.reset_positive then
        sc.kind = "reset"
        local _, seconds = M.cost_of(sc.item)
        sc.seconds = seconds
        stats.add(force_index, "refine.resets")
    else
        sc.kind = "pass"
        sc.progress = 1
        stats.add(force_index, "refine.passed")
    end
    record.sc = sc
    return sc
end

-- One look of a script attempt. The item stays in the input slot until it leaves (mining or taking
-- it back returns it as it was; the packs already paid for the attempt are spent).
local function script_step(record, entity, ctx, stack, paused, stop)
    local tick = ctx.tick
    local sc = record.sc
    if sc and not (stack and stack.valid_for_read and stack.name == sc.item and stack.quality.name == sc.from) then
        record.sc, sc = nil, nil
    end
    if not sc and not stateful(stack) then
        record.next_tick = tick + 1 -- back to the furnace on the next look
        return
    end
    -- The furnace never takes these items; an attempt of the furnace itself waits meanwhile.
    if not entity.disabled_by_script then entity.disabled_by_script = true end
    local idle_power = machine_power(entity) / 30
    if not sc and (paused or stop) then
        set_status(record, "paused", "yellow")
        power.set(record.interface, idle_power)
        publish(record, false)
        record.next_tick = tick + M.LOOK
        return
    end
    sc = sc or start_item(record, entity, stack, tick)
    local dt = math.max(0, tick - sc.last_tick)
    sc.last_tick = tick
    if paused then
        set_status(record, "paused", "yellow")
        power.set(record.interface, idle_power)
        publish(record, true)
        record.next_tick = tick + M.LOOK
        return
    end

    local speed = math.max(entity.crafting_speed, 0.01)
    local starved, supply = false, 1
    if sc.progress < 1 then
        supply = power.satisfaction(record.interface)
        if sc.kind == "refine" then
            local rate = speed / (sc.seconds * 60)
            local slow = rules.workshop_mode(sc.mode).time
            local target = math.min(1, sc.progress + dt * rate * supply / slow)
            -- Paid ahead like a furnace attempt; without packs the attempt waits, nothing is lost.
            local need = rules.prepay(sc.cost, sc.paid, target, (M.LOOK + 1) * rate)
            if need > 0 then
                local drained = M.drain(entity, need)
                if drained > 0 then
                    sc.paid = math.min(1, sc.paid + drained / sc.cost)
                    stats.add(entity.force.index, "refine.resource", drained)
                end
                starved = drained + 1e-9 < need and sc.paid < 1 - 1e-9
            end
            sc.progress = math.min(target, sc.paid)
            if sc.paid >= 1 - 1e-9 and target >= 1 - 1e-9 then sc.progress = 1 end
        else
            -- Reset: 1/5 of the attempt, at most RESET_MAX_SECONDS (as in the furnace).
            local ticks = math.min(rules.RESET_SHARE * sc.seconds * 60 / speed, rules.RESET_MAX_SECONDS * 60)
            sc.progress = math.min(1, sc.progress + dt * supply / math.max(ticks, 1))
        end
    end

    if sc.progress >= 1 then
        if sc.kind == "refine" and not sc.final then roll(entity.force.index, sc, ctx) end
        local quality = sc.kind == "refine" and model.quality_name(sc.grade)
            or sc.kind == "reset" and "normal" or sc.from
        if deliver(entity, stack, quality) then
            record.sc = nil
            record.starved_since = nil
            alert(record, false)
            publish(record, false)
            record.next_tick = tick + 1
            return
        end
        set_status(record, "output-full", "yellow")
        power.set(record.interface, idle_power)
        publish(record, true)
        record.next_tick = tick + M.LOOK
        return
    end

    power.set(record.interface, starved and idle_power or machine_power(entity))
    if starved then
        set_status(record, "no-resource", "red")
        record.starved_since = record.starved_since or tick
    else
        record.starved_since = nil
        if supply < 0.999 then
            set_status(record, "low-power", "yellow")
        elseif sc.kind == "refine" then
            set_status(record, "working", "green", sc.grade)
        else
            set_status(record, sc.kind == "reset" and "reset" or "passing", "green")
        end
    end
    alert(record, record.starved_since ~= nil and tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
    publish(record, true)
    record.next_tick = tick + M.LOOK
end

function M.step(record, ctx)
    local entity = record.entity
    local tick = ctx.tick
    if (record.drive_tick or 0) <= tick then
        ensure_drive(entity)
        record.drive_tick = tick + 600
    end
    local crafting = entity.is_crafting()

    -- Circuit control: pause holds the current attempt; "stop" lets it finish first.
    -- The flag is written after the look: an attempt without packs also disables the furnace.
    local disable, paused, stop = false, false, false
    if record.settings.circuit then
        paused = emitter.read(entity, S.cmd_pause) > 0
        stop = emitter.read(entity, S.cmd_stop) > 0
        disable = paused or (stop and not crafting)
    end

    -- The resource total is needed only for the circuit signal; the GUI counts it itself.
    local emitting = record.emitter and record.emitter.valid
    record.available = emitting and M.available(entity) or nil
    local source = entity.get_inventory(defines.inventory.furnace_source)
    local input = source and source[1]
    if record.sc or stateful(input) then
        script_step(record, entity, ctx, input, paused, stop)
        if record.sc or record.next_tick > tick + 1 then return end
        -- Nothing left for the script: the furnace takes over on this look.
        input = source[1]
        if stateful(input) then return end
    end
    local recipe, quality = entity.get_recipe()
    if not crafting or not recipe or not quality then
        record.craft = nil
        local hold = hold_input(entity, source)
        record.held = hold or nil
        -- An idle furnace stays stopped with an empty input slot: an item put in between two looks
        -- must not be taken before the script has seen it (a used pack would come back full).
        local empty = source == nil or source.is_empty()
        local stopped = disable or hold or empty
        if entity.disabled_by_script ~= stopped then entity.disabled_by_script = stopped end
        local item_waits = hold and source ~= nil and not source.is_empty()
        if item_waits and not disable then
            record.starved_since = record.starved_since or tick
        else
            record.starved_since = nil
        end
        alert(record, record.starved_since ~= nil and tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
        power.set(record.interface, machine_power(entity) / 30)
        if disable then
            set_status(record, "paused", "yellow")
        elseif item_waits then
            set_status(record, "no-resource", "red")
        elseif entity.status == defines.entity_status.full_output then
            set_status(record, "output-full", "yellow")
        elseif source and source.is_empty() then
            set_status(record, "waiting", "yellow")
        else
            set_status(record, "idle", "yellow")
        end
        publish(record, false)
        -- Short polling: a new attempt must be seen early (see idle_look); a released furnace is seen
        -- on the next tick.
        record.next_tick = tick + (stopped and idle_look(record, entity) or 1)
        return
    end

    local key = recipe.name .. "|" .. entity.products_finished
    local craft = record.craft
    local progress = entity.crafting_progress
    if not craft or craft.key ~= key then craft = begin_craft(record, entity, recipe, quality, key, progress) end

    -- A paused refinement keeps the short look of its attempt: it may resume right after a look.
    local look = craft.kind == "refine" and record.look or M.LOOK
    if disable then
        set_status(record, "paused", "yellow")
        power.set(record.interface, machine_power(entity) / 30)
    elseif craft.kind == "refine" then
        refine_step(record, entity, craft, progress, ctx)
        look = record.look
    else
        record.held = nil
        power.set(record.interface, machine_power(entity))
        set_status(record, craft.kind == "reset" and "reset" or "passing", "green")
    end
    -- Close to completion the furnace takes the next item from the input slot by itself: look every
    -- tick so that a pack put there is seen (and handled by script) before that.
    if craft.kind ~= "refine" or craft.final then look = 1 end
    local stopped = disable or record.held == true
    if entity.disabled_by_script ~= stopped then entity.disabled_by_script = stopped end
    publish(record, true)
    record.next_tick = tick + look
end

-- Mining after the attempt is decided returns the item at the reached grade, not the starting one.
function M.on_mined(entity, buffer)
    local record = M.get(entity)
    local craft = record and record.craft
    if not (craft and craft.kind == "refine" and buffer and buffer.valid) then return end
    if craft.grade == craft.start_grade or not craft.item then return end
    local removed = buffer.remove({name = craft.item, quality = craft.from, count = 1})
    if removed > 0 then
        buffer.insert({name = craft.item, quality = model.quality_name(craft.grade), count = 1})
    end
end

function M.on_tick(ctx)
    local s = storage.ic_workshops
    if not s then return end
    for id, record in pairs(s.records) do
        if not record.entity.valid then
            M.forget(id)
        elseif record.next_tick <= ctx.tick then
            M.step(record, ctx)
        end
    end
end

-- Summary for the GUI: current craft, probabilities and resource.
function M.describe(record)
    local entity = record.entity
    local craft = record.sc or record.craft
    local info = {status = record.status_key or "idle", available = M.available(entity),
        settings = record.settings}
    if craft then
        info.kind, info.item, info.grade, info.attempts = craft.kind, craft.item, craft.grade, craft.attempts
        info.progress, info.paid = craft.progress or entity.crafting_progress, craft.paid
        info.cost, info.seconds = craft.cost, craft.seconds
        if craft.kind == "refine" and craft.grade < 0 then
            local mode = rules.workshop_mode(craft.mode)
            info.mode = mode.name
            info.distribution = rules.mode_distribution(craft.grade, mode)
            info.expected = rules.mode_attempts(craft.grade, mode)
        end
    end
    return info
end

return M
