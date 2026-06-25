local OV = angelsmods.functions.OV
local special_vanilla = clowns.special_vanilla
local ore_table = clowns.tables.ores
-- lookup table to convert ore name to trigger name
local get_trigger_name = clowns.tables.get_trigger_name
local icon_lookup_table = clowns.tables.icon_lookup_table
local tweaked_icon_lookup = clowns.tables.tweaked_icon_lookup
local CT = clowns.tables
-------------------------------------------------------------------------------
-- FUNCTION AND LOOKUP TABLES SET-UP FOR SORTING ITEMS, ICONS AND CONDITIONS --
-------------------------------------------------------------------------------
--set clownsore triggers
angelsmods.trigger.refinery_products = angelsmods.trigger.refinery_products or {} --set up if it does not already exist
angelsmods.trigger.refinery_products["Adamantite"] = true
angelsmods.trigger.refinery_products["Orichalcite"] = true
angelsmods.trigger.refinery_products["Phosphorite"] = true
angelsmods.trigger.refinery_products["Elionagate"] = true
--angelsmods.trigger.refinery_products["lithium"] = true 
if not special_vanilla then
  angelsmods.trigger.refinery_products["Antitate"] = true
  angelsmods.trigger.refinery_products["Pro-Galena"] = true
  angelsmods.trigger.refinery_products["Sanguinate"] = true
  angelsmods.trigger.refinery_products["Meta-Garnierite"] = true
  angelsmods.trigger.refinery_products["Nova-Leucoxene"] = true
  angelsmods.trigger.refinery_products["Plumbic"] = true
  angelsmods.trigger.refinery_products["Stannic"] = true
  angelsmods.trigger.refinery_products["Manganic"] = true
  angelsmods.trigger.refinery_products["Titanic"] = true
  angelsmods.trigger.refinery_products["Phosphic"] = true
end
--add pyanodons stuff to refinery_products if active
if mods["pycoalprocessing"] then
  angelsmods.trigger.refinery_products["raw-borax"] = true
  angelsmods.trigger.refinery_products["nexelit-ore"] = true
  angelsmods.trigger.refinery_products["niobium-ore"] = true
  angelsmods.trigger.refinery_products["rare-earth-dust"] = true
  if mods["pyfusionenergy"] then
    angelsmods.trigger.refinery_products["molybdenum-ore"] = true
    angelsmods.trigger.refinery_products["regolite-rock"] = true
    angelsmods.trigger.refinery_products["kimberlite-rock"] = true
  end
end

--check if the ore trigger is on
local ore_exists = function(ore_name)
  if angelsmods.trigger.ores[get_trigger_name[ore_name] or ore_name] then
    return true
  end
  if angelsmods.trigger.refinery_products[ore_name] then
    return true
  end
  return false
end
--angelsmods.functions.ore_exists = ore_exists

-- function to merge tables, but not override indexes, but keep (different) contents
local merge_table_of_tables = function(recipes_table)
  local big_table = {}
  for _, recipes in pairs(recipes_table) do
    for _, recipe in pairs(recipes or {}) do
      table.insert(big_table, recipe)
    end
  end
  return big_table
end

