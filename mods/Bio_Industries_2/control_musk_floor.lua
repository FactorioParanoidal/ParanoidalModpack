------------------------------------------------------------------------------------
-- Musk floor (solar mat tile): every tile has a hidden solar panel and a hidden pole.
-- storage.bi_musk_floor_table.surfaces[surface_index][x][y] = force name
-- Also handles fertilizer placed on tiles where nothing may grow.
------------------------------------------------------------------------------------
local M = {}

local trees = require("control_tree")

local MAT = "bi-solar-mat"
local POLE = "bi-musk-mat-hidden-pole"
local PANEL = "bi-musk-mat-hidden-panel"
local HIDDEN = { POLE, PANEL }

local FERTILIZERS = {
    ["fertilizer"] = true,
    ["bi-adv-fertilizer"] = true,
}

local floor = math.floor

local function surface_tiles(surface_index, create)
    local musk = storage.bi_musk_floor_table
    if not (musk and musk.surfaces) then
        if not create then
            return
        end
        musk = musk or {}
        musk.surfaces = musk.surfaces or {}
        storage.bi_musk_floor_table = musk
    end
    local tiles = musk.surfaces[surface_index]
    if not tiles and create then
        tiles = {}
        musk.surfaces[surface_index] = tiles
    end
    return tiles
end

-- Force of musk floor placed by a script (the event names no force)
local function default_force()
    if BioInd.UseMuskForce then
        return BioInd.MuskForceName
    end
    local found
    for _, force in pairs(game.forces) do
        if #force.players > 0 then
            if found then
                return "player"
            end
            found = force.name
        end
    end
    return found or "player"
end

local function tile_xy(position)
    return floor(position.x or position[1]), floor(position.y or position[2])
end

-- Hidden entities are searched by centre (radius): their collision box is empty.
-- Create the hidden entities of a tile unless they exist already (musk floor restored
-- after fertilizer, or placed again by a script).
local function place(surface, x, y, force)
    local position = { x + 0.5, y + 0.5 }
    local have = {}
    for _, entity in pairs(surface.find_entities_filtered({ name = HIDDEN, position = position, radius = 0.01 })) do
        if have[entity.name] then
            entity.destroy()
        else
            have[entity.name] = true
        end
    end
    for _, name in ipairs(HIDDEN) do
        if not have[name] then
            local created = surface.create_entity({ name = name, position = position, force = force })
            if created then
                created.minable = false
                created.destructible = false
            end
        end
    end

    local tiles = surface_tiles(surface.index, true)
    tiles[x] = tiles[x] or {}
    tiles[x][y] = type(force) == "string" and force or force.name
end

local function remove(surface, x, y)
    for _, entity in pairs(surface.find_entities_filtered({ name = HIDDEN, position = { x + 0.5, y + 0.5 }, radius = 0.01 })) do
        entity.destroy()
    end
    local tiles = surface_tiles(surface.index)
    local column = tiles and tiles[x]
    if column then
        column[y] = nil
        if not next(column) then
            tiles[x] = nil
        end
    end
end


