-- Production modes of assembling machines and furnaces: normal / careful / precise.
-- A machine in a mode is its hidden twin (prototypes/mode-twins.lua): crafting speed / 5 or / 20 and power x5 or
-- x20, so the engine itself runs every operation slower at any machine speed. A switch replaces the machine in
-- place by an engine fast replace, which keeps the recipe, the running operation (progress and the result
-- quality fixed at its start), inventories, modules, fluids, wires and circuit settings (engine check
-- test-runs/ic-twin1-20261102); health, last user, the finished counter and script flags are copied here.
-- The quality-module boost of a mode is a hidden beacon on the machine with weighted quality modules, tuned every
-- REFRESH ticks (and when the window is open, closed or settings are pasted) so that the engine roll has the
-- chance of `boost` independent native rolls (rules.boosted_chance). The defect decision of an operation
-- (careful: +4 control levels, precise: none) stays in scripts/defects/crafter.lua.
-- A switch to a weaker mode during an operation decides it again by the new mode (a boosted result is kept
-- with the share of the weaker chance, the defect roll is repeated); a switch to a stronger mode helps only
-- from the next operation on, so a mode cannot be held for a moment to improve one operation.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local wheel = require("scripts.wheel")
local stats = require("scripts.stats")

local M = {}
M.types = {["assembling-machine"] = true, furnace = true}
M.VERSION = 2
M.REFRESH = 90 -- the beacon follows modules, beacons and the recipe quality this often

-- Set by control.lua: recipe(name) -> compiled recipe info (scripts/defects/compiled.lua), no_quality() ->
-- recipes without quality (allow_quality = false), quality_everywhere.
M.context = {}
-- Set by control.lua: on_tracked(new_entity, old_unit_number, keep) of the defect scheduler, for the machines
-- that a migration replaces.
M.on_tracked = nil

local STRENGTH = {}
for index, name in ipairs(rules.mode_order) do STRENGTH[name] = index end

local split_cache, eligible_names, boost_names, no_mode, twin_list = {}, {}, {}, nil, nil
function M.reset_cache() split_cache, eligible_names, boost_names, no_mode, twin_list = {}, {}, {}, nil, nil end