-------------------------------------------------------------------------------
-- Localisation Functions --
-------------------------------------------------------------------------------
-- function to create localised descriptions for the regular sorting ores
local create_basic_clowns_sorting_localisation = function(localised_base_name, sorting_tier_names, sorting_results, has_ore)
  -- extract the higher tier sorting results
  local higher_tiers_additional_results = {}
  local any_tier_results = {}
  local any_tier_results_present = {}
  for tier, tier_results in pairs(sorting_results or {}) do
    local results = {}
    for _, result in pairs(tier_results) do
      -- register all results in this tier
      results[result] = true
      if not any_tier_results_present[result] then
        table.insert(any_tier_results, result)
        any_tier_results_present[result] = true
      end
    end
    local higher_results = {}
    for result_tier, result_tier_results in pairs(sorting_results or {}) do
      -- register results only from higher tiers
      if result_tier > tier then
        for _, result in pairs(result_tier_results) do
          if (not results[result]) and (not higher_results[result]) then
            if not higher_tiers_additional_results[tier] then higher_tiers_additional_results[tier] = {} end
            table.insert(higher_tiers_additional_results[tier], result)
            higher_results[result] = true
          end
        end
      end
    end
  end
  if has_ore then
    sorting_results[0] = any_tier_results
    higher_tiers_additional_results[0] = any_tier_results
  end

  -- create a list of localised sorting results for each tier
  local localised_sorting_results = {}
  for tier, tier_results in pairs(sorting_results or {}) do
    local higher_tier_results = higher_tiers_additional_results[tier]
    localised_sorting_results[tier] = {
      sorting  = {},
      refining = higher_tier_results and {} or nil
    }
    if tier > 0 and localised_sorting_results[tier].sorting then
      for _, tier_result in pairs(tier_results) do
        table.insert(localised_sorting_results[tier].sorting, {"",
          string.format("[img=item/%s]", tier_result),
          {"item-description.loc-space"},
          {string.format("item-description.loc-%s", (special_vanilla and tier_result or nil) or get_trigger_name[tier_result] or tier_result)}
        })
      end
    end
    if localised_sorting_results[tier].refining then
      for _, tier_result in pairs(higher_tier_results) do
        table.insert(localised_sorting_results[tier].refining, {"",
          string.format("[img=item/%s]", tier_result),
          {"item-description.loc-space"},
          {string.format("item-description.loc-%s", (special_vanilla and tier_result or nil) or get_trigger_name[tier_result] or tier_result)}
        })
      end
    end
  end

  -- construct the localised description
  local tiered_localised_description = {}
  local localised_indentation = {""}
  for _=1,7 do
    table.insert(localised_indentation, {"item-description.loc-space"})
  end
  
  for tier, tier_localisation in pairs(localised_sorting_results) do
    --log(serpent.block(tier_localisation))
    tiered_localised_description[tier] = {""}

    if tier_localisation.sorting and next(tier_localisation.sorting) then
      local sorting = {""}
      if #tiered_localised_description[tier] > 1 then --protection new line
        table.insert(sorting, {"item-description.loc-nl"})
      end
      table.insert(sorting, {"item-description.angels-ore-sorting"}) --listing title
      for _, sorting_localised_result in pairs(tier_localisation.sorting) do
        table.insert(sorting, {"", {"item-description.loc-nl"}, localised_indentation}) --indent
        table.insert(sorting, sorting_localised_result)
      end
      --log(serpent.block(sorting))
      table.insert(tiered_localised_description[tier], sorting)
    end
    --log(serpent.block(tiered_localised_description[tier]))
    if tier_localisation.refining and next(tier_localisation.refining) then
      local refining = {""}
      if #tiered_localised_description[tier] > 1 then --protection new line
        table.insert(refining, {"item-description.loc-nl"})
      end
      if tier_localisation.sorting and next(tier_localisation.sorting) then --new title
        table.insert(refining, {"item-description.angels-ore-refining-again"})
      else
        table.insert(refining, {"item-description.angels-ore-refining"}) --for raw ores, full refine title
      end
      for _, refining_localised_result in pairs(tier_localisation.refining) do
        table.insert(refining, {"", {"item-description.loc-nl"}, localised_indentation}) --indent
        table.insert(refining, refining_localised_result)
      end
      table.insert(refining, {"", {"item-description.loc-nl"}, localised_indentation})
      table.insert(tiered_localised_description[tier], refining)
      --log(serpent.block(refining))
    end
    --log(serpent.block(tiered_localised_description[tier]))
  end

  -- add the localisation to the the item
  for tier, tier_localised_description in pairs(tiered_localised_description) do
    if tier == 0 then
      local item_name = string.format(localised_base_name, "")
      local item = data.raw.item[item_name]
      if item then
        if item.localised_description then
          item.localised_description = {"", item.localised_description, tier_localised_description}
        else
          item.localised_description = tier_localised_description
        end
      end
      local resource = data.raw.resource[item_name]
      if resource then
        if resource.localised_description then
          resource.localised_description = {"", resource.localised_description, tier_localised_description}
        else
          resource.localised_description = tier_localised_description
        end
      end
      resource = data.raw.resource["infinite-" .. item_name]
      if resource then
        if resource.localised_description then
          resource.localised_description = {"", resource.localised_description, tier_localised_description}
        else
          resource.localised_description = tier_localised_description
        end
      end
    else
      local item_name = string.format(localised_base_name, "-"..(sorting_tier_names[tier] or ""))
      local item = data.raw.item[item_name]
      if item then
        if item.localised_description then
          item.localised_description = {"", item.localised_description, tier_localised_description}
        else
          item.localised_description = tier_localised_description
        end
      end
    end
  end
