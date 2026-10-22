BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)
require("util")

if BioInd.get_startup_setting("BI_Enable_gvv_support") then
    BioInd.writeDebug("Activating support for gvv!")
    require("__gvv__/gvv")()
end

-- Every event has a single handler here, so events are registered directly with
-- script.on_event and native filters (no kry_stdlib dispatcher).
local compound = require("control_compound")
local trees = require("control_tree")
local arboretum = require("control_arboretum")
local musk_floor = require("control_musk_floor")
local settings_changed = require("settings_changed")
require("remote") -- milestones

local events = defines.events
local compounds = compound.compounds
local bio_trees = trees.bio_trees


local function Create_dummy_force()
    -- Create dummy force for musk floor if electric grid overlay should NOT be shown in map view
    local f = game.create_force(BioInd.MuskForceName)
    -- Set new force as neutral to every other force
    for name, force in pairs(game.forces) do
        if name ~= BioInd.MuskForceName then
            f.set_friend(force, false)
            f.set_cease_fire(force, true)
        end
    end
    -- New force won't share chart data with any other force
    f.share_chart = false
end


-- Older script versions read these prototype-derived values from storage. They are
-- still written so that a save made now keeps working if the mod is rolled back.
local function write_legacy_storage()
    storage.compound_entities = table.deepcopy(compounds)
    storage.bi.trees = {}
    for name in pairs(bio_trees) do
        storage.bi.trees[name] = true
    end
    storage.bi.barren_tiles = table.deepcopy(trees.get_barren_tiles())
    if storage.bi_arboretum_recipe_table then
        local list = {}
        for name, need in pairs(arboretum.get_recipes()) do
            list[name] = { items = table.deepcopy(need.items), fluids = table.deepcopy(need.fluids) }
        end
        storage.bi_arboretum_recipe_table = list
    end
    storage.compatible = storage.compatible or {}
    storage.compatible.AlienBiomes = BioInd.AB_tiles()
    storage.mod_settings = storage.mod_settings or {}
    storage.mod_settings.garden_pole_connectors =
        compounds["bi-bio-garden"] and compounds["bi-bio-garden"].hidden.pole and
        compound.get_garden_connectors() or nil
    local musk = storage.bi_musk_floor_table
    musk.tiles = musk.tiles or {}
    musk.forces = musk.forces or {}
end


--------------------------------------------------------------------
-- Bring storage in line with the prototypes and the map. Called by on_init,
-- on_configuration_changed and the migration of the runtime rework; idempotent.
local function setup_storage()
    if BioInd.is_debug then
        game.check_prototype_translations()
    end
    storage.bi = storage.bi or {}

    local stats = compound.setup_storage()
    stats.dropped_trees = trees.setup_storage()
    musk_floor.setup_storage()
    write_legacy_storage()

    -- Create dummy force for musk floor if electric grid overlay should NOT be shown in map view
    if BioInd.UseMuskForce and not game.forces[BioInd.MuskForceName] then
        Create_dummy_force()
    end
    return stats
end
BioInd.setup_storage = setup_storage

script.on_init(function()
    setup_storage()
    storage.bi_musk_floor_table.use_musk_force = BioInd.UseMuskForce
end)

script.on_configuration_changed(function(data)
    setup_storage()
    -- Has setting BI_Show_musk_floor_in_mapview changed?
    if data.mod_startup_settings_changed then
        settings_changed.musk_floor()
    end
end)


--------------------------------------------------------------------
-- Entities
--------------------------------------------------------------------
local function on_built(event)
    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end
    local name = entity.name
    if compounds[name] then
        compound.built(entity)
    elseif name == "seedling" then
        trees.seed_planted(entity, event.tick)
    end
end

-- Mined (before removal), died or destroyed by a script
local function on_removed(event)
    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end
    local name = entity.name
    if compounds[name] then
        compound.removed(entity)
    elseif name == "seedling" or bio_trees[name] then
        trees.removed(entity)
    end
end

-- Seed bombs: the seedlings of the standard and advanced bomb also fertilize the tile.
local AB = BioInd.AB_tiles()
local seed_bomb_tiles = {
    ["seedling-2"] = AB and "vegetation-green-grass-3" or "grass-3",
    ["seedling-3"] = AB and "vegetation-green-grass-1" or "grass-1",
}

local function on_trigger_created_entity(event)
    local entity = event.entity
    if not (entity and entity.valid) then
        return
    end
    local name = entity.name
    if name == "seedling" then
        trees.seed_planted_trigger(entity, event.tick)
    elseif seed_bomb_tiles[name] then
        local surface = entity.surface
        local position = entity.position
        if not trees.get_barren_tiles()[surface.get_tile(position.x, position.y).name] then
            surface.set_tiles({ { name = seed_bomb_tiles[name], position = position } })
        end
        trees.seed_planted_trigger(entity, event.tick)
    end
end


--------------------------------------------------------------------
-- Registration. The filters are derived from prototypes, so they are the same on
-- every client and need no storage.
--------------------------------------------------------------------
local function name_filters(...)
    local names, seen = {}, {}
    for _, list in ipairs({ ... }) do
        for _, name in pairs(list) do
            if not seen[name] and prototypes.entity[name] then
                seen[name] = true
                names[#names + 1] = name
            end
        end
    end
    table.sort(names)
    local filters = {}
    for i, name in ipairs(names) do
        filters[i] = { filter = "name", name = name }
    end
    return filters
end

local function register(ids, handler, filters)
    if filters[1] then
        for _, id in ipairs(ids) do
            script.on_event(id, handler, filters)
        end
    end
end

local tree_names = {}
for name in pairs(bio_trees) do
    tree_names[#tree_names + 1] = name
end

register({ events.on_built_entity, events.on_robot_built_entity,
        events.script_raised_built, events.script_raised_revive },
    on_built, name_filters(compound.names, { "seedling" }))

register({ events.on_pre_player_mined_item, events.on_robot_pre_mined,
        events.on_entity_died, events.script_raised_destroy },
    on_removed, name_filters(compound.names, { "seedling" }, tree_names))

register({ events.on_entity_damaged }, compound.damaged,
    compound.arboretum_radar and name_filters({ "bi-arboretum", compound.arboretum_radar }) or {})

register({ events.on_sector_scanned }, arboretum.on_sector_scanned,
    compound.arboretum_radar and name_filters({ compound.arboretum_radar }) or {})

script.on_event(events.on_trigger_created_entity, on_trigger_created_entity)

script.on_event({ events.on_player_built_tile, events.on_robot_built_tile }, musk_floor.on_tile_built)
script.on_event({ events.on_player_mined_tile, events.on_robot_mined_tile }, musk_floor.on_tile_mined)
script.on_event(events.script_raised_set_tiles, musk_floor.on_script_set_tiles)
script.on_event({ events.on_surface_deleted, events.on_surface_cleared }, musk_floor.on_surface_removed)

script.on_nth_tick(trees.PROCESS_INTERVAL, trees.on_nth_tick)


------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV, {
    __newindex = function(self, key, value) --locked_global_write
        error('\n\n[ER Global Lock] Forbidden global *write*:\n'
            .. serpent.line { key = key or '<nil>', value = value or '<nil>' } .. '\n')
    end,
    __index = function(self, key) --locked_global_read
        if not (key == "game" or key == "mods" or key == "storage") then
            error('\n\n[ER Global Lock] Forbidden global *read*:\n'
                .. serpent.line { key = key or '<nil>' } .. '\n')
        end
    end
})
