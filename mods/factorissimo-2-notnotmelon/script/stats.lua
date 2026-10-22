-- Paranoidal: state of every factory, sampled once per second from the pollution loop (script/pollution.lua).
--   power_ratio      power satisfaction of the network the factory is wired to, from its power sensor
--                    (factory-power-input-*: charges at 1 kW, the buffer is read and emptied here);
--   active           a machine inside works or a generator produces (checked once a minute, see scan_factory);
--   power_use/power_gen  estimated consumption and production inside, J per tick (same scan);
--   pollution_rate   pollution released outside during the last second;
--   uptime_since     start of the current streak of work without power shortage;
--   clean_since      start of the current streak of work without releasing pollution;
--   launched         the factory has worked with power and at least one connection.
-- Longest streaks per force are kept for MxlChievements (remote get_force_records). The first factory that
-- works inside another factory and the first factory clean for an hour research hidden "scripted"
-- technologies, which Milestones shows. PM RPG System gives experience for launching more factories of a
-- tier than the force ever had at the same time (rebuilding the same factories gives nothing).
-- Factories in Blueprint Sandboxes take no part in records, milestones and experience.

local SENSOR_ENERGY_PER_TICK = 1000 / 60 -- J, the input flow limit of the power sensor (1 kW)
local SENSOR_BUFFER = 10000 -- J, buffer_capacity of factory-power-input-* (prototypes/component.lua)
local ACTIVITY_INTERVAL = 3600
local HOUR = 216000
local CLEAN_MILESTONE_TICKS = HOUR
local POWER_OK = 0.99
local CLEAN_EPSILON = 0.01 -- released pollution per second treated as none
local LAUNCH_POWER = 0.5
local LAUNCH_XP_SHARE = {0.10, 0.20, 0.35, 0.50} -- share of the current level bar of PM RPG System, by tier

local MILESTONE_NESTED = "factory-milestone-nested"
local MILESTONE_CLEAN = "factory-milestone-clean"

local WORKING = {
    [defines.entity_status.working] = true,
    [defines.entity_status.low_power] = true,
}
local MIN_CONSUMPTION = 0.2 -- modules cannot lower the consumption below 20 %

local function interior_area(factory)
    local D = factory.layout.inside_size / 2 + 1
    return {{factory.inside_x - D, factory.inside_y - D}, {factory.inside_x + D, factory.inside_y + D}}
end
factorissimo.factory_interior_area = interior_area

-- INTERIOR SCAN: activity, machines, nested factories, electric power --
-- The engine has no power statistics per entity (only per network, and the interior shares the network of the
-- outside), so the power is estimated: working consumers at their full usage (modules and beacons included)
-- plus drain, idle ones at their drain; steam engines and turbines exactly (last tick), burner generators at full
-- power while working, solar panels by the solar power of the floor, electric energy interfaces by their settings.
-- Factory floors have the surface property "solar-power" = 0: solar panels there (also the hidden panels of
-- Bio Industries buildings) give nothing and are not counted as generators at all.
-- Factories built inside add their last values. One pass once a minute per factory (sample_factory) and every
-- 2 seconds for the factory selected in an open dispatcher.

local MACHINE_TYPES = {["assembling-machine"] = true, furnace = true, ["mining-drill"] = true, lab = true}
local BONUS_TYPES = {["assembling-machine"] = true, furnace = true, ["mining-drill"] = true, lab = true, ["rocket-silo"] = true}
local SCAN_TYPES = {
    "assembling-machine", "furnace", "mining-drill", "lab", "rocket-silo", "inserter", "beacon", "lamp", "radar",
    "roboport", "pump", "offshore-pump", "electric-turret", "boiler", "loader", "loader-1x1", "arithmetic-combinator",
    "decider-combinator", "selector-combinator", "programmable-speaker", "generator", "burner-generator", "solar-panel",
    "electric-energy-interface", BUILDING_TYPE,
}

--- Share of the full output of solar panels on the surface, or false when the surface gives no solar power
--- (factory floors: surface property "solar-power" = 0).
local function solar_share(surface)
    local power = surface.get_property("solar-power") / 100 * surface.solar_power_multiplier
    if power <= 0 then return false end
    return power * math.max(0, 1 - surface.darkness / 0.85)