end
-----------------------------------------------------------------
-- CREATE SORTING RECIPES USING THE ABOVE FUNCTIONS AND TABLES --
-----------------------------------------------------------------
local create_basic_recipe = function(refinery_product, recipe_base_name, adv)
  for i,ore in pairs(clowns.tables.ores) do
    data:extend(
    { --crushed
      {
        type = "recipe",
        name = ore.."-crushed-processing",
        localised_name = {"recipe-name.clowns-refining","Crushed",{"entity-name."..ore}},
        category = "angels-ore-sorting",
        subgroup = "clowns-ore-sorting-t1",
        allow_decomposition = false,
        enabled = false,
        energy_required = 1,
        ingredients = {{type = "item", name = ore.."-crushed", amount = 4}},
        results = {{type = "item", name = "angels-slag", amount = 1}},
        icons =
        {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/crushed.png", icon_size = 64, scale = 0.25, shift = {-8, 8},}
        },
        icon_size = 32,
        order = "a["..ore.."]",
      },
      --Chunk
      {
        type = "recipe",
        name = ore.."-chunk-processing",
        localised_name = {"recipe-name.clowns-refining",{"entity-name."..ore},"Chunk"},
        category = "angels-ore-sorting-2",
        subgroup = "clowns-ore-sorting-t2",
        allow_decomposition = false,
        enabled = false,
        energy_required = 1.5,
        ingredients = {{type = "item", name = ore.."-chunk", amount = 6}},
        results= {{type = "item", name = "angels-slag", amount = 1},},
        icons =
        {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/chunk.png", icon_size = 64, scale = 0.25, shift = {-8, 8},}
        },
        icon_size = 32,
        order = "a["..ore.."]",
      },
      --Crystal
      {
        type = "recipe",
        name = ore.."-crystal-processing",
        localised_name = {"recipe-name.clowns-refining",{"entity-name."..ore},"Crystal"},
        category = "angels-ore-sorting-3",
        subgroup = "clowns-ore-sorting-t3",
        allow_decomposition = false,
        enabled = false,
        energy_required = 2,
        ingredients = {{type = "item", name = ore.."-crystal", amount = 8}},
        results = {{type = "item", name = "angels-slag", amount = 1},},
        icons =
        {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/crystal.png", icon_size = 64, scale = 0.25, shift = {-8, 8},}
        },
        icon_size = 32,
        order = "a["..ore.."]",
      },
      --Pure
      {
        type = "recipe",
        name = ore.."-pure-processing",
        localised_name = {"recipe-name.clowns-refining","Purified",{"entity-name."..ore}},
        category = "angels-ore-sorting-4",
        subgroup = "clowns-ore-sorting-t4",
        allow_decomposition = false,
        enabled = false,
        energy_required = 2,
        ingredients = {{type = "item", name = ore.."-pure", amount = 9}},
        results = {{type = "item", name = "angels-void", amount = 1}},
        icons =
        {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/pure.png", icon_size = 64, scale = 0.25, shift = {-8, 8},}
        },
        icon_size = 32,
        order = "a["..ore.."]",
      }
    }
  )
  end
end
---------------------------------------------------------------------------
     -- UPDATE SORTING RECIPES USING THE ABOVE FUNCTIONS AND TABLES --
-- This function is a direct rip (with some tweaks) from angels-refining --
---------------------------------------------------------------------------
-- function to create the (regular) sorted results for an ore, disables it if it is unused
local create_sorting_recipes = function(refinery_product, recipe_base_name, sorted_ore_results, advanced_sorting)
  local recipes = {}
  local sorting_results = {}
  local tiers = advanced_sorting and {"crushed", "powder", "dust", "crystal"} or {"crushed", "chunk", "crystal", "pure"}
  for tier, tier_name in pairs(tiers) do
    local recipe_used = false
    local recipe = {name = string.format(recipe_base_name, "-" .. tier_name .. "-processing"), results = {}}
    if angelsmods.trigger.refinery_products[refinery_product] then
      for ore_name, ore_amounts in pairs(sorted_ore_results or {}) do
        local ore_amount = (ore_amounts or {})[tier]
        if ore_name == "!!" then
          if ore_amount then
            table.insert(recipe.results, {"!!"})
          end
        else
          if not angelsmods.trigger.ores[get_trigger_name[ore_name] or ore_name] then
            ore_amount = 0
          end
          if ore_amount and ore_amount > 0 then
            table.insert(recipe.results, {type = "item", name = ore_name, amount = ore_amount})
            recipe_used = true

            if not sorting_results[tier] then sorting_results[tier] = {} end
            table.insert(sorting_results[tier], ore_name)
          end
        end
      end
    else
      angelsmods.functions.OV.disable_recipe(string.format(recipe_base_name, "-" .. tier_name))
    end

    if recipe_used then
      table.insert(recipes, recipe)
    else
      angelsmods.functions.OV.disable_recipe(recipe.name)
    end
  end

  if advanced_sorting and not angelsmods.trigger.refinery_products[refinery_product] then
    angelsmods.functions.OV.disable_recipe(string.format(recipe_base_name, "sludge"))
    angelsmods.functions.OV.disable_recipe(string.format(recipe_base_name, "solution"))
    angelsmods.functions.OV.disable_recipe(string.format(recipe_base_name, "anode-sludge-filtering"))
    angelsmods.functions.OV.disable_recipe(string.format(recipe_base_name, "anode-sludge"))
  end
