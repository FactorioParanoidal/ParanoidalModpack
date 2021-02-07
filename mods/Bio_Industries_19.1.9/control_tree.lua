local BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)

-- All tree Growing stuff
local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)

local terrains = require("libs/trees-and-terrains")

Bi_Industries = {}

Bi_Industries.fertility = {
    ["vegetation-green-grass-1"] = 100,
    ["grass-1"] =  100,
    ["grass-3"] =  85,
    ["grass-2"] =  70,
    ["grass-4"] =  60,
    ["red-desert-0"] =  50,
    ["dirt-3"] =  40,
    ["dirt-5"] =  37,
    ["dirt-6"] =  34,
    ["dirt-7"] =  31,
    ["dirt-4"] =  28,
    ["dry-dirt"] =  25,
    ["dirt-2"] =  22,
    ["dirt-1"] =  19,
    ["red-desert-2"] =  16,
    ["red-desert-3"] =  13,
    ["sand-3"] =  10,
    ["sand-2"] =  7,
    ["sand-1"] =  4,
    ["red-desert-1"] =  1,
    ["frozen-snow-0"] = 1,
    ["frozen-snow-1"] = 1,
    ["frozen-snow-2"] = 1,
    ["frozen-snow-3"] = 1,
    ["frozen-snow-4"] = 1,
    ["frozen-snow-5"] = 1,
    ["frozen-snow-6"] = 1,
    ["frozen-snow-7"] = 1,
    ["frozen-snow-8"] = 1,
    ["frozen-snow-9"] = 1,
    ["mineral-aubergine-dirt-1"] = 45,
    ["mineral-aubergine-dirt-2"] = 45,
    ["mineral-aubergine-dirt-3"] = 25,
    ["mineral-aubergine-dirt-4"] = 25,
    ["mineral-aubergine-dirt-5"] = 25,
    ["mineral-aubergine-dirt-6"] = 25,
    ["mineral-aubergine-dirt-7"] = 25,
    ["mineral-aubergine-dirt-8"] = 25,
    ["mineral-aubergine-dirt-9"] = 25,
    ["mineral-aubergine-sand-1"] = 15,
    ["mineral-aubergine-sand-2"] = 15,
    ["mineral-aubergine-sand-3"] = 10,
    ["mineral-beige-dirt-1"] = 45,
    ["mineral-beige-dirt-2"] = 45,
    ["mineral-beige-dirt-3"] = 25,
    ["mineral-beige-dirt-4"] = 25,
    ["mineral-beige-dirt-5"] = 25,
    ["mineral-beige-dirt-6"] = 25,
    ["mineral-beige-dirt-7"] = 25,
    ["mineral-beige-dirt-8"] = 25,
    ["mineral-beige-dirt-9"] = 25,
    ["mineral-beige-sand-1"] = 10,
    ["mineral-beige-sand-2"] = 10,
    ["mineral-beige-sand-3"] = 10,
    ["mineral-black-dirt-1"] = 45,
    ["mineral-black-dirt-2"] = 45,
    ["mineral-black-dirt-3"] = 25,
    ["mineral-black-dirt-4"] = 25,
    ["mineral-black-dirt-5"] = 25,
    ["mineral-black-dirt-6"] = 25,
    ["mineral-black-dirt-7"] = 25,
    ["mineral-black-dirt-8"] = 25,
    ["mineral-black-dirt-9"] = 25,
    ["mineral-black-sand-1"] = 10,
    ["mineral-black-sand-2"] = 10,
    ["mineral-black-sand-3"] = 10,
    ["mineral-brown-dirt-1"] = 25,
    ["mineral-brown-dirt-2"] = 25,
    ["mineral-brown-dirt-3"] = 25,
    ["mineral-brown-dirt-4"] = 25,
    ["mineral-brown-dirt-5"] = 25,
    ["mineral-brown-dirt-6"] = 25,
    ["mineral-brown-dirt-7"] = 25,
    ["mineral-brown-dirt-8"] = 25,
    ["mineral-brown-dirt-9"] = 25,
    ["mineral-brown-sand-1"] = 10,
    ["mineral-brown-sand-2"] = 10,
    ["mineral-brown-sand-3"] = 10,
    ["mineral-cream-dirt-1"] = 25,
    ["mineral-cream-dirt-2"] = 25,
    ["mineral-cream-dirt-3"] = 25,
    ["mineral-cream-dirt-4"] = 25,
    ["mineral-cream-dirt-5"] = 25,
    ["mineral-cream-dirt-6"] = 25,
    ["mineral-cream-dirt-7"] = 25,
    ["mineral-cream-dirt-8"] = 25,
    ["mineral-cream-dirt-9"] = 25,
    ["mineral-cream-sand-1"] = 10,
    ["mineral-cream-sand-2"] = 10,
    ["mineral-cream-sand-3"] = 10,
    ["mineral-dustyrose-dirt-1"] = 25,
    ["mineral-dustyrose-dirt-2"] = 25,
    ["mineral-dustyrose-dirt-3"] = 25,
    ["mineral-dustyrose-dirt-4"] = 25,
    ["mineral-dustyrose-dirt-5"] = 25,
    ["mineral-dustyrose-dirt-6"] = 25,
    ["mineral-dustyrose-dirt-7"] = 25,
    ["mineral-dustyrose-dirt-8"] = 25,
    ["mineral-dustyrose-dirt-9"] = 25,
    ["mineral-dustyrose-sand-1"] = 10,
    ["mineral-dustyrose-sand-2"] = 10,
    ["mineral-dustyrose-sand-3"] = 10,
    ["mineral-grey-dirt-1"] = 25,
    ["mineral-grey-dirt-2"] = 25,
    ["mineral-grey-dirt-3"] = 25,
    ["mineral-grey-dirt-4"] = 25,
    ["mineral-grey-dirt-5"] = 25,
    ["mineral-grey-dirt-6"] = 25,
    ["mineral-grey-dirt-7"] = 25,
    ["mineral-grey-dirt-8"] = 25,
    ["mineral-grey-dirt-9"] = 25,
    ["mineral-grey-sand-1"] = 10,
    ["mineral-grey-sand-2"] = 10,
    ["mineral-grey-sand-3"] = 10,
    ["mineral-purple-dirt-1"] = 25,
    ["mineral-purple-dirt-2"] = 25,
    ["mineral-purple-dirt-3"] = 25,
    ["mineral-purple-dirt-4"] = 25,
    ["mineral-purple-dirt-5"] = 25,
    ["mineral-purple-dirt-6"] = 25,
    ["mineral-purple-dirt-7"] = 25,
    ["mineral-purple-dirt-8"] = 25,
    ["mineral-purple-dirt-9"] = 25,
    ["mineral-purple-sand-1"] = 10,
    ["mineral-purple-sand-2"] = 10,
    ["mineral-purple-sand-3"] = 10,
    ["mineral-red-dirt-1"] = 25,
    ["mineral-red-dirt-2"] = 25,
    ["mineral-red-dirt-3"] = 25,
    ["mineral-red-dirt-4"] = 25,
    ["mineral-red-dirt-5"] = 25,
    ["mineral-red-dirt-6"] = 25,
    ["mineral-red-dirt-7"] = 25,
    ["mineral-red-dirt-8"] = 25,
    ["mineral-red-dirt-9"] = 25,
    ["mineral-red-sand-1"] = 10,
    ["mineral-red-sand-2"] = 10,
    ["mineral-red-sand-3"] = 10,
    ["mineral-tan-dirt-1"] = 25,
    ["mineral-tan-dirt-2"] = 25,
    ["mineral-tan-dirt-3"] = 25,
    ["mineral-tan-dirt-4"] = 25,
    ["mineral-tan-dirt-5"] = 25,
    ["mineral-tan-dirt-6"] = 25,
    ["mineral-tan-dirt-7"] = 25,
    ["mineral-tan-dirt-8"] = 25,
    ["mineral-tan-dirt-9"] = 25,
    ["mineral-tan-sand-1"] = 10,
    ["mineral-tan-sand-2"] = 10,
    ["mineral-tan-sand-3"] = 10,
    ["mineral-violet-dirt-1"] = 25,
    ["mineral-violet-dirt-2"] = 25,
    ["mineral-violet-dirt-3"] = 25,
    ["mineral-violet-dirt-4"] = 25,
    ["mineral-violet-dirt-5"] = 25,
    ["mineral-violet-dirt-6"] = 25,
    ["mineral-violet-dirt-7"] = 25,
    ["mineral-violet-dirt-8"] = 25,
    ["mineral-violet-dirt-9"] = 25,
    ["mineral-violet-sand-1"] = 10,
    ["mineral-violet-sand-2"] = 10,
    ["mineral-violet-sand-3"] = 10,
    ["mineral-white-dirt-1"] = 25,
    ["mineral-white-dirt-2"] = 25,
    ["mineral-white-dirt-3"] = 25,
    ["mineral-white-dirt-4"] = 25,
    ["mineral-white-dirt-5"] = 25,
    ["mineral-white-dirt-6"] = 25,
    ["mineral-white-dirt-7"] = 25,
    ["mineral-white-dirt-8"] = 25,
    ["mineral-white-dirt-9"] = 25,
    ["mineral-white-sand-1"] = 10,
    ["mineral-white-sand-2"] = 10,
    ["mineral-white-sand-3"] = 10,
    ["vegetation-blue-grass-1"] = 70,
    ["vegetation-blue-grass-2"] = 70,
    ["vegetation-green-grass-2"] = 75,
    ["vegetation-green-grass-3"] = 85,
    ["vegetation-green-grass-4"] = 70,
    ["vegetation-mauve-grass-1"] = 70,
    ["vegetation-mauve-grass-2"] = 70,
    ["vegetation-olive-grass-1"] = 70,
    ["vegetation-olive-grass-2"] = 70,
    ["vegetation-orange-grass-1"] = 70,
    ["vegetation-orange-grass-2"] = 70,
    ["vegetation-purple-grass-1"] = 70,
    ["vegetation-purple-grass-2"] = 70,
    ["vegetation-red-grass-1"] = 70,
    ["vegetation-red-grass-2"] = 70,
    ["vegetation-turquoise-grass-1"] = 70,
    ["vegetation-turquoise-grass-2"] = 70,
    ["vegetation-violet-grass-1"] = 70,
    ["vegetation-violet-grass-2"] = 70,
    ["vegetation-yellow-grass-1"] = 70,
    ["vegetation-yellow-grass-2"] = 70,
    ["volcanic-blue-heat-1"] = 1,
    ["volcanic-blue-heat-2"] = 1,
    ["volcanic-blue-heat-3"] = 1,
    ["volcanic-blue-heat-4"] = 1,
    ["volcanic-green-heat-1"] = 1,
    ["volcanic-green-heat-2"] = 1,
    ["volcanic-green-heat-3"] = 1,
    ["volcanic-green-heat-4"] = 1,
    ["volcanic-orange-heat-1"] = 1,
    ["volcanic-orange-heat-2"] = 1,
    ["volcanic-orange-heat-3"] = 1,
    ["volcanic-orange-heat-4"] = 1,
    ["volcanic-purple-heat-1"] = 1,
    ["volcanic-purple-heat-2"] = 1,
    ["volcanic-purple-heat-3"] = 1,
    ["volcanic-purple-heat-4"] = 1,
    ["landfill"] = 1,
}

