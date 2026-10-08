-- Registry and tick scheduler for crafting machines and drills. Each entity is
-- looked at only when its next craft/cycle can approach completion; no surface or
-- inventory scans per tick. Storage: storage.ic_defects. No on_load mutations.
local crafter = require("scripts.defects.crafter")
local drill = require("scripts.defects.drill")
local model = require("scripts.defects.model")
local M = {}

M.kinds = {
    ["assembling-machine"] = "crafter", furnace = "crafter", ["rocket-silo"] = "crafter",
    ["mining-drill"] = "drill",
}
M.types = {"assembling-machine", "furnace", "rocket-silo", "mining-drill"}
local trackable_names = {} -- deterministic prototype cache, rebuilt after load

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

local function state()
    local s = storage.ic_defects
    if not s then
        s = {records = {}, buckets = {}, warnings = {}}
        storage.ic_defects = s
    end
    return s
end

local function schedule(s, record, tick)
    record.due = tick
    local bucket = s.buckets[tick]
    if not bucket then
        bucket = {}
        s.buckets[tick] = bucket
    end
    bucket[#bucket + 1] = record.id
end

-- Player-placeable entities only: hidden technical machines of other mods and
-- Creative Mod test sources are left alone.
function M.trackable(entity)
    if not (entity and entity.valid and M.kinds[entity.type] and entity.unit_number) then return false end
    local name = entity.name
    local result = trackable_names[name]
    if result == nil then
        local items = entity.prototype.items_to_place_this
        result = items ~= nil and #items > 0 and not name:find("^creative%-mod")
        trackable_names[name] = result
    end
    return result
end

function M.track(entity, source, delay)
    if not M.trackable(entity) then return end
    local s = state()
    local id = entity.unit_number
    if s.records[id] and s.records[id].entity.valid then return end
    local record = {id = id, entity = entity, kind = M.kinds[entity.type]}
    -- A clone copies the machine state: keep the decision for its running craft.
    local previous = source and source.valid and source.unit_number and s.records[source.unit_number]
    if previous then
        record.craft = copy(previous.craft)
        record.cycle = copy(previous.cycle)
        record.debt = copy(previous.debt)
        record.debt_key = previous.debt_key
    end
    s.records[id] = record
    schedule(s, record, game.tick + (delay or 1))
end

-- init/configuration change: discover entities and rebuild the schedule.
-- Existing records (pending decisions) are kept.
function M.rescan()
    local s = state()
    for id, record in pairs(s.records) do
        if not record.entity.valid then s.records[id] = nil end
    end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{type = M.types}) do M.track(entity) end
    end
    -- Rebuild a deterministic schedule spread over one second; stale buckets
    -- could otherwise refer to ticks that are already in the past.
    local ids = {}
    for id in pairs(s.records) do ids[#ids + 1] = id end
    table.sort(ids)
    s.buckets = {}
    for i, id in ipairs(ids) do schedule(s, s.records[id], game.tick + 1 + i % 60) end
end

function M.clear()
    trackable_names = {}
    storage.ic_defects = nil
end

local function warn(s, force, status, entity)
    local key = force.index .. ":" .. status .. ":" .. entity.name
    if s.warnings[key] then return end
    s.warnings[key] = true
    force.print({"ic-defects.machine-" .. status, entity.localised_name})
    log("IC defects: " .. status .. " for " .. entity.name .. " (force " .. force.name .. ")")
end

-- context(): {random, finished, exclude_finished, min_energy, emissions}; built
-- only on ticks that have work.
function M.on_tick(tick, context)
    local s = storage.ic_defects
    local bucket = s and s.buckets[tick]
    if not bucket then return end
    s.buckets[tick] = nil
    local ctx = context()
    local levels = {}
    for i = 1, #bucket do
        local record = s.records[bucket[i]]
        if record and record.due == tick then
            local entity = record.entity
            if not entity.valid then
                s.records[record.id] = nil
            else
                local force = entity.force
                local level = levels[force.index]
                if level == nil then
                    level = model.completed_level(force.technologies)
                    levels[force.index] = level
                end
                local step = record.kind == "drill" and drill.step or crafter.step
                local delay, warning = step(record, level, ctx)
                if warning then warn(s, force, warning, entity) end
                if entity.valid then
                    schedule(s, record, tick + math.max(1, math.floor(delay or 30)))
                else
                    s.records[record.id] = nil
                end
            end
        end
    end
end

function M.register(enabled, context)
    local filters = {}
    for _, kind in ipairs(M.types) do filters[#filters + 1] = {filter = "type", type = kind} end
    local function built(event)
        if enabled() then M.track(event.entity) end
    end
    -- One registration per event: filters are event-specific.
    script.on_event(defines.events.on_built_entity, built, filters)
    script.on_event(defines.events.on_robot_built_entity, built, filters)
    script.on_event(defines.events.script_raised_built, built, filters)
    script.on_event(defines.events.script_raised_revive, built, filters)
    script.on_event(defines.events.on_entity_cloned, function(event)
        if enabled() then M.track(event.destination, event.source) end
    end, filters)
    script.on_event(defines.events.on_chunk_generated, function(event)
        if not enabled() then return end
        for _, entity in pairs(event.surface.find_entities_filtered{area = event.area, type = M.types}) do
            M.track(entity)
        end
    end)
    script.on_event(defines.events.on_tick, function(event)
        if enabled() then M.on_tick(event.tick, context) end
    end)
end

return M
