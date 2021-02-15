local BioInd = require('common')('Bio_Industries')
local ICONPATH = "__Bio_Industries__/graphics/icons/"

-- If OwnlyMe's or Tral'a "Robot Tree Farm" mods are active, they will create variatons
-- of our variations of tree prototypes. Remove them!
local ignore_trees = BioInd.get_tree_ignore_list()
local removed = 0

for name, _ in pairs(ignore_trees or {}) do
  if name:match("rtf%-bio%-tree%-.+%-%d-%d+") then
    data.raw.tree[name] = nil
    ignore_trees[name] = nil
    removed = removed + 1
    BioInd.show("Removed tree prototype", name)
  end
end
BioInd.writeDebug("Removed %g tree prototypes. Number of trees to ignore now: %g", {removed, table_size(ignore_trees)})

BI.Settings.BI_Game_Tweaks_Emissions_Multiplier = settings.startup["BI_Game_Tweaks_Emissions_Multiplier"].value


-- 5dim Stack changes
--~ if settings.startup["5d-change-stack"] and settings.startup["5d-change-stack"].value then
if BioInd.get_startup_setting("5d-change-stack") then
  local item = data.raw.item["wood"]
   if item then
      item.stack_size = math.max(210, item.stack_size)
   end
end


-- Moved to data-updates.lua for 0.18.34/1.1.4!
--~ ---- Game Tweaks ---- Recipes
--~ if BI.Settings.BI_Game_Tweaks_Recipe then
  --~ --- Concrete Recipe Tweak
  --~ thxbob.lib.recipe.remove_ingredient("concrete", "iron-ore")
  --~ thxbob.lib.recipe.add_new_ingredient("concrete", {type = "item", name = "iron-stick", amount = 2})

  --~ --- Stone Wall
  --~ thxbob.lib.recipe.add_new_ingredient("stone-wall", {type = "item", name = "iron-stick", amount = 1})

  --~ --- Rail (Remove Stone and Add Crushed Stone)
  --~ if data.raw.item["stone-crushed"] then
    --~ thxbob.lib.recipe.remove_ingredient("rail", "stone")
    --~ thxbob.lib.recipe.add_new_ingredient("rail", {type = "item", name = "stone-crushed", amount = 6})
    --~ thxbob.lib.recipe.remove_ingredient("bi-rail-wood", "stone")
    --~ thxbob.lib.recipe.add_new_ingredient("bi-rail-wood", {type = "item", name = "stone-crushed", amount = 6})
  --~ end

  --~ -- vanilla rail recipe update
  --~ thxbob.lib.recipe.add_new_ingredient("rail", {type = "item", name = "concrete", amount = 6})
--~ end

---- Game Tweaks ---- Tree
if BI.Settings.BI_Game_Tweaks_Tree then
  for tree_name, tree in pairs(data.raw["tree"] or {}) do
    if tree.minable and not ignore_trees[tree_name] then
BioInd.writeDebug("Tree name: %s\tminable.result: %s", {tree.name, (tree.minable and tree.minable.result or "nil")}, "line")
    --CHECK FOR SINGLE RESULTS
      if tree.minable.result then
        --CHECK FOR VANILLA TREES WOOD x 4
        if tree.minable.result == "wood" and tree.minable.count == 4 then
  BioInd.writeDebug("Changing wood yield of %s to random value.", {tree.name})
          tree.minable.mining_particle = "wooden-particle"
          tree.minable.mining_time = 1.5
          tree.minable.results = {
            {
              type = "item",
              name = "wood",
              amount_min = 1,
              amount_max = 6
            }
          }
        -- CONVERT RESULT TO RESULTS
        else
  BioInd.writeDebug("Converting tree.minable.result to tree.minable.results!")
  --~ BioInd.show("tree.minable", tree.minable)

          tree.minable.mining_particle = "wooden-particle"
          tree.minable.results = {
            {
              type = "item",
              name = tree.minable.result,
              amount = tree.minable.count,
            }
          }
  --~ BioInd.show("tree.minable.results", tree.minable.results)
        end
      --CHECK FOR RESULTS TABLE
      elseif tree.minable.results then
BioInd.writeDebug("Changing results!")
        for r, result in pairs(tree.minable.results) do
          --CHECK FOR RESULT WOOD x 4
          if result.name == "wood" and result.amount == 4 then
            result.amount = nil
            result.amount_min = 1
            result.amount_max = 6
          end
        end
        tree.minable.result = nil
        tree.minable.count = nil
      end
    else
