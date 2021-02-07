local BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)
local settings_changed = require("settings_changed")

if BioInd.get_startup_setting("BI_Enable_gvv_support") then
  BioInd.writeDebug("Activating support for gvv!")
  require("__gvv__/gvv")()
end


-- We can't just check if Alien Biomes is active, because we need to know if
-- the tiles we need from it exist in the game! To check this, we must call
-- game.get_tile_prototypes(), but this will crash in script.on_load(). So,
-- let's just declare the variable here and fill it later.
local AlienBiomes

--~ local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(false)
require ("util")
require ("libs/util_ext")
require ("control_tree")
require ("control_arboretum")
if BioInd.get_startup_setting("BI_Bio_Cannon") then
  require ("control_bio_cannon")
end
---************** Used for Testing -----
--require ("Test_Spawn")
---*************


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

    BioInd.writeDebug("Created force: %s", {game.forces[BioInd.MuskForceName].name})
end


-- Generate a look-up table with the names of our trees
local function get_bi_trees()
  local list = {}

  local trees = game.get_filtered_entity_prototypes({{filter = "type", type = "tree"}})
  for tree_name, tree in pairs(trees) do
    if tree_name:match("^bio%-tree%-.+%-%d$") then
BioInd.show("Found matching tree", tree_name)
      list[tree_name] = true
    end
  end

  return list
end


-- Generate a look-up table with the names of tiles that can't be changed by fertilizer
local tile_patterns = {
  ".*concrete.*",
  ".*stone%-path.*",
  "^bi%-solar%-mat$",
  "^bi%-wood%-floor$",
}
local function get_fixed_tiles()
  local list = {}

  for tile_name, tile in pairs(game.tile_prototypes) do
    for p, pattern in ipairs(tile_patterns) do
      if tile_name:match(pattern) then
BioInd.show("Found matching tile", tile_name)
        -- If a tile is minable and fertilizer is used on it, we must deduct the mined
        -- tiles from the player/robot again!
        list[tile_name] = tile.mineable_properties.products or true
      end
    end
  end
BioInd.show("Forbidden tiles", list)
  return list
end


-- Generate a look-up table with recipe ingredients, as other mods may have changed them
local function get_arboretum_recipes()
  local list = {}

  local recipes = game.recipe_prototypes
  local name

  for i = 1, 5 do
    name = "bi-arboretum-r" .. i
    list[name] = {}
    list[name].items = {}
    list[name].fluids = {}

    for i, ingredient in pairs(recipes[name].ingredients) do
      if ingredient.type == "item" then
        list[name].items[ingredient.name] = ingredient.amount
      else
        list[name].fluids[ingredient.name] = ingredient.amount
      end
    end
  end

  BioInd.show("Terraformer recipes", list)
  return list
end


--------------------------------------------------------------------
local function init()
BioInd.writeDebug("Entered init!")
  if BioInd.is_debug then
    game.check_prototype_translations()
  end

  global = global or {}

  --------------------------------------------------------------------
  -- Settings
  --------------------------------------------------------------------
  -- Global table for storing the last state of certain mod settings
  global.mod_settings = global.mod_settings or {}
  if BioInd.get_startup_setting("BI_Easy_Bio_Gardens") then
    global.mod_settings.garden_pole_connectors = BioInd.get_garden_pole_connectors()
  else
    global.mod_settings.garden_pole_connectors = nil
  end

  -- Global table for storing the data of compound entities. They may change between
  -- saves (e.g. Bio gardens only need hidden poles when the "Easy gardens" setting
  -- is active).
  --~ global.compound_entities = global.compound_entities or BioInd.compound_entities
  global.compound_entities = BioInd.rebuild_compound_entity_list()


  --------------------------------------------------------------------
  -- Tree stuff!
  --------------------------------------------------------------------
  global.bi = global.bi or {}
  global.bi.tree_growing = global.bi.tree_growing or {}
  for i = 1, 4 do
    global.bi["tree_growing_stage_" .. i] = global.bi["tree_growing_stage_" .. i] or {}
  end

  -- List of tree prototypes created by BI
  global.bi.trees = get_bi_trees()

  -- List of tile prototypes that can't be fertilized
  global.bi.barren_tiles = get_fixed_tiles()

  --------------------------------------------------------------------
  -- Compound entities
  --------------------------------------------------------------------
  -- Check what global tables we need for compound entities
  local compound_entity_tables = {}
  --~ for compound, compound_data in pairs(BioInd.compound_entities) do
  for compound, compound_data in pairs(global.compound_entities) do
    -- BioInd.compound_entities contains entries that point to the same table
    -- (e.g. straight/curved rails, or overlay entities), so we just overwrite
    -- them to remove duplicates
    compound_entity_tables[compound_data.tab] = compound
  end