-- {base, mode} of a twin name, nil for any other name.
function M.split(name)
    local cached = split_cache[name]
    if cached == nil then
        cached = false
        for _, mode in ipairs(rules.mode_order) do
            local suffix = names.mode_twin_suffix[mode]
            if suffix and #name > #suffix and name:sub(-#suffix) == suffix then
                local base = name:sub(1, -#suffix - 1)
                if prototypes.entity[base] and prototypes.entity[name] then cached = {base = base, mode = mode} end
            end
        end
        split_cache[name] = cached
    end
    return cached or nil
end

function M.base_name(name)
    local split = M.split(name)
    return split and split.base or name
end

-- Mode of a machine prototype name: "normal" for any machine that is not a twin.
function M.mode_of_name(name)
    local split = M.split(name)
    return split and split.mode or "normal"
end

-- Mode definition of a machine prototype name (nil for normal), for the defect scheduler.
function M.definition_of_name(name)
    local split = M.split(name)
    return split and rules.modes[split.mode] or nil
end

function M.twin_name(base, mode)
    if mode == "normal" then return base end
    local suffix = names.mode_twin_suffix[mode]
    local name = suffix and base .. suffix
    return name and prototypes.entity[name] and name or nil
end

-- Every twin prototype name (surface searches at a configuration change).
function M.twin_names()
    if not twin_list then
        twin_list = {}
        for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = {"assembling-machine", "furnace"}}})) do
            if M.split(name) then twin_list[#twin_list + 1] = name end
        end
        table.sort(twin_list)
    end
    return twin_list
end

-- Machines that can never produce an item and construction sites (prototypes/expansion-final.lua).
local function excluded(name)
    if not no_mode then
        local mod_data = prototypes.mod_data and prototypes.mod_data[names.mod_data]
        no_mode = mod_data and mod_data.data.no_mode or {}
    end
    return no_mode[name] == true
end

-- Player-placeable assembling machines and furnaces that can produce items and have twins (also the twins
-- themselves), except the workshop and Creative Mod.
function M.eligible(entity)
    if not (entity and entity.valid and M.types[entity.type] and entity.unit_number) then return false end
    local name = entity.name
    local result = eligible_names[name]
    if result == nil then
        local base = M.base_name(name)
        local prototype = prototypes.entity[base]
        local items = prototype and prototype.items_to_place_this
        result = base ~= names.workshop and items ~= nil and #items > 0 and not base:find("^creative%-mod")
            and not excluded(base) and M.twin_name(base, "careful") ~= nil and M.twin_name(base, "precise") ~= nil
        eligible_names[name] = result
    end
    return result
end

function M.mode_name(entity)
    if not (entity and entity.valid) then return "normal" end
    return M.mode_of_name(entity.name)
end

-- Can the machine take a quality effect from a beacon?
local function can_boost(entity)
    local name = entity.name
    local result = boost_names[name]
    if result == nil then
        local prototype = entity.prototype
        local allowed = prototype.allowed_effects
        local receiver = prototype.effect_receiver
        result = allowed ~= nil and allowed.quality == true and not (receiver and receiver.uses_beacon_effects == false)
        boost_names[name] = result
    end
    return result
end

function M.state()
    local s = storage.ic_modes
    if not s then
        s = {records = {}, buckets = {}, version = M.VERSION}
        storage.ic_modes = s
    end
    return s
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

local function destroy_beacon(record)
    local beacon = record.beacon
    if beacon and beacon.valid then beacon.destroy() end
    record.beacon, record.bits = nil, 0
end

-- Quality effect of the machine without its mode beacon (modules, player beacons), to four decimals (the
-- resolution of effects in Factorio 2.1).
function M.native_quality_effect(entity)
    local effects = entity and entity.valid and entity.effects
    local total = effects and effects.quality or 0
    local s = storage.ic_modes
    local record = s and entity.unit_number and s.records[entity.unit_number]
    local beacon = record and record.beacon
    if beacon and beacon.valid then
        local own = beacon.effects
        total = total - (own and own.quality or 0)
    end
    return math.floor(total * 10000 + 0.5) / 10000
end

-- The recipe and its quality the machine works on now (a furnace: also the previous one).
local function current_recipe(entity)
    local recipe, quality = entity.get_recipe()
    if recipe then return recipe.name, quality end
    if entity.type == "furnace" then
        local previous = entity.previous_recipe
        if previous then
            local name = previous.name
            if type(name) ~= "string" then name = name and name.name end
            local q = previous.quality
            if type(q) == "string" then q = prototypes.quality[q] end
            if name and prototypes.recipe[name] then return name, q end
        end
    end
end
M.current_recipe = current_recipe

-- Native upgrade chance of the machine's next operation and whether the mode boost applies to it.
local function native_chance(entity)
    if not can_boost(entity) then return nil end
    local name, quality = current_recipe(entity)
    if not (name and quality) then return nil end
    local ctx = M.context
    local no_quality = ctx.no_quality and ctx.no_quality()
    if no_quality and no_quality[name] then return nil end
    if quality.name:find("^ic%-defect%-") then return nil end
    -- Recycling never gets the boost (a recycler loop would multiply it), nor results that become standard.
    local info = ctx.recipe and ctx.recipe(name)
    if not info or info.recycling or not (info.all_finished or ctx.quality_everywhere) then return nil end
    local probability = quality.next and quality.next_probability or 0
    if probability <= 0 then return nil end
    local effect = M.native_quality_effect(entity)
    if effect <= 0 then return nil end
    return math.min(1, effect * probability), probability, effect
end

-- Beacon effect in thousandths (the weights of the mode modules, prototypes/mode-twins.lua) for a mode: the
-- engine chance (native effect + beacon) x next_probability equals rules.boosted_chance(native chance, boost).
local function target_bits(entity, mode)
    local definition = rules.modes[mode]
    if not (definition and definition.boost > 1) then return 0 end
    local chance, probability, effect = native_chance(entity)
    if not chance or chance >= 1 then return 0 end
    local wanted = rules.boosted_chance(chance, definition.boost) / probability - effect
    return math.max(0, math.min(2 ^ names.mode_module_count - 1, math.floor(wanted * 1000 + 0.5)))
end

local function set_bits(record, bits)
    local entity = record.entity
    local beacon = record.beacon
    if bits <= 0 then
        if beacon then destroy_beacon(record) end
        return
    end
    if not (beacon and beacon.valid) then
        beacon = entity.surface.create_entity({name = names.mode_beacon, position = entity.position, force = entity.force,
            raise_built = false, create_build_effect_smoke = false})
        if not beacon then return end
        beacon.destructible = false
        record.beacon, record.bits = beacon, 0
    end
    if record.bits == bits then return end
    local inventory = beacon.get_module_inventory()
    inventory.clear()
    local rest = bits
    for index = 1, names.mode_module_count do
        if rest % 2 == 1 then inventory.insert({name = names.mode_module_prefix .. index, count = 1}) end
        rest = math.floor(rest / 2)
    end
    record.bits = bits
end

-- Operations done in a mode (panel counters): the finished counter since the last look.
local function count_operations(record)
    local entity = record.entity
    local finished = entity.products_finished
    local done = finished - (record.finished or finished)
    if done > 0 then stats.add(entity.force.index, "mode." .. record.mode, done) end
    record.finished = finished
end

-- Looks at a moded machine: operations, beacon position and modules. Returns false when the record is gone.
function M.refresh(record)
    local entity = record.entity
    if not entity.valid then
        M.forget(record.id)
        return false
    end
    count_operations(record)
    local beacon = record.beacon
    if beacon and beacon.valid then
        if beacon.surface ~= entity.surface then
            destroy_beacon(record)
        else
            local a, b = beacon.position, entity.position
            if a.x ~= b.x or a.y ~= b.y then beacon.teleport(b) end -- moved by a script (dollies)
            if beacon.force ~= entity.force then beacon.force = entity.force end
        end
    end
    set_bits(record, target_bits(entity, record.mode))
    return true
end

-- Looks at the machine now if it is in a mode (window opened or closed, settings pasted, teleported).
function M.wake(entity)
    local s = storage.ic_modes
    local record = s and entity and entity.valid and entity.unit_number and s.records[entity.unit_number]
    if record then M.refresh(record) end
end

-- A twin without a record (built from a ghost, cloned, found at a configuration change): record, indicator,
-- beacon. Returns the record.
function M.adopt(entity)
    if not (entity and entity.valid and entity.unit_number) then return nil end
    local split = M.split(entity.name)
    if not split then return nil end
    local s = M.state()
    local id = entity.unit_number
    local record = s.records[id]
    if record and record.entity.valid then return record end
    record = {id = id, entity = entity, mode = split.mode, finished = entity.products_finished, bits = 0}
    s.records[id] = record
    script.register_on_object_destroyed(entity)
    draw_indicator(record)
    M.refresh(record)
    wheel.add(s.buckets, record, game.tick + M.REFRESH)
    return record
end

function M.forget(id)
    local s = storage.ic_modes
    local record = s and s.records[id]
    if not record then return end
    destroy_indicator(record)
    destroy_beacon(record)
    if record.interface and record.interface.valid then record.interface.destroy() end -- layout 1
    s.records[id] = nil
end

-- Script flags of a machine that a replacement does not carry.
local FLAGS = {"destructible", "minable_flag", "operable", "rotatable", "disabled_by_script"}

-- Replaces `entity` by the machine `target` of the same group. Returns the new entity or nil.
local function swap(entity, target, from_mode, to_mode)
    local s = storage.ic_modes
    local old_id = entity.unit_number
    local record = s and s.records[old_id]
    local viewers = {}
    for _, player in pairs(game.connected_players) do
        if player.opened == entity then viewers[#viewers + 1] = player end
    end
    -- The running operation: a switch to a weaker mode decides it again (see the header).
    local weaker = STRENGTH[to_mode] < STRENGTH[from_mode]
    local reroll
    if weaker and entity.is_crafting() and record and (record.bits or 0) > 0 then
        local _, recipe_quality = current_recipe(entity)
        local result = entity.result_quality
        if recipe_quality and result and result.level > recipe_quality.level and not result.name:find("^ic%-defect%-") then
            local chance = native_chance(entity)
            if chance then
                local before = rules.boosted_chance(chance, rules.modes[from_mode].boost)
                local after = rules.boosted_chance(chance, rules.modes[to_mode].boost)
                reroll = {keep = before > 0 and after / before or 1, quality = recipe_quality.name}
            end
        end
    end
    if record then
        count_operations(record)
        M.forget(old_id)
    end
    local surface, position = entity.surface, entity.position
    local health, last_user, finished = entity.health, entity.last_user, entity.products_finished
    local flags = {}
    for _, key in ipairs(FLAGS) do flags[key] = entity[key] end
    local new = surface.create_entity({name = target, position = position, direction = entity.direction,
        quality = entity.quality, force = entity.force, mirror = entity.mirroring, fast_replace = true, spill = false,
        raise_built = false, create_build_effect_smoke = false})
    if not (new and new.valid and not entity.valid) then
        -- Not replaced (no common fast-replaceable group): undo; a twin keeps its record.
        if new and new.valid and entity.valid then new.destroy() end
        if record and entity.valid then M.adopt(entity) end
        return nil
    end
    if health then new.health = health end
    if last_user then new.last_user = last_user end
    new.products_finished = finished
    for _, key in ipairs(FLAGS) do
        if new[key] ~= flags[key] then new[key] = flags[key] end
    end
    if reroll and new.is_crafting() and math.random() >= reroll.keep then new.result_quality = reroll.quality end
    for _, player in ipairs(viewers) do
        if player.valid and player.connected then player.opened = new end
    end
    return new, old_id, not weaker
end

-- Sets the mode of a machine. on_tracked(new_entity, old_unit_number, keep_decision): the defect scheduler
-- follows the replacement. Returns the machine (the same, or its replacement) or nil and a reason.
function M.set(entity, mode, on_tracked)
    if not M.eligible(entity) then return nil, "not-eligible" end
    if not rules.modes[mode] then mode = "normal" end
    local current = M.mode_name(entity)
    if current == mode then
        if mode ~= "normal" then
            local record = M.adopt(entity)
            if record then M.refresh(record) end
        end
        return entity
    end
    if entity.to_be_deconstructed() or entity.to_be_upgraded() then return nil, "marked" end
    local target = M.twin_name(M.base_name(entity.name), mode)
    if not target then return nil, "no-twin" end
    local new, old_id, keep = swap(entity, target, current, mode)
    if not new then return nil, "failed" end
    if mode ~= "normal" then M.adopt(new) end
    if on_tracked then on_tracked(new, old_id, keep) end
    return new
end

function M.on_tick(tick)
    local s = storage.ic_modes
    if not s then return end
    -- An older save loaded without a configuration change (same mod version): migrate now.
    if s.version ~= M.VERSION then
        M.rescan()
        return
    end
    local buckets = s.buckets
    if not buckets then return end
    local bucket = wheel.take(buckets, tick)
    if not bucket then return end
    local records = s.records
    for index = 1, #bucket do
        local record = records[bucket[index]]
        if record and record.due == tick then
            if record.entity.valid and not M.eligible(record.entity) then
                M.revert(record)
            elseif M.refresh(record) then
                wheel.add(buckets, record, tick + M.REFRESH)
            end
        end
    end
    wheel.release(bucket)
end

-- A twin of a machine that lost its modes (recyclers since 2026-11-02, a save loaded without a configuration
-- change, or a twin built from an older ghost) goes back to the original machine; the defect scheduler follows.
function M.revert(record)
    local entity = record.entity
    local new, old_id, keep = swap(entity, M.base_name(entity.name), record.mode, "normal")
    if new then
        if M.on_tracked then M.on_tracked(new, old_id, keep) end
    else
        M.forget(record.id)
    end
    return new
end

-- Configuration change with defects on. Layout 1 (until 2026-11-02: the machine slowed by script with a hidden
-- power interface) becomes twins; twins that lost their modes go back to the original; every twin on the map
-- gets a record; beacons of no record (a cloned area, a lost record) go.
function M.rescan()
    M.reset_cache()
    local s = storage.ic_modes
    local old = nil
    if s and s.version ~= M.VERSION then
        old = s.records or {}
        s = nil
        storage.ic_modes = nil
    end
    s = M.state()
    if old then
        local ids = {}
        for id in pairs(old) do ids[#ids + 1] = id end
        table.sort(ids)
        for _, id in ipairs(ids) do
            local record = old[id]
            if record.render then
                local object = rendering.get_object_by_id(record.render)
                if object and object.valid then object.destroy() end
            end
            if record.interface and record.interface.valid then record.interface.destroy() end
            local entity = record.entity
            if entity and entity.valid and record.mode and record.mode ~= "normal" and rules.modes[record.mode] then
                M.set(entity, record.mode, M.on_tracked)
            end
        end
    end
    local ids = {}
    for id in pairs(s.records) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local record = s.records[id]
        record.finished = nil
        if not record.entity.valid then M.forget(id) end
    end
    -- One search per surface for twins and beacons (no twin prototypes: nothing can be on the map).
    local twins = M.twin_names()
    local wanted = {names.mode_beacon}
    for _, name in ipairs(twins) do wanted[#wanted + 1] = name end
    local beacons = {}
    for _, surface in pairs(game.surfaces) do
        if #twins > 0 then
            for _, entity in pairs(surface.find_entities_filtered({name = wanted})) do
                if entity.name == names.mode_beacon then
                    beacons[#beacons + 1] = entity
                elseif not M.eligible(entity) then
                    M.forget(entity.unit_number)
                    swap(entity, M.base_name(entity.name), M.mode_name(entity), "normal")
                else
                    local record = M.adopt(entity)
                    if record then
                        record.finished = entity.products_finished
                        if not (record.render and rendering.get_object_by_id(record.render)) then draw_indicator(record) end
                        M.refresh(record)
                    end
                end
            end
        end
    end
    local own = {}
    for _, record in pairs(s.records) do
        if record.beacon and record.beacon.valid then own[record.beacon.unit_number] = true end
    end
    for _, beacon in ipairs(beacons) do
        if beacon.valid and not own[beacon.unit_number] then beacon.destroy() end
    end
    s.buckets = wheel.spread(s.records, game.tick, M.REFRESH)
end

-- Defects (and with them the modes) switched off: every twin goes back to its original machine. Twins come only
-- from modes, so a game without mode records has nothing to revert (no surface search).
function M.revert_all()
    M.reset_cache()
    if not storage.ic_modes then return end
    local s = storage.ic_modes
    for id in pairs(s.records or {}) do M.forget(id) end
    local twins = M.twin_names()
    local wanted = {names.mode_beacon}
    for _, name in ipairs(twins) do wanted[#wanted + 1] = name end
    for _, surface in pairs(game.surfaces) do
        if #twins > 0 then
            for _, entity in pairs(surface.find_entities_filtered({name = wanted})) do
                if entity.name == names.mode_beacon then entity.destroy()
                else swap(entity, M.base_name(entity.name), M.mode_name(entity), "normal") end
            end
        end
    end
    storage.ic_modes = nil
end

return M
