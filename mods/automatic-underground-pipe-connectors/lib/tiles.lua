--- Choosing and placing the ground a connector pipe needs underneath it.
local tiles = {}

--- Find the item that places a tile, remembering the answer in `storage.tile_lookup`
---@param tile_name string
---@return string|false item_name `false` when no item places this tile
local function tile_item_name(tile_name)
    storage.tile_lookup = storage.tile_lookup or {}
    local cover_item_name = storage.tile_lookup[tile_name]
    if cover_item_name == nil then
        cover_item_name = false
        local items_to_place_this = prototypes.tile[tile_name].items_to_place_this
        if items_to_place_this and items_to_place_this[1] then
            cover_item_name = items_to_place_this[1].name
        end
        storage.tile_lookup[tile_name] = cover_item_name
    end
    return cover_item_name
end

--- Find the tile that covers another tile, if any.
--- A per-force override set by another mod wins over the tile prototype's own default.
---@param surface LuaSurface
---@param force LuaForce
---@param tile_prototype LuaTilePrototype
---@return LuaTilePrototype?
local function cover_tile_for(surface, force, tile_prototype)
    return surface.get_default_cover_tile(force, tile_prototype) or tile_prototype.default_cover_tile
end

--- Would the game let a player place `cover_tile_prototype` on top of `target_tile_prototype`?
--- `place_as_tile.condition` is an exclusion mask: the target must have none of its layers.
---@param cover_tile_prototype LuaTilePrototype
---@param target_tile_prototype LuaTilePrototype
---@return boolean
local function tile_can_cover(cover_tile_prototype, target_tile_prototype)
    local cover_item_name = tile_item_name(cover_tile_prototype.name)
    if not cover_item_name then return false end
    local place_as_tile_result = prototypes.item[cover_item_name].place_as_tile_result
    if not place_as_tile_result then return false end
    local blocked = false
    for layer in pairs(place_as_tile_result.condition.layers) do
        if target_tile_prototype.collision_mask.layers[layer] then
            blocked = true
            break
        end
    end
    -- nothing in the base game sets `invert`, so this reading of it is untested
    if place_as_tile_result.invert then blocked = not blocked end
    if blocked then return false end
    -- when the item names the tiles it may be placed on, the target has to be one of them
    local tile_condition = place_as_tile_result.tile_condition
    if tile_condition and #tile_condition > 0 then
        for _, allowed_tile_prototype in pairs(tile_condition) do
            if allowed_tile_prototype.name == target_tile_prototype.name then return true end
        end
        return false
    end
    return true
end

--- Find a tile to cover a meltable tile with, so that a pipe can sit on it.
--- Nothing in the prototypes nominates one, so fall back through increasingly weak guesses.
---@param surface LuaSurface
---@param force LuaForce
---@param target_tile_prototype LuaTilePrototype The meltable tile in the way
---@param underground_tile LuaTile The ground the underground pipe that triggered us is standing on
---@param inventory LuaInventory?
---@return LuaTilePrototype?
local function find_melt_cover_tile(surface, force, target_tile_prototype, underground_tile, inventory)
    ---@param candidate LuaTilePrototype?
    ---@return boolean
    local function usable(candidate)
        return candidate ~= nil
            and not candidate.collision_mask.layers.meltable
            and tile_can_cover(candidate, target_tile_prototype)
    end

    -- an override another mod set for this force wins
    local override_tile_prototype = surface.get_default_cover_tile(force, target_tile_prototype)
    if usable(override_tile_prototype) then return override_tile_prototype end

    -- otherwise match the foundation the player already laid for the underground pipe itself,
    -- which is the only tile we know they chose deliberately for this spot
    if usable(underground_tile.prototype) then return underground_tile.prototype end

    -- then whatever the tile prototype nominates, in case a mod filled it in
    if usable(target_tile_prototype.default_cover_tile) then return target_tile_prototype.default_cover_tile end

    -- last resort, for a ghost we aren't charging anyone for: anything that would be legal here,
    -- preferring something the player is carrying, lowest name first so every player agrees
    local carried_tile_prototype --[[@type LuaTilePrototype?]]
    local any_tile_prototype --[[@type LuaTilePrototype?]]
    for candidate_name, candidate in pairs(prototypes.tile) do
        if usable(candidate) then
            local candidate_item_name = tile_item_name(candidate_name)
            if candidate_item_name and inventory and inventory.get_item_count(candidate_item_name) > 0 then
                if not carried_tile_prototype or candidate_name < carried_tile_prototype.name then
                    carried_tile_prototype = candidate
                end
            elseif not any_tile_prototype or candidate_name < any_tile_prototype.name then
                any_tile_prototype = candidate
            end
        end
    end
    return carried_tile_prototype or any_tile_prototype
end

--- The ground at a position, captured well enough to put it back exactly as it was
---@alias TileState { position: TilePosition, name: string, hidden_tile: string?, double_hidden_tile: string? }

---@param tile LuaTile
---@return TileState
local function save_tile_state(tile)
    return {
        position = tile.position,
        name = tile.name,
        hidden_tile = tile.hidden_tile,
        double_hidden_tile = tile.double_hidden_tile,
    }
end

--- Put the ground back the way `save_tile_state` found it, quietly: no events, no undo entry, no items
---@param surface LuaSurface
---@param tile_state TileState
---@param correct_tiles boolean Only worth doing if the tile was visible to the player in the meantime
local function restore_tile_state(surface, tile_state, correct_tiles)
    surface.set_tiles(
        { { name = tile_state.name, position = tile_state.position } },
        correct_tiles, false, false, false )
    surface.set_hidden_tile( tile_state.position, tile_state.hidden_tile )
    surface.set_double_hidden_tile( tile_state.position, tile_state.double_hidden_tile )
end

tiles.tile_item_name = tile_item_name
tiles.cover_tile_for = cover_tile_for
tiles.tile_can_cover = tile_can_cover
tiles.find_melt_cover_tile = find_melt_cover_tile
tiles.save_tile_state = save_tile_state
tiles.restore_tile_state = restore_tile_state

return tiles