BioInd.show("Need to check these tables in global", compound_entity_tables)

  -- Prepare global tables storing data of compound entities
  local result
  for compound_tab, compound_name in pairs(compound_entity_tables) do
    -- Init table
    global[compound_tab] = global[compound_tab] or {}
    BioInd.writeDebug("Initialized global[%s] (%s entities stored)",
                      {compound_name, table_size(global[compound_tab])})
    -- If this compound entity requires additional tables in global, initialize
    -- them now!
    local related_tables = global.compound_entities[compound_name].add_global_tables
    if related_tables then
      for t, tab in ipairs(related_tables or {}) do
        global[tab] = global[tab] or {}
        BioInd.writeDebug("Initialized global[%s] (%s values)", {tab, table_size(global[tab])})
      end
    end
    -- If this compound entity requires additional values in global, initialize
    -- them now!
    local related_vars = global.compound_entities[compound_name].add_global_values
    if related_vars then
      for var_name, value in pairs(related_vars or {}) do
        global[var_name] = global[var_name] or value
        BioInd.writeDebug("Set global[%s] to %s", {var_name, global[var_name]})
      end
    end

    -- Clean up global tables (We can skip this for empty tables!)
    if next(global[compound_tab]) then
      -- Remove invalid entities
      result = BioInd.clean_global_compounds_table(compound_name)
      BioInd.writeDebug("Removed %s invalid entries from global[%s]!",
                        {result, compound_tab})
      -- Restore missing hidden entities
      result = BioInd.restore_missing_entities(compound_name)
      BioInd.writeDebug("Checked %s compound entities and restored %s missing hidden entries for global[\"%s\"]!",
                        {result.checked, result.restored, compound_tab})
    end
  end
  -- Search all surfaces for unregistered compound entities
  result = BioInd.find_unregistered_entities()
  BioInd.writeDebug("Registered %s forgotten entities!", {result})



  --------------------------------------------------------------------
  -- Musk floor
  --------------------------------------------------------------------
  global.bi_musk_floor_table = global.bi_musk_floor_table or {}
  global.bi_musk_floor_table.tiles = global.bi_musk_floor_table.tiles or {}
  global.bi_musk_floor_table.forces = global.bi_musk_floor_table.forces or {}



  --------------------------------------------------------------------
  -- Arboretum
  --------------------------------------------------------------------
  -- Global table for arboretum radars
  global.bi_arboretum_radar_table = global.bi_arboretum_radar_table or {}

  -- Global table of ingredients for terraformer recipes
  global.bi_arboretum_recipe_table = get_arboretum_recipes()


  --------------------------------------------------------------------
  -- Compatibility with other mods
  --------------------------------------------------------------------
  global.compatible = global.compatible or {}
  global.compatible.AlienBiomes = BioInd.AB_tiles()


  -- enable researched recipes
  for i, force in pairs(game.forces) do
    BioInd.writeDebug("Reset technology effects for force %s.", {force.name})
    force.reset_technology_effects()
  end

  -- Create dummy force for musk floor if electric grid overlay should NOT be shown in map view
  if BioInd.UseMuskForce and not game.forces[BioInd.MuskForceName] then
    --~ BioInd.writeDebug("Force for musk floor is required but doesn't exist.")
    Create_dummy_force()
  end

end


--------------------------------------------------------------------
local function On_Load()
  log("Entered On_Load!")
  --~ if global.bi_bio_cannon_table ~= nil then
    --~ Event.register(defines.events.on_tick, function(event) end)
  --~ end
end


--------------------------------------------------------------------
local function On_Config_Change(ConfigurationChangedData)
BioInd.writeDebug("On Configuration changed: %s", {ConfigurationChangedData})
  --~ if global.bi_bio_cannon_table ~= nil then
    --~ Event.register(defines.events.on_tick, function(event) end)
  --~ end

  -- Re-initialize global tables etc.
  init()

  -- Has setting BI_Show_musk_floor_in_mapview changed?
  if ConfigurationChangedData.mod_startup_settings_changed then
    settings_changed.musk_floor()
    -- Has this been obsoleted by the new init process? Turn it off for now!
    --~ settings_changed.bio_garden()
  end

  -- We've made a list of the tree prototypes that are currently available. Now we
  -- need to make sure that the lists of growing trees don't contain removed tree
  -- prototypes! (This fix is needed when "Alien Biomes" has been removed; it should
  -- work with all other mods that create trees as well.)
  local trees = global.bi.trees
  local tab
  -- Growing stages
  for i = 1, 4 do
    tab = global.bi["tree_growing_stage_" .. i]
BioInd.writeDebug("Number of trees in growing stage %s: %s", {i, table_size(tab)})
    for t, tree in pairs(tab) do
      if not trees[tree.tree_name] then
