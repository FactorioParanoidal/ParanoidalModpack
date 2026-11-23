local indicators = require("script.specialization-indicators")
local inspection = require("script.specialization-inspection")
local station = require("script.power-station")

local TECH = "factory-specialization-optimization"
local PERIOD = 10 * 60
local HOVER_COOLDOWN = 2 * 60
local THRESHOLDS = {10, 20, 40}
local TYPES = {"assembling-machine", "furnace"}
local CHANNELS = {"speed", "consumption"}
local PREFIX = "factory-specialization-"
local INSPECT_INPUT = PREFIX .. "inspect"
local INSPECT_ROWS = {[PREFIX .. "speed"] = 1, [PREFIX .. "efficiency"] = 2}

local function eligible(factory)
    local building, force, surface = factory.building, factory.force, factory.inside_surface
    if not (factory.built and not factory.inactive and factory.layout and building and building.valid
        and force and force.valid and building.force == force and surface and surface.valid) then return false end
    local tech = force.technologies[TECH]
    return tech and tech.researched
end

local function change_effect(entity, entry, speed, consumption)
    local effect = entity.local_effect
    if not effect then return end
    local changed = false
    for i, channel in ipairs(CHANNELS) do
        local delta = i == 1 and speed or consumption
        local base = effect[channel] or 0
        local old = entry[channel]
        -- Keep unrelated channels and any same-channel replacement another script made since our write.
        if old and base == old.written then base = old.base end
        local value = math.min(1000, math.max(-1000, math.floor((base + delta) * 10000 + 0.5) / 10000))
        if value ~= (effect[channel] or 0) then
            effect[channel] = value
            changed = true
        end
        entry[channel] = delta ~= 0 and {base = base, written = value} or nil
    end
    if changed then
        entity.local_effect = effect
        -- The engine stores four decimals; compare against what actually survived the write.
        local actual = entity.local_effect
        for _, channel in ipairs(CHANNELS) do
            if entry[channel] then entry[channel].written = actual[channel] or 0 end
        end
    end
end

local function release(unit, entry)
    if entry.entity.valid then change_effect(entry.entity, entry, 0, 0) end
    storage.factory_specialization_effects[unit] = nil
end

local function clear(factory)
    station.clear(factory)
    local state = factory.specialization
    if not state then return end
    local slots = storage.factory_specialization_slots
    local slot = slots and slots[factory.id % PERIOD]
    if slot then slot[factory.id] = nil end
    for unit in pairs(state.units) do
        local entry = storage.factory_specialization_effects[unit]
        if entry and entry.factory_id == factory.id then release(unit, entry) end
    end
    inspection.clear(factory)
    indicators.clear(state)
    factory.specialization = nil
end
factorissimo.clear_factory_specialization = clear

local function sync(factory)
    local slots = storage.factory_specialization_slots
    if not slots then return end
    if not eligible(factory) then
        clear(factory)
        return
    end
    factory.specialization = factory.specialization or {units = {}}
    local index = factory.id % PERIOD
    local slot = slots[index] or {}
    slots[index] = slot
    slot[factory.id] = factory
end
factorissimo.sync_factory_specialization = sync

-- The IC machine modes replace the entity prototype without changing its underlying model/tier.
local function model_of(entity)
    local name = entity.name
    local base = name:match("^(.+)%-ic%-mode%-careful$") or name:match("^(.+)%-ic%-mode%-precise$")
    if base and script.active_mods["ic-more-qualities"] and prototypes.entity[base] then return base end
    return name
end

local function add_group(groups, key, model, recipe)
    local group = groups[key]
    if not group then
        group = {model = model, recipe = recipe, count = 0}
        groups[key] = group
    end
    group.count = group.count + 1
    return group
end

