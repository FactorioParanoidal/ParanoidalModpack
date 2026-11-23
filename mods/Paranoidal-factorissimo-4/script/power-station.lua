local rules = require("script.power-station-rules")
local credit = require("script.power-station-credit")
local filters = require("script.power-station-filters")
local indicators = require("script.specialization-indicators")
local markers = require("script.passage-markers")
local M = {}
local ENERGY = "factory-specialization-power-energy"
local TECH = "factory-specialization-optimization"
local blocked = {furnace = true, lab = true, ["mining-drill"] = true, reactor = true,
    ["fusion-reactor"] = true, ["fusion-generator"] = true, ["burner-generator"] = true,
    ["solar-panel"] = true, ["rocket-silo"] = true}
local models = {}

local function allowed(factory)
    local b, f, s = factory.building, factory.force, factory.inside_surface
    return factory.built and not factory.inactive and factory.layout and b and b.valid and f and f.valid
        and b.force == f and s and s.valid and f.technologies[TECH] and f.technologies[TECH].researched
end

local function rated_pollution(entity, source)
    local p = entity.prototype
    local emissions = p.emissions_per_second.pollution or 0
    if source then
        emissions = emissions + (source.emissions_per_joule.pollution or 0)
            * p.get_max_energy_usage(entity.quality) * 60
    end
    return emissions * 60
end

local function model(entity)
    local key = entity.name .. "\0" .. entity.quality.name
    local cached = models[key]
    if cached ~= nil then return cached end
    local p, t = entity.prototype, entity.type
    local info = false
    if t == "boiler" and p.boiler_mode == "output-to-separate-pipe" then
        local source = p.burner_prototype or p.fluid_energy_source_prototype
        local steam, water
        for i, box in ipairs(p.fluidbox_prototypes) do
            if box.filter and box.filter.name == "steam" then steam = i end
            if box.filter and box.filter.name == "water" then water = box.filter end
        end
        if source and steam and water and p.target_temperature and p.target_temperature > water.default_temperature then
            info = {kind = "boiler", box = steam, temperature = p.target_temperature,
                rate = p.get_max_energy_usage(entity.quality) * 60
                    / ((p.target_temperature - water.default_temperature) * p.fluidbox_prototypes[steam].filter.heat_capacity),
                pollution = math.max(0, rated_pollution(entity, source))}
        end
    elseif t == "generator" and not p.burns_fluid then
        for i, box in ipairs(p.fluidbox_prototypes) do
            if box.filter and box.filter.name == "steam" then
                info = {kind = "engine", box = i, rate = (p.get_fluid_usage_per_tick(entity.quality) or 0) * 60,
                    minimum = p.minimum_input_temperature or box.filter.default_temperature,
                    maximum = p.maximum_input_temperature or math.huge,
                    useful_temperature = p.maximum_temperature, default_temperature = box.filter.default_temperature,
                    output = p.get_max_energy_production(entity.quality)}
                break
            end
        end
    elseif t == "assembling-machine" and (entity.name:match("^CW%-air%-filter%-machine%-")
        or entity.name:match("^angels%-air%-filter")) then
        local source = p.electric_energy_source_prototype or p.burner_prototype or p.fluid_energy_source_prototype
        info = {kind = "filter", cleaning = math.max(0, -rated_pollution(entity, source))}
    end
    models[key] = info
    return info
end

local function filter_ready(entity)
    local recipe, quality = entity.get_recipe()
    if not recipe then return false end
    -- A loaded craft remains serviced, including the clean-air pause after consuming its last filter.
    if entity.is_crafting() then return true end
    local inventory = entity.get_inventory(defines.inventory.crafter_input)
    for _, ingredient in ipairs(recipe.ingredients) do
        if ingredient.type == "item" and (not inventory
            or inventory.get_item_count {name = ingredient.name, quality = quality} < ingredient.amount) then return false end
        if ingredient.type == "fluid" then return false end
    end
    return true
end

