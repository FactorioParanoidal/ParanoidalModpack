-- Registry and tick scheduler for crafting machines and drills (storage.ic_defects). Rewritten 2026-10-29
-- for performance (review/ic-perf-audit-20261029/REPORT.md):
--   * only entities that can ever need handling are tracked: crafting machines whose recipes can make a
--     defect-capable product, take a finished ingredient or recycle (scripts/defects/compiled.lua), machines
--     with a production mode and defective drills;
--   * one timer wheel (scripts/wheel.lua): an entity is looked at only on its tick;
--   * a machine with nothing to handle sleeps; a player looking at it, pasted settings, a production mode
--     or a lost quality-control level wake it.
-- No surface scans per tick. No on_load mutations: an older storage layout is migrated on first access.
local crafter = require("scripts.defects.crafter")
local drill = require("scripts.defects.drill")
local model = require("scripts.defects.model")
local compiled = require("scripts.defects.compiled")
local wheel = require("scripts.wheel")
local names = require("scripts.expansion.names")
local M = {}

M.VERSION = 2
M.kinds = {
    ["assembling-machine"] = "crafter", furnace = "crafter", ["rocket-silo"] = "crafter",
    ["mining-drill"] = "drill",
}
M.types = {"assembling-machine", "furnace", "rocket-silo", "mining-drill"}
M.crafter_types = {"assembling-machine", "furnace", "rocket-silo"}
M.SPREAD = 60          -- a wake or migration spreads the looks over this many ticks
M.LEVEL_REFRESH = 600  -- quality-control levels are recounted this often (research changed by a script)
local trackable_names = {} -- deterministic prototype cache, rebuilt after load

local function migrate(s)
    -- Layout 1 (until 2026-10-29): two looks per craft, every machine and drill tracked, owed ingredients.
    -- Records are rebuilt by the rules of layout 2; running crafts are seen anew.
    local old = s.records or {}
    s.records, s.buckets, s.version = {}, {}, M.VERSION
    s.warnings = s.warnings or {}
    for key in pairs(s.warnings) do
        if key:find(":missed%-craft:") then s.warnings[key] = nil end
    end
    s.levels = nil
    local ids = {}
    for id in pairs(old) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local entity = old[id].entity
        if entity and entity.valid then M.track(entity) end
    end
    s.buckets = wheel.spread(s.records, game.tick, M.SPREAD)
end

local function state()
    local s = storage.ic_defects
    if not s then
        s = {records = {}, buckets = {}, warnings = {}, version = M.VERSION}
        storage.ic_defects = s
    elseif s.version ~= M.VERSION then
        migrate(s)
    end
    return s
end
M.state = state

-- Player-placeable entities only: hidden technical machines of other mods, Creative Mod test sources, the
-- refinement workshop (own logic) and the relics of the legendary ruins (AbandonedRuins-paranoidal,
-- "pd-relic-*": they never add defects) are left alone.
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

local function moded(id)
    local modes = storage.ic_modes
    return modes ~= nil and modes.records[id] ~= nil
end

-- Starts tracking an entity that can need handling, or moves the next look of a tracked one forward.
-- delay: ticks until the first look (default 1).
function M.track(entity, source, delay)
    if not M.trackable(entity) then return end
    local s = state()
    local id = entity.unit_number
    local tick = game.tick + (delay or 1)
    local existing = s.records[id]
    if existing and existing.entity.valid then
        wheel.advance(s.buckets, existing, tick)
        return
    end
    local kind = M.kinds[entity.type]
    if kind == "drill" then
        if not model.is_defect(entity.quality.name) then return end
    elseif not (compiled.machine(entity).relevant or moded(id)) then
        return
    end
    local record = {id = id, entity = entity, kind = kind, name = entity.name, type = entity.type,
        force_index = entity.force.index}
    -- A clone copies the machine state: keep the decision of its running craft or cycle.
    local previous = source and source.valid and source.unit_number and s.records[source.unit_number]
    if previous then
        local function copy(value)
            if type(value) ~= "table" or value.object_name then return value end
            local result = {}
            for key, item in pairs(value) do result[key] = copy(item) end
            return result
        end
        record.craft = copy(previous.craft)
        record.cycle = copy(previous.cycle)
        if record.cycle then record.cycle.source = nil end
    end
    s.records[id] = record
    wheel.add(s.buckets, record, tick)
end

-- A machine may have a new recipe (window, paste): look at it soon; an untracked one is tracked if it
-- can need handling now.
function M.wake(entity, delay)
    if entity and entity.valid and M.kinds[entity.type] then M.track(entity, nil, delay) end
end

local function surface_search(visit)
    local relevant = compiled.relevant_names({{filter = "type", type = M.crafter_types}})
    for _, surface in pairs(game.surfaces) do
        if #relevant > 0 then
            for _, entity in pairs(surface.find_entities_filtered({name = relevant})) do visit(entity) end
        end
        -- Defective drills only, but a quality filter compares levels (defects have level 0 like normal).
        for _, entity in pairs(surface.find_entities_filtered({type = "mining-drill"})) do visit(entity) end
    end
end

