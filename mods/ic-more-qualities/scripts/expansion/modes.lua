-- Production modes of assembling machines and furnaces: normal / careful / precise.
-- The defect handler (scripts/defects/crafter.lua) applies the mode of each craft: slower
-- progress, better defect distribution and a stronger quality-module roll.
-- This module stores the selected mode, draws the alt-mode indicator, draws the extra power and
-- performs the boosted quality roll. A selected mode applies from the next operation on; the running
-- operation keeps the mode it started with and keeps paying its extra power, also after a switch to
-- normal (the record stays until that operation is over).
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

local eligible_names, no_mode = {}, nil
function M.reset_cache() eligible_names, no_mode = {}, nil end

-- Machines that can never produce an item and construction sites (prototypes/expansion-final.lua).
local function excluded(name)
    if not no_mode then
        local mod_data = prototypes.mod_data and prototypes.mod_data[names.mod_data]
        no_mode = mod_data and mod_data.data.no_mode or {}
    end
    return no_mode[name] == true
end

-- Player-placeable assembling machines and furnaces that can produce items, except the workshop and
-- Creative Mod.
function M.eligible(entity)
    if not (entity and entity.valid and M.types[entity.type] and entity.unit_number) then return false end
    local name = entity.name
    local result = eligible_names[name]
    if result == nil then
        local items = entity.prototype.items_to_place_this
        result = name ~= names.workshop and items ~= nil and #items > 0 and not name:find("^creative%-mod")
            and not excluded(name)
        eligible_names[name] = result
    end
    return result
end

function M.mode_name(entity)
    local s = storage.ic_modes
    local record = s and entity and entity.valid and entity.unit_number and s.records[entity.unit_number]
    return record and record.mode or "normal"
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
-- Normal during a craft: the record stays as "normal" (no indicator, not exported) so that the craft
-- started in a mode keeps paying for it; draw_power drops it when no moded craft is left.
function M.set(entity, mode, on_tracked)
    if not M.eligible(entity) then return false end
    if not rules.modes[mode] then mode = "normal" end
    local s = M.state()
    local id = entity.unit_number
    local record = s.records[id]
    if mode == "normal" then
        if record then
            destroy_indicator(record)
            record.mode = "normal"
            if not entity.is_crafting() then M.forget(id) end
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
        record.max_power, record.electric = nil, nil -- prototypes may have changed
        if not record.entity.valid then
            M.forget(id)
        elseif not M.eligible(record.entity) then
            -- A machine that no longer has modes (e.g. after this update): drop the mode, its indicator
            -- and its extra power; its running craft continues at normal speed (defect scheduler record,
            -- same unit number).
            M.forget(id)
            local defects = storage.ic_defects
            local tracked = defects and defects.records[id]
            if tracked and tracked.craft then tracked.craft.mode = nil end
        elseif record.mode == "normal" then
            if not record.entity.is_crafting() then M.forget(id) end
        elseif not (record.render and rendering.get_object_by_id(record.render)) then
            draw_indicator(record)
        end
    end
end

-- Burner machines pay `energy` (J) from the change of a fuel item burnt earlier, the burning fuel and
-- then the fuel inventory; the rest of a whole item taken from the inventory stays as change.
-- Returns the paid share 0..1.
local function burn(record, burner, energy)
    local paid = math.min(energy, record.fuel_change or 0)
    record.fuel_change = (record.fuel_change or 0) - paid
    if paid < energy and burner.currently_burning then
        local remaining = burner.remaining_burning_fuel
        local take = math.min(remaining, energy - paid)
        if take > 0 then
            burner.remaining_burning_fuel = remaining - take
            paid = paid + take
        end
    end
    local inventory = burner.inventory
    if inventory then
        for index = 1, #inventory do
            if energy - paid <= 1e-6 then break end
            local stack = inventory[index]
            while energy - paid > 1e-6 and stack.valid_for_read do
                local prototype = stack.prototype
                local value = prototype.fuel_value or 0
                if value <= 0 then break end
                local burnt = prototype.burnt_result
                if burnt then
                    local output = burner.burnt_result_inventory
                    if not (output and output.insert({name = burnt.name, quality = stack.quality.name, count = 1}) > 0) then
                        break
                    end
                end
                if stack.count > 1 then stack.count = stack.count - 1 else stack.clear() end
                local take = math.min(value, energy - paid)
                paid = paid + take
                record.fuel_change = record.fuel_change + value - take
            end
        end
    end
    return math.max(0, math.min(1, paid / energy))
end

-- Extra power of a moded craft. definition: mode of the running craft (nil: no moded craft);
-- working: progress is being made (false: the machine stopped, no extra power is demanded).
-- Electric machines: hidden consumer of the same footprint; burner machines: the extra energy is
-- burnt from their fuel. Both pay for the interval since the previous call at the demand set then.
-- Returns the supply 0..1 of that interval; 0 for progress made while nothing was demanded.
function M.draw_power(entity, definition, working, tick)
    local s = storage.ic_modes
    if not (s and next(s.records)) then return 1 end -- called on every look of every machine
    local id = entity.unit_number
    local record = id and s.records[id]
    if not record then return 1 end
    local extra = 0
    local prototype
    -- Prototype data of the machine (its quality never changes), kept on the record; reset by rescan.
    local max_power = record.max_power
    if not max_power then
        prototype = entity.prototype
        max_power = prototype.get_max_energy_usage(entity.quality)
        record.max_power = max_power
        record.electric = prototype.electric_energy_source_prototype ~= nil
    end
    if working and definition then
        extra = max_power * math.max(0.2, 1 + entity.consumption_bonus) * rules.extra_power(definition)
    end
    local previous = record.demand -- nil: record from an older version
    local supply = 1
    if record.electric then
        supply = power.satisfaction(record.interface)
        if extra > 0 and not (record.interface and record.interface.valid) then
            local name = power_name(entity)
            record.interface = name and power.create(entity, name) or nil
        end
        power.set(record.interface, extra)
    else
        local burner = entity.burner
        local elapsed = tick - (record.last_tick or tick)
        local demand = previous or 0
        if burner and demand > 0 and elapsed > 0 then
            local burner_prototype = (prototype or entity.prototype).burner_prototype
            local effectivity = burner_prototype and burner_prototype.effectivity or 1
            if effectivity <= 0 then effectivity = 1 end
            supply = burn(record, burner, demand * elapsed / effectivity)
        end
        if extra <= 0 then record.fuel_change = nil end
    end
    -- The machine resumed after a stop: that progress was made without extra power.
    if working and definition and previous == 0 then supply = 0 end
    record.demand = extra
    record.last_tick = tick
    -- Normal was selected during a moded craft: that craft is over now.
    if not definition and record.mode == "normal" then M.forget(id) end
    return supply
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
