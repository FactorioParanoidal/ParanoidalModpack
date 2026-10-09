-- Settings follow the buildings: Shift+right/left click copy, blueprints (entity tags) and
-- replacing a building by another one at the same place (fast replace, upgrade planner).
local names = require("scripts.expansion.names")
local workshop = require("scripts.expansion.workshop")
local post = require("scripts.expansion.post")
local modes = require("scripts.expansion.modes")

local M = {}
local TAG = "ic_quality"
local REPLACE_TICKS = 2

local function key_of(surface_index, position)
    return string.format("%d:%.2f:%.2f", surface_index, position.x, position.y)
end

-- Settings of a live record (works also after its entity became invalid).
local function export_record(kind, record)
    if kind == "workshop" then
        local settings = workshop.export_settings(record)
        if settings.reset_positive or settings.circuit then return {workshop = settings} end
    elseif kind == "post" then
        return {post = post.export_settings(record)}
    elseif kind == "mode" and record.mode and record.mode ~= "normal" then
        return {mode = record.mode}
    end
end

function M.export(entity)
    if not (entity and entity.valid) then return nil end
    if entity.name == names.workshop then
        local record = workshop.get(entity)
        return record and export_record("workshop", record)
    elseif entity.name == names.post then
        local record = post.get(entity)
        return record and export_record("post", record)
    elseif modes.eligible(entity) then
        local mode = modes.mode_name(entity)
        if mode ~= "normal" then return {mode = mode} end
    end
end

-- Applies exported settings; hooks.track_machine lets the defect scheduler watch moded machines.
function M.import(entity, settings, hooks)
    if not (entity and entity.valid and type(settings) == "table") then return end
    if entity.name == names.workshop and settings.workshop then
        local record = workshop.track(entity)
        if record then workshop.apply_settings(record, settings.workshop) end
    elseif entity.name == names.post and settings.post then
        local record = post.track(entity)
        if record then post.apply_settings(record, settings.post) end
    elseif settings.mode and modes.eligible(entity) then
        modes.set(entity, settings.mode, hooks and hooks.track_machine)
    end
end

-- Settings of whatever building had this unit number (entity may already be invalid).
function M.export_unit(unit)
    for _, pair in ipairs({{"workshop", storage.ic_workshops}, {"post", storage.ic_posts}, {"mode", storage.ic_modes}}) do
        local record = pair[2] and pair[2].records[unit]
        if record then return export_record(pair[1], record) end
    end
end

-- A destroyed building leaves a ghost: robots rebuild it with the same settings.
function M.on_post_died(event)
    local ghost = event.ghost
    if not (ghost and ghost.valid and event.unit_number) then return end
    local settings = M.export_unit(event.unit_number)
    if not settings then return end
    local tags = ghost.tags or {}
    tags[TAG] = settings
    ghost.tags = tags
end

function M.on_settings_pasted(event, hooks)
    local source, destination = event.source, event.destination
    if not (source and source.valid and destination and destination.valid) then return end
    if source.name == names.workshop and destination.name == names.workshop then
        local from, to = workshop.get(source), workshop.track(destination)
        if from and to then workshop.apply_settings(to, workshop.export_settings(from)) end
    elseif source.name == names.post and destination.name == names.post then
        local from, to = post.get(source), post.track(destination)
        if from and to then post.apply_settings(to, post.export_settings(from)) end
    elseif modes.eligible(source) and modes.eligible(destination) then
        modes.set(destination, modes.mode_name(source), hooks and hooks.track_machine)
    end
end

local function blueprint_target(event, player)
    if event.record and event.record.valid then return event.record end
    for _, stack in ipairs({event.stack, player.blueprint_to_setup, player.cursor_stack}) do
        if stack and stack.valid_for_read and stack.is_blueprint then return stack end
    end
end

function M.on_setup_blueprint(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local target = blueprint_target(event, player)
    if not target then return end
    local mapping = event.mapping and event.mapping.get()
    if not mapping then return end
    for index, entity in pairs(mapping) do
        local settings = M.export(entity)
        if settings then target.set_blueprint_entity_tag(index, TAG, settings) end
    end
end

function M.tags_of(event)
    local tags = event.tags
    return tags and tags[TAG]
end

-- Remember the settings of a destroyed building for a replacement built on the same spot.
function M.remember(kind, record)
    local settings = export_record(kind, record)
    if not (settings and record.surface_index and record.position) then return end
    storage.ic_replaced = storage.ic_replaced or {}
    storage.ic_replaced[key_of(record.surface_index, record.position)] = {tick = game.tick, settings = settings}
    -- The destroyed event may arrive after the replacement was built: look for it now.
    local surface = game.get_surface(record.surface_index)
    if not surface then return end
    for _, entity in pairs(surface.find_entities_filtered({position = record.position})) do
        if entity.valid and entity.unit_number and entity.unit_number ~= record.id
            and entity.position.x == record.position.x and entity.position.y == record.position.y then
            M.consume(entity, M.hooks)
        end
    end
end

function M.consume(entity, hooks)
    local replaced = storage.ic_replaced
    if not replaced then return end
    local key = key_of(entity.surface.index, entity.position)
    local entry = replaced[key]
    if not entry then return end
    replaced[key] = nil
    if game.tick - entry.tick > REPLACE_TICKS then return end
    M.import(entity, entry.settings, hooks)
end

function M.cleanup()
    local replaced = storage.ic_replaced
    if not replaced then return end
    for key, entry in pairs(replaced) do
        if game.tick - entry.tick > REPLACE_TICKS then replaced[key] = nil end
    end
end

return M