BioInd.writeDebug("Ignoring  %s!", {tree.name})
    end
--~ BioInd.show("tree.minable", tree.minable)
  end
end


---- Game Tweaks ---- Player (Changed for 0.18.34/1.1.4!)
if BI.Settings.BI_Game_Tweaks_Player then
  -- There may be more than one character in the game! Here's a list of
  -- the character prototype names or patterns matching character prototype
  -- names we want to ignore.
  local blacklist = {
    ------------------------------------------------------------------------------------
    --                                  Known dummies                                 --
    ------------------------------------------------------------------------------------
    -- Autodrive
    "autodrive-passenger",
    -- AAI Programmable Vehicles
    "^.+%-_%-driver$",
    -- Minime
    "minime_character_dummy",
    -- Water Turret (currently the dummies are not characters -- but things may change!)
    "^WT%-.+%-dummy$",
    ------------------------------------------------------------------------------------
    --                                Other characters                                --
    ------------------------------------------------------------------------------------
    -- Bob's Classes and Multiple characters mod
    "^.*bob%-character%-.+$",
  }

  local whitelist = {
    -- Default character
    "^character$",
    -- Characters compatible with Minime
    "^.*skin.*$",
  }

  local tweaks = {
    loot_pickup_distance        = 5,    -- default 2
    build_distance              = 20,   -- Vanilla 6
    drop_item_distance          = 20,   -- Vanilla 6
    reach_distance              = 20,   -- Vanilla 6
    item_pickup_distance        = 6,    -- Vanilla 1
    reach_resource_distance     = 6,    -- Vanilla 2.7
  }

  local found, ignore
  for char_name, character in pairs(data.raw.character) do
BioInd.show("Checking character", char_name)
    found = false

    for w, w_pattern in ipairs(whitelist) do
--~ BioInd.show("w_pattern", w_pattern)
      if char_name == w_pattern or char_name:match(w_pattern) then
        ignore = false
BioInd.show("Found whitelisted character name", char_name)
        for b, b_pattern in ipairs(blacklist) do
--~ BioInd.show("b_pattern", b_pattern)

          if char_name == b_pattern or char_name:match(b_pattern) then
BioInd.writeDebug("%s is on the ignore list!", char_name)
            -- Mark character as found
            ignore = true
            break
          end
        end
        if not ignore then
          found = true
          break
        end
      end
      if found then
        break
      end
    end

    -- Apply tweaks
    if found then
      for tweak_name, tweak in pairs(tweaks) do
        if character[tweak_name] < tweak then
BioInd.writeDebug("Changing %s from %s to %s", {tweak_name, character[tweak_name], tweak})
          character[tweak_name] = tweak
        end
      end
    end
  end
end


-- Moved to data-updates.lua for 0.18.34/1.1.4!
--~ ---- Game Tweaks ---- Disassemble Recipes
--~ require("prototypes.Bio_Tweaks.recipe")
--~ if BI.Settings.BI_Game_Tweaks_Disassemble then
  --~ for recipe, tech in pairs({
    --~ ["bi-burner-mining-drill-disassemble"] = "automation-2",
    --~ ["bi-burner-inserter-disassemble"] = "automation-2",
    --~ ["bi-long-handed-inserter-disassemble"] = "automation-2",
    --~ ["bi-stone-furnace-disassemble"] = "automation-2",
    --~ ["bi-steel-furnace-disassemble"] = "advanced-material-processing",
  --~ }) do
    --~ thxbob.lib.tech.add_recipe_unlock(tech, recipe)
  --~ end

--~ end

---- Game Tweaks ---- Production science pack recipe
if data.raw.recipe["bi-production-science-pack"] then
  BI_Functions.lib.allow_productivity("bi-production-science-pack")
  thxbob.lib.tech.add_recipe_unlock("production-science-pack", "bi-production-science-pack")
  BioInd.writeDebug("Unlock for recipe \"bi-production-science-pack\" added.")
end