BioInd.writeDebug("Removing invalid tree %s (%s)", {t, tree.tree_name})
        tab[t] = nil
      end
    end
    -- Removing trees will create gaps in the table, but we need it as a continuous
    -- list. (Trees need to be sorted by growing time, and we always look at the
    -- tree with index 1 when checking if a tree has completed the growing stage, so
    -- lets sort the table after all invalid trees have been removed!)
    table.sort(tab, function(a, b) return a.time < b.time end)
BioInd.show("Final tree list", tab)
  end
end


--------------------------------------------------------------------
--- Used for some compatibility with Angels Mods
Event.register(defines.events.on_player_joined_game, function(event)
   local player = game.players[event.player_index]
   local force = player.force
   local techs = force.technologies

  --~ if settings.startup["angels-use-angels-barreling"] and
     --~ settings.startup["angels-use-angels-barreling"].value then
  if BioInd.get_startup_setting("angels-use-angels-barreling") then
      techs['fluid-handling'].researched = false
      techs['bi-tech-fertilizer'].reload()
      local _t = techs['angels-fluid-barreling'].researched
      techs['angels-fluid-barreling'].researched = false
      techs['angels-fluid-barreling'].researched = _t
   end
end)


---------------------------------------------
Event.register(defines.events.on_trigger_created_entity, function(event)
  --- Used for Seed-bomb
  local ent = event.entity
  local surface = ent.surface
  local position = ent.position

  -- 'AlienBiomes' is a bool value -- we don't want to read it again if it's false,
  -- but only if it hasn't been set yet!
  AlienBiomes = AlienBiomes ~= nil and AlienBiomes or BioInd.AB_tiles()

  -- Basic
  if ent.name == "seedling" then
    BioInd.writeDebug("Seed Bomb Activated - Basic")
    seed_planted_trigger(event)

  -- Standard
  elseif ent.name == "seedling-2" then
    BioInd.writeDebug("Seed Bomb Activated - Standard")
    local terrain_name_s = AlienBiomes and "vegetation-green-grass-3" or "grass-3"
    surface.set_tiles{{name = terrain_name_s, position = position}}
    seed_planted_trigger(event)

  -- Advanced
  elseif ent.name == "seedling-3" then
    BioInd.writeDebug("Seed Bomb Activated - Advanced")
    local terrain_name_a = AlienBiomes and "vegetation-green-grass-1" or "grass-1"
    surface.set_tiles{{name = terrain_name_a, position = position}}
    seed_planted_trigger(event)
  end
end)

--------------------------------------------------------------------
local function On_Built(event)
  local entity = event.created_entity or event.entity
  if not (entity and entity.valid) then
    BioInd.arg_err(entity or "nil", "entity")
  end

  local surface = BioInd.is_surface(entity.surface) or
                    BioInd.arg_err(entity.surface or "nil", "surface")
  local position = BioInd.normalize_position(entity.position) or
                    BioInd.arg_err(entity.position or "nil", "position")
  local force = entity.force

BioInd.writeDebug("Entered function On_Built with these data: " .. serpent.block(event))
--~ BioInd.writeDebug("Entity name: %s", {BioInd.print_name_id(entity)})

  -- We can ignore ghosts -- if ghosts are revived, there will be
  -- another event that triggers where actual entities are placed!
  if entity.name == "entity-ghost" then
    BioInd.writeDebug("Built ghost of %s -- return!", {entity.ghost_name})
    return
  end

  BioInd.show("Built entity", BioInd.print_name_id(entity))

  local base_entry = global.compound_entities[entity.name]
  local base = base_entry and entity

  -- We've found a compound entity!
  if base then
    -- Make sure we work with a copy of the original table! We don't want to
    -- remove anything from it for real.
    local hidden_entities = util.table.deepcopy(base_entry.hidden)

    BioInd.writeDebug("%s (%s) is a compound entity. Need to create %s", {base.name, base.unit_number, hidden_entities})
BioInd.show("hidden_entities", hidden_entities)
    --~ local new_base, new_base_name, optional
    local new_base
    local new_base_name = base_entry.new_base_name
    -- If the base entity is only an overlay, we'll replace it with the real base
    -- entity and raise an event. The hidden entities will be created in the second
    -- pass (triggered by building the final entity).
BioInd.show("base_entry.new_base_name", base_entry.new_base_name)
BioInd.show("base_entry.new_base_name == base.name", base_entry.new_base_name == base.name)
BioInd.show("base_entry.optional", base_entry.optional)
    --~ if new_base_name then
    if new_base_name and new_base_name ~= base.name then
      new_base = surface.create_entity({
        name = new_base_name,
        position = base.position,
        direction = base.direction,
        force = base.force,
        raise_built = true
      })
      new_base.health = base.health
      BioInd.show("Created final base entity", BioInd.print_name_id(new_base))

      base.destroy({raise_destroy = true})
      base = new_base
      BioInd.writeDebug("Destroyed old base entity!")

    -- Second pass: We've placed the final base entity now, so we can create the
    -- the hidden entities!
    else