------------------------------------------------------------------------------------
-- Fertilizer was used on tiles where nothing may grow (concrete, musk floor etc.):
-- restore these tiles and take back the items the player/robot got for them.
local function fertilizer_used(event, surface)
    local barren = trees.get_barren_tiles()
    local player = event.player_index and game.get_player(event.player_index)
    local robot = event.robot
    local restore = {}
    for _, t in pairs(event.tiles) do
        local old_name = t.old_tile.name
        local products = barren[old_name]
        if products then
            restore[#restore + 1] = { name = old_name, position = t.position }
            if type(products) == "table" then
                for _, product in ipairs(products) do
                    local remove_this = { name = product.name, count = product.amount or product.amount_max or 1 }
                    if player then
                        player.remove_item(remove_this)
                    elseif robot and robot.valid then
                        robot.remove_item(remove_this)
                    end
                end
            end
        elseif old_name == MAT then
            local x, y = tile_xy(t.position)
            remove(surface, x, y)
        end
    end
    if restore[1] then
        -- Restored musk floor keeps its hidden entities (see place()).
        surface.set_tiles(
            restore,
            true, -- correct_tiles
            true, -- remove_colliding_entities
            true, -- remove_colliding_decoratives
            true  -- raise_event
        )
    end
end


-- Musk floor among the replaced or mined tiles. The table knows every tile with hidden
-- entities, so no tile prototype has to be read; nothing to do on surfaces without it.
local function removed_tiles(event)
    local known = surface_tiles(event.surface_index)
    if not known then
        return
    end
    local surface
    for _, t in pairs(event.tiles) do
        local x, y = tile_xy(t.position)
        local column = known[x]
        if column and column[y] then
            surface = surface or game.get_surface(event.surface_index)
            if not surface then
                return
            end
            remove(surface, x, y)
        end
    end
end

------------------------------------------------------------------------------------
-- on_player_built_tile, on_robot_built_tile
function M.on_tile_built(event)
    if event.tile.name == MAT then
        local surface = game.get_surface(event.surface_index)
        if not surface then
            return
        end
        local force
        if BioInd.UseMuskForce then
            force = BioInd.MuskForceName
        elseif event.player_index then
            force = game.get_player(event.player_index).force.name
        elseif event.robot and event.robot.valid then
            force = event.robot.force.name
        else
            force = default_force()
        end
        for _, t in pairs(event.tiles) do
            local x, y = tile_xy(t.position)
            place(surface, x, y, force)
        end
        return
    end

    local item = event.item
    if item and FERTILIZERS[item.name] then
        local surface = game.get_surface(event.surface_index)
        if surface then
            fertilizer_used(event, surface)
        end
        return
    end

    removed_tiles(event)
end

-- on_player_mined_tile, on_robot_mined_tile
M.on_tile_mined = removed_tiles

-- script_raised_set_tiles: only the new tiles are known, so musk floor that was
-- replaced is found in our table.
function M.on_script_set_tiles(event)
    local tiles = event.tiles
    if not tiles then
        return
    end
    local surface_index = event.surface_index
    local known = surface_tiles(surface_index)
    local surface, force
    for _, t in pairs(tiles) do
        if t.name == MAT then
            surface = surface or game.get_surface(surface_index)
            if not surface then
                return
            end
            force = force or default_force()
            local x, y = tile_xy(t.position)
            local column = known and known[x]
            place(surface, x, y, column and column[y] or force)
        elseif known then
            local x, y = tile_xy(t.position)
            local column = known[x]
            if column and column[y] then
                surface = surface or game.get_surface(surface_index)
                if not surface then
                    return
                end
                remove(surface, x, y)
            end
        end
    end
end

-- on_surface_deleted, on_surface_cleared
function M.on_surface_removed(event)
    local musk = storage.bi_musk_floor_table
    if musk and musk.surfaces then
        musk.surfaces[event.surface_index] = nil
    end
end


------------------------------------------------------------------------------------
-- on_init / on_configuration_changed / migration: rebuild the table from the hidden
-- panels of all surfaces. (Older versions kept one table for all surfaces.)
function M.setup_storage()
    local musk = storage.bi_musk_floor_table or {}
    storage.bi_musk_floor_table = musk

    local surfaces = {}
    if prototypes.entity[PANEL] then
        for _, surface in pairs(game.surfaces) do
            local panels = surface.find_entities_filtered({ name = PANEL })
            if panels[1] then
                local tiles = {}
                for _, panel in pairs(panels) do
                    local x, y = tile_xy(panel.position)
                    tiles[x] = tiles[x] or {}
                    tiles[x][y] = panel.force.name
                end
                surfaces[surface.index] = tiles
            end
        end
    end
    musk.surfaces = surfaces
end

return M