---- Game Tweaks ---- Bots
if BI.Settings.BI_Game_Tweaks_Bot then
  -- Logistic & Construction bots can't catch fire or be mined
  local function immunify(bot)
    -- Changed for 0.18.34/1.1.4!
    --~ if not bot.flags then
      --~ bot.flags = {}
    --~ end
    --~ if not bot.resistances then
      --~ bot.resistances = {}
    --~ end
    local can_insert = true
    bot.flags = bot.flags or {}
    bot.resistances = bot.resistances or {}
    for f, flag in pairs(bot.flags) do
      if flag == "not-flammable" then
        can_insert = false
        break
      end
    end
    if can_insert then
      table.insert(bot.flags, "not-flammable")
      BioInd.writeDebug("Added flag \"not-flammable\" to %s", {bot.name})
    end

    can_insert = true
    for r, resistance in pairs(bot.resistances) do
      if resistance.type == "fire" and resistance.percent ~= 100 then
        BioInd.writeDebug("Change resistance against \"fire\" from %s to 100 %% for %s", {resistance.percent or "nil", bot.name})
        bot.resistances[r] = {type = "fire", percent = 100}
        can_insert = false
        break
      end
    end
    if can_insert then
      table.insert(bot.resistances, {type = "fire", percent = 100})
      BioInd.writeDebug("Added resistance against  \"fire\" to %s", {bot.name})
    end

    bot.minable = nil
    BioInd.writeDebug("Made  %s unminable", {bot.name})
  end

  --catches modded bots too
  for _, bot in pairs(data.raw['construction-robot']) do
    immunify(bot)
  end

  for _, bot in pairs(data.raw['logistic-robot']) do
    immunify(bot)
  end
end


---- Game Tweaks ----
if BI.Settings.BI_Game_Tweaks_Stack_Size then
  -- Changed for 0.18.34/1.1.4
  local tweaks = {
    ["wood"]            = 200,
    ["stone"]           = 200,
    ["stone-crushed"]   = 400,
    ["concrete"]        = 500,
    ["slag"]            = 400,
  }
  local item
--[[drd
  for tweak_name, tweak in pairs(tweaks) do
    item = data.raw.item[tweak_name]
    if item and item.stack_size < tweak then
      BioInd.writeDebug("Changing stacksize of %s from %s to %s", {item.name, item.stack_size, tweak})
      item.stack_size = 800
    end
  end
]]--
end


--- Update fuel_emissions_multiplier values DrD
if BI.Settings.BI_Game_Tweaks_Emissions_Multiplier then
  for item, factor in pairs({
	["pellet-coke"] = 1.05,
    ["enriched-fuel"] = 0.75,
    ["solid-fuel"] = 1.2,
    ["solid-carbon"] = 0.9,
    ["carbon"] = 0.9,
    ["wood-bricks"] = 1.05,
    ["rocket-fuel"] = 2,
    ["bi-seed"] = 1.30,
    ["seedling"] = 1.30,
    ["bi-wooden-pole-big"] = 1.5,
    ["bi-wooden-pole-huge"] = 1.5,
    ["bi-wooden-fence"] = 1.5,
    ["bi-wood-pipe"] = 1.5,
    ["bi-wood-pipe-to-ground"] = 1.5,
    ["bi-wooden-chest-large"] = 1.30,
    ["bi-wooden-chest-huge"] = 1.30,
    ["bi-wooden-chest-giga"] = 1.30,
    ["bi-ash"] = 1.30,
    ["ash"] = 1.30,
    ["wood-charcoal"] = 1.25,
    ["cellulose-fiber"] = 1.40,
    ["bi-woodpulp"] = 1.40,
    ["solid-coke"] = 1.25,
    ["wood-pellets"] = 1.1,
    ["coal-crushed"] = 2,
    ["wood"] = 1.75,
    ["coal"] = 3.00,
    -- Removed in 0.17.48/0.18.16
    --~ ["thorium-fuel-cell"] = 5.00,
  }) do
    BI_Functions.lib.fuel_emissions_multiplier_update(item, factor)
  end
end




-- Make vanilla and Bio boilers exchangeable
if BI.Settings.BI_Bio_Fuel then
  local boiler = data.raw["boiler"]["boiler"]
  local boiler_group = boiler.fast_replaceable_group or "boiler"

  boiler.fast_replaceable_group = boiler_group
  data.raw["boiler"]["bi-bio-boiler"].fast_replaceable_group = boiler_group
end

--~ -- Make vanilla and wooden rails exchangeable
--~ -- local straight = data.raw["straight-rail"]["straight-rail"].fast_replaceable_group or "rail"
--~ -- local curved = data.raw["curved-rail"]["curved-rail"].fast_replaceable_group or "rail"
--~ local vanilla, group

--~ for f, form in ipairs({"straight", "curved"}) do
  --~ vanilla = data.raw[form .. "-rail"][form .. "-rail"]
  --~ group =vanilla and vanilla.fast_replaceable_group or "rail"