BioInd.writeDebug("Second pass -- creating hidden entities!")
BioInd.show("base_entry", base_entry)

BioInd.writeDebug("global[%s]: %s", {base_entry.tab, global[base_entry.tab]})
BioInd.show("base.name", base.name)
BioInd.show("base.unit_number", base.unit_number)
BioInd.show("hidden_entities", hidden_entities)

      -- We must call create_entities even if there are no hidden entities (e.g. if
      -- the "Easy Gardens" setting is disabled and no hidden poles are required)
      -- because the compound entity gets registered there!
      BioInd.create_entities(global[base_entry.tab], base, hidden_entities)
      BioInd.writeDebug("Stored %s in table: %s",
                        {BioInd.print_name_id(base), global[base_entry.tab][base.unit_number]})
    end

  -- The built entity isn't one of our compound entities.
  else
BioInd.writeDebug("%s is not a compound entity!", {BioInd.print_name_id(entity)})

    -- If one of our hidden entities has been built, we'll have raised this event
    -- ourselves and have passed on the base entity.
    base = event.base_entity

    local entities = BioInd.compound_entities
BioInd.show("Base entity", BioInd.print_name_id(base))

    -- The hidden entities are listed with a common handle ("pole", "panel" etc.). We
    -- can get it from the reverse-lookup list via the entity type!
    local h_key = BioInd.HE_map_reverse[entity.type]
    BioInd.show("h_key", h_key or "nil")

    -- Arboretum radar -- we need to add it to the table!
    if entity.type == "radar" and
      entity.name == entities["bi-arboretum-area"].hidden[h_key].name and base then
      global.bi_arboretum_radar_table[entity.unit_number] = base.unit_number
      entity.backer_name = ""
      BioInd.writeDebug("Added %s to global.bi_arboretum_radar_table", {BioInd.print_name_id(entity)})

    -- Electric poles -- we need to take care that they don't hook up to hidden poles!
    elseif entity.type == "electric-pole" then
--drd BioInd.show("entities[\"bi-straight-rail-power\"].hidden[h_key].name", entities["bi-straight-rail-power"].hidden[h_key].name)
      local pole = entity
      -- Make sure hidden poles of the Bio gardens are connected correctly!
      if pole.name == entities["bi-bio-garden"].hidden[h_key].name and base then
BioInd.writeDebug("Bio garden!")
        BioInd.connect_garden_pole(base, pole)
        BioInd.writeDebug("Connected %s (%s)", {pole.name, pole.unit_number or "nil"})

      -- Make sure hidden poles for powered rails are connected correctly!
--[[drd      elseif pole.name == entities["bi-straight-rail-power"].hidden[h_key].name and base then
BioInd.writeDebug("Powered rail!")
        BioInd.connect_power_rail(base, pole)
        BioInd.writeDebug("Connected %s", {BioInd.print_name_id(pole)})

      -- Do nothing for rail-to-power connectors
      elseif pole.name == "bi-power-to-rail-pole" then
        BioInd.writeDebug("Nothing to do for %s", {BioInd.print_name_id(pole)})
]]--
      -- Disconnect other poles from hidden poles on powered rails
--[[drd
      else
BioInd.writeDebug("Must disconnect!")
        for n, neighbour in ipairs(pole.neighbours["copper"] or {}) do
		
          if neighbour.name == entities["bi-straight-rail-power"].hidden[h_key].name then
            pole.disconnect_neighbour(neighbour)
            BioInd.writeDebug("Disconnected %s from %s",
                              {BioInd.print_name_id(pole), BioInd.print_name_id(neighbour)})
          end

        end
]]--drd
      end

    -- A seedling has been planted
    elseif entity.name == "seedling" then
      seed_planted(event)
      BioInd.writeDebug("Planted seedling!")

    -- Something else has been built
    else
      BioInd.writeDebug("Nothing to do for %s!", {entity.name})
    end
  end
  BioInd.writeDebug("End of function On_Built")
end


local function remove_plants(entity_position, tabl)
BioInd.writeDebug("Entered function remove_plants(%s, %s)", {entity_position or "nil", tabl or "nil"})
    local e = BioInd.normalize_position(entity_position)
    if not e then
      BioInd.arg_err(entity_position or "nil", "position")
    end
    BioInd.check_args(tabl, "table")

    local pos

    for k, v in pairs(tabl or {}) do
      pos = BioInd.normalize_position(v.position)
      if pos and pos.x == e.x and pos.y == e.y then
BioInd.writeDebug("Removing entry %s from table: %s", {k, v})
        table.remove(tabl, k)
        break
      end
    end
end


