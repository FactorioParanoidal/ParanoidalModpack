-- Production modes of assembling machines and furnaces: normal / careful / precise.
-- The defect handler (scripts/defects/crafter.lua) applies the mode of each craft: slower
-- progress, fewer losses, better defect distribution and a stronger quality-module roll.
-- This module stores the selected mode, draws the alt-mode indicator, draws the extra power and
-- performs the boosted quality roll. A selected mode applies from the next operation on.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local power = require("scripts.expansion.power")
local shared = require("prototypes.expansion-shared")
local stats = require("scripts.stats")

local M = {}
M.types = {["assembling-machine"] = true, furnace = true}

function M.state()
    local s = storage.ic_modes
    if not s then
        s = {records = {}}
        storage.ic_modes = s
    end
    return s
end

local eligible_names = {}
function M.reset_cache() eligible_names = {} end

-- Player-placeable assembling machines and furnaces, except the workshop and Creative Mod.
function M.eligible(entity)
    if not (entity and entity.valid and M.types[entity.type] and entity.unit_number) then return false end
    local name = entity.name
    local result = eligible_names[name]
    if result == nil then
        local items = entity.prototype.items_to_place_this
        result = name ~= names.workshop and items ~= nil and #items > 0 and not name:find("^creative%-mod")
        eligible_names[name] = result
    end
    return result
end

function M.mode_name(entity)
    local s = storage.ic_modes
    local record = s and entity and entity.valid and entity.unit_number and s.records[entity.unit_number]
    return record and record.mode or "normal"
end

-- Mode definition for a new craft, nil for normal.
function M.definition(entity)
    local name = M.mode_name(entity)
    return name ~= "normal" and rules.modes[name] or nil
end

local function power_name(entity)
    local w, h = shared.box_tiles(entity.prototype.collision_box)
    local direction = entity.direction
    if direction == defines.direction.east or direction == defines.direction.west then w, h = h, w end
    local name = names.mode_power_prefix .. w .. "x" .. h
    return prototypes.entity[name] and name or nil
end

local function destroy_indicator(record)
    if record.render then
        local object = rendering.get_object_by_id(record.render)
        if object and object.valid then object.destroy() end
        record.render = nil
    end
end

local function draw_indicator(record)
    destroy_indicator(record)
    local entity = record.entity
    local box = entity.prototype.selection_box
    local object = rendering.draw_sprite({
        sprite = "ic-mode-" .. record.mode,
        target = {entity = entity, offset = {box.left_top.x + 0.45, box.left_top.y + 0.45}},
        surface = entity.surface,
        only_in_alt_mode = true,
        x_scale = 0.45, y_scale = 0.45,
        render_layer = "entity-info-icon-above",
    })
    record.render = object and object.id
end

-- on_tracked: called with the entity so that the defect scheduler watches it.
function M.set(entity, mode, on_tracked)
    if not M.eligible(entity) then return false end
    if not rules.modes[mode] then mode = "normal" end
    local s = M.state()
    local id = entity.unit_number
    local record = s.records[id]
    if mode == "normal" then
        if record then
            destroy_indicator(record)
            power.destroy(record.interface)
            s.records[id] = nil
        end
        return true
    end
    if not record then
        record = {id = id, entity = entity, surface_index = entity.surface.index,
            position = {x = entity.position.x, y = entity.position.y}}
        s.records[id] = record
        script.register_on_object_destroyed(entity)
    end
    record.mode = mode
    draw_indicator(record)
    if on_tracked then on_tracked(entity) end
    return true
end

function M.forget(id)
    local s = storage.ic_modes
    local record = s and s.records[id]
    if not record then return end
    destroy_indicator(record)
    power.destroy(record.interface)
    s.records[id] = nil
end

function M.rescan()
    local s = storage.ic_modes
    if not s then return end
    for id, record in pairs(s.records) do
        if not record.entity.valid then
            M.forget(id)
        elseif not (record.render and rendering.get_object_by_id(record.render)) then
            draw_indicator(record)
        end
    end
end

-- Extra power while a moded craft runs. Electric machines: hidden consumer of the same footprint;
-- burner machines: the extra energy is taken from the burning fuel. Returns the supply 0..1.
function M.draw_power(entity, definition, working, tick)
    local s = storage.ic_modes
    local record = s and s.records[entity.unit_number]
    if not record then return 1 end
    local base = entity.prototype.get_max_energy_usage(entity.quality) * math.max(0.2, 1 + entity.consumption_bonus)
    local extra = (working and definition) and base * rules.extra_power(definition) or 0
    if entity.prototype.electric_energy_source_prototype then
        if extra > 0 and not (record.interface and record.interface.valid) then
            local name = power_name(entity)
            record.interface = name and power.create(entity, name) or nil
        end
        power.set(record.interface, extra)
        return extra > 0 and power.satisfaction(record.interface) or 1
    end
    local burner = entity.burner
    if burner and extra > 0 then
        local elapsed = tick - (record.last_tick or tick)
        if burner.currently_burning and elapsed > 0 then
            burner.remaining_burning_fuel = math.max(0, burner.remaining_burning_fuel - extra * elapsed)
        end
    end
    record.last_tick = tick
    return 1
end

-- Stronger quality-module roll: same total chance as `boost` independent native rolls.
-- Applied once per craft, only when the native roll did not already upgrade the result.
function M.boost(entity, recipe_quality, definition, random)
    if not (definition and definition.boost > 1 and recipe_quality) then return false end
    local effects = entity.effects
    local quality_effect = effects and effects.quality or 0
    if quality_effect <= 0 then return false end
    local current = entity.result_quality
    if not current or current.name ~= recipe_quality.name then return false end
    local upgrade = recipe_quality.next
    if not upgrade then return false end
    local chance = math.min(1, quality_effect * recipe_quality.next_probability)
    local extra = rules.extra_chance(chance, definition.boost)
    if extra <= 0 or random() >= extra then return false end
    local force = entity.force
    if not force.is_quality_unlocked(upgrade) then return false end
    while upgrade.next and upgrade.next_probability > 0 and force.is_quality_unlocked(upgrade.next)
        and random() < upgrade.next_probability do
        upgrade = upgrade.next
    end
    entity.result_quality = upgrade
    stats.add(force.index, "mode.boost")
    return true
end

return M