--~ BioInd.show("vanilla.name", vanilla and vanilla.name or "nil")
--~ BioInd.show("vanilla.fast_replaceable_group", vanilla and vanilla.fast_replaceable_group or "nil")
  --~ if vanilla then
    --~ vanilla.fast_replaceable_group = group
  --~ end
  --~ data.raw[form .. "-rail"]["bi-" .. form .. "-rail-power"].fast_replaceable_group = group
  --~ data.raw[form .. "-rail"]["bi-" .. form .. "-rail-wood"].fast_replaceable_group = group
  --~ data.raw[form .. "-rail"]["bi-" .. form .. "-rail-wood-bridge"].fast_replaceable_group = group
--~ end


if mods["Krastorio2"] then
  -- Krastorio² needs much more wood than usually provided by Bio Industries. If Krastorio² is
  -- active, BI should produce much more wood/wood pulp. For better baĺancing, our recipes should
  -- also be changed to require more wood/wood pulp as ingredients.
  -- Recipes for making wood should also use/produce more seeds, seedlings, and water. It shouldn't
  -- be necessary to increase the input of ash and fertilizer in these recipes as they already
  -- require more wood/wood pulp.
  local update = {
    "wood", "bi-woodpulp",
    "bi-seed", "seedling", "water",
  }
  for _, recipe in pairs(data.raw.recipe) do
    BioInd.writeDebug("Recipe has \"mod\" property: %s", {recipe.mod and true or false})
    if recipe.mod == "Bio_Industries" then
      krastorio.recipes.multiplyIngredients(recipe.name, update, 4)
      krastorio.recipes.multiplyProducts(recipe.name, update, 4)
      BioInd.writeDebug("Changed ingredients for %s: %s", {recipe and recipe.name or "nil", recipe and recipe.ingredients or "nil"})
      BioInd.writeDebug("Changed results for %s: %s", {recipe and recipe.name or "nil", recipe and recipe.results or "nil"})
    end
  end


  --~ -- Remove recipes for liquid air and nitrogen
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-liquid-air")
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-nitrogen")
  --~ data.raw.recipe["bi-liquid-air"].hidden = true
  --~ data.raw.recipe["bi-nitrogen"].hidden = true

  --~ -- Replace liquid air with oxygen in Algae Biomass 2 and 3
  --~ thxbob.lib.recipe.replace_ingredient("bi-biomass-2", "liquid-air", "oxygen")
  --~ thxbob.lib.recipe.replace_ingredient("bi-biomass-3", "liquid-air", "oxygen")
end



--~ if mods["Krastorio"] then
  --~ -- Remove recipes for liquid air and nitrogen
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-liquid-air")
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-nitrogen")
  --~ data.raw.recipe["bi-liquid-air"].hidden = true
  --~ data.raw.recipe["bi-nitrogen"].hidden = true

  -- Replace liquid air with oxygen in Algae Biomass 2 and 3
  --~ thxbob.lib.recipe.replace_ingredient("bi-biomass-2", "liquid-air", "oxygen")
  --~ thxbob.lib.recipe.replace_ingredient("bi-biomass-3", "liquid-air", "oxygen")
--~ end


--~ if mods["angelspetrochem"] then
  --~ -- "Angel's Petro Chemical Processing" replaces petroleum-gas with gas-methane.
  --~ -- That doesn't make sense for our recipe, so we revert this change -- the
  --~ -- petroleum gas can still be converted to methane-gas with the converter-valve.
  --~ thxbob.lib.recipe.remove_result("bi-basic-gas-processing", "gas-methane")
  --~ thxbob.lib.recipe.add_result("bi-basic-gas-processing", {
      --~ amount = 15,
      --~ name = "petroleum-gas",
      --~ type = "fluid"
  --~ })

  -- Liquid air and nitrogen aren't needed -- remove unlock recipes!
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-liquid-air")
  --~ thxbob.lib.tech.remove_recipe_unlock("bi-tech-fertilizer", "bi-nitrogen")
  --~ data.raw.recipe["bi-liquid-air"] = nil
  --~ data.raw.recipe["bi-nitrogen"] = nil
--~ end

