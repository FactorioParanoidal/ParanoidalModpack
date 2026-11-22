local LIGHT_TECH = "factory-interior-upgrade-lights"
local PERMABLACK_SURFACES = {
    ["tenebris-factory-floor"] = true,
    ["maraxsis-trench-factory-floor"] = true,
}

local function clear_room_light(factory)
    local light = factory.ceiling_light
    if light and light.valid then light.destroy() end
    factory.ceiling_light = nil
end

local function update_room_light(factory, mixed)
    if not (mixed and factory.ceiling_light_researched) then
        clear_room_light(factory)
    elseif not (factory.ceiling_light and factory.ceiling_light.valid) then
        factory.ceiling_light = rendering.draw_light {
            sprite = "utility/light_medium",
            surface = factory.inside_surface,
            target = {x = factory.inside_x, y = factory.inside_y},
            -- Scale the 300 pixel light cone past the corners of the square workshop.
            scale = (factory.layout.inside_size + 8) * 2 * 32 / 300,
        }
    end
end

local function refresh_floor(index)
    local floors = storage.factory_floor_lighting
    local state = floors[index]
    if not state then return end
    state.queued = false
    local surface = game.get_surface(index)
    if not (surface and surface.valid) or state.lit + state.dark == 0 then
        floors[index] = nil
        return
    end

    local mode = "dark"
    if state.lit > 0 then
        -- Daytime also controls solar production. On a solar-capable shared floor prefer
        -- daylight to disabling the greenhouse for every room; do not edit solar-power here.
        mode = (state.dark == 0 or surface.get_property("solar-power") > 0) and "day" or "mixed"
    end
    local daytime = mode == "day" and 0 or 0.5
    if surface.daytime ~= daytime then surface.daytime = daytime end
    if not surface.freeze_daytime then surface.freeze_daytime = true end
    if (state.mode == "mixed") ~= (mode == "mixed") then
        for _, factory in pairs(storage.surface_factories[index] or {}) do
            if factory.ceiling_light_researched ~= nil then update_room_light(factory, mode == "mixed") end
        end
    end
    state.mode = mode
end
factorissimo.register_delayed_function("factory_refresh_floor_lighting", refresh_floor)

local function queue_floor(index, state)
    if state.queued then return end
    state.queued = true
    factorissimo.execute_later("factory_refresh_floor_lighting", 1, index)
end

local function adjust_count(state, lit, delta)
    if lit then state.lit = state.lit + delta else state.dark = state.dark + delta end
end

function factorissimo.clear_factory_lights(factory)
    clear_room_light(factory)
    local old = factory.ceiling_light_researched
    if old == nil then return end
    factory.ceiling_light_researched = nil
    local surface = factory.inside_surface
    if not (surface and surface.valid) then return end
    local state = storage.factory_floor_lighting[surface.index]
    if not state then return end
    adjust_count(state, old, -1)
    queue_floor(surface.index, state)
end

function factorissimo.build_lights_upgrade(factory)
    local surface, force = factory.inside_surface, factory.force
    if not (surface and surface.valid and factory.layout and force and force.valid) then return end
    local permablack = PERMABLACK_SURFACES[surface.name]
    if permablack then
        surface.brightness_visual_weights = {r = 1, g = 1, b = 1}
        surface.min_brightness = 0
    end
    local tech = force.technologies[LIGHT_TECH]
    local researched = not permablack and tech ~= nil and tech.researched
    local floors = storage.factory_floor_lighting or {}
    storage.factory_floor_lighting = floors
    local index = surface.index
    local state = floors[index] or {lit = 0, dark = 0}
    floors[index] = state
    local old = factory.ceiling_light_researched
    if old ~= researched then
        if old ~= nil then adjust_count(state, old, -1) end
        adjust_count(state, researched, 1)
        factory.ceiling_light_researched = researched
        if state.mode == "mixed" then update_room_light(factory, true) end
    end
    queue_floor(index, state)
end

local function restore_factory_lights()
    storage.factory_floor_lighting = {}
    for _, factory in pairs(storage.factories) do
        local upgrades = factory.layout and factory.layout.upgrades
        if not upgrades then
            factorissimo.build_lights_upgrade(factory)
        else
            for _, upgrade in pairs(upgrades) do
                if upgrade[1] == "factorissimo" and upgrade[2] == "build_lights_upgrade" then
                    factorissimo.build_lights_upgrade(factory)
                    break
                end
            end
        end
    end
end

-- A same-version update might load without on_configuration_changed. No writes in on_load.
local restore_on_tick = false
factorissimo.on_event(factorissimo.events.on_load(), function()
    restore_on_tick = not storage.factory_floor_lighting
end)
factorissimo.on_event(factorissimo.events.on_init(), function()
    restore_on_tick = false
    storage.factory_floor_lighting = storage.factory_floor_lighting or {}
end)
factorissimo.on_event(defines.events.on_tick, function()
    if not restore_on_tick then return end
    restore_on_tick = false
    restore_factory_lights()
end)

factorissimo.on_event(defines.events.on_forces_merged, function(event)
    for _, factory in pairs(storage.factories) do
        if factory.force == event.destination and factory.ceiling_light_researched ~= nil then
            factorissimo.build_lights_upgrade(factory)
        end
    end
end)
