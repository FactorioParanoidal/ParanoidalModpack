local function position_to_chunk(position)
    return {
        x = math.floor(position.x / 32),
        y = math.floor(position.y / 32)
    }
end
local function chunk_position_to_chunk_area(position)
    return {
        {
            x = position.x * 32 - 16,
            y = position.y * 32 - 16
        },
        {
            x = position.x * 32 + 16,
            y = position.y * 32 + 16
        }
    }
end

function on_entity_died(event)
    if event and event.cause then
        local cause = event.cause
        if cause.name == 'artillery-wagon' or cause.name == 'artillery-turret' then
            local entity = event.entity
            local position = position_to_chunk(entity.position)
            local force = event.cause.force
            local surface = event.cause.surface
            game.forces[force.name].chart(surface, chunk_position_to_chunk_area(position))
        end
    end
end
-- Only the structures artillery shoots at (nests, worms, turrets): without a filter the handler ran for every
-- death on the map, including each biter killed by the defences, trees and buildings.
script.on_event(defines.events.on_entity_died, on_entity_died, {
    { filter = "type", type = "unit-spawner" },
    { filter = "type", type = "turret" },
    { filter = "type", type = "ammo-turret" },
    { filter = "type", type = "electric-turret" },
    { filter = "type", type = "fluid-turret" },
    { filter = "type", type = "artillery-turret" },
})