local function snapshot(factory)
    local result = {nodes = 0, edges = {}, sources = {}, sinks = {}, tanks = {}, generators = {}, filters = {}, pollution = 0, cleaning = 0}
    local area = factorissimo.factory_interior_area(factory)
    local entities = factory.inside_surface.find_entities_filtered {area = area, force = factory.force}
    local boxes, connections, classified = {}, {}, {}
    for _, entity in ipairs(entities) do
        local p = entity.position
        if entity.unit_number and entity.type ~= "entity-ghost" and p.x >= area[1][1] and p.x < area[2][1]
            and p.y >= area[1][2] and p.y < area[2][2] then
            local info = model(entity)
            classified[entity.unit_number] = info
            -- A room containing a placed child factory is not a pure station. This also prevents
            -- applying this specialization to both child exhaust and its containing workshop.
            if has_layout(entity.name) or blocked[entity.type]
                or (entity.type == "electric-energy-interface" and entity.power_production > 0)
                or ((entity.type == "boiler" or entity.type == "generator" or entity.type == "assembling-machine") and not info) then
                result.disqualified = true
            end
            if info and info.kind == "filter" and info.cleaning > 0 then
                local receiver = entity.prototype.effect_receiver
                if receiver and receiver.uses_local_effects and filter_ready(entity) then
                    result.cleaning = result.cleaning + info.cleaning -- Nominal, never the boosted effect.
                    result.filters[#result.filters + 1] = entity
                end
            end
            local list, links = {}, {}
            boxes[entity.unit_number], connections[entity.unit_number] = list, links
            for i = 1, entity.fluids_count do
                local box = entity.get_fluid_box_prototype(i)
                if box and box.object_name == "LuaFluidBoxPrototype" and (not box.filter or box.filter.name == "steam")
                    and entity.status ~= defines.entity_status.pipeline_overextended then
                    result.nodes = result.nodes + 1
                    list[i] = result.nodes
                    links[i] = entity.get_fluid_box_pipe_connections(i) or {}
                    if entity.type == "storage-tank" and not entity.prototype.hidden then
                        result.tanks[#result.tanks + 1] = {node = list[i], capacity = entity.get_fluid_capacity(i)}
                    end
                end
            end
            if info and info.kind == "boiler" and list[info.box] then
                result.sources[#result.sources + 1] = {node = list[info.box], rate = info.rate, temperature = info.temperature}
                result.pollution = result.pollution + info.pollution
            elseif info and info.kind == "engine" and list[info.box] and info.rate > 0 then
                result.sinks[#result.sinks + 1] = {node = list[info.box], entity = entity, rate = info.rate, minimum = info.minimum,
                    maximum = info.maximum, useful_temperature = info.useful_temperature, default_temperature = info.default_temperature}
                result.generators[#result.generators + 1] = entity
                result.output = (result.output or 0) + info.output
            end
        end
    end
    for _, entity in ipairs(entities) do
        local list = entity.valid and boxes[entity.unit_number]
        if list then
            for i, node in pairs(list) do
                for _, link in ipairs(connections[entity.unit_number][i]) do
                    local target, index = link.target, link.target_fluidbox_index
                    local other = target and target.valid and boxes[target.unit_number]
                    if other and other[index] and link.flow_direction ~= "input" then
                        local back = connections[target.unit_number][index][link.target_pipe_connection_index or 0]
                        if back and back.flow_direction ~= "output" then
                            result.edges[#result.edges + 1] = {node, other[index]}
                        end
                    end
                end
            end
            if entity.type == "pump" then
                for i, input in pairs(list) do
                    local a = entity.get_fluid_box_prototype(i)
                    if a.production_type == "input" then
                        for j, output in pairs(list) do
                            if entity.get_fluid_box_prototype(j).production_type == "output" then
                                result.edges[#result.edges + 1] = {input, output}
                            end
                        end
                    end
                end
            end
        end
    end
    return result
end

local function update_panel(factory, state)
    local specialization = factory.specialization
    if not specialization then return end
    local was_visible = specialization.rows and specialization.rows[3] ~= nil
    indicators.update_station(factory, specialization, state)
    local is_visible = specialization.rows and specialization.rows[3] ~= nil
    if was_visible ~= is_visible then
        local index = storage.factory_passages and storage.factory_passages[factory.id]
        if index then markers.update_labels(factory, index) end
    end
end

function M.clear(factory)
    filters.clear(factory)
    update_panel(factory, nil)
    local state = factory.power_station
    if state and state.helper and state.helper.valid then state.helper.destroy() end
    factory.power_station = nil
    if storage.factory_station_active then storage.factory_station_active[factory.id] = nil end
    if storage.factory_station_dirty then storage.factory_station_dirty[factory.id] = nil end
end

function M.refresh(factory)
    if not allowed(factory) then M.clear(factory); return end
    local sample = snapshot(factory)
    local tiers = rules.evaluate(sample, factory.layout.inside_size)
    local state = factory.power_station or {}
    factory.power_station = state
    state.fuel, state.power, state.ecology = tiers.fuel, tiers.power, tiers.ecology
    state.generators, state.multiplier = tiers.generators or {}, credit.multiplier(tiers.fuel, tiers.power)
    state.dirty = false
    state.bounds = factorissimo.factory_interior_area(factory)
    state.capacity = math.max(1, (sample.output or 0) * (state.multiplier - 1) * 2)
    state.last_output = 0
    filters.apply(factory, sample.filters, filters.rate(state.ecology))
    storage.factory_station_active = storage.factory_station_active or {}
    if state.multiplier > 1 then
        if not (state.helper and state.helper.valid and state.helper.force == factory.force) then
            if state.helper and state.helper.valid then state.helper.destroy() end
            local pole = factorissimo.get_or_create_inside_power_pole(factory)
            state.helper = factory.inside_surface.create_entity {name = ENERGY, position = pole.position, force = factory.force}
            if state.helper then
                state.helper.destructible = false
                state.helper.operable = false
                state.helper.energy = 0
                state.last_buffer = 0
                state.last_tick = game.tick
            end
        end
        if state.helper then
            state.helper.electric_buffer_size = state.capacity
            storage.factory_station_active[factory.id] = factory
        end
    else
        if state.helper and state.helper.valid then state.helper.destroy() end
        state.helper = nil
        storage.factory_station_active[factory.id] = nil
    end
    update_panel(factory, state)
end

local function queue_refresh(factory)
    storage.factory_station_dirty = storage.factory_station_dirty or {}
    storage.factory_station_dirty[factory.id] = factory
    if factory.power_station then factory.power_station.dirty = true end
end

local function filter_live(factory, entity)
    local state = factory.power_station
    if not (state and state.ecology > 0 and not state.dirty and allowed(factory)
        and entity.force == factory.force and entity.surface == factory.inside_surface) then return false end
    local p, a = entity.position, state.bounds
    return p.x >= a[1][1] and p.x < a[2][1] and p.y >= a[1][2] and p.y < a[2][2] and filter_ready(entity)
end

local function mark_dirty(event)
    local entity = event.entity or event.destination
    if not (entity and entity.valid) or entity.name:find("^factory%-specialization%-") then return end
    filters.invalidate(entity) -- Also releases an old owner after a move into another room.
    local factory = remote_api.find_surrounding_factory(entity.surface, entity.position)
    if not (factory and factory.built) then return end
    filters.clear(factory)
    queue_refresh(factory)
end
factorissimo.on_event(factorissimo.events.on_built(), mark_dirty)
factorissimo.on_event(factorissimo.events.on_destroyed(), mark_dirty)
factorissimo.on_event({defines.events.on_player_rotated_entity, defines.events.on_entity_settings_pasted,
    defines.events.script_raised_teleported, defines.events.on_entity_cloned}, mark_dirty)

factorissimo.on_event(factorissimo.events.on_init(), function()
    filters.reset()
    models = {}
    storage.factory_station_active = storage.factory_station_active or {}
    storage.factory_station_dirty = {}
end)

factorissimo.on_event(defines.events.on_tick, function(event)
    filters.prune(filter_live, queue_refresh) -- Owned recipients only; no entity searches.
    local dirty = storage.factory_station_dirty
    if dirty then
        local budget = 2
        for id, factory in pairs(dirty) do
            dirty[id] = nil
            M.refresh(factory)
            budget = budget - 1
            if budget == 0 then break end
        end
    end
    local active = storage.factory_station_active
    if not active then return end
    for id, factory in pairs(active) do
        local state = factory.power_station
        local helper = state and state.helper
        if not allowed(factory) or not (helper and helper.valid) then
            M.clear(factory)
        elseif not state.dirty and state.last_tick ~= event.tick then
            local produced, network = 0, helper.electric_network_id
            if network then
                for _, generator in ipairs(state.generators) do
                    -- Disabled/sleeping generators can retain their last nonzero production value.
                    if generator.valid and generator.active
                        and (generator.status == defines.entity_status.working or generator.status == defines.entity_status.low_power)
                        and generator.force == factory.force and generator.surface == factory.inside_surface
                        and generator.electric_network_id == network then
                        local p, a = generator.position, state.bounds
                        if p.x >= a[1][1] and p.x < a[2][1] and p.y >= a[1][2] and p.y < a[2][2] then
                            produced = produced + generator.energy_generated_last_tick
                        end
                    end
                end
            end
            local before = helper.energy
            state.last_output = math.max(0, (state.last_buffer or before) - before)
            helper.energy = credit.refill(before, produced, state.multiplier, state.capacity)
            state.last_buffer, state.last_tick = helper.energy, event.tick
        end
    end
end)

return M