local function get_tile_fertility(surface, position)
  surface = BioInd.is_surface(surface) or BioInd.arg_err(surface or "nil", "surface")
  position = BioInd.normalize_position(position) or BioInd.arg_err(position or "nil", "position")

  local fertility = Bi_Industries.fertility[surface.get_tile(position.x, position.y).name]

  return fertility and {fertility = fertility, key = "fertilizer"} or
                        {fertility = 1, key = "default"}
end


local function plant_tree(tabl, tree, create_entity)
  BioInd.check_args(tabl, "table")
  BioInd.check_args(tree, "table")
  BioInd.check_args(tree.time, "number", "time")
  -- tree.tree_name is only required if we really want to create a tree,
  -- not if we just want to add a table entry!
  if create_entity then
    BioInd.check_args(tree.tree_name, "string", "tree_name")
  end

  if not (tree.position and BioInd.normalize_position(tree.position)) then
    BioInd.arg_err(tree.position or "nil", "position")
  elseif not (tree.surface and BioInd.is_surface(tree.surface)) then
    BioInd.arg_err(tree.surface or "nil", "surface")
  end

  -- Update table
  table.insert(tabl, tree)
  table.sort(tabl, function(a, b) return a.time < b.time end)

  -- Plant the new tree
  if create_entity then
    tree.surface.create_entity({
      name = tree.tree_name,
      position = tree.position,
      force = "neutral"
    })
  end
