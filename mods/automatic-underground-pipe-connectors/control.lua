local util = require("util")
local neighbors = require("lib.neighbors")
local tiles = require("lib.tiles")
local undo = require("lib.undo")

---@class (exact) Storage
---@field pipe_lookup PipeLookup
---@field tile_lookup TileLookup
---@field index_rebuilt_tick integer
---@type Storage
storage=storage

--- Lookup table from underground pipe entity to the equivalent pipe entity and item, based on recipes
---@alias PipeLookupEntry { item:string, entity:string }
storage.pipe_lookup = storage.pipe_lookup or {}

--- Lookup table from underground pipe entity to the equivalent pipe entity and item, based on recipes
---@alias PipeLookup table<string, PipeLookupEntry>
storage.pipe_lookup = storage.pipe_lookup or {}

--- Lookup table from tile name to the item name that places it, or `false` if no item does
---@alias TileLookup table<string, string|false>
storage.tile_lookup = storage.tile_lookup or {}

---
---@alias EntityEtc
---| LuaEntity
---| LuaSurface.create_entity_param.base
---| LuaSurface.can_place_entity_param
---| LuaSurface.can_fast_replace_param

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
    local neighbors_directions = neighbors.directions_to_neighbors[underground_direction]
    local pipe_position_delta = util.direction_vectors[underground_direction]
    local pipe_item_name = lookup_entry.item
    local pipe_entity_name = lookup_entry.entity
    local pipe_position = {
        underground_position.x + pipe_position_delta[1],
        underground_position.y + pipe_position_delta[2]
    }
    -- decide what we are connecting to before anything reads `placing_ghost`
    local found_neighbor, neighbor_is_ghost = neighbors.find_connection_neighbor(
        underground_surface, underground_position, neighbors_directions,
        underground_entity_name, pipe_position )
    if not found_neighbor then
        -- bail out because there's nothing here worth connecting to
        return
    end
    if neighbor_is_ghost then
        -- a ghost neighbor gets a ghost pipe, which costs nothing from inventory
        placing_ghost = true
    end

    local player = game.players[event.player_index]
    local inventory = player.get_main_inventory()
    -- The map editor does not charge for a build, so a connector placed alongside
    -- one should not be charged for either, and there is nothing to run out of
    -- that would justify downgrading it to a ghost.
    local free_build = player.controller_type == defines.controllers.editor
    local pipe_stack --[[@type LuaItemStack?]]

    -- if we don't have any regular pipes in our inventory we want to place a ghost instead
    if not placing_ghost and not free_build then
        if inventory then
            pipe_stack = inventory.find_item_stack(pipe_item_name)
            placing_ghost = not pipe_stack
        else
            placing_ghost = true
        end
    end

    local existing_tile = underground_surface.get_tile( pipe_position[ 1 ], pipe_position[ 2 ] );
    local existing_tile_state = tiles.save_tile_state( existing_tile )
    local cover_tile_proto = tiles.cover_tile_for( underground_surface, entity.force, existing_tile.prototype )
    ---@type EntityEtc?
    local tile_ghost_definition
    -- tile ghosts stack, eg a concrete ghost over an ice platform ghost over ammoniacal ocean,
    -- and what matters is whichever one ends up on top
    ---@type LuaTilePrototype?
    local ghosted_tile_prototype
    local existing_tile_ghosts = underground_surface.find_entities_filtered{
        name = "tile-ghost", position = pipe_position }
    for _, existing_tile_ghost in pairs(existing_tile_ghosts) do
        local existing_ghost_tile_prototype = existing_tile_ghost.ghost_prototype --[[@as LuaTilePrototype]]
        if not ghosted_tile_prototype or not existing_ghost_tile_prototype.collision_mask.layers.meltable then
            ghosted_tile_prototype = existing_ghost_tile_prototype
        end
    end
    if cover_tile_proto then
        placing_ghost = true;
        if #existing_tile_ghosts == 0 then
            tile_ghost_definition = {
                name = "tile-ghost",
                position = pipe_position,
                inner_name = cover_tile_proto.name,
                -- properties just for create_entity
                force = entity.force,
                player = event.player_index,
                raise_built = true,
                create_build_effect_smoke = true,
                spawn_decorations = true,
                -- properties just for can_place_entity
                build_check_type = defines.build_check_type.script_ghost,
            }
            if not underground_surface.can_place_entity(
                tile_ghost_definition --[[@as LuaSurface.can_place_entity_param]] )
            then
                -- bail out because we can't place the tile ghost
                return
            end
        end
    end

    local tile_proto_to_check_for_melt = existing_tile.prototype
    if ghosted_tile_prototype then
        tile_proto_to_check_for_melt = ghosted_tile_prototype
    elseif cover_tile_proto then
        tile_proto_to_check_for_melt = cover_tile_proto
    end

    -- a pipe collides with the meltable layer, so a meltable tile needs a cover tile of its own
    ---@type EntityEtc?
    local melt_tile_ghost_definition
    ---@type Tile?
    local melt_tile
    ---@type string?
    local melt_tile_item_name
    if tile_proto_to_check_for_melt.collision_mask.layers.meltable then
        local underground_tile = underground_surface.get_tile( underground_position.x, underground_position.y )
        local melt_cover_tile_proto = tiles.find_melt_cover_tile(
            underground_surface, entity.force, tile_proto_to_check_for_melt, underground_tile, inventory )
        if not melt_cover_tile_proto then
            -- bail out because we don't know what to cover the meltable tile with
            return
        end
        -- a real cover tile only makes sense under a real pipe, and only if we have the item to pay for it
        local cover_ghost = placing_ghost
        if not cover_ghost and not free_build then
            local cover_item_name = tiles.tile_item_name( melt_cover_tile_proto.name )
            if cover_item_name and inventory and inventory.find_item_stack( cover_item_name ) then
                melt_tile_item_name = cover_item_name
            else
                -- without the item the cover has to be a ghost, and a pipe can't sit on an uncovered meltable tile
                cover_ghost = true
                placing_ghost = true
            end
        end
        if cover_ghost then
            melt_tile_ghost_definition = {
                name = "tile-ghost",
                position = pipe_position,
                inner_name = melt_cover_tile_proto.name,
                -- properties just for create_entity
                force = entity.force,
                player = event.player_index,
                raise_built = true,
                create_build_effect_smoke = true,
                spawn_decorations = true,
                -- properties just for can_place_entity
                build_check_type = defines.build_check_type.script_ghost,
            }
            -- only worth asking when the ground we picked this tile for is the ground that is there
            -- now. with another cover tile going underneath first the answer would be about the wrong
            -- tile, eg concrete refused over ammoniacal ocean when an ice platform ghost is going
            -- between them, so leave it to create_entity once the tile below it exists
            if tile_proto_to_check_for_melt.name == existing_tile.name
            and not underground_surface.can_place_entity(
                melt_tile_ghost_definition --[[@as LuaSurface.can_place_entity_param]] ) then
                -- bail out because we can't place the cover tile ghost
                return
            end
        else
            melt_tile = { name = melt_cover_tile_proto.name, position = existing_tile.position }
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

    -- a pipe collides with the meltable layer, so on a meltable tile the build check would fail on ground
    -- we are about to cover. lay the cover tile down for the check and put it straight back, so the check
    -- still catches everything else it is here for, fluid mixing included
    local can_place --[[@type boolean]]
    if melt_tile then
        underground_surface.set_tiles( { melt_tile }, false, false, false, false )
        can_place = underground_surface.can_place_entity(
            pipe_entity_definition --[[@as LuaSurface.can_place_entity_param]] )
        tiles.restore_tile_state( underground_surface, existing_tile_state, false )
    else
        can_place = underground_surface.can_place_entity(
            pipe_entity_definition --[[@as LuaSurface.can_place_entity_param]] )
    end
    if not can_place then
        -- bail out because we can't place a pipe, could be blocked or a fluid mixing violation
        return
    end

    if placing_ghost then
        local found_entities = underground_surface.find_entities(
            { pipe_entity_definition.position, pipe_entity_definition.position } )
        for _,found_entity in pairs(found_entities) do
            if found_entity.type ~= "tile-ghost" then
                -- bail out because there's already something where we'd place a ghost
                return
            end
        end
    end

    if underground_surface.can_fast_replace( pipe_entity_definition --[[@as LuaSurface.can_fast_replace_param]] ) then
        local ghost = underground_surface.find_entity("entity-ghost", pipe_entity_definition.position)
        -- a matching ghost is ok to replace, so only bail out for anything else
        if not ghost or ghost.ghost_name ~= pipe_entity_name then
            -- bail out because there's something here our pipe would fast replace
            return
        end
    end

    -- found something to connect to! everything below this point actually changes the world,
    -- so anything that fails has to put back whatever the steps before it managed to place
    ---@type LuaEntity[]
    local placed_tile_ghosts = {}
    local placed_melt_tile = false
    ---@type UndoState?
    local undo_state_before_melt_tile

    --- Undo whatever we placed, so a failure part way through leaves no trace
    local function rollback()
        for _, tile_ghost in pairs(placed_tile_ghosts) do
            if tile_ghost.valid then
                tile_ghost.destroy()
            end
        end
        if placed_melt_tile then
            tiles.restore_tile_state( underground_surface, existing_tile_state, true )
            if undo_state_before_melt_tile then
                -- the tile is gone again, so the player shouldn't be offered an undo for it
                undo.restore_undo_state( player, undo_state_before_melt_tile )
            end
            if melt_tile_item_name and inventory then
                inventory.insert({name=melt_tile_item_name, count=1})
            end
        end
    end

    if tile_ghost_definition then
        local tile_ghost = underground_surface.create_entity(
            tile_ghost_definition --[[@as LuaSurface.create_entity_param]] )
        if not tile_ghost then
            -- bail out because we couldn't place the cover tile ghost the pipe needs
            return
        end
        placed_tile_ghosts[#placed_tile_ghosts+1] = tile_ghost
    end

    if melt_tile_ghost_definition then
        local tile_ghost = underground_surface.create_entity(
            melt_tile_ghost_definition --[[@as LuaSurface.create_entity_param]] )
        if not tile_ghost then
            rollback()
            -- bail out because we couldn't place the cover tile ghost the pipe needs
            return
        end
        placed_tile_ghosts[#placed_tile_ghosts+1] = tile_ghost
    end

    if melt_tile then
        -- the trial run above proved the pipe fits once this tile is down.
        -- passing the player puts the tile in their undo queue, alongside the underground they just placed
        undo_state_before_melt_tile = undo.save_undo_state( player )
        underground_surface.set_tiles( {melt_tile}, true, false, true, true, player )
        placed_melt_tile = true
        if melt_tile_item_name and inventory then
            -- we only chose a real tile over a ghost because this item was in inventory
            inventory.remove({name=melt_tile_item_name})
        end
    end

    if not placing_ghost and not free_build then
        -- we ensured above that placing_ghost is true xor we have the necessary item to remove from inventory
        if inventory then
            inventory.remove({name=pipe_item_name})
        else
            player.print("Placed a pipe for free. This shouldn't happen. Please report a bug on "
                .. "the Automatic Underground Pipe Connectors mod discussion page or github issue "
                .. "tracker, including your game save.")
        end
    end

    -- place the pipe or ghost entity
    if not underground_surface.create_entity(pipe_entity_definition --[[@as LuaSurface.create_entity_param]]) then
        -- the world changed under us between the checks above and now
        rollback()
        if not placing_ghost and not free_build and inventory then
            inventory.insert({name=pipe_item_name, count=1})
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
    -- tile prototypes and the items that place them can change with the mod list
    storage.tile_lookup = {}
    local underground_recipe_prototypes = prototypes.get_recipe_filtered(
        {
            {
                filter="has-product-item",
                elem_filters={{filter="place-result",elem_filters={{filter="type",type="pipe-to-ground"}}}}
            },
            {
                mode="and",filter="has-ingredient-item",
                elem_filters={{filter="place-result",elem_filters={{filter="type",type="pipe"}}}}
            }
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

    -- The item needs to be able to place the pipe
    if not pipe_items[lookup_entry.item]
    -- The item needs to exist (theoretically we can skip this since it was in an items_to_place_this)
    or not prototypes.item[lookup_entry.item]
    -- The pipe needs to be an actual pipe
    or not pipe_prototype or pipe_prototype.type ~= "pipe"
    -- The underground needs to be an actual underground
    or not underground_prototype or underground_prototype.type ~= "pipe-to-ground" then
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

script.on_event(
    defines.events.on_built_entity,
    on_built_entity,
    {{filter="type",type="pipe-to-ground"},{filter="ghost_type",type="pipe-to-ground"}}
)