--------------------------------------------------------------------
local function On_Pre_Remove(event)
BioInd.writeDebug("Entered function On_Pre_Remove(%s)", {event})
  local entity = event.entity

  if not (entity and entity.valid) then
    BioInd.writeDebug("No valid entity -- nothing to do!")
    return
  end

  --~ local compound_entity = BioInd.compound_entities[entity.name]
  local compound_entity = global.compound_entities[entity.name]
  local base_entry = compound_entity and global[compound_entity.tab][entity.unit_number]
BioInd.show("entity.name", entity.name)
BioInd.show("entity.unit_number", entity.unit_number)

BioInd.show("compound_entity", compound_entity)
BioInd.show("base_entry", base_entry)
BioInd.show("compound_entity.tab", compound_entity and compound_entity.tab or "nil")
BioInd.writeDebug("global[%s]: %s", {compound_entity and compound_entity.tab or "nil", compound_entity and global[compound_entity.tab] or "nil"})

  -- Found a compound entity from our list!
  if base_entry then
BioInd.writeDebug("Found compound entity %s",
                  {base_entry.base and BioInd.print_name_id(base_entry.base)})

    -- Arboretum: Need to separately remove the entry from the radar table
    if entity.name == "bi-arboretum" and base_entry.radar and base_entry.radar.valid then
      global.bi_arboretum_radar_table[base_entry.radar.unit_number] = nil
BioInd.show("Removed arboretum radar! Table", global.bi_arboretum_radar_table)
    end

    -- Power rails: Connections must be explicitely removed, otherwise the poles
    -- from the remaining rails will automatically connect and bridge the gap in
    -- the power supply!
--[[drd
    if entity.name:match("bi%-%a+%-rail%-power") then
BioInd.writeDebug("Before")
      BioInd.writeDebug("Disconnecting %s!", {BioInd.print_name_id(base_entry.pole)})
BioInd.writeDebug("After")
      base_entry.pole.disconnect_neighbour()
    end
]]--
    -- Default: Remove all hidden entities!
    for hidden, h_name in pairs(compound_entity.hidden or {}) do
BioInd.show("hidden", hidden)

--~ BioInd.writeDebug("Removing hidden entity %s %s", {base_entry[hidden] and base_entry[hidden].valid and base_entry[hidden].name or "nil", base_entry[hidden] and base_entry[hidden].valid and base_entry[hidden].unit_number or "nil"})
BioInd.writeDebug("Removing hidden entity %s", {BioInd.print_name_id(base_entry[hidden])})
      BioInd.remove_entity(base_entry[hidden])
      base_entry[hidden] = nil
    end
    global[compound_entity.tab][entity.unit_number] = nil

  -- Rail-to-power: Connections must be explicitely removed, otherwise the poles
  -- from the different rail tracks hooked up to this connector will automatically
  -- keep the separate power networks connected!
--[[drd  elseif entity.name == "bi-power-to-rail-pole" then
    BioInd.writeDebug("Rail-to-power connector has been removed")
    entity.disconnect_neighbour()
    BioInd.writeDebug("Removed copper wires from %s (%g)", {entity.name, entity.unit_number})
]]--

  -- Removed seedling
  elseif entity.name == "seedling" then
    BioInd.writeDebug("Seedling has been removed")
    remove_plants(entity.position, global.bi.tree_growing)

  -- Removed tree
  elseif entity.type == "tree" and global.bi.trees[entity.name] then
    BioInd.show("Removed tree", entity.name)

    local tree_stage = entity.name:match('^.+%-(%d)$')
BioInd.writeDebug("Removed tree %s (grow stage: %s)", {entity.name, tree_stage or nil})
    if tree_stage then
      remove_plants(entity.position, global.bi["tree_growing_stage_" .. tree_stage])
    else
      error(string.format("Tree %s does not have a valid tree_stage: %s", entity.name, tree_stage or "nil"))
    end

  -- Removed something else
  else
    BioInd.writeDebug("%s has been removed -- nothing to do!", {entity.name})
  end
end


--------------------------------------------------------------------
local function On_Damage(event)
  local f_name = "On_Damage"
  BioInd.writeDebug("Entered function %s(%s)", {f_name, event})
  local entity = event.entity
  local final_health = event.final_health

  local arb = "bi-arboretum"
  local associated

  -- Base was damaged: Find the radar associated with it!
  if entity.name == arb then
    associated = global.bi_arboretum_table[entity.unit_number].radar
  -- Radar was damaged: Find the base entity!
  elseif entity.name == global.compound_entities[arb].hidden.radar.name then
    local base_id = global.bi_arboretum_radar_table[entity.unit_number]
    associated = global.bi_arboretum_table[base_id].base
  end

  if associated and associated.valid then
    associated.health = final_health
    BioInd.writeDebug("%s was damaged (%s). Reducing health of %s to %s!", {
                      BioInd.print_name_id(entity),
                      event.final_damage_amount,
                      entity.name == arb and "associated radar" or "base",
                      associated.health
                    })
  end