end

-- t_base, t_penalty: numbers; seedbomb: Boolean
local function plant_seed(event, t_base, t_penalty, seedbomb)
  for a, arg in pairs({
    {arg = event, type = "table"},
    {arg = t_base, type = "number"},
    {arg = t_penalty, type = "number"}
  }) do
    BioInd.check_args(arg.arg, arg.type, arg.desc)
  end

BioInd.show("event", event)
BioInd.show("t_base", t_base)
BioInd.show("t_penalty", t_penalty)
BioInd.show("seedbomb", seedbomb)
  -- Seed Planted (Put the seedling in the table)
  local entity = event.entity or event.created_entity or
                  BioInd.arg_err("nil", "entity")
  local surface = BioInd.is_surface(entity.surface) or
                  BioInd.arg_err(entity.surface or "nil", "surface")
  local pos = BioInd.normalize_position(entity.position) or
                  BioInd.arg_err(entity.position or "nil", "position")

  -- Minimum will always be 1
  local fertility = get_tile_fertility(surface, pos).fertility

  -- Things will grow faster on fertile than on barren tiles
  -- (No penalty for tiles with maximum fertility)
  local grow_time = math.max(1, math.random(t_base) + t_penalty - (40 * fertility))
  local tree_data = {
    position = pos,
    time = event.tick + grow_time,
    surface = surface,
    seed_bomb = seedbomb
  }
  plant_tree(global.bi.tree_growing, tree_data, false)
