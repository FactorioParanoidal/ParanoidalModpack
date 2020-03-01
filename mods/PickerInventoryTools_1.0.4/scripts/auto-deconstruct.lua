--------------------------------------------------------------------------------
--[[autodeconstruct]] --
--------------------------------------------------------------------------------
--"title": "Auto Deconstruct",
--"author": "mindmix",
--"description": "This mod marks drills that have no more resources to mine for deconstruction."

local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Entity = require('__stdlib__/stdlib/entity/entity')
local table = require('__stdlib__/stdlib/utils/table')
local start_tick = require('__PickerAtheneum__/scripts/intra-mod-ticker')

local auto_deconstruct_event = Event.generate_event_name('picker-auto-deconstruct')

local targets =
    table.array_to_dictionary {
    'container',
    'logistic-container',
    'infinity-container'
}

local function has_targeters(entity)
    local filter = {force = entity.force, area = Area(entity.selection_box):expand(10), type = 'mining-drill'}
    for _, ent in pairs(entity.surface.find_entities_filtered(filter)) do
        if ent.drop_target == entity and not ent.to_be_deconstructed(entity.force) then
            return true
        end
    end
    return false
end

local function deconstructable(entity)
    return Entity.can_deconstruct(entity) and not Entity.is_circuit_connected(entity)
end

local function check_for_deconstruction(event)
    local drill = event.entity
    if drill and drill.valid then
        if drill.status == defines.entity_status.no_minable_resources then
            if not drill.to_be_deconstructed(drill.force) then
                if deconstructable(drill) and not Entity.has_fluidbox(drill) then
                    if drill.order_deconstruction(drill.force) then
                        if settings.global['picker-autodeconstruct-target'].value then
                            local target = drill.drop_target
                            if target and targets[target.type] and deconstructable(target) and not has_targeters(target) then
                                target.order_deconstruction(drill.force)
                            end
                        end
                    end
                end
            end
        elseif not event.ran_once then
            start_tick {
                event_name = auto_deconstruct_event,
                ran_once = true,
                entity = drill
            }
        end
    end
end
Event.on_event(auto_deconstruct_event, check_for_deconstruction)

local function on_resource_depleted(event)
    if settings.global['picker-autodeconstruct'].value then
        local resource = event.entity
        local filter = {type = 'mining-drill', area = Area(resource.selection_box):expand(10)}
        for _, drill in pairs(resource.surface.find_entities_filtered(filter)) do
            start_tick {
                event_name = auto_deconstruct_event,
                entity = drill
            }
        end
    end
end
Event.on_event(defines.events.on_resource_depleted, on_resource_depleted)

local function init()
    for _, surface in pairs(game.surfaces) do
        for _, drill in pairs(surface.find_entities_filtered {type = 'mining-drill'}) do
            check_for_deconstruction({entity = drill})
        end
    end
end
Event.on_init(init)