local loc_base_name
  if string.find(recipe_base_name,"clowns-ore",1) then
    loc_base_name=string.format("clownsore%s", string.sub(recipe_base_name, -4, -3) .. "%s")
  else
    loc_base_name=string.format("clowns-ore%s", string.sub(recipe_base_name, -3, -3) .. "%s")
  end
  create_basic_clowns_sorting_localisation(loc_base_name, tiers, sorting_results, not advanced_sorting)
  return recipes
end

-- function to create the mixed sorted results for an ore, disables it if it is unused
local create_sorting_mix_recipe = function(recipe_base_name, ore_result_products, icon_names, ingredients_overrides)
  local recipes = {}
  for recipe_index, ore_result_product in pairs(ore_result_products) do
    local ore_name = type(ore_result_product) == "table" and (ore_result_product[1] or ore_result_product.name) or ore_result_product
    local ore_amount = type(ore_result_product) == "table" and (ore_result_product[2] or ore_result_product.amount) or 1
    local type_name = type(ore_result_product) == "table" and ore_result_product.type or "item"
    local recipe = {
      name = string.format(recipe_base_name, recipe_index),
      results = {
        {"!!"},
        {
          type = type_name,
          name = ore_name,
          amount = ore_amount
        },
      },
      localised_name = { type_name .. "-name." .. ore_name }
    }
    if angelsmods.trigger.ores[get_trigger_name[ore_name] or ore_name] and ore_amount > 0 then
      local icon_name = (icon_names or {})[recipe_index]
      if icon_name then
        if type(icon_name) == "table" then
          recipe.icons = icon_name -- maybe improve this?
        else
          recipe.icon = string.format("__angelsrefininggraphics__/graphics/icons/%s", icon_name)
        end
      end
      local ingredients_override = (ingredients_overrides or {})[recipe_index]
      if ingredients_override then
        local ingredients_override_used = false
        local ingredients = {{"!!"}}
        for _, ingredient in pairs(ingredients_override) do
          local ingredient_name = ingredient.name or ingredient[1]
          local ingredient_amount = ingredient.amount or ingredient[2]
          if ingredient_amount > 0 then -- todo: check if ingredient exist in triggers?
            table.insert(
              ingredients,
              {type = ingredient.type or "item", name = ingredient_name, amount = ingredient_amount}
            )
            ingredients_override_used = true
          end
        end
        if ingredients_override_used then
          recipe.ingredients = ingredients
        end
      end
      table.insert(recipes, recipe)
    else
      angelsmods.functions.OV.disable_recipe(recipe.name)
    end
  end
  return recipes
end

-------------------------------------------------------------------------------
-- REGULAR SORTING ------------------------------------------------------------
-------------------------------------------------------------------------------
create_basic_recipe("Adamantite", "clowns-ore1%s")
create_basic_recipe("Orichalcite", "clowns-ore4%s")
create_basic_recipe("Phosphorite", "clowns-ore5%s")
create_basic_recipe("Elionagate", "clowns-ore7%s")
if not special_vanilla then
  create_basic_recipe("Antitate", "clowns-ore2%s")
  create_basic_recipe("Pro-Galena", "clowns-ore3%s")
  create_basic_recipe("Sanguinate", "clowns-ore6%s")
  create_basic_recipe("Meta-Garnierite", "clowns-ore8%s")
  create_basic_recipe("Nova-Leucoxene", "clowns-ore9%s")