end

function seed_planted(event)
  plant_seed(event, 1000, 4000, false)
end

function seed_planted_trigger(event)
  plant_seed(event, 2000, 6000, true)
end

function seed_planted_arboretum(event, entity)
  event.created_entity = entity
  plant_seed(event, 2000, 6000, false)
end


function summ_weight(tabl)
  local summ = 0
  for i, tree_weights in pairs(tabl or {}) do
    if (type(tree_weights) == "table") and tree_weights.weight then
      summ = summ + tree_weights.weight
    end
  end
  return summ
end

function tree_from_max_index_tabl(max_index, tabl)
  BioInd.check_args(max_index, "number")

  local rnd_index = math.random(max_index)
  for tree_name, tree_weights in pairs(tabl or {}) do
    if (type(tree_weights) == "table") and tree_weights.weight then
      rnd_index = rnd_index - tree_weights.weight
      if rnd_index <= 0 then
        return tree_name
      end
    end
  end
  return nil
end

function random_tree(surface, position)
  surface = BioInd.is_surface(surface) or BioInd.arg_err(surface or "nil", "surface")
  position = position and BioInd.normalize_position(position) or
                    BioInd.arg_err(position or "nil", "position")
  local tile_name = surface.get_tile(position.x, position.y).name

BioInd.show("random_tree: tile_name", tile_name)
BioInd.show("terrains[tile_name]", terrains[tile_name])
  if terrains[tile_name] then
    local trees_table = terrains[tile_name]
    local max_index = summ_weight(trees_table)
BioInd.writeDebug("Found %s in table terrains. trees_table: %s\tmax_index: %s", {tile_name,trees_table, max_index})
    return tree_from_max_index_tabl(max_index, trees_table)
  end
end


-- Settings used for the different grow stages
local stage_settings = {
  [1] = {
    fertilizer = {max = 1500, penalty = 3000, factor = 30},
    default = {max = 1500, penalty = 6000, factor = 30},
  },
  [2] = {
    fertilizer = {max = 1000, penalty = 2000, factor = 20},
    default = {max = 1500, penalty = 6000, factor = 30},
  },
  [3] = {
    fertilizer = {max = 1000, penalty = 2000, factor = 20},
    default = {max = 1500, penalty = 6000, factor = 30},
  },
}

local function Grow_tree_first_stage(first_stage_table, event)
  BioInd.check_args(first_stage_table, "table")
  BioInd.check_args(event, "table")
  local surface = BioInd.is_surface(first_stage_table.surface) or
                    BioInd.arg_err(first_stage_table.surface or "nil", "surface")
  local position = BioInd.normalize_position(first_stage_table.position) or
                    BioInd.arg_err(first_stage_table.position or "nil", "position")
  local seed_bomb = first_stage_table.seed_bomb

  local tree = surface.find_entity("seedling", position)
  local tree2 = surface.find_entity("seedling-2", position)
  local tree3 = surface.find_entity("seedling-3", position)