end

--------------------------------------------------------------------
local function On_Death(event)
  local f_name = "On_Death"
BioInd.writeDebug("Entered function %s(%s)", {f_name, event})

  local entity = event.entity
  if not entity then
    error("Something went wrong -- no entity data!")
  end

  if
      -- Table checks
      global.compound_entities[entity.name] or
      global.bi.trees[entity.name] or
      -- Entity checks
      entity.name == global.compound_entities["bi-arboretum"].hidden.radar.name or
      --drd entity.name == "bi-power-to-rail-pole" or
      entity.name == "seedling" then

    BioInd.writeDebug("Divert to On_Pre_Remove!")
    On_Pre_Remove(event)
  else
    BioInd.writeDebug("Nothing to do!")
  end
end


--------------------------------------------------------------------
-- Radar stuff
--------------------------------------------------------------------

-- Radar completed a sector scan
local function On_Sector_Scanned(event)
  local f_name = "On_Sector_Scanned"
  BioInd.writeDebug("Entered function %s(%s)", {f_name, event})

  ---- Each time a Arboretum-Radar scans a sector  ----
  local arboretum = global.bi_arboretum_radar_table[event.radar.unit_number]
  if arboretum then
    Get_Arboretum_Recipe(global.bi_arboretum_table[arboretum], event)
  end
end