end
if clowns.special_vanilla then
OV.patch_recipes(
  merge_table_of_tables {
    create_sorting_recipes("Adamantite"     , "clowns-ore1%s", CT.adamantite),
    create_sorting_recipes("Orichalcite"    , "clowns-ore4%s", CT.orichalcite),
    create_sorting_recipes("Phosphorite"    , "clowns-ore5%s", CT.phosphorite),
    create_sorting_recipes("Elionagate"     , "clowns-ore7%s", CT.elionagate),
  }
)
else
  OV.patch_recipes(
  merge_table_of_tables {
    create_sorting_recipes("Adamantite"     , "clowns-ore1%s", CT.adamantite),
    create_sorting_recipes("Antitate"       , "clowns-ore2%s", CT.antitate),
    create_sorting_recipes("Pro-Galena"     , "clowns-ore3%s", CT.progalena),
    create_sorting_recipes("Orichalcite"    , "clowns-ore4%s", CT.orichalcite),
    create_sorting_recipes("Phosphorite"    , "clowns-ore5%s", CT.phosphorite),
    create_sorting_recipes("Sanguinate"     , "clowns-ore6%s", CT.sanguinate),
    create_sorting_recipes("Elionagate"     , "clowns-ore7%s", CT.elionagate),
    create_sorting_recipes("Meta-Garnierite", "clowns-ore8%s", CT.metagarnierite),
    create_sorting_recipes("Nova-Leucoxene" , "clowns-ore9%s", CT.novaleucoxene),
    ore_exists("Stannic")  and create_sorting_recipes("Stannic", "clownsore11%s", CT.stannic,  true) or nil,
    ore_exists("Plumbic")  and create_sorting_recipes("Plumbic", "clownsore12%s", CT.plumbic,  true) or nil,
    ore_exists("Manganic") and create_sorting_recipes("Manganic","clownsore13%s", CT.manganic, true) or nil,
    ore_exists("Titanic")  and create_sorting_recipes("Titanic", "clownsore14%s", CT.titanic,  true) or nil,
    ore_exists("Phosphic") and create_sorting_recipes("Phosphic","clownsore15%s", CT.phosphic, true) or nil
  }
)
end
-------------------------------------------------------------------------------
-- MIXED SORTING --------------------------------------------------------------
-------------------------------------------------------------------------------
OV.patch_recipes(--add a sort for special vanilla items to start with??
  merge_table_of_tables {
    -- CRUSHED
    create_sorting_mix_recipe( 
      "clowns-crushed-mix%i-processing",
      CT.crushed_mix_processing,
      clowns.functions.get_icon_table(CT.crushed_mix_processing),
      { --special vanilla overrides
        --[[1]] special_vanilla and {
            {type = "item", name = "clowns-ore7-crushed", amount = 2},
            {type = "item", name = "clowns-ore5-crushed", amount = 2}
          } or nil,
        --[[2]] nil,
        --[[3]] nil,
        --[[4]] nil,
        --[[5]] nil,
        --[[6]] nil,
        --[[7]] nil
      }
    ),
    -- CHUNK
    create_sorting_mix_recipe(
      "clowns-chunk-mix%i-processing",
      CT.chunk_mix_processing,
      clowns.functions.get_icon_table(CT.chunk_mix_processing),
      { --special vanilla overrides
        --[[1]] special_vanilla and {{type = "item", name = "clowns-ore1-chunk", amount = 2},{type = "item", name = "clowns-ore5-chunk", amount = 2}} or nil,
        --[[2]] nil,
        --[[3]] nil,
        --[[4]] nil,
        --[[5]] nil,
        --[[6]] nil,
        --[[7]] nil,
        --[[8]] nil,
        --[[9]] nil
      }
    ),
    -- CRYSTAL
    create_sorting_mix_recipe(
      "clowns-crystal-mix%i-processing",
      CT.crystal_mix_processing,
      clowns.functions.get_icon_table(CT.crystal_mix_processing),
      { --special vanilla overrides
        --[[1]] nil,
        --[[2]] nil,
        --[[3]] nil,
        --[[4]] nil,
        --[[5]] special_vanilla and {{type = "item", name = "clowns-ore4-crystal", amount = 2},{type = "item", name = "clowns-ore7-crystal", amount = 2}} or nil,
        --[[6]] nil,
        --[[7]] nil,
      }
    ),
    -- PURIFIED
    create_sorting_mix_recipe(
      "clowns-pure-mix%i-processing",
      CT.pure_mix_processing,
      clowns.functions.get_icon_table(CT.pure_mix_processing),
      { --special vanilla overrides
        --[[1]] nil,
        --[[2]] nil,
        --[[3]] nil,
        --[[4]] nil,
        --[[5]] special_vanilla and {{type = "item", name = "clowns-ore1-pure", amount = 2},{type = "item", name = "clowns-resource2", amount = 2},{type = "item", name = "clowns-ore7-pure", amount = 2}} or nil,
        --[[6]] nil,
      }
    )
  }
)