BioInd.writeDebug("tree: %s\ttree2: %s\ttree3: %s", {tree or "nil", tree2 or "nil", tree3 or "nil"})

  -- fertility will be 1 if terrain type is not listed above, so very small chance to grow.
  local f = get_tile_fertility(surface, position)
  local fertility, key = f.fertility, f.key
BioInd.show("fertility", fertility)
BioInd.show("key", key)
  -- Random value. Tree will grow if this value is smaller than the 'Fertility' value
  local growth_chance = math.random(100)

  local tree_name, can_be_placed
  if tree or tree2 or tree3 then
BioInd.writeDebug("Found a seedling!")
    tree_name = random_tree(surface, position)
BioInd.show("tree_name", tree_name)
  end

  if tree and tree_name and not seed_bomb then
BioInd.writeDebug("tree and not seed_bomb")
    tree.destroy()
BioInd.writeDebug("Destroyed tree!")
    --- Depending on Terrain, choose tree type & Convert seedling into a tree
    if key == "fertilizer" then
BioInd.writeDebug("New tree can grow!")
      -- Grow the new tree
      can_be_placed = surface.can_place_entity({
        name = tree_name, position = position, force = "neutral"
      })

      if tree_name and can_be_placed and growth_chance <= (fertility + 5) then
BioInd.writeDebug("Can be placed etc!")
        -- Trees will grow faster on Fertile than on barren tiles
        local grow_time = math.max(1, math.random(2000) + 4000 - (40 * fertility))
BioInd.writeDebug("grow_time: %s", {grow_time})

        local stage_1_tree_name = "bio-tree-" .. tree_name .. "-1"
        if not (game.item_prototypes[stage_1_tree_name] or
                game.entity_prototypes[stage_1_tree_name]) then
          stage_1_tree_name = tree_name
        end
BioInd.writeDebug("stage_1_tree_name: %s", {stage_1_tree_name})

        local tree_data = {
          tree_name = stage_1_tree_name,
          final_tree = tree_name,
          position = position,
          time = event.tick + grow_time,
          surface = surface
        }
        plant_tree(global.bi.tree_growing_stage_1, tree_data, true)
      end
    end
  end

  --- Seed Bomb Code
  if tree_name and tree2 or tree3 then

    if tree2 then tree2.destroy() end
    if tree3 then tree3.destroy() end

    --- Depending on terrain, choose tree type & convert seedling into a tree
    if key == "fertilizer" then
      can_be_placed = surface.can_place_entity{
        name = tree_name,
        position = position,
        force = "neutral"
      }
      if can_be_placed and tree_name and growth_chance <= fertility then
        surface.create_entity{
          name = tree_name,
          position = position,
          force = "neutral"
        }
      end
    end
  end

  if seed_bomb then
    BioInd.writeDebug("Seed bomb was used!")
    if tree then
      tree.destroy()
    end

    --- Depending on Terrain, choose tree type & Convert seedling into a tree
    if key == "fertilizer" then
      BioInd.writeDebug("Got Tile")
      if tree_name then
        BioInd.writeDebug("Found Tree")
        can_be_placed = surface.can_place_entity({
          name = tree_name, position = position, force = "neutral"
        })
        if can_be_placed and growth_chance <= fertility then
          surface.create_entity{name = tree_name, position = position, force = "neutral"}
        end
      else
        BioInd.writeDebug("Tree not Found")
      end
    else
      BioInd.writeDebug("Tile not Found")
    end
  end
end

local function Grow_tree_last_stage(last_stage_table)
  BioInd.check_args(last_stage_table, "table")
  BioInd.check_args(last_stage_table.tree_name, "string", "tree_name")
  BioInd.check_args(last_stage_table.final_tree, "string", "final_tree")

  local surface = BioInd.is_surface(last_stage_table.surface) or
                    BioInd.arg_err(last_stage_table.surface or "nil", "surface")
  local position = BioInd.normalize_position(last_stage_table.position) or
                    BioInd.arg_err(last_stage_table.position or "nil", "position")

  local tree_name = last_stage_table.tree_name
  local final_tree = last_stage_table.final_tree

  local tree = tree_name and surface.find_entity(tree_name, position)


  if tree then
    tree.destroy()

    -- fertility will be 1 if terrain type not listed above, so very small change to grow.
    local f = get_tile_fertility(surface, position)
    local fertility, key = f.fertility, f.key

    -- Random value. Tree will grow if this value is smaller than the 'Fertility' value
    local growth_chance = math.random(100)

    --- Convert growing tree to fully grown tree
    if (key == "fertilizer" or growth_chance <= fertility) then

      -- Grow the new tree
      BioInd.writeDebug("Final Tree Name: %s", {final_tree})
      surface.create_entity({
          name = final_tree,
          position = position,
          force = "neutral"
        })
    end
  end
