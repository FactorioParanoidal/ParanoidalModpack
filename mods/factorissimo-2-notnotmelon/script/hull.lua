-- Paranoidal: reinforced hull of factory buildings (technologies factory-hull-1..3, prototypes/hull.lua).
-- Every level reduces the damage a factory building takes: part of each non-lethal hit is healed back
-- (the engine cannot raise the maximum health of placed buildings). From the first level an attack from
-- outside raises the alarm inside the factory and inside all factories built in it: a blinking red light
-- for 10 seconds and the alarm sound for 3 seconds for the players inside. A running alarm is not restarted.

local HULL = require("prototypes.hull-config")

local ALARM_TICKS = 600
local SOUND_REPEATS = 3
local SOUND_INTERVAL = 60
local MAX_FACTORIES = 1000 -- a factory can contain itself through packed copies; the walk stops anyway

local REDUCTION = {} -- technology name -> share of the damage that is healed back
for _, hull in ipairs(HULL) do REDUCTION["factory-hull-" .. hull.level] = hull.reduction / 100 end
local ALARM_TECHNOLOGY = "factory-hull-1"

-- force index -> {reduction = number, alarm = boolean}; dropped when a research of the force changes.
local hull_cache = {}

local function hull_of(force)
    local cached = hull_cache[force.index]
    if cached then return cached end
    local technologies = force.technologies
    local reduction = 0
    for name, value in pairs(REDUCTION) do
        local technology = technologies[name]
        if technology and technology.researched and value > reduction then reduction = value end
    end
    local alarm = technologies[ALARM_TECHNOLOGY]
    cached = {reduction = reduction, alarm = alarm ~= nil and alarm.researched}
    hull_cache[force.index] = cached
    return cached
end
factorissimo.factory_hull_of = hull_of

factorissimo.on_event({
    defines.events.on_research_finished,
    defines.events.on_research_reversed,
    defines.events.on_force_reset,
    defines.events.on_technology_effects_reset,
}, function(event)
    local force = event.force or (event.research and event.research.force)
    if force then hull_cache[force.index] = nil end
end)

factorissimo.on_event(defines.events.on_forces_merged, function()
    hull_cache = {}
end)

-- ALARM --

local function play_alarm(player_indices)
    for _, index in pairs(player_indices) do
        local player = game.get_player(index)
        if player and player.connected then player.play_sound {path = "factorissimo-alarm"} end
    end
end
factorissimo.register_delayed_function("factory_alarm_sound", play_alarm)

--- The factory and all factories built inside it (any depth).
local function factory_with_children(factory)
    local list, seen = {factory}, {[factory] = true}
    local by_entity = storage.factories_by_entity
    local i = 1
    while list[i] and i <= MAX_FACTORIES do
        local current = list[i]
        local surface = current.inside_surface
        if surface and surface.valid and current.layout then
            for _, building in pairs(surface.find_entities_filtered {area = factorissimo.factory_interior_area(current), type = BUILDING_TYPE}) do
                local child = by_entity[building.unit_number]
                if child and child.built and child.layout and not seen[child] then
                    seen[child] = true
                    list[#list + 1] = child
                end
            end
        end
        i = i + 1
    end
    return list
end

local function inside(position, x, y, D)
    return position.x >= x - D and position.x <= x + D and position.y >= y - D and position.y <= y + D
end

local function draw_alarm(factory)
    local surface = factory.inside_surface
    local force = factory.force
    local x, y = factory.inside_x, factory.inside_y
    local D = factory.layout.inside_size / 2 + 1
    local forces = {force}

    rendering.draw_rectangle {
        color = {r = 0.35, g = 0, b = 0, a = 0.35},
        filled = true,
        left_top = {x - D, y - D},
        right_bottom = {x + D, y + D},
        surface = surface,
        forces = forces,
        time_to_live = ALARM_TICKS,
        blink_interval = 30,
    }
    -- Light for factories without interior lighting, where the floor is dark.
    local step = D / 2
    for _, offset in pairs {{-step, -step}, {step, -step}, {-step, step}, {step, step}, {0, 0}} do
        rendering.draw_light {
            sprite = "utility/light_medium",
            scale = D / 6,
            intensity = 0.9,
            minimum_darkness = 0,
            color = {r = 1, g = 0, b = 0},
            target = {x + offset[1], y + offset[2]},
            surface = surface,
            forces = forces,
            time_to_live = ALARM_TICKS,
            blink_interval = 30,
        }
    end
    local door_x = factory.inside_door_x or x
    local door_y = factory.inside_door_y or (y + D)
    for _, offset in pairs {{-6, -2}, {6, -2}} do
        rendering.draw_sprite {
            sprite = "utility/danger_icon",
            x_scale = 2,
            y_scale = 2,
            target = {door_x + offset[1], door_y + offset[2]},
            surface = surface,
            forces = forces,
            time_to_live = ALARM_TICKS,
            render_layer = "entity-info-icon-above",
        }
    end
end

local function raise_alarm(factory)
    local tick = game.tick
    if (factory.alarm_until or 0) > tick then return end

    local listeners, heard = {}, {}
    for _, affected in pairs(factory_with_children(factory)) do
        affected.alarm_until = tick + ALARM_TICKS
        local surface = affected.inside_surface
        if surface and surface.valid then
            draw_alarm(affected)
            local surface_index = surface.index
            local D = affected.layout.inside_size / 2 + 2
            for _, player in pairs(affected.force.connected_players) do
                if not heard[player.index] and player.surface_index == surface_index
                    and inside(player.position, affected.inside_x, affected.inside_y, D) then
                    heard[player.index] = true
                    listeners[#listeners + 1] = player.index
                end
            end
        end
    end

    if listeners[1] then
        play_alarm(listeners)
        for i = 1, SOUND_REPEATS - 1 do
            factorissimo.execute_later("factory_alarm_sound", i * SOUND_INTERVAL, listeners)
        end
    end
end
factorissimo.raise_factory_alarm = raise_alarm

-- DAMAGE --

factorissimo.on_event(defines.events.on_entity_damaged, function(event)
    local entity = event.entity
    if not (entity and entity.valid) or not has_layout(entity.name) then return end
    local factory = storage.factories_by_entity[entity.unit_number]
    if not (factory and factory.layout) then return end
    local force = entity.force
    local hull = hull_of(force)

    local final_health = event.final_health
    if hull.reduction > 0 and final_health > 0 then
        entity.health = final_health + event.final_damage_amount * hull.reduction
    end

    if hull.alarm then
        local attacker = event.force
        if not (attacker and (attacker.index == force.index or force.is_friend(attacker))) then
            raise_alarm(factory)
        end
    end
end, {{filter = "type", type = BUILDING_TYPE}})