end

local kinds = {} -- entity name -> what the scan reads from it, or false; derived from prototypes only
local function kind_of(name)
    local info = kinds[name]
    if info ~= nil then return info end
    info = false
    local prototype = prototypes.entity[name]
    if has_layout(name) then
        info = {kind = "factory"}
    elseif prototype and not name:find("^factory%-power%-input%-") then
        local t = prototype.type
        local source = prototype.electric_energy_source_prototype
        if t == "generator" then
            info = {kind = "generator"}
        elseif t == "burner-generator" then
            info = {kind = "burner", output = prototype.get_max_power_output() or 0}
        elseif t == "solar-panel" then
            info = {kind = "solar", output = prototype.get_max_energy_production() or 0}
        elseif t == "electric-energy-interface" then
            info = {kind = "interface"}
        elseif source then
            -- roboports: idle usage only, the charging of robots is not estimated
            local usage = t == "roboport" and (prototype.energy_usage or 0) or prototype.get_max_energy_usage()
            info = {kind = "consumer", usage = usage, drain = source.drain or 0, bonus = BONUS_TYPES[t], machine = MACHINE_TYPES[t]}
        elseif MACHINE_TYPES[t] then
            info = {kind = "machine", machine = true}
        end
    end
    kinds[name] = info
    return info
end

--- Scans the interior: factory.active, machines, machines_working, children, power_use, power_gen (J per tick),
--- generators, generators_working; active_tick = tick.
function factorissimo.scan_factory(factory, tick)
    factory.active_tick = tick
    local surface = factory.inside_surface
    if not (surface and surface.valid and factory.layout) then
        factory.active = false
        factory.power_use, factory.power_gen = nil, nil
        return
    end
    local use, gen, generators, generators_working = 0, 0, 0, 0
    local machines, machines_working, children = 0, 0, 0
    local solar -- nil: not read yet; false: the floor gives no solar power; else the share of full output
    local by_entity = storage.factories_by_entity
    for _, entity in pairs(surface.find_entities_filtered {area = interior_area(factory), type = SCAN_TYPES}) do
        local info = kind_of(entity.name)
        if info then
            local kind = info.kind
            if kind == "consumer" or kind == "machine" then
                local working = WORKING[entity.status]
                if info.machine then
                    machines = machines + 1
                    if working then machines_working = machines_working + 1 end
                end
                if kind == "consumer" then
                    if working then
                        local multiplier = 1
                        if info.bonus then
                            multiplier = 1 + entity.consumption_bonus
                            if multiplier < MIN_CONSUMPTION then multiplier = MIN_CONSUMPTION end
                        end
                        use = use + info.usage * multiplier + info.drain
                    else
                        use = use + info.drain
                    end
                end
            elseif kind == "generator" then
                generators = generators + 1
                local produced = entity.energy_generated_last_tick
                if produced > 0 then
                    gen = gen + produced
                    generators_working = generators_working + 1
                end
            elseif kind == "burner" then
                generators = generators + 1
                if entity.status == defines.entity_status.working then
                    gen = gen + info.output
                    generators_working = generators_working + 1
                end
            elseif kind == "solar" then
                if solar == nil then solar = solar_share(surface) end
                if solar then generators = generators + 1 end
                if solar and solar > 0 then
                    gen = gen + info.output * solar
                    generators_working = generators_working + 1
                end
            elseif kind == "interface" then
                local produced = entity.power_production
                use = use + entity.power_usage
                if produced > 0 then
                    generators = generators + 1
                    generators_working = generators_working + 1
                    gen = gen + produced
                end
            else -- a factory building inside
                local child = by_entity[entity.unit_number]
                if child and child ~= factory then
                    children = children + 1
                    use = use + (child.power_use or 0)
                    gen = gen + (child.power_gen or 0)
                end
            end
        end
    end
    factory.machines, factory.machines_working, factory.children = machines, machines_working, children
    factory.power_use, factory.power_gen = use, gen
    factory.generators, factory.generators_working = generators, generators_working
    factory.active = machines_working > 0 or gen > 0
end

