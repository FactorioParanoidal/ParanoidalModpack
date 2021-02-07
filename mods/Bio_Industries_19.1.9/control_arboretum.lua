local BioInd = require("__" .. script.mod_name .. "__.common")(script.mod_name)

BioInd.writeDebug("Entered control_arboretum.lua")

---Arboretum Stuff

--~ local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(false)

-- If a recipe with NORMAL FERTILIZER is used, don't fertilize tiles set have "true"
-- set! (Fertile tiles set to true in this table can't be made more fertile with
-- normal fertilizer, and nothing should grow on the other tiles.)
local Terrain_Check_1 = {
  --~ ["landfill"] = true,
  ["grass-1"] = true,                   -- Fertility: 100%
  ["grass-3"] = true,                   -- Fertility: 85%
  ["vegetation-green-grass-1"] = true,  -- Fertility: 100%
  ["vegetation-green-grass-3"] = true,  -- Fertility: 85%
}

-- If a recipe with ADVANCED FERTILIZER is used, don't fertilize tiles set have "true" set!
-- (Fertile tiles in this table can't be made more fertile, and nothing should grow on the
--  the others tiles!)
local Terrain_Check_2 = {
  --~ ["landfill"] = true,
  ["grass-1"] = true,                   -- Fertility: 100%
  ["vegetation-green-grass-1"] = true,  -- Fertility: 100%
}

local plant_radius = 75
--~ local plant_radius = 25

-- Different tiles are used if AlienBiomes is active
local AB, terrain_name_g1, terrain_name_g3

-- OmniFluid replaces all fluids with items, so the arboretum won't have a fluidbox!
--~ local OmniFluid


local function get_new_position(pos)
  pos = BioInd.normalize_position(pos) or BioInd.arg_err("nil", position)
  local xxx = math.random(-plant_radius, plant_radius)
  local yyy = math.random(-plant_radius, plant_radius)

  return {x = pos.x + xxx, y = pos.y + yyy}
end


-- Check that all ingredients are available!
local function check_ingredients(arboretum)
  local recipe = arboretum.get_recipe()
  local need = recipe and global.bi_arboretum_recipe_table[recipe.name]

  local function check(need, have)
    for name, amount in pairs(need or {}) do
      if not (have and have[name]) or (have[name] < amount) then
        BioInd.writeDebug("Missing ingredient %s (have %s of %s)", {name, have[name] or 0, amount})
        return false
      end
    end
    return true
  end

  local inventory = arboretum.get_inventory(defines.inventory.assembling_machine_input)
  return need and
          check(need.items, inventory and inventory.get_contents()) and
          check(need.fluids, arboretum.get_fluid_contents()) and
          {ingredients = need, name = recipe.name} or nil
end


local function consume_ingredients(arboretum, need)
  local inventory = arboretum.get_inventory(defines.inventory.assembling_machine_input)
  for item, i in pairs(need.items or {}) do
    inventory.remove({name = item, count = i})
BioInd.writeDebug("Removed %s (%s)", {item, i})
  end
BioInd.show("Inventory", inventory.get_contents() or "nil")

  for fluid, f in pairs(need.fluids or {}) do
    arboretum.remove_fluid({name = fluid, amount = f})
BioInd.writeDebug("Removed %s (%s)", {fluid, f})
  end
BioInd.show("Fluid contents", arboretum.get_fluid_contents() or "nil")
end


local function set_tile(current, target, surface, position)
  if current ~= target then
    surface.set_tiles(
      {{name = target, position = position}},
      true,         -- correct_tiles
      true,         -- remove_colliding_entities
      true,         -- remove_colliding_decoratives
      true          -- raise_event
    )
  end
end