local function descending(groups)
    local list = {}
    for _, group in pairs(groups) do list[#list + 1] = group end
    table.sort(list, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        if a.model ~= b.model then return a.model < b.model end
        return (a.recipe or "") < (b.recipe or "")
    end)
    return list
end

local function tier_for(groups, total)
    for _, group in ipairs(groups) do
        if group.recipe ~= "" then -- A machine without a recipe cannot qualify for the series.
            if 10 * group.count < 9 * total then return 0 end
            for i = #THRESHOLDS, 1, -1 do
                if group.count >= THRESHOLDS[i] then return i end
            end
            return 0
        end
    end
    return 0
end

local function snapshot(factory)
    local machines, series, park, machine_series, machine_models = {}, {}, {}, {}, {}
    local area = factorissimo.factory_interior_area(factory)
    local left, right = area[1], area[2]
    for _, machine in ipairs(factory.inside_surface.find_entities_filtered {area = area, type = TYPES, force = factory.force}) do
        local p = machine.position
        -- The engine's area query uses bounding boxes; the machine's centre determines its floor.
        if p.x >= left[1] and p.x < right[1] and p.y >= left[2] and p.y < right[2]
            and not machine.name:find("^rsc%-silo%-stage") then
            local receiver = machine.prototype.effect_receiver
            if receiver and receiver.uses_local_effects then
                local model = model_of(machine)
                local recipe = machine.get_recipe()
                local name = recipe and recipe.name
                if not name and machine.type == "furnace" then
                    local previous = machine.previous_recipe
                    local id = previous and previous.name
                    name = type(id) == "string" and id or (id and id.name)
                end
                name = name or ""
                local i = #machines + 1
                machines[i] = machine
                machine_models[i] = add_group(park, model, model)
                machine_series[i] = add_group(series, model .. "\0" .. name, model, name)
            end
        end
    end
    series, park = descending(series), descending(park)
    -- Tied candidates share the highlight; an unconfigured machine can never lead a speed series.
    local best_series = 0
    for _, group in ipairs(series) do
        if group.recipe ~= "" then best_series = group.count; break end
    end
    local best_model = park[1] and park[1].count or 0
    local matches = {}
    for i, group in ipairs(machine_series) do
        matches[i] = (group.recipe ~= "" and group.count == best_series and 1 or 0)
            + (machine_models[i].count == best_model and 2 or 0)
    end
    return machines, series, park, matches
end

local function apply(state, factory_id, machines, speed, efficiency)
    local applied = storage.factory_specialization_effects
    local units = {}
    if speed > 0 or efficiency > 0 then
        for _, machine in ipairs(machines) do
            local unit = machine.unit_number
            local entry = applied[unit] or {entity = machine}
            entry.factory_id = factory_id
            change_effect(machine, entry, speed * 0.05, -efficiency * 0.05)
            applied[unit] = entry
            units[unit] = true
        end
    end
    for unit in pairs(state.units) do
        local entry = applied[unit]
        if not units[unit] and entry and entry.factory_id == factory_id then release(unit, entry) end
    end
    state.units = units
end

local function refresh(factory, tick, interval)
    if not eligible(factory) then clear(factory); return end
    local state = factory.specialization
    if not state or (state.tick and tick - state.tick < interval and inspection.has_snapshot(factory)) then return end
    local machines, series, park, matches = snapshot(factory)
    local speed, efficiency = tier_for(series, #machines), tier_for(park, #machines)
    apply(state, factory.id, machines, speed, efficiency)
    indicators.update(factory, state, series, park, #machines, speed, efficiency, THRESHOLDS)
    station.refresh(factory)
    state.tick = tick
    inspection.update(factory, machines, matches, speed, efficiency)
    return true
end

factorissimo.on_event(factorissimo.events.on_init(), function()
    inspection.reset()
    storage.factory_specialization_slots = {}
    storage.factory_specialization_effects = storage.factory_specialization_effects or {}
    storage.factory_specialization_markers = storage.factory_specialization_markers or {}
    for _, factory in pairs(storage.factories) do sync(factory) end
end)

factorissimo.on_event(defines.events.on_tick, function(event)
    local slots = storage.factory_specialization_slots
    local slot = slots and slots[event.tick % PERIOD]
    if not slot then return end
    for _, factory in pairs(slot) do refresh(factory, event.tick, HOVER_COOLDOWN) end
end)

local function sync_force(force)
    for _, factory in pairs(storage.factories or {}) do
        if factory.force == force then sync(factory) end
    end
end

factorissimo.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    if event.research.name == TECH then sync_force(event.research.force) end
end)

factorissimo.on_event({defines.events.on_force_reset, defines.events.on_technology_effects_reset}, function(event)
    sync_force(event.force)
end)

factorissimo.on_event(defines.events.on_forces_merged, function(event)
    sync_force(event.destination)
end)

local function selected_row(player)
    local entity = player.selected
    local index = entity and entity.valid and INSPECT_ROWS[entity.name]
    if not index then return end
    local markers = storage.factory_specialization_markers
    local id = markers and markers[entity.unit_number]
    local factory = id and storage.factories[id]
    local state = factory and factory.specialization
    local row = state and state.rows and state.rows[index]
    if row and row.marker == entity and inspection.at_factory(player, factory) then return factory, index, entity end
end

factorissimo.on_event(defines.events.on_selected_entity_changed, function(event)
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    local factory, row = selected_row(player)
    if inspection.select(player, factory, row, false) then
        if not factory or not refresh(factory, event.tick, HOVER_COOLDOWN) then inspection.redraw(player) end
    end
end)

factorissimo.on_event(INSPECT_INPUT, function(event)
    if event.in_gui then return end
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    local factory, row, marker = selected_row(player)
    if not marker then return end
    -- Ignore stale world selection when the operating click was outside the plate.
    local p, box = event.cursor_position, marker.selection_box
    if p.x < box.left_top.x or p.x > box.right_bottom.x or p.y < box.left_top.y or p.y > box.right_bottom.y then return end
    if inspection.select(player, factory, row, true) then inspection.redraw(player) end
end)

factorissimo.on_event(defines.events.on_player_changed_position, inspection.position_changed)
factorissimo.on_event({defines.events.on_player_changed_surface, defines.events.on_player_changed_force,
    defines.events.on_player_controller_changed, defines.events.on_player_died, defines.events.on_player_joined_game,
    defines.events.on_player_left_game, defines.events.on_player_removed}, function(event)
    inspection.drop(event.player_index)
end)

factorissimo.on_event(defines.events.on_entity_cloned, function(event)
    local effects = storage.factory_specialization_effects
    if not (effects and next(effects)) then return end
    local source, destination = event.source, event.destination
    if not (source.valid and destination.valid and (source.type == TYPES[1] or source.type == TYPES[2])) then return end
    local entry = effects[source.unit_number]
    -- If the clone carries local effects, strip only the source's owned contribution. The next
    -- snapshot can give the destination the bonus of its own floor, if any.
    if entry then change_effect(destination, {speed = entry.speed, consumption = entry.consumption}, 0, 0) end
end)