--- Whether the factory has a copper wire to a power network.
function factorissimo.is_factory_wired(factory)
    local pole = factory._inside_power_pole
    if not (pole and pole.valid) then return false end
    -- The connector is allocated lazily: without wires it may not exist (nil), which means "not wired".
    local connector = pole.get_wire_connector(defines.wire_connector_id.pole_copper, false)
    return connector ~= nil and connector.connection_count > 0
end

-- The buffer size and flow limits of an electric energy interface are saved per entity: sensors of buildings
-- placed before 9.12.0 keep the empty buffer of the old prototype and never charge. Such a sensor is replaced
-- once by a new one from the current prototype (the power of the factory does not go through it).
local function renew_sensor(factory, sensor)
    factory.sensor_checked = true
    if (sensor.electric_buffer_size or 0) >= SENSOR_BUFFER then return sensor end
    local surface, name, position, force = sensor.surface, sensor.name, sensor.position, sensor.force
    sensor.destroy()
    local new = surface.create_entity {name = name, position = position, force = force}
    factory.outside_energy_receiver = new
    factory.power_ratio, factory.power_tick = nil, nil
    if not new then return nil end
    new.destructible = false
    new.operable = false
    new.rotatable = false
    return new
end

local function sample_power(factory, tick)
    local sensor = factory.outside_energy_receiver
    if sensor and sensor.valid and not factory.sensor_checked then sensor = renew_sensor(factory, sensor) end
    if not (sensor and sensor.valid) then
        factory.power_ratio, factory.power_tick = nil, nil
        return
    end
    local last = factory.power_tick
    local energy = sensor.energy
    sensor.energy = 0
    factory.power_tick = tick
    if not last or tick <= last then return end -- the first sample only starts the measurement
    local ratio = energy / (SENSOR_ENERGY_PER_TICK * (tick - last))
    factory.power_ratio = ratio > 1 and 1 or ratio
end

--- Forgets the measurements of a factory whose building was placed or removed.
function factorissimo.reset_factory_stats(factory)
    factory.power_ratio, factory.power_tick = nil, nil
    factory.active, factory.active_tick = nil, nil
    factory.power_use, factory.power_gen, factory.generators, factory.generators_working = nil, nil, nil, nil
    factory.machines, factory.machines_working, factory.children = nil, nil, nil
    factory.sensor_checked = nil
    factory.uptime_since, factory.clean_since = nil, nil
    factory.pollution_rate = nil
    factory.in_sandbox = nil
end

-- RECORDS, MILESTONES, EXPERIENCE --

local function force_records(force_index)
    local records = storage.factory_records
    local record = records[force_index]
    if not record then
        record = {clean = 0, uptime = 0}
        records[force_index] = record
    end
    return record
end

local function trigger_milestone(force, name)
    local done = storage.factory_milestones[force.index]
    if done and done[name] then return end
    local technology = force.technologies[name]
    if technology and not technology.researched then force.script_trigger_research(name) end
    done = done or {}
    done[name] = true
    storage.factory_milestones[force.index] = done
end

local function same_force(a, b)
    return a and b and a.valid and b.valid and a.index == b.index
end

local function launched_count(force, tier)
    local count = 0
    for _, other in pairs(storage.factories) do
        if other.built and other.launched and other.layout and (other.layout.tier or 0) == tier and same_force(other.force, force) then
            count = count + 1
        end
    end
    return count
end

