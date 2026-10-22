--- Finding the thing a newly placed underground pipe ought to connect to.
local neighbors = {}

---Map from underground pipe direction to the locations and directions of neighbors
---it might connect to by adding a single pipe
---@type { [defines.direction]: { pos: Vector, dir: defines.direction }[] }
local directions_to_neighbors = {
    [defines.direction.north] = { -- for an underground pipe pointing north
        -- a pipe at one of these positions and directions would trigger a connection
        {pos={-1,-1}, dir=defines.direction.east }, -- one space ahead and left, pointing east
        {pos={ 0,-2}, dir=defines.direction.south}, -- two spaces ahead, pointing south
        {pos={ 1,-1}, dir=defines.direction.west }, -- one space ahead and right, pointing west
    },
    [defines.direction.east ] = {
        {pos={ 1,-1}, dir=defines.direction.south},
        {pos={ 2, 0}, dir=defines.direction.west },
        {pos={ 1, 1}, dir=defines.direction.north},
    },
    [defines.direction.south] = {
        {pos={ 1, 1}, dir=defines.direction.west },
        {pos={ 0, 2}, dir=defines.direction.north},
        {pos={-1, 1}, dir=defines.direction.east },
    },
    [defines.direction.west ] = {
        {pos={-1, 1}, dir=defines.direction.north},
        {pos={-2, 0}, dir=defines.direction.east },
        {pos={-1,-1}, dir=defines.direction.south},
    },
}

---@param entity LuaEntity
local function entity_type_or_ghost_type(entity)
    return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

---@param entity LuaEntity
---@param position MapPosition
---@return boolean place
local function should_place_based_on_neighbor_fluidbox_prototypes(entity, position)
    local fluidbox = entity.fluidbox
    for i = 1, #fluidbox do
        for _, pipe_connection in pairs( fluidbox.get_pipe_connections(i) ) do
            -- floor operation rounds to nearest 0.5 to mimic pipe connection snapping behavior
            if position[1] == math.floor( ( pipe_connection.target_position.x + 0.25 ) * 2 ) / 2 and
               position[2] == math.floor( ( pipe_connection.target_position.y + 0.25 ) * 2 ) / 2 then
                return true
            end
        end
    end
    return false
end

--- Is this entity, found at a candidate position, a non-pipe entity with a fluid connection onto `pipe_position`?
---@param candidate_entity LuaEntity
---@param entity_type string
---@param pipe_position MapPosition
---@return boolean
local function is_fluidbox_neighbor(candidate_entity, entity_type, pipe_position)
    -- fluid wagons have fluidbox connections for pumps, but not for pipes
    if entity_type == "pipe" or entity_type == "pipe-to-ground" or entity_type == "fluid-wagon" then
        return false
    end
    local fluidbox = candidate_entity.fluidbox
    return fluidbox ~= nil and #fluidbox > 0
        and should_place_based_on_neighbor_fluidbox_prototypes(candidate_entity, pipe_position)
end

--- Look at the three possible locations for another underground or entity to connect to.
--- One area search per location: it already returns the undergrounds and ghosts that
--- separate find_entity calls used to look up first, so they are recognized from its result.
---@param surface LuaSurface
---@param underground_position MapPosition
---@param neighbors_directions { pos: Vector, dir: defines.direction }[]
---@param underground_entity_name string
---@param pipe_position MapPosition
---@return boolean place Found something worth connecting to
---@return boolean neighbor_is_ghost What we found is a ghost, so our pipe has to be one too
local function find_connection_neighbor(
    surface, underground_position, neighbors_directions, underground_entity_name, pipe_position)
    for _, neighbor_candidate in pairs(neighbors_directions) do
        local candidate_pos = {
            underground_position.x + neighbor_candidate.pos[1],
            underground_position.y + neighbor_candidate.pos[2],
        }
        -- priority at one location, as before: a matching underground, then a matching
        -- underground ghost, then a non-pipe entity with a fluidbox connection
        local ghost_match, fluidbox_match = false, false
        for _, candidate_entity in pairs(surface.find_entities( { candidate_pos, candidate_pos } )) do
            local entity_type = candidate_entity.type
            if entity_type == "entity-ghost" then
                if candidate_entity.ghost_name == underground_entity_name
                and candidate_entity.direction == neighbor_candidate.dir then
                    ghost_match = true
                elseif not ghost_match and not fluidbox_match
                and is_fluidbox_neighbor(candidate_entity, candidate_entity.ghost_type, pipe_position) then
                    fluidbox_match = true
                end
            elseif entity_type == "pipe-to-ground"
            and candidate_entity.name == underground_entity_name
            and candidate_entity.direction == neighbor_candidate.dir then
                return true, false
            elseif not ghost_match and not fluidbox_match
            and is_fluidbox_neighbor(candidate_entity, entity_type, pipe_position) then
                fluidbox_match = true
            end
        end
        if ghost_match then return true, true end
        if fluidbox_match then return true, false end
    end
    return false, false
end

neighbors.directions_to_neighbors = directions_to_neighbors
neighbors.entity_type_or_ghost_type = entity_type_or_ghost_type
neighbors.should_place_based_on_neighbor_fluidbox_prototypes = should_place_based_on_neighbor_fluidbox_prototypes
neighbors.find_connection_neighbor = find_connection_neighbor

return neighbors
