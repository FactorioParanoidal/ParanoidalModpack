-- wind
-- https://www.geogebra.org/m/GDgua6HK
-- y = sin(3x/2)/3+sin(2x/2+2)/3+sin(3x/2-3)/2-sin(4x/2+1)/3-sin(5x/2+3)/4-sin(6x/2+4)/2+sin(x/3)+2.5

local handle_settings = require("scripts/handle_settings")
local wind_speed = require("scripts/wind_speed")

local powersetting = handle_settings.WindPower()
local use_extended_collision_area = handle_settings.useExtendedCollisionArea()
local use_surface_wind_speed = handle_settings.useSurfaceWindSpeed()
local wind_scale_with_pressure = handle_settings.scaleWithPressure()

local output_modifiers = {
    ['texugo-wind-turbine'] = 1,
    ['texugo-wind-turbine2'] = 10,
    ['texugo-wind-turbine3'] = 100,
    ['texugo-wind-turbine4'] = 1000,
}

local quality_factor = {
    [0] = 1,
    [1] = 1.3,
    [2] = 1.6,
    [3] = 1.9,
    [4] = 2.5
}

-- collision rectangles
local turbine_map = {
    ['texugo-wind-turbine'] = 'twt-collision-rect',
    ['texugo-wind-turbine2'] = 'twt-collision-rect2',
    ['texugo-wind-turbine3'] = 'twt-collision-rect3',
    ['texugo-wind-turbine4'] = 'twt-collision-rect4',
}

local reverse_map = {
    ['twt-collision-rect'] = 'texugo-wind-turbine',
    ['twt-collision-rect2'] = 'texugo-wind-turbine2',
    ['twt-collision-rect3'] = 'texugo-wind-turbine3',
    ['twt-collision-rect4'] = 'texugo-wind-turbine4',
}

local function resetWindCount(event)
    if storage.wind >= 1800 then
        storage.wind = 0
    end
end
-- ###############################################################

local function updatePressures()
    local pressures = {}
    for k, v in pairs(prototypes.space_location) do
        if v.type == "planet" then
            pressures[k] = v.surface_properties and v.surface_properties.pressure or 1000 -- if no pressure set, assume default (from nauvis)
        end
    end

    storage.pressures =  pressures
end
-- ###############################################################

local function businessLogic(event)
    storage.wind = storage.wind + 0.02
    local x = storage.wind
    -- legacy function
    local y = not use_surface_wind_speed and ((math.sin(3*x/2)/3)+(math.sin(2*x/2+2)/3)+(math.sin(3*x/2-3)/2)-(math.sin(4*x/2+1)/3)-
            (math.sin(5*x/2+3)/4)-(math.sin(6*x/2+4)/2)+math.sin(x/3)+2.5)/4.655 or 0

    local knownSurface = {}
    -- prevent nil access
    if not storage.pressures then
        updatePressures()
    end

    local nauvis = storage.pressures['nauvis']

    for _, wind_turbine in pairs(storage.wind_turbines) do
        local entity = wind_turbine.entity
        local name = wind_turbine.name

        if entity.valid and entity.type == 'electric-energy-interface' then
            local ql = entity.quality.level
            local qf
            -- if somebody uses a mod with additional quality levels
            if ql > 4 then
                qf = quality_factor[4] + (ql - 4) / ql
            else
                qf = quality_factor[ql]
            end

            local pf = 1
            if use_surface_wind_speed then
                local surface = wind_turbine.surface
                local surface_index = surface.index
                local surface_name = surface.name

                -- surface already used in this round?
                if knownSurface[surface_index] then
                    y = knownSurface[surface_index].y
                    pf = knownSurface[surface_index].pf
                else
                    -- we need ~70% propability (exactly 450/675 = 2/3). windspeed has an average of 50%
                    y = math.sqrt(wind_speed.windspeed(surface_index))

                    if wind_scale_with_pressure then
                        -- scale with pressure on planet
                        pf = storage.pressures[surface_name] / nauvis
                    end

                    knownSurface[surface_index] = {
                        y = y,
                        pf = pf
                    }
                end
            end

            entity.power_production = y * 67500/60 * powersetting * output_modifiers[name] * qf * pf
            entity.electric_buffer_size = 67500/60 * powersetting * output_modifiers[name] * qf * pf
        end
    end
end
-- ###############################################################

--- check after switching use_extended_collision_area on
local function check_collisions()
    for _, wind_turbine in pairs(storage.wind_turbines) do
        local entity = wind_turbine.entity
        local name = wind_turbine.name
        local position= wind_turbine.position
        local surface = wind_turbine.surface
        local cb = entity.prototype.collision_box
        local cm = entity.prototype.collision_mask.layers
        local area = {{ position.x + cb.left_top.x, position.y + cb.left_top.y },
                      { position.x + cb.right_bottom.x, position.y + cb.right_bottom.y }}

        -- ignore ore, ...
        local inside = surface.find_entities_filtered( { area = area, collision_mask = cm })

        if table_size(inside) > 2 then
            -- if colliding, spill it at the former position
            local quality = entity.quality.name
            local force = entity.force
            -- create alert
            for _, player in pairs(force.players) do
                player.add_custom_alert(entity,
                                        { type = 'entity', name = name, quality = quality, },
                                        { "alerts.texugo-wind-extended-collision-area" },
                                        true)
            end

            entity.destroy()
            surface.spill_item_stack({ position = position,
                                       stack = { name = name, count = 1, quality = quality },
                                       max_radius = 1, })
        end
    end