-- init/configuration change: discover entities and rebuild the schedule. Existing records are kept
-- (a running moded craft). visit(entity) also sees every found entity.
function M.rescan()
    trackable_names = {}
    local s = state()
    -- Prototypes and technologies may have changed: count the levels again.
    s.levels = nil
    for id, record in pairs(s.records) do
        local entity = record.entity
        if not entity.valid then
            s.records[id] = nil
        else
            record.speed, record.multiplier = nil, nil
            record.force_index = entity.force.index
        end
    end
    surface_search(function(entity) M.track(entity) end)
    -- Moded machines are tracked whatever their prototype.
    local modes = storage.ic_modes
    for _, mode_record in pairs(modes and modes.records or {}) do
        if mode_record.entity.valid then M.track(mode_record.entity) end
    end
    s.buckets = wheel.spread(s.records, game.tick, M.SPREAD)
end

-- Every machine is looked at again within one second (research 10 was lost: sleeping machines may have
-- crafts to roll again).
function M.wake_all()
    local s = storage.ic_defects
    if not s then return end
    s = state()
    s.buckets = wheel.spread(s.records, game.tick, M.SPREAD)
end

-- Completed quality-control level of a force. Kept in storage, so every peer reads the same value;
-- refreshed by research events and every LEVEL_REFRESH ticks (research changed by a script).
local function level_of(s, index)
    local levels = s.levels
    if not levels then
        levels = {}
        s.levels = levels
    end
    local level = levels[index]
    if level == nil then
        local force = game.forces[index]
        level = force and force.valid and model.completed_level(force.technologies) or 0
        levels[index] = level
    end
    return level
end

function M.level(force)
    return level_of(state(), force.index)
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
    if wake then M.wake_all() end
end

local function invalidate_level(force)
    local s = storage.ic_defects
    local levels = s and s.levels
    if not (levels and force and force.valid) then return end
    local before = levels[force.index]
    levels[force.index] = nil
    if before == 10 and M.level(force) < 10 then M.wake_all() end
end

function M.clear()
    trackable_names = {}
    compiled.reset()
    storage.ic_defects = nil
end

function M.reset_cache()
    trackable_names = {}
    compiled.reset()
end

local function warn(s, record, status, entity)
    local force = entity.force
    local key = force.index .. ":" .. status .. ":" .. record.name
    if s.warnings[key] then return end
    s.warnings[key] = true
    -- After quality control 10 the warning goes to the log only, not to chat.
    if level_of(s, force.index) < 10 then force.print({"ic-defects.machine-" .. status, entity.localised_name}) end
    log("IC defects: " .. status .. " for " .. record.name .. " (force " .. force.name .. ")")
end

-- context(): the scheduler context (scripts/defects/crafter.lua), built only on ticks with work.
function M.on_tick(tick, context)
    local s = storage.ic_defects
    if not s then return end
    if s.version ~= M.VERSION then s = state() end
    local bucket = wheel.take(s.buckets, tick)
    if not bucket then return end
    local ctx = context()
    local records = s.records
    for i = 1, #bucket do
        local record = records[bucket[i]]
        if record and record.due == tick then
            local entity = record.entity
            if not entity.valid then
                records[record.id] = nil
            else
                local level = level_of(s, record.force_index)
                local delay, warning
                if record.kind == "drill" then
                    delay, warning = drill.step(record, level, ctx)
                else
                    delay, warning = crafter.step(record, level, ctx)
                end
                if warning then warn(s, record, warning, entity) end
                if delay == false or not entity.valid then
                    records[record.id] = nil
                else
                    wheel.add(s.buckets, record, tick + math.max(1, math.floor(delay or 30)))
                end
            end
        end
    end
    wheel.release(bucket)
end

-- Handlers are added to the shared event dispatcher (scripts/events.lua).
function M.register(enabled, context, events)
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
        -- Ruins and other map generation scripts place buildings with the chunk.
        for _, entity in pairs(event.surface.find_entities_filtered{area = event.area, type = M.types}) do
            M.track(entity)
        end
    end)
    -- The window of a machine is open: its recipe may change at any moment. Closing it or pasting
    -- settings brings an early look (a sleeping machine wakes, an untracked one is tracked if needed).
    events.on(defines.events.on_gui_closed, function(event)
        if enabled() and event.entity then M.wake(event.entity) end
    end)
    events.on(defines.events.on_entity_settings_pasted, function(event)
        if enabled() then M.wake(event.destination) end
    end)
    events.on(defines.events.on_forces_merged, function()
        if enabled() then
            local s = state()
            s.levels = nil
            for _, record in pairs(s.records) do
                if record.entity.valid then record.force_index = record.entity.force.index end
            end
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
        local tick = event.tick
        if tick % M.LEVEL_REFRESH == 0 then M.refresh_levels() end
        -- Machines with an open window are looked at every 10 ticks while sleeping.
        if tick % 10 == 0 then
            local s = storage.ic_defects
            if s and s.version == M.VERSION then
                for _, player in pairs(game.connected_players) do
                    if player.opened_gui_type == defines.gui_type.entity then
                        local entity = player.opened
                        local record = entity and entity.valid and entity.unit_number and s.records[entity.unit_number]
                        if record then wheel.advance(s.buckets, record, tick + 1)
                        elseif entity and entity.valid and M.kinds[entity.type] then M.track(entity) end
                    end
                end
            end
        end
        M.on_tick(tick, context)
    end)
end

return M