--------------------------------------------------------------------
-- Solar Mat stuff
--------------------------------------------------------------------
--[[drd
--------------------------------------------------------------------
-- Solar mat was removed
local function solar_mat_removed(event)
  BioInd.writeDebug("Entered solar_mat_removed (\"%s\")", {event})

  local surface = game.surfaces[event.surface_index]
  local tiles = event.tiles

  local pos, x, y
  -- tiles contains an array of the old tiles and their position
  for t, tile in pairs(tiles) do
    if tile.old_tile and tile.old_tile.name == "bi-solar-mat" then
      pos = BioInd.normalize_position(tile.position)
      x, y = pos.x, pos.y

BioInd.writeDebug("Looking for hidden entities to remove")
      for _, o in pairs(surface.find_entities_filtered{
        name = {'bi-musk-mat-hidden-pole', 'bi-musk-mat-hidden-panel'},
        position = {x + 0.5, y + 0.5}
      } or {}) do
BioInd.show("Removing", o.name)
        o.destroy()
      end

      -- Remove tile from global tables
      local force_name = global.bi_musk_floor_table.tiles and
                          global.bi_musk_floor_table.tiles[x] and
                          global.bi_musk_floor_table.tiles[x][y]
      if force_name then
BioInd.writeDebug("Removing Musk floor tile from tables!")
        global.bi_musk_floor_table.tiles[x][y] = nil
        if not next(global.bi_musk_floor_table.tiles[x]) then
          global.bi_musk_floor_table.tiles[x] = nil
        end

        if global.bi_musk_floor_table.forces[force_name] and
            global.bi_musk_floor_table.forces[force_name][x] then
          global.bi_musk_floor_table.forces[force_name][x][y] = nil
          if not next(global.bi_musk_floor_table.forces[force_name][x]) then
            global.bi_musk_floor_table.forces[force_name][x] = nil
          end
        end
      end

    end
  end

   BioInd.writeDebug("bi-solar-mat: removed %g tiles", {table_size(tiles)})
end


--------------------------------------------------------------------
-- A solar mat must be placed
local function place_musk_floor(force, position, surface)
  BioInd.check_args(force, "string")
  position = BioInd.normalize_position(position) or BioInd.arg_err(position, "position")
  surface = BioInd.is_surface(surface) or BioInd.arg_err(surface, "surface")

  local x, y = position.x, position.y
  local created
  for n, name in ipairs({"bi-musk-mat-hidden-pole", "bi-musk-mat-hidden-panel"}) do
    created = surface.create_entity({name = name, position = {x + 0.5, y + 0.5}, force = force})
    created.minable = false
    created.destructible = false
    BioInd.writeDebug("Created %s: %s", {name, created.unit_number})
  end

  -- Add to global tables!
  global.bi_musk_floor_table.tiles[x] = global.bi_musk_floor_table.tiles[x] or {}
  global.bi_musk_floor_table.tiles[x][y] = force

  global.bi_musk_floor_table.forces[force] = global.bi_musk_floor_table.forces[force] or {}
  global.bi_musk_floor_table.forces[force][x] = global.bi_musk_floor_table.forces[force][x] or {}
  global.bi_musk_floor_table.forces[force][x][y] = true
end

--------------------------------------------------------------------
-- Solar mat was built

local function solar_mat_built(event)
BioInd.show("Entered function \"solar_mat_built\"", event)
  -- Called from player, bot and script-raised events, so event may
  -- contain "robot" or "player_index"

  local tile = event.tile
  local surface = game.surfaces[event.surface_index]
  local player = event.player_index and game.players[event.player_index]
  local robot = event.robot
  local force = (BioInd.UseMuskForce and BioInd.MuskForceName) or
                (event.player_index and game.players[event.player_index].force.name) or
                (event.robot and event.robot.force.name) or
                event.force.name
BioInd.show("Force.name", force)

  -- Item that was used to place the tile
  local item = event.item
  local old_tiles = event.tiles


  local position --, x, y


  -- Musk floor has been built -- create hidden entities!
  if tile.name == "bi-solar-mat" then
    BioInd.writeDebug("Solar Mat has been built -- must create hidden entities!")
BioInd.show("Tile data", tile )

    --~ for index, old_tile in pairs(old_tiles or {}) do
    for index, t in pairs(old_tiles or {tile}) do
BioInd.show("Read old_tile inside loop", t)
      -- event.tiles will also contain landscape tiles like "grass-1", and it will always
      -- contain at least one tile
      position = BioInd.normalize_position(t.position)
      -- If we got here by a call from script_raised_built, force may be stored
      -- with the tile
      force = force or t.force
BioInd.show("Got force from tile data", t.force or "false")
      BioInd.writeDebug("Building solar mat for force %s at position %s",
        {tostring(type(force) == "table" and force.name or force), position})

      place_musk_floor(force, position, surface)
    end

  -- Fertilizer/Advanced fertilizer has been used. Check if the tile was valid
  -- (no Musk floor, no wooden floor, no concrete etc.)
  elseif item and (item.name == "fertilizer" or item.name == "bi-adv-fertilizer") then

    local restore_tiles = {}
    local products

    for index, t in pairs(old_tiles or {tile}) do
BioInd.show("index", index)
BioInd.show("t.old_tile.name", t.old_tile.name)

      -- We want to restore removed tiles if nothing is supposed to grow on them!
      if global.bi.barren_tiles[t.old_tile.name] then
BioInd.writeDebug("%s was used on forbidden ground (%s)!", {item.name, t.old_tile.name})
        restore_tiles[#restore_tiles + 1] = {name = t.old_tile.name, position = t.position}

        -- Is that tile minable?
        products = global.bi.barren_tiles[t.old_tile.name]
        if type(products) == "table" then
          for p, product in ipairs(products) do
            if player then
BioInd.writeDebug("Removing %s (%s) from player %s", {product.name, product.amount, player.name})
              player.remove_item({name = product.name, count = product.amount})
            elseif robot then
BioInd.writeDebug("Removing %s (%s) from robot %s", {product.name, product.amount, robot.unit_number})
              robot.remove_item({name = product.name, count = product.amount})
            end
          end
        end
      end
    end
BioInd.show("restore_tiles", restore_tiles)
    if restore_tiles then
      surface.set_tiles(
        restore_tiles,
        true,         -- correct_tiles
        true,         -- remove_colliding_entities
        true,         -- remove_colliding_decoratives
        true          -- raise_event
      )
    end

  -- Some other tile has been built -- check if it replaced musk floor!
  else
    local test
    local removed_tiles = {}
    for index, t in pairs(old_tiles or {tile}) do
      position = BioInd.normalize_position(t.position)
      test = global.bi_musk_floor_table and
              global.bi_musk_floor_table.tiles and
              global.bi_musk_floor_table.tiles[position.x] and
              global.bi_musk_floor_table.tiles[position.x][position.y]
      if test then
        removed_tiles[#removed_tiles + 1] = {
          old_tile = {name = "bi-solar-mat"},
          position = position
        }
      end
    end
    if next(removed_tiles) then
      --~ solar_mat_removed(surface, removed_tiles)
      solar_mat_removed({surface_index = event.surface_index, tiles = removed_tiles})
    else
      BioInd.writeDebug("%s has been built -- nothing to do!", {tile.name})
    end
  end

end


--------------------------------------------------------------------
-- A tille has been changed
local function Tile_Changed(event)
  local f_name = "Tile_Changed"
  BioInd.writeDebug("Entered function %s(%s)", {f_name, event})

  -- The event gives us only a list of the new tiles that have been placed.
  -- So let's check if any Musk floor has been built!
  local new_musk_floor_tiles = {}
  local old_musk_floor_tiles = {}
  local remove_musk_floor_tiles = {}
  local pos, old_tile, force

  local tile_force

  for t, tile in ipairs(event.tiles) do
BioInd.show("t", t)
    pos = BioInd.normalize_position(tile.position)
    tile_force = global.bi_musk_floor_table.tiles[pos.x] and
                  global.bi_musk_floor_table.tiles[pos.x][pos.y]
                  --~ -- Fall back to MuskForceName if it is available
                 --~ UseMuskForce and MuskForceName or
                 --~ -- Fall back to "neutral"
                 --~ "neutral"
BioInd.show("Placed tile", tile.name)

    -- Musk floor was placed
    if tile.name == "bi-solar-mat" then
      BioInd.writeDebug("Musk floor tile was placed!")
      new_musk_floor_tiles[#new_musk_floor_tiles + 1] = {
        old_tile = { name = tile.name },
        position = pos,
        force = tile_force or
                BioInd.UseMuskForce and BioInd.MuskForceName or
                "neutral"
      }
    -- Other tile was placed -- by one of our fertilizers?
    elseif tile.name:match("^vegetation%-green%-grass%-[13]$") or
            tile.name:match("^vegetation%-green%-grass%-[13]$") then
      BioInd.writeDebug("Fertilizer was used!")

      -- Fertilizer was used on a Musk floor tile -- restore the tile!
BioInd.show("Musk floor tile in position", tile_force)
      if tile_force then
        old_musk_floor_tiles[#old_musk_floor_tiles + 1] = {
          old_tile = { name == "bi-solar-mat" },
          position = pos,
          force = tile_force
        }

      -- Other tile was placed on a Musk floor tile -- remove Musk floor from lists!
      elseif tile_force then
        remove_musk_floor_tiles[#remove_musk_floor_tiles + 1] = {
          old_tile = { name == "bi-solar-mat" },
          position = pos,
        }
      end
    end
  end
BioInd.show("new_musk_floor_tiles", new_musk_floor_tiles)
BioInd.show("old_musk_floor_tiles", old_musk_floor_tiles)
BioInd.show("remove_musk_floor_tiles", remove_musk_floor_tiles)

  if next(new_musk_floor_tiles) then
    solar_mat_built({
      surface_index = event.surface_index,
      tile = {name = "bi-solar-mat"},
      force = BioInd.MuskForceName,
      tiles = new_musk_floor_tiles
    })
  end
  if next(old_musk_floor_tiles) then
    solar_mat_built({
      surface_index = event.surface_index,
      tile = {name = "bi-solar-mat"},
      tiles = old_musk_floor_tiles
    })
  end
  if next(remove_musk_floor_tiles) then
    solar_mat_removed({surface_index = event.surface_index, tiles = remove_musk_floor_tiles})
  end
  BioInd.show("End of function", f_name)
end
end
]]--drd

--------------------------------------------------------------------


Event.register(Event.core_events.configuration_changed, On_Config_Change)
Event.register(Event.core_events.init, init)
Event.register(Event.core_events.load, On_Load)


Event.build_events = {
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive
}
Event.pre_remove_events = {
  defines.events.on_pre_player_mined_item,
  defines.events.on_robot_pre_mined,
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
}
--~ Event.remove_events = {
  --~ defines.events.on_player_mined_entity,
  --~ defines.events.on_robot_mined_entity,
--~ }
Event.death_events = {
  defines.events.on_entity_died,
  defines.events.script_raised_destroy
}
Event.tile_build_events = {
  defines.events.on_player_built_tile,
  defines.events.on_robot_built_tile
}
Event.tile_remove_events = {
  defines.events.on_player_mined_tile,
  defines.events.on_robot_mined_tile
}
Event.tile_script_action = {
  defines.events.script_raised_set_tiles
}

Event.register(Event.build_events, On_Built)
Event.register(Event.pre_remove_events, On_Pre_Remove)
--~ Event.register(Event.remove_events, On_Remove)
--~ Event.register(Event.remove_events, On_Remove)
Event.register(Event.death_events, On_Death)
--Event.register(Event.tile_build_events, solar_mat_built)
--Event.register(Event.tile_remove_events, solar_mat_removed)


Event.register(defines.events.on_entity_damaged, On_Damage, function(event)
  -- A function is needed for event filtering with stdlib!
  local entity = event.entity

  -- Ignore damage without effect (invulnerable/resistant entities)
  if event.final_damage_amount ~= 0 and
      -- Terraformer/Terraformer radar was damaged
      (global.bi_arboretum_table[entity.unit_number] or
       global.bi_arboretum_radar_table[entity.unit_number]) then
    return true
  end
end)

-- Radar scan
Event.register(defines.events.on_sector_scanned, On_Sector_Scanned, function(event)
  -- A function is needed for event filtering with stdlib!
  if event.radar.name == BioInd.compound_entities["bi-arboretum"].hidden.radar.name then
    return true
  end
end)

-- Tile changed
--Event.register(Event.tile_script_action, Tile_Changed)


------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV, {
  __newindex = function (self, key, value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key = key or '<nil>', value = value or '<nil>'} .. '\n')
    end,
  __index = function (self, key) --locked_global_read
    if not (key == "game" or key == "mods") then
      error('\n\n[ER Global Lock] Forbidden global *read*:\n'
        .. serpent.line{key = key or '<nil>'} .. '\n')
    end
  end
})