function Get_Arboretum_Recipe(ArboretumTable, event)
  BioInd.writeDebug("Entered function Get_Arboretum_Recipe(%s, %s)", {ArboretumTable, event})
  if not ArboretumTable then
    BioInd.writeDebug("%s is not a valid ArboretumTable. Leaving immediately!")
    return
  end

  local arboretum = ArboretumTable.base
  --~ local new_position, currentTilename, can_be_placed
  local new_position, currentTilename
  local pos, surface, Inventory, stack

  -- 'AlienBiomes' is a bool value -- we don't want to read it again if it's false,
  -- but only if it hasn't been set yet!
  AB = global.compatible.AlienBiomes
  terrain_name_g1 = terrain_name_g1 or (AB and "vegetation-green-grass-1" or "grass-1")
  terrain_name_g3 = terrain_name_g3 or (AB and "vegetation-green-grass-3" or "grass-3")


  local check = check_ingredients(arboretum)
  local ingredients, recipe_name
  if check then
    ingredients, recipe_name = check.ingredients, check.name
  end

  if ingredients then
    local create_seedling, new_plant
    pos = BioInd.normalize_position(arboretum.position) or
          BioInd.arg_err("nil", "position")
    surface = arboretum.surface

    -- Just plant a tree and hope the ground is fertile!
    if recipe_name == "bi-arboretum-r1" then
      BioInd.writeDebug(tostring(recipe_name) .. ": Just plant a tree")

      --- 10 attempts to find a random spot to plant a tree and/or change terrain
      for k = 1, 10 do
        new_position = get_new_position(pos)
        new_plant = {
          name= "seedling",
          position = new_position,
          force = "neutral"
        }

        if surface.can_place_entity(new_plant) then
          consume_ingredients(arboretum, ingredients)
          create_seedling = surface.create_entity(new_plant)
          seed_planted_arboretum(event, create_seedling)
          --- After sucessfully planting a tree, break out of the loop.
          break
        else
          BioInd.writeDebug("Can't plant here (attempt %s)", k)
        end
      end
    -- Fertilize the ground with normal fertilizer. Ignore tiles listed in Terrain_Check_1!
    elseif recipe_name == "bi-arboretum-r2" then
      BioInd.writeDebug(tostring(recipe_name) .. ": Just change terrain to grass-3 (basic)")

      for k = 1, 10 do --- 10 attempts to find a random spot to plant a tree and / or change terrain
        new_position = get_new_position(pos)
        currentTilename = surface.get_tile(new_position.x, new_position.y).name

        -- We need to fertilize the ground!
        if Bi_Industries.fertility[currentTilename] and not Terrain_Check_1[currentTilename] then
          consume_ingredients(arboretum, ingredients)
          set_tile(currentTilename, terrain_name_g3, surface, new_position)
          --- After sucessfully changing the terrain, break out of the loop.
          break
        else
          BioInd.writeDebug("%s: Can't change terrain (%s)",
                            {k, currentTilename or "unknown tile"})
        end
      end
    -- Fertilize the ground with advanced fertilizer. Ignore tiles listed in Terrain_Check_2!
    elseif recipe_name == "bi-arboretum-r3" then
      BioInd.writeDebug(tostring(recipe_name) .. ": Just change terrain to grass-1 (advanced)")

      for k = 1, 10 do --- 10 attempts to find a random spot to plant a tree and / or change terrain
        new_position = get_new_position(pos)
        currentTilename = surface.get_tile(new_position.x, new_position.y).name

        if Bi_Industries.fertility[currentTilename] and currentTilename ~= terrain_name_g1 then
          consume_ingredients(arboretum, ingredients)
          set_tile(currentTilename, terrain_name_g1, surface, new_position)
          --- After sucessfully changing the terrain, break out of the loop.
          break
        else
          BioInd.writeDebug("%s: Can't change terrain (%s)",
                            {k, currentTilename or "unknown tile"})
        end
      end
    -- Fertilize the ground with normal fertilizer. Ignore tiles listed in Terrain_Check_1!
    -- Also plant a tree.
    elseif recipe_name == "bi-arboretum-r4" then
      BioInd.writeDebug(tostring(recipe_name) .. ": Plant Tree AND change the terrain to grass-3 (basic)")

      for k = 1, 10 do --- 10 attempts to find a random spot to plant a tree and / or change terrain
        new_position = get_new_position(pos)
        currentTilename = surface.get_tile(new_position.x, new_position.y).name
        new_plant = {
          name= "seedling",
          position = new_position,
          force = "neutral"
        }

        -- Test to see if we can plant
        if surface.can_place_entity(new_plant) and Bi_Industries.fertility[currentTilename] then
          consume_ingredients(arboretum, ingredients)
          -- Refund fertilizer -- no need to waste it on fertile ground!
          if Terrain_Check_1[currentTilename] then
            arboretum.insert({name = "fertilizer", count = ingredients.items.fertilizer})
            BioInd.writeDebug("Refunded fertilizer!")
          end

          set_tile(currentTilename, terrain_name_g3, surface, new_position)
          create_seedling = surface.create_entity(new_plant)
          seed_planted_arboretum(event, create_seedling)
          --- After sucessfully planting a tree or changing the terrain, break out of the loop.
          break
        else
          BioInd.writeDebug("%s: Can't change terrain and plant a tree (%s)",
                            {k, currentTilename or "unknown tile"})
        end
      end
    -- Fertilize the ground with advanced fertilizer. Ignore tiles listed in Terrain_Check_2!
    -- Also plant a tree.
    elseif recipe_name == "bi-arboretum-r5" then
      BioInd.writeDebug(tostring(recipe_name) .. ": Plant Tree and change the terrain to grass-1 (advanced)")

      for k = 1, 10 do --- 10 attempts to find a random spot to plant a tree and / or change terrain
        new_position = get_new_position(pos)
        currentTilename = surface.get_tile(new_position.x, new_position.y).name
        new_plant = {
          name= "seedling",
          position = new_position,
          force = "neutral"
        }

        if surface.can_place_entity(new_plant) and Bi_Industries.fertility[currentTilename] then
          consume_ingredients(arboretum, ingredients)
          -- Refund fertilizer -- no need to waste it on fertile ground!
          if Terrain_Check_2[currentTilename] then
            arboretum.insert({
              name = "bi-adv-fertilizer", count = ingredients.items["bi-adv-fertilizer"]
            })
            BioInd.writeDebug("Refunded advanced fertilizer!")
          end

          set_tile(currentTilename, terrain_name_g1, surface, new_position)
          create_seedling = surface.create_entity(new_plant)
          seed_planted_arboretum (event, create_seedling)
          --- After sucessfully planting a tree or changing the terrain, break out of the loop.
          break
        else
          BioInd.writeDebug("%s: Can't change terrain and plant a tree (%s)",
                            {k, currentTilename or "unknown tile"})
        end
      end
    else
      BioInd.writeDebug("Terraformer has no recipe!")
    end
  end
end
