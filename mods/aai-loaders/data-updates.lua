if mods["Krastorio2"] then
  require("prototypes/loader-sets/krastorio2")
end

if mods["space-exploration"] then
  require("prototypes/loader-sets/space-exploration")
end

local function _sub_icons(icon_main, ...)
  local icons_sub = {...}
  local results = {{ icon = icon_main, shift = {2, 0}, icon_size = 64 }}

  for _, icon in pairs(icons_sub) do
    table.insert(results, {
      icon = icon.icon or icon,
      scale = icon.scale or 0.25,
      shift = icon.shift or {-7, -7},
      icon_size = icon.icon_size or 64
    })
  end

  return results
end

-- Create simple lubricant recipe if appropriate
if settings.startup["aai-loaders-mode"].value == "lubricated" then
  local vanilla_advanced_oil_recipe = {
    ingredients = {
      ["crude-oil"] = 100,
      ["water"] = 50
    },
    products = {
      ["heavy-oil"] = 25,
      ["light-oil"] = 45,
      ["petroleum-gas"] = 55
    }
  }
  local vanilla_lubricant_recipe = {
    ingredients = {
      ["heavy-oil"] = 10
    },
    products = {
      ["lubricant"] = 10
    }
  }
  local lubricant_recipe_setting = settings.startup["aai-loaders-lubricant-recipe"].value
  local enable_lubricant_recipe = true

  -- Check if simple lubricant recipe should be enabled
  if lubricant_recipe_setting == "auto" then
    local advanced_oil_recipe = data.raw.recipe["advanced-oil-processing"]
    local lubricant_recipe = data.raw.recipe["lubricant"]

    -- Evaluate advanced oil recipe
    if advanced_oil_recipe and advanced_oil_recipe.ingredients and advanced_oil_recipe.results then
      -- Verify ingredients
      for _, ingredient in pairs(advanced_oil_recipe.ingredients) do
        if ingredient.type ~= "fluid" or
          vanilla_advanced_oil_recipe.ingredients[ingredient.name] ~= ingredient.amount then
          enable_lubricant_recipe = false
        end
      end

      -- Verify products
      for _, product in pairs(advanced_oil_recipe.results) do
        if product.type ~= "fluid" or not product.amount or
          vanilla_advanced_oil_recipe.products[product.name] ~= product.amount then
          enable_lubricant_recipe = false
        end
      end
    else
      enable_lubricant_recipe = false
    end

    -- Evaluate lubricant recipe
    if lubricant_recipe and lubricant_recipe.ingredients and lubricant_recipe.results then
      -- Verify ingredients
      for _, ingredient in pairs(lubricant_recipe.ingredients) do
        if ingredient.type ~= "fluid" or
          vanilla_lubricant_recipe.ingredients[ingredient.name] ~= ingredient.amount then
          enable_lubricant_recipe = false
        end
      end

      -- Verify products
      for _, product in pairs(lubricant_recipe.results) do
        if product.type ~= "fluid" or not product.amount or
          vanilla_lubricant_recipe.products[product.name] ~= product.amount then
          enable_lubricant_recipe = false
        end
      end
    else
      enable_lubricant_recipe = false
    end
  elseif lubricant_recipe_setting == "disabled" then
    enable_lubricant_recipe = false
  end

  if enable_lubricant_recipe and not data.raw.recipe["lubricant-from-crude-oil"] then
    if data.raw.fluid["crude-oil"] and data.raw.fluid["lubricant"] and data.raw.technology["oil-processing"] then
      local icons

      if data.raw.fluid["lubricant"].icon and data.raw.fluid["crude-oil"].icon then
        icons = _sub_icons(data.raw.fluid["lubricant"].icon,
          data.raw.fluid["crude-oil"].icon)
      end

      -- Add recipe
      data:extend{
        {
          name = "lubricant-from-crude-oil",
          type = "recipe",
          subgroup = mods["space-exploration"] and "oil" or "fluid-recipes",
          category = "chemistry",
          enabled = false,
          icons = icons,
          crafting_machine_tint = {
            primary = {0, 0, 0, 0.75},
            secondary = {0, 0, 0, 0.75},
            tertiary = {0, 0, 0, 0.75},
            quaternary = {0, 0, 0, 0.75}
          },
          energy_required = 1,
          ingredients = {{type="fluid", name="crude-oil", amount=10}},
          results = {{type="fluid", name="lubricant", amount=2}}
        }
      }

      -- Add recipe to oil-processing tech
      table.insert(data.raw.technology["oil-processing"].effects,
        {type="unlock-recipe", recipe="lubricant-from-crude-oil"})

      -- Allow productivity module usage
      for _, prototype in pairs(data.raw["module"]) do
        if prototype.limitation and string.find(prototype.name, "productivity", 1, true) then
          table.insert(prototype.limitation, "lubricant-from-crude-oil")
        end
      end
    end
  end
end
