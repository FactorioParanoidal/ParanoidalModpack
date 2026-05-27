local util = require("util")

---@class (exact) Storage
---@field pipe_lookup PipeLookup
---@field index_rebuilt_tick integer
---@type Storage
storage=storage

--- Lookup table from underground pipe entity to the equivalent pipe entity and item, based on recipes
---@alias PipeLookupEntry { item:string, entity:string }
storage.pipe_lookup = storage.pipe_lookup or {}

--- Lookup table from underground pipe entity to the equivalent pipe entity and item, based on recipes
---@alias PipeLookup table<string, PipeLookupEntry>
storage.pipe_lookup = storage.pipe_lookup or {}

---Map from underground pipe direction to the locations and directions of neighbors it might connect to by adding a single pipe
---@type { [defines.direction]: { pos: Vector, dir: defines.direction }[] }
local directions_to_neighbors = {
    [defines.direction.north] = { -- for an underground pipe pointing north
        {pos={-1,-1}, dir=defines.direction.east }, -- one space ahead and left, a pipe pointing east would trigger a connection
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

---
---@alias EntityEtc LuaEntity|LuaSurface.create_entity_param.base|LuaSurface.can_place_entity_param|LuaSurface.can_fast_replace_param

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

---@param event EventData.on_built_entity
local function on_built_entity(event)
    local entity = event.entity
    if not entity then return end
    if not entity.valid then return end

    local underground_entity_name --[[@type string]]

    local placing_ghost --[[@type boolean]]
    if entity.type == "entity-ghost" then
        placing_ghost = true
        underground_entity_name = entity.ghost_name
    else
        placing_ghost = false
        underground_entity_name = entity.name
    end

    local lookup_entry = storage.pipe_lookup[underground_entity_name]
    if not lookup_entry then return end -- we don't know what pipe goes with this underground pipe, bail out

    local underground_surface = entity.surface
    local underground_direction = entity.direction
    local underground_position = entity.position
    local neighbors_directions = directions_to_neighbors[underground_direction]
    local pipe_position_delta = util.direction_vectors[underground_direction]
    local pipe_item_name = lookup_entry.item
    local pipe_entity_name = lookup_entry.entity
    local pipe_position = {
        underground_position.x + pipe_position_delta[1],
        underground_position.y + pipe_position_delta[2]
    }
    local player = game.players[event.player_index]
    local inventory = player.get_main_inventory()
    local pipe_stack --[[@type LuaItemStack?]]

    -- if we don't have any regular pipes in our inventory we want to place a ghost instead
    if not placing_ghost then
        if inventory then
            pipe_stack = inventory.find_item_stack(pipe_item_name)
            placing_ghost = not pipe_stack
        else
            placing_ghost = true
        end
    end

    local place_tile = false;
    local existing_tile = underground_surface.get_tile( pipe_position[ 1 ], pipe_position[ 2 ] );
    local cover_tile = existing_tile.prototype.default_cover_tile
    local tile_ghost_definition
    if cover_tile then
        if cover_tile.name == "ice-platform" then
            -- TODO logic for concrete on ice platforms
            return
        end
        placing_ghost = true;
        local existing_tile_ghost = underground_surface.find_entity( "tile-ghost", pipe_position )
        if existing_tile_ghost == nil then
            place_tile = true;
            ---@type EntityEtc
            tile_ghost_definition = {
                name = "tile-ghost",
                position = pipe_position,
                inner_name = cover_tile.name,
                -- properties just for create_entity
                force = entity.force,
                player = event.player_index,
                raise_built = true,
                create_build_effect_smoke = true,
                spawn_decorations = true,
                -- properties just for can_place_entity
                build_check_type = defines.build_check_type.script_ghost,
            }
            if not underground_surface.can_place_entity( tile_ghost_definition --[[@as LuaSurface.can_place_entity_param]] ) then
            -- bail out because we can't place the tile ghost
                return
            end
        end
    end

    ---@type EntityEtc
    local pipe_entity_definition = {
        name = placing_ghost and "entity-ghost" or pipe_entity_name,
        position = pipe_position,
        -- properties just for create_entity
        force = entity.force,
        player = event.player_index,
        raise_built = true,
        create_build_effect_smoke = true,
        spawn_decorations = true,

        -- properties just for can_place_entity
        build_check_type = placing_ghost and defines.build_check_type.script_ghost or defines.build_check_type.manual,
    }
    if placing_ghost then
        pipe_entity_definition.inner_name = pipe_entity_name
    end

    if not underground_surface.can_place_entity( pipe_entity_definition --[[@as LuaSurface.can_place_entity_param]] ) then
        -- bail out because we can't place a pipe, could be blocked or a fluid mixing violation
        return
    end

    if placing_ghost then
        local found_entities = underground_surface.find_entities( { pipe_entity_definition.position, pipe_entity_definition.position } )
        for _,found_entity in pairs(found_entities) do
            if found_entity.type ~= "tile-ghost" then
                -- bail out because there's already something where we'd place a ghost
                return
            end
        end
    end

    if underground_surface.can_fast_replace( pipe_entity_definition --[[@as LuaSurface.can_fast_replace_param]] ) then
        local ghost = underground_surface.find_entity("entity-ghost", pipe_entity_definition.position)
        if ghost and ghost.ghost_name == pipe_entity_name then
            -- don't bail out, matching ghost is ok to replace
        else
            -- bail out because there's something here our pipe would fast replace
            return
        end
    end

    -- look at the three possible locations for another underground or entity to connect
    for _, neighbor_candidate in pairs(neighbors_directions) do
        local candidate_pos = {underground_position.x + neighbor_candidate.pos[1], underground_position.y + neighbor_candidate.pos[2]}
        local place = false
        -- first, check for a matching underground pipe
        local neighbor_entity = underground_surface.find_entity( underground_entity_name, candidate_pos )
        if neighbor_entity and neighbor_entity.name == underground_entity_name and neighbor_entity.direction == neighbor_candidate.dir then
            place = true
        end
        if not place then
            -- check for a matching underground pipe ghost
            local neighbor_ghost = underground_surface.find_entity( "entity-ghost", candidate_pos )
            if neighbor_ghost and neighbor_ghost.ghost_name == underground_entity_name and neighbor_ghost.direction == neighbor_candidate.dir then
                place = true
                placing_ghost = true
            end
        end
        if not place then
            -- check for a matching non-pipe entity with a fluidbox connection
            local neighbor_entities = underground_surface.find_entities( { candidate_pos, candidate_pos } )
            for _,neighbor_entity in pairs(neighbor_entities) do
                local entity_type = entity_type_or_ghost_type(neighbor_entity)
                if entity_type == "fluid-wagon" then
                    -- these have fluidbox connections for pumps, but not for pipes
                    goto continue_neighbor_entities
                end
                if  ( entity_type ~= "pipe" and entity_type ~= "pipe-to-ground"
                    ) and (
                        neighbor_entity.fluidbox and
                        #neighbor_entity.fluidbox > 0
                    )
                then
                    if should_place_based_on_neighbor_fluidbox_prototypes(neighbor_entity, pipe_position) then
                        place = true
                        goto bail_neighbor_entities
                    end
                end
                ::continue_neighbor_entities::
            end
        end
        ::bail_neighbor_entities::
        if place then
            -- found something to connect to!
            if not placing_ghost then
                -- we ensured above that placing_ghost is true xor we have the necessary item to remove from inventory
                if inventory then
                    inventory.remove({name=pipe_item_name})
                else
                    player.print("Placed a pipe for free. This shouldn't happen. Please report a bug on the Automatic Underground Pipe Connectors mod discussion page or github issue tracker, including your game save.")
                end
            end
            local tile_failed = false
            if place_tile then
                tile_failed = not underground_surface.create_entity( tile_ghost_definition --[[@as LuaSurface.create_entity_param]] )
            end
            if not tile_failed then
                -- place the pipe or ghost entity
                underground_surface.create_entity(pipe_entity_definition --[[@as LuaSurface.create_entity_param]])
            end
            -- no need to check other potential neighbors
            break
        end
    end
end

--- Find recipes that produce underground pipes to match them to pipes, save results to `global.pipe_lookup`
local function rebuild_index()
    -- TODO recursively search through ingredient recipes to find pipe->X->Y->Z->underground like SchallPipeScaling
    -- TODO handle undergrounds with multiple recipes or multiple ingredients per recipe
    if storage.index_rebuilt_tick == game.tick then
        return
    end
    storage.index_rebuilt_tick = game.tick
    local underground_recipe_prototypes = prototypes.get_recipe_filtered(
        {
            {filter="has-product-item",elem_filters={{filter="place-result",elem_filters={{filter="type",type="pipe-to-ground"}}}}},
            {mode="and",filter="has-ingredient-item",elem_filters={{filter="place-result",elem_filters={{filter="type",type="pipe"}}}}}
        }
    )
    for _, underground_recipe_prototype in pairs(underground_recipe_prototypes) do
        local underground_entity_name --[[@type string]]
        local pipe_item_name --[[@type string]]
        local pipe_entity_name --[[@type string]]
        -- Find the entity for the first recipe product that is a pipe-to-ground
        for _, product in pairs(underground_recipe_prototype.products) do
            local result = product.type == "item" and prototypes.item[product.name].place_result
            if result and prototypes.entity[result.name].type == "pipe-to-ground" then
                underground_entity_name = result.name
                break
            end
        end
        if underground_entity_name == nil then goto continue_underground_recipe_prototype end
        -- Find the entity and item for the first recipe ingredient that is a pipe
        for _, ingredient in pairs(underground_recipe_prototype.ingredients) do
            local result = ingredient.type == "item" and prototypes.item[ingredient.name].place_result
            if result and prototypes.entity[result.name].type == "pipe" then
                pipe_item_name = ingredient.name
                pipe_entity_name = result.name
                break
            end
        end
        if underground_entity_name and pipe_item_name and pipe_entity_name then
            -- Remember that when this underground entity is placed, this pipe item and entity are the ones to use
            -- Also remember which item places the underground entity
            storage.pipe_lookup[underground_entity_name] = {item = pipe_item_name, entity = pipe_entity_name }
        end
        ::continue_underground_recipe_prototype::
    end
end

script.on_init(rebuild_index)
script.on_configuration_changed(rebuild_index)

--- Filters out extra fields in the item_pipe and makes sure the references are valid entities and item
---@param underground_entity string
---@param lookup_entry PipeLookupEntry
---@return PipeLookupEntry lookup_entry Has been filtered of extra fields
local function validate_lookup(underground_entity, lookup_entry)
    -- Filter out the extra fields
    lookup_entry = { item = lookup_entry.item, entity = lookup_entry.entity }
    local underground_prototype = prototypes.entity[underground_entity]
    local pipe_prototype = prototypes.entity[lookup_entry.entity]

    ---@type table<string, true>
    local pipe_items = {}
    for _, stack in pairs(pipe_prototype.items_to_place_this) do
        pipe_items[stack.name] = true
    end

    if not pipe_items[lookup_entry.item] -- The item needs to be able to place the pipe
    or not prototypes.item[lookup_entry.item] -- The item needs to exist (theoretically we can skip this since it was in an items_to_place_this)
    or not pipe_prototype or pipe_prototype.type ~= "pipe" -- The pipe needs to be an actual pipe
    or not underground_prototype or underground_prototype.type ~= "pipe-to-ground" then -- The underground needs to be an actual underground
        error("Given underground lookup entry is not valid: "..underground_entity.." -> "..serpent.line(lookup_entry))
    end

    return lookup_entry
end

remote.add_interface("automatic-underground-pipe-connectors", {
    --- Allows mods to see what undergrounds are considered
    ---@return PipeLookup
    get_undergrounds = function()
        return storage.pipe_lookup
    end,
    --- Allows mods to completely overwrite undergrounds
    ---@param new_lookup PipeLookup
    set_undergrounds = function(new_lookup)
        -- To make sure the new lookup is valid
        for underground, lookup_entry in pairs(new_lookup) do
            new_lookup[underground] = validate_lookup(underground, lookup_entry)
        end

        storage.pipe_lookup = new_lookup
    end,
    --- Allows mods to add underground and pipe connections for when they don't follow the expected recipe pattern.
    ---@param new_undergrounds PipeLookup
    add_undergrounds = function(new_undergrounds)
        for underground, lookup_entry in pairs(new_undergrounds) do
            storage.pipe_lookup[underground] = validate_lookup(underground, lookup_entry)
        end
    end,
    --- Allows mods to remove undergrounds just in case
    ---@param old_undergrounds string[]
    remove_undergrounds = function(old_undergrounds)
        for _, underground in pairs(old_undergrounds) do
            if storage.pipe_lookup[underground] then
                log("Removing the lookup entry for '"..underground.."'")
                storage.pipe_lookup[underground] = nil
            end
        end
    end,
})

script.on_event( defines.events.on_built_entity, on_built_entity, {{filter="type",type="pipe-to-ground"},{filter="ghost_type",type="pipe-to-ground"}})