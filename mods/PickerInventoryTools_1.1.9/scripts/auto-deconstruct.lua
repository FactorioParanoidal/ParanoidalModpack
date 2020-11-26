--[[
    "title": "Auto Deconstruct",
    "author": "mindmix",
    "description": "This mod marks drills that have no more resources to mine for deconstruction."
--]]
local Event = require('__stdlib__/stdlib/event/event')
local Entity = require('__stdlib__/stdlib/entity/entity')
local table = require('__stdlib__/stdlib/utils/table')
local push_tick = require('__PickerAtheneum__/scripts/intra-mod-ticker')

local auto_deconstruct_event = Event.generate_event_name('picker-auto-deconstruct')

local targets =
    table.array_to_dictionary {
    'container',
    'logistic-container',
    'infinity-container'
}

local enabled = not script.active_mods['AutoDeconstruct']

local function has_other_drop_targets(entity)
    local filter = {force = entity.force, position = entity.position, radius = 6, type = 'mining-drill'}
    for _, ent in pairs(entity.surface.find_entities_filtered(filter)) do
        if ent.drop_target == entity and not ent.to_be_deconstructed(entity.force) then
            return true
        end
    end
    return false
end

local function deconstructable(entity)
    return Entity.can_deconstruct(entity) and Entity.count_circuit_connections(entity) <= 1 and not Entity.has_fluidbox(entity)
end

local function check_for_deconstruction(event)
    local drill = event.entity

    if not (drill and drill.valid) then
        return
    end

    if drill.status == defines.entity_status.no_minable_resources then
        if drill.to_be_deconstructed(drill.force) or not deconstructable(drill) then
            return
        end

        if not drill.order_deconstruction(drill.force) then
            return
        end

        if settings.global['picker-autodeconstruct-target'].value then
            local target = drill.drop_target
            if target and targets[target.type] and deconstructable(target) and not has_other_drop_targets(target) then
                target.order_deconstruction(drill.force)
            end
        end
    elseif not event.ran_once then
        -- no_minable_resources is false when the depleted event is triggered.
        -- Push it back into the queue to run on the next available tick.
        event.ran_once = true
        push_tick(event)
    end
end
Event.on_event(auto_deconstruct_event, check_for_deconstruction)

local function on_resource_depleted(event)
    if settings.global['picker-autodeconstruct'].value then
        local resource = event.entity
        local filter = {type = 'mining-drill', radius = 6, position = resource.position}
        for _, drill in pairs(resource.surface.find_entities_filtered(filter)) do
            push_tick {
                name = auto_deconstruct_event,
                entity = drill,
                added_on = event.tick,
                events_per_tick = 10
            }
        end
    end
end
Event.on_event_if(enabled, defines.events.on_resource_depleted, on_resource_depleted)

local function init()
    for _, surface in pairs(game.surfaces) do
        for _, drill in pairs(surface.find_entities_filtered {type = 'mining-drill'}) do
            check_for_deconstruction({entity = drill})
        end
    end
end
Event.on_init_if(enabled, init)
