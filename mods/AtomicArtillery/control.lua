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
script.on_event(defines.events.on_entity_died, on_entity_died)