--~ -- "Alien Biomes" overwrites tiles in item definitions even if these tiles have been
--~ -- disabled via start-up settings. (This has been fixed in "Alien Biomes" 0.5.2 for
--~ -- Factorio 0.18, but let's keep it the code for easier maintainability as long as
--~ --  Factorio 0.17.79 is stable!)
--~ local AlienBiomes = data.raw.tile["vegetation-green-grass-3"] and
                    --~ data.raw.tile["vegetation-green-grass-1"] and true or false

--~ if not AlienBiomes then
  --~ data.raw.item["fertilizer"].place_as_tile.result = "grass-3"
  --~ data.raw.item["bi-adv-fertilizer"].place_as_tile.result = "grass-1"
--~ end

-- Make sure fertilizers have the "place_as_tile" property!
local AlienBiomes = data.raw.tile["vegetation-green-grass-3"] and
                    data.raw.tile["vegetation-green-grass-1"] and true or false

-- We've already set place_as_tile. If it doesn't exist, our fertilizer definition has
-- been overwritten by some other mod, so we restore icons and localization and add
-- place_as_tile again!
local fertilizer = data.raw.item["fertilizer"]
if not fertilizer.place_as_tile then
  fertilizer.place_as_tile = {
    result = AlienBiomes and "vegetation-green-grass-3" or "grass-3",
    condition_size = 1,
    condition = { "water-tile" }
  }
  fertilizer.icon = ICONPATH .. "fertilizer_64.png"
  fertilizer.icon_size = 64
  fertilizer.icons = {
    {
      icon = ICONPATH .. "fertilizer_64.png",
      icon_size = 64,
    }
  }
  fertilizer.localised_name = {"BI-item-name.fertilizer"}
  fertilizer.localised_description = {"BI-item-description.fertilizer"}
end

data.raw.item["bi-adv-fertilizer"].place_as_tile = {
  result = AlienBiomes and "vegetation-green-grass-1" or "grass-1",
  condition_size = 1,
  condition = { "water-tile" }
}

if mods["pycoalprocessing"] and BI.Settings.BI_Bio_Fuel then
    -- Bio_Fuel/recipe.lua:30:      {type = "item", name = "bi-ash", amount = 15}
    thxbob.lib.recipe.remove_result ("bi-basic-gas-processing", "bi-ash")
    thxbob.lib.recipe.add_result("bi-basic-gas-processing", {
      type = "item",
      name = "ash",
      amount = 15
    })
end


-- Moved to data-updates.lua for 0.18.34/1.1.4!
--~ -- "Transport drones" ruins rails by removing object-layer from the collision mask. That
--~ -- causes problems for our "Wooden rail bridges" as they will also pass through cliffs.
--~ -- Fix the collision masks for rail bridges if "Transport drones" is active!
--~ if mods["Transport_Drones"] then
  --~ for _, type in pairs({"straight-rail", "curved-rail"}) do
        --~ data.raw[type]["bi-" .. type .. "-wood-bridge"].collision_mask = BioInd.RAIL_BRIDGE_MASK
  --~ end
--~ end
--~ require("prototypes.Wood_Products.rail_updates")

------------------------------------------------------------------------------------
-- Add icons to our prototypes
BioInd.BI_add_icons()


---TESTING!
--~ for k,v in pairs(data.raw["curved-rail"]) do
--~ log(v.name)
--~ end
--~ for k,v in pairs(data.raw["straight-rail"]) do
--~ log(v.name)
--~ end
--~ for k,v in pairs(data.raw["rail-planner"]) do
--~ log(v.name)
--~ end

--~ BioInd.writeDebug("Testing at end of data-final-fixes.lua!")
--~ for rail_name, rail in pairs(data.raw["straight-rail"]) do
  --~ BioInd.show("rail_name", rail_name)
  --~ BioInd.show("flags", rail.flags)
  --~ BioInd.show("fast_replaceable_group", rail.fast_replaceable_group)
  --~ BioInd.show("next_upgrade", rail.next_upgrade)
  --~ BioInd.show("bounding_box", rail.bounding_box)
  --~ BioInd.show("collision_mask", rail.collision_mask)
--~ end
--~ for r, recipe in pairs(data.raw.recipe) do
  --~ if r:match("^.*boiler.*$") then
    --~ BioInd.writeDebug("recipe: %s\torder: %s\tsubgroup: %s", {r, recipe.order or "", recipe.subgroup or "" })
  --~ end
--~ end

for k, v in pairs(data.raw) do
  for t, p in pairs(v) do
    if p.se_allow_in_space then
      BioInd.writeDebug("%s (%s) can be built in space!", {p.name, t})
    end
  end
end
