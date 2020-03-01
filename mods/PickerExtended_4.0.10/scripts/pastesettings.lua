-------------------------------------------------------------------------------
--[Copy pipe direction]--
-------------------------------------------------------------------------------
--Modified from "Copy Assembler Pipe Direction", by "IronCartographer",
--https://mods.factorio.com/mods/IronCartographer/CopyAssemblerPipeDirection

local Event = require('__stdlib__/stdlib/event/event')

local function on_entity_settings_pasted(event)
    --Copy assembler pipe direction if entity is square and has fluidboxes
    local source = event.source and event.source.supports_direction and (event.source.fluidbox and #event.source.fluidbox > 0) and (event.source.prototype.collision_box and event.source.prototype.collision_box.x == event.source.prototype.collision_box.y) and event.source.prototype.fast_replaceable_group == 'assembling-machine'
    local destination =
        event.destination and event.destination.supports_direction and (event.destination.fluidbox and #event.destination.fluidbox > 0) and (event.destination.prototype.collision_box and event.destination.prototype.collision_box.x == event.destination.prototype.collision_box.y) and event.destination.prototype.fast_replaceable_group == 'assembling-machine'
    if source and destination then
        event.destination.direction = event.source.direction
    end
end
Event.register(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
