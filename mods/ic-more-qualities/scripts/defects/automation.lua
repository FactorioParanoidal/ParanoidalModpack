-- Registry and tick scheduler for crafting machines and drills. Each entity is
-- looked at only when its next craft/cycle can approach completion; no surface or
-- inventory scans per tick. Storage: storage.ic_defects. No on_load mutations.
local crafter = require("scripts.defects.crafter")
local drill = require("scripts.defects.drill")
local model = require("scripts.defects.model")
local names = require("scripts.expansion.names")
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

-- Rebuilds a deterministic schedule spread over one second; stale buckets
-- could otherwise refer to ticks that are already in the past.
local function spread(s)
    local ids = {}
    for id in pairs(s.records) do ids[#ids + 1] = id end
    table.sort(ids)
    s.buckets = {}
    for i, id in ipairs(ids) do schedule(s, s.records[id], game.tick + 1 + i % 60) end
end

-- Player-placeable entities only: hidden technical machines of other mods,
-- Creative Mod test sources, the refinement workshop (own logic) and the relics of the
-- legendary ruins (AbandonedRuins-paranoidal, "pd-relic-*": they never add defects) are left alone.
function M.trackable(entity)
    if not (entity and entity.valid and M.kinds[entity.type] and entity.unit_number) then return false end
    local name = entity.name
    local result = trackable_names[name]
    if result == nil then
        local items = entity.prototype.items_to_place_this
        result = items ~= nil and #items > 0 and not name:find("^creative%-mod") and name ~= names.workshop
            and not name:find("^pd%-relic%-")
        trackable_names[name] = result
    end
    return result
end

function M.track(entity, source, delay)
    if not M.trackable(entity) then return end
    local s = state()
    local id = entity.unit_number
    local existing = s.records[id]
    if existing and existing.entity.valid then
        -- Already watched, maybe rarely (research 10): a new mode must be seen soon. The old bucket
        -- entry is skipped by the due check in on_tick.
        local due = game.tick + (delay or 1)
        if not existing.due or existing.due > due then schedule(s, existing, due) end
        return
    end
    local kind = M.kinds[entity.type]
    -- Research 10: a drill that is not defective has nothing to handle (no loss, no slowdown, no extra
    -- drain) and is not tracked at all; M.wake finds it again if the force loses research 10.
    if kind == "drill" and not model.is_defect(entity.quality.name) and M.level(entity.force) == 10 then return end
    local record = {id = id, entity = entity, kind = kind}
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
-- Existing records (pending decisions) are kept. visit(entity) also sees every found entity.
function M.rescan(visit)
    local s = state()
    -- Prototypes and technologies may have changed: count the levels again (M.track reads them).
    s.levels = nil
    for id, record in pairs(s.records) do
        if not record.entity.valid then s.records[id] = nil end
    end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{type = M.types}) do
            M.track(entity)
            if visit then visit(entity) end
        end
    end
    spread(s)
end

-- Every machine is looked at again within one second (research 10 was lost: rarely watched
-- machines need their normal looks back). Drills untracked at research 10 are found again; rare
-- (research reversed or reset), so a surface search is acceptable.
function M.wake()
    local s = storage.ic_defects
    if not s then return end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{type = "mining-drill"}) do M.track(entity) end
    end
    spread(s)
end

-- Completed quality-control level of a force. Kept in storage, so every peer reads the same value;
-- refreshed by research events and every LEVEL_REFRESH ticks (research changed by a script).
M.LEVEL_REFRESH = 600
function M.level(force)
    local s = state()
    local levels = s.levels
    if not levels then
        levels = {}
        s.levels = levels
    end
    local level = levels[force.index]
    if level == nil then
        level = model.completed_level(force.technologies)
        levels[force.index] = level
    end
    return level
end

-- Recounts the cached levels; a force that lost research 10 gets every machine looked at again.
function M.refresh_levels()
    local s = storage.ic_defects
    local levels = s and s.levels
    if not levels then return end
    local wake = false
    for index, level in pairs(levels) do
        local force = game.forces[index]
        local now = force and force.valid and model.completed_level(force.technologies) or nil
        if now ~= level then
            levels[index] = now
            if level == 10 and now then wake = true end
        end
    end
    if wake then M.wake() end
end

local function invalidate_level(force)
    local s = storage.ic_defects
    local levels = s and s.levels
    if not (levels and force and force.valid) then return end
    local before = levels[force.index]
    levels[force.index] = nil
    if before == 10 and M.level(force) < 10 then M.wake() end
end

function M.clear()
    trackable_names = {}
    storage.ic_defects = nil
end

local function warn(s, force, status, entity)
    local key = force.index .. ":" .. status .. ":" .. entity.name
    if s.warnings[key] then return end
    s.warnings[key] = true
    -- After quality control 10 the warning goes to the log only, not to chat.
    if M.level(force) < 10 then force.print({"ic-defects.machine-" .. status, entity.localised_name}) end
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
    for i = 1, #bucket do
        local record = s.records[bucket[i]]
        if record and record.due == tick then
            local entity = record.entity
            if not entity.valid then
                s.records[record.id] = nil
            else
                local force = entity.force
                local level = M.level(force)
                local step = record.kind == "drill" and drill.step or crafter.step
                local delay, warning = step(record, level, ctx)
                if warning then warn(s, force, warning, entity) end
                if delay == false then
                    -- Nothing left to handle for this entity (standard drill at research 10).
                    s.records[record.id] = nil
                elseif entity.valid then
                    schedule(s, record, tick + math.max(1, math.floor(delay or 30)))
                else
                    s.records[record.id] = nil
                end
            end
        end
    end
end

-- Handlers are added to the shared event dispatcher (scripts/events.lua).
-- on_built(entity, tags, source) is an optional extra hook for every built machine.
function M.register(enabled, context, events, on_built)
    local filters = {}
    for _, kind in ipairs(M.types) do filters[#filters + 1] = {filter = "type", type = kind} end
    local function built(event)
        if enabled() then M.track(event.entity) end
    end
    -- Filters are event-specific; the dispatcher merges them with other subsystems.
    events.on(defines.events.on_built_entity, built, filters)
    events.on(defines.events.on_robot_built_entity, built, filters)
    events.on(defines.events.script_raised_built, built, filters)
    events.on(defines.events.script_raised_revive, built, filters)
    events.on(defines.events.on_entity_cloned, function(event)
        if enabled() then M.track(event.destination, event.source) end
    end, filters)
    events.on(defines.events.on_chunk_generated, function(event)
        if not enabled() then return end
        for _, entity in pairs(event.surface.find_entities_filtered{area = event.area, type = M.types}) do
            M.track(entity)
            if on_built then on_built(entity) end
        end
    end)
    local function research_changed(event)
        local research = event.research
        if research and research.valid and research.name:sub(1, #model.research_prefix) == model.research_prefix then
            invalidate_level(research.force)
        end
    end
    events.on(defines.events.on_research_finished, research_changed)
    events.on(defines.events.on_research_reversed, research_changed)
    events.on(defines.events.on_force_reset, function(event) invalidate_level(event.force) end)
    events.on(defines.events.on_technology_effects_reset, function(event) invalidate_level(event.force) end)
    events.on(defines.events.on_tick, function(event)
        if not enabled() then return end
        if event.tick % M.LEVEL_REFRESH == 0 then M.refresh_levels() end
        M.on_tick(event.tick, context)
    end)
end

return M