local function reward_launch(factory)
    local force = factory.force
    local tier = factory.layout.tier or 0
    local count = launched_count(force, tier)
    local records = storage.launch_records[force.index] or {}
    storage.launch_records[force.index] = records
    if count <= (records[tier] or 0) then return end
    records[tier] = count

    local rpg = remote.interfaces["RPG"]
    if not (rpg and rpg.PlayerXPPercCurrentBar) then return end
    local building = factory.building
    local player = building and building.valid and building.last_user
    if not (player and player.valid) then return end
    local share = LAUNCH_XP_SHARE[tier] or LAUNCH_XP_SHARE[#LAUNCH_XP_SHARE]
    pcall(remote.call, "RPG", "PlayerXPPercCurrentBar", player.name, share)
end

local function is_nested(factory)
    local surface = factory.outside_surface
    return surface and surface.valid and storage.surface_factories[surface.index] ~= nil
end

local function in_sandbox(factory)
    if factory.in_sandbox == nil then
        local surface = factory.outside_surface
        factory.in_sandbox = surface and surface.valid
            and factorissimo.is_inside_sandbox(surface, {x = factory.outside_x, y = factory.outside_y}) or false
    end
    return factory.in_sandbox
end

-- SAMPLING --

--- Called once per second for every factory. `released` is the pollution released outside in that second.
function factorissimo.sample_factory(factory, released, tick)
    if not (factory.built and factory.layout) then
        if factory.power_tick or factory.uptime_since or factory.clean_since then factorissimo.reset_factory_stats(factory) end
        return
    end

    factorissimo.check_name_labels(factory)
    sample_power(factory, tick)
    local active_tick = factory.active_tick
    if not active_tick or active_tick + ACTIVITY_INTERVAL <= tick then factorissimo.scan_factory(factory, tick) end
    released = released or 0
    factory.pollution_rate = released

    local working = not factory.inactive and factory.active
    local ratio = factory.power_ratio
    if ratio then
        if working and ratio >= POWER_OK then
            factory.uptime_since = factory.uptime_since or tick
        else
            factory.uptime_since = nil
        end
    end
    if working and released <= CLEAN_EPSILON then
        factory.clean_since = factory.clean_since or tick
    else
        factory.clean_since = nil
    end

    local force = factory.force
    if not (force and force.valid) or in_sandbox(factory) then return end

    local record = force_records(force.index)
    if factory.uptime_since then
        local streak = tick - factory.uptime_since
        if streak > record.uptime then record.uptime = streak end
    end
    if factory.clean_since then
        local streak = tick - factory.clean_since
        if streak > record.clean then record.clean = streak end
        if streak >= CLEAN_MILESTONE_TICKS then trigger_milestone(force, MILESTONE_CLEAN) end
    end
    if not factory.inactive and is_nested(factory) then trigger_milestone(force, MILESTONE_NESTED) end

    if not factory.launched and not factory.inactive and ratio and ratio >= LAUNCH_POWER and next(factory.connections or {}) then
        factory.launched = true
        reward_launch(factory)
    end
end

--- Longest streaks of the force in ticks: {clean = ..., uptime = ...}.
function factorissimo.get_force_records(force_index)
    local record = storage.factory_records[force_index]
    return {clean = record and record.clean or 0, uptime = record and record.uptime or 0}
end

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.factory_records = storage.factory_records or {}
    storage.factory_milestones = storage.factory_milestones or {}
    if not storage.launch_records then
        -- Factories that already work when this feature appears count as launched without experience.
        storage.launch_records = {}
        for _, factory in pairs(storage.factories) do
            if factory.built and factory.layout and next(factory.connections or {}) then factory.launched = true end
        end
        for _, factory in pairs(storage.factories) do
            local force = factory.force
            if factory.launched and factory.built and factory.layout and force and force.valid then
                local records = storage.launch_records[force.index] or {}
                storage.launch_records[force.index] = records
                local tier = factory.layout.tier or 0
                records[tier] = (records[tier] or 0) + 1
            end
        end
    end
end)

-- Researching a hidden milestone technology again (for example after a reset of the force) is allowed.
factorissimo.on_event(defines.events.on_research_reversed, function(event)
    local research = event.research
    if research.name == MILESTONE_NESTED or research.name == MILESTONE_CLEAN then
        local done = storage.factory_milestones and storage.factory_milestones[research.force.index]
        if done then done[research.name] = nil end
    end
end)

factorissimo.on_event({defines.events.on_force_reset, defines.events.on_technology_effects_reset}, function(event)
    if storage.factory_milestones then storage.factory_milestones[event.force.index] = nil end
end)

factorissimo.on_event(defines.events.on_forces_merged, function(event)
    if storage.factory_milestones then storage.factory_milestones[event.source_index] = nil end
    if storage.factory_records then storage.factory_records[event.source_index] = nil end
    if storage.launch_records then storage.launch_records[event.source_index] = nil end
end)