end


local function Grow_tree_stage(stage_table, stage)
BioInd.writeDebug("Entered function Grow_tree_stage(%s, %s)", {stage_table, stage})
  BioInd.check_args(stage_table, "table")
  BioInd.check_args(stage, "number")

  if stage == 4 then
    Grow_tree_last_stage(stage_table)
  else
    for a, arg in pairs({
      {arg = stage_table.tree_name, type = "string", desc = "tree_name"},
      {arg = stage_table.final_tree, type = "string", desc = "final_tree"},
      {arg = stage_table.time, type = "number", desc = "time"},
    }) do
      BioInd.check_args(arg.arg, arg.type, arg.desc)
    end

    local tree_name = stage_table.tree_name
    local final_tree = stage_table.final_tree
    local time_planted = stage_table.time

    local surface = BioInd.is_surface(stage_table.surface) or
                      BioInd.arg_err(stage_table.surface or "nil", "surface")
    local position = BioInd.normalize_position(stage_table.position) or
                      BioInd.arg_err(stage_table.position or "nil", "position")



    local tree = tree_name and surface.find_entity(tree_name, position)

    if tree then
      tree.destroy()

      local next_stage = stage + 1
      --- Depending on Terrain, choose tree type & Convert seedling into a tree
      local f = get_tile_fertility(surface, position)
      local fertility, key = f.fertility, f.key

      local next_stage_tree_name = "bio-tree-" .. final_tree .. "-" .. next_stage
      if not (game.item_prototypes[next_stage_tree_name] or
                game.entity_prototypes[next_stage_tree_name]) then
        next_stage_tree_name = final_tree
        BioInd.writeDebug("Next stage %g: Prototype did not exist", {next_stage})
      else
        BioInd.writeDebug("Next stage %g: %s", {next_stage, next_stage_tree_name})
      end

      local can_be_placed = surface.can_place_entity{
        name = next_stage_tree_name,
        position = position,
        force = "neutral"
      }

      if can_be_placed then

        if next_stage_tree_name == final_tree then
          BioInd.writeDebug("Tree reached final stage, don't insert")
          surface.create_entity({
            name = final_tree,
            position = position,
            force = "neutral"
          })
        else
          -- Trees will grow faster on fertile than on barren tiles!
          local s = stage_settings[stage][key]
          local grow_time = math.max(1, math.random(s.max) + s.penalty - (s.factor * fertility))

          local tree_data = {
            tree_name = next_stage_tree_name,
            final_tree = final_tree,
            position = position,
            time = time_planted + grow_time,
            surface = surface
          }
          plant_tree(global.bi["tree_growing_stage_" .. next_stage], tree_data, true)
        end
      end

    else
      BioInd.writeDebug("Did not find that tree I was looking for...")
    end
  end
end


---- Growing Tree
--Event.register(-12, function(event)
Event.register(defines.events.on_tick, function(event)
  if global.bi.tree_growing_stage_1 == nil then
    for i = 1, 4 do
      global.bi["tree_growing_stage_" .. i] = {}
    end
  end

  while next(global.bi.tree_growing) do
    -- Table entries are sorted by "time", so we can stop if the first entry's
    -- "time" refers to a tick in the future!
    if event.tick < global.bi.tree_growing[1].time then
      --~ BioInd.writeDebug("Still growing")
      break
    end
--~ BioInd.writeDebug("Not growing! Calling Grow_tree_stage_0")
    Grow_tree_first_stage(global.bi.tree_growing[1], event)
    table.remove(global.bi.tree_growing, 1)
--~ BioInd.writeDebug("global.bi.tree_growing: %s", {global.bi.tree_growing}, "line")
  end

  for stage = 1, 4 do
    local stage_table = global.bi["tree_growing_stage_" .. stage]
    while next(stage_table) do
      if event.tick < stage_table[1].time then
        break
      end
      Grow_tree_stage(stage_table[1], stage)
      table.remove(stage_table, 1)
    end
  end
end)
