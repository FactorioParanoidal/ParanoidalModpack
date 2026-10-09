-- Refinement workshop runtime.
-- The furnace recognises the inserted item and runs one hidden 1 -> 1 recipe per item; its burner
-- keeps an internal drive, so the two burner slots only store repair packs. This module:
--   * drains the durability of the stored packs while an attempt progresses (paid ahead by two
--     ticks; without resource the progress is held, nothing is lost),
--   * scales progress by the supply of the hidden electric consumer,
--   * decides each attempt shortly before completion: 90% one grade up, then 10% per extra grade;
--     below standard the same item stays inside and the next attempt starts automatically,
--   * resets positive quality (optional, 1/5 time, no packs) and passes standard items through.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local power = require("scripts.expansion.power")
local emitter = require("scripts.expansion.emitter")
local stats = require("scripts.stats")

local M = {}
local S = names.signals
local NO_RESOURCE_ALERT_TICKS = 300

function M.state()
    local s = storage.ic_workshops
    if not s then
        s = {records = {}}
        storage.ic_workshops = s
    end
    return s
end

local costs_cache
function M.reset_cache() costs_cache = nil end

function M.costs()
    if not costs_cache then
        local mod_data = prototypes.mod_data[names.mod_data]
        costs_cache = mod_data and mod_data.data.costs or {}
    end
    return costs_cache
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
end

function M.apply_settings(record, settings)
    if type(settings) ~= "table" then return end
    record.settings.reset_positive = settings.reset_positive == true
    M.set_circuit(record, settings.circuit == true)
end

function M.export_settings(record)
    return {reset_positive = record.settings.reset_positive, circuit = record.settings.circuit}
end

function M.set_circuit(record, enabled)
    record.settings.circuit = enabled
    if enabled then
        if not (record.emitter and record.emitter.valid) then record.emitter = emitter.create(record.entity) end
    else
        emitter.destroy(record.emitter)
        record.emitter, record.emitted = nil, nil
        if record.entity.valid and record.entity.disabled_by_script then record.entity.disabled_by_script = false end
    end
end