end

--- check after switching use_extended_collision_area off
local function check_connectivity()
    for _, wind_turbine in pairs(storage.wind_turbines) do
        local entity = wind_turbine.entity
        local name = wind_turbine.name
        local surface = wind_turbine.surface

        if not (entity.is_connected_to_electric_network() or surface.has_global_electric_network) then
            local quality = entity.quality.name
            local force = entity.force
            -- create alert
            for _, player in pairs(force.players) do
                player.add_custom_alert(entity,
                                        { type = 'entity', name = name, quality = quality, },
                                        { "alerts.texugo-wind-not-connected" },
                                        true)
            end
        end
    end
end
-- ###############################################################

--- register complexer events, i.e with additional filters
local function registerEvents()
    -- Damage to the base (can only take impact damage) is transmitted to the turbine (for example, when impacting with a car or tank)
    script.on_event(defines.events.on_entity_damaged, function(event)
        local entity = event.entity
        if entity and reverse_map[entity.name] then
            for _, turbine in pairs(entity.surface.find_entities_filtered{position = entity.position, name = reverse_map[entity.name]}) do
                if event.cause then
                    turbine.damage(event.original_damage_amount, event.force, event.damage_type.name, event.cause)
                else
                    turbine.damage(event.original_damage_amount, event.force, event.damage_type.name)
                end
                -- Keep the two entities damage in sync as long as the turbine hasn't been destroyed
                if turbine and turbine.valid then
                    entity.health = turbine.health
                end
            end
        end
    end,
            {
                {filter="type", type = "simple-entity-with-owner"},
                {filter="name", name = "twt-collision-rect"},
                {filter="name", name = "twt-collision-rect2"},
                {filter="name", name = "twt-collision-rect3"},
                {filter="name", name = "twt-collision-rect4"}
            }
    )
end
-- ###############################################################

local function build_entity(event)
    local twt = event.created_entity or event.entity
    if turbine_map[twt.name] then
        local registration_number = script.register_on_object_destroyed(twt)
        storage.wind_turbines[registration_number] = {
            entity = twt,
            name = twt.name,
            position = twt.position,
            surface = twt.surface
        }
        local collision_rect = twt.surface.create_entity{name = turbine_map[twt.name], position = twt.position, force = twt.force}
        collision_rect.minable = false
        collision_rect.health = twt.health
    end
end
-- ###############################################################

local function destroy_object(event)
    local twt = storage.wind_turbines[event.registration_number]
    if twt and turbine_map[twt.name] then
        if twt.surface.valid then
            for _, collision_rect in pairs(twt.surface.find_entities_filtered{position = twt.position, name = turbine_map[twt.name]}) do
                collision_rect.destroy()
            end
        end
    end
    storage.wind_turbines[event.registration_number] = nil
end
-- ###############################################################

local function checkSettings()
    if storage.old_extended_collision_area == nil then
        log("no old_extended_collision_area present")
        --- in prior versions all turbine always had an extended collision_area
        storage.old_extended_collision_area = true
    end

    if use_extended_collision_area ~= storage.old_extended_collision_area then
        log("use_extended_collision_area has changed")
        -- check existing wind turbines
        if use_extended_collision_area then
            check_collisions()
        else
            check_connectivity()
        end

        storage.old_extended_collision_area = use_extended_collision_area
    end
end
-- ###############################################################

--- called from on_init
local function initializer()
    storage.wind = storage.wind or 0
    storage.wind_turbines = storage.wind_turbines or {}
    storage.wind_speed_on_surface = storage.wind_speed_on_surface or {}

    checkSettings()
    registerEvents()
    updatePressures()
end
-- ###############################################################

--- called from on_load
local function load()
    registerEvents()
end
-- ###############################################################

--- called from on_configuration_changed
local function configuration_changed()
    checkSettings()
end
-- ###############################################################

local control = {}

control.on_init = initializer
control.on_load = load
control.on_configuration_changed = configuration_changed

control.events = {
    [defines.events.on_surface_created] = updatePressures,
    [defines.events.on_surface_deleted] = updatePressures,
    [defines.events.on_built_entity] = build_entity,
    [defines.events.on_robot_built_entity] = build_entity,
    [defines.events.script_raised_revive]= build_entity,
    [defines.events.on_object_destroyed]= destroy_object,
}

control.on_nth_tick = {
    [120] = businessLogic,
    [6000] = resetWindCount,
}

return control