function M.track(entity, settings)
    if not (entity and entity.valid and entity.name == names.workshop) then return nil end
    local s = M.state()
    local record = s.records[entity.unit_number]
    if record and record.entity.valid then return record end
    record = {
        id = entity.unit_number, entity = entity, next_tick = 0, status = nil,
        settings = {reset_positive = false, circuit = false},
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

local function set_status(record, key, diode, parameter)
    local label_key = key .. "|" .. tostring(parameter)
    if record.status == label_key then return end
    record.status = label_key
    record.status_key = key
    local label = {"ic-quality.workshop-status-" .. key}
    if parameter ~= nil then label[2] = parameter end
    record.entity.custom_status = {diode = defines.entity_status_diode[diode], label = label}
end

local function grade_text(grade)
    return {"ic-quality.grade-" .. tostring(-grade)}
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
    local craft = record.craft
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
    elseif quality.name ~= "normal" and record.settings.reset_positive then
        craft.kind = "reset"
        entity.result_quality = "normal"
        if progress < 1 - rules.RESET_SHARE then
            entity.crafting_progress = 1 - rules.RESET_SHARE
            craft.progress = 1 - rules.RESET_SHARE
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

local function attempt(record, entity, craft, ctx)
    local force_index = entity.force.index
    local before = craft.grade
    local after = rules.refine_outcome(before, ctx.random)
    craft.attempts = craft.attempts + 1
    stats.add(force_index, "refine.attempts")
    if after == before then
        stats.add(force_index, "refine.fail")
    else
        stats.add(force_index, "refine.success")
        local jump = after - before
        stats.add(force_index, "refine.jump" .. math.min(3, jump))
    end
    if after == 0 then
        entity.result_quality = "normal"
        craft.final = true
        craft.grade = 0
        stats.add(force_index, "refine.normalized")
    else
        craft.grade = after
        craft.paid = 0
        craft.progress = 0
        entity.result_quality = model.quality_name(after)
        entity.crafting_progress = 0
    end
end

local function refine_step(record, entity, craft, progress, ctx)
    local rate = entity.crafting_speed / (craft.seconds * 60)
    local supply = power.satisfaction(record.interface)
    power.set(record.interface, machine_power(entity))
    local previous = craft.progress or 0
    if progress > previous and supply < 1 then progress = previous + (progress - previous) * supply end
    -- Pay ahead of the progress; without resource the attempt waits (nothing is lost).
    local need = rules.prepay(craft.cost, craft.paid, progress, 2 * rate)
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
    if craft.paid < 1 - 1e-9 then progress = math.min(progress, math.max(0, 1 - 1.5 * rate)) end
    if progress < entity.crafting_progress - 1e-9 then entity.crafting_progress = progress end
    craft.progress = progress

    if not craft.final and craft.paid >= 1 - 1e-9 and progress + 1.5 * rate >= 1 then
        attempt(record, entity, craft, ctx)
    end

    if starved then
        set_status(record, "no-resource", "red")
        record.starved_since = record.starved_since or ctx.tick
    else
        record.starved_since = nil
        if supply < 0.999 then
            set_status(record, "low-power", "yellow")
        else
            set_status(record, "working", "green", grade_text(craft.grade))
        end
    end
    alert(record, record.starved_since ~= nil and ctx.tick - record.starved_since >= NO_RESOURCE_ALERT_TICKS)
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
    local disable = false
    if record.settings.circuit then
        local paused = emitter.read(entity, S.cmd_pause) > 0
        local stop = emitter.read(entity, S.cmd_stop) > 0
        disable = paused or (stop and not crafting)
    end
    if entity.disabled_by_script ~= disable then entity.disabled_by_script = disable end

    record.available = M.available(entity)
    local recipe, quality = entity.get_recipe()
    if not crafting or not recipe or not quality then
        record.craft = nil
        record.starved_since = nil
        alert(record, false)
        power.set(record.interface, machine_power(entity) / 30)
        local source = entity.get_inventory(defines.inventory.furnace_source)
        if disable then
            set_status(record, "paused", "yellow")
        elseif entity.status == defines.entity_status.full_output then
            set_status(record, "output-full", "yellow")
        elseif source and source.is_empty() then
            set_status(record, "waiting", "yellow")
        else
            set_status(record, "idle", "yellow")
        end
        publish(record, false)
        -- Short polling: even the shortest attempt (x4 speed) lasts 15 ticks and must be seen early.
        record.next_tick = tick + 2
        return
    end

    local key = recipe.name .. "|" .. entity.products_finished
    local craft = record.craft
    local progress = entity.crafting_progress
    if not craft or craft.key ~= key then craft = begin_craft(record, entity, recipe, quality, key, progress) end

    if disable then
        set_status(record, "paused", "yellow")
        power.set(record.interface, machine_power(entity) / 30)
    elseif craft.kind == "refine" then
        refine_step(record, entity, craft, progress, ctx)
    else
        power.set(record.interface, machine_power(entity))
        set_status(record, craft.kind == "reset" and "reset" or "passing", "green")
    end
    publish(record, true)
    record.next_tick = tick + 1
end

-- Mining during a series returns the item at the grade it has reached, not the starting one.
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
    local craft = record.craft
    local info = {status = record.status_key or "idle", available = record.available or M.available(entity),
        settings = record.settings}
    if craft then
        info.kind, info.item, info.grade, info.attempts = craft.kind, craft.item, craft.grade, craft.attempts
        info.progress, info.paid = craft.progress or entity.crafting_progress, craft.paid
        info.cost, info.seconds = craft.cost, craft.seconds
        if craft.kind == "refine" and craft.grade < 0 then
            info.distribution = rules.refine_distribution(craft.grade)
            info.expected = rules.expected_attempts(craft.grade)
        end
    end
    return info
end

return M
