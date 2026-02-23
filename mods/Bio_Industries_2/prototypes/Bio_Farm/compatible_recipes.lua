local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_BA = BioInd.modRoot .. "/graphics/icons/mod_bobangels/"
local ICONPATH_AAI = BioInd.modRoot .. "/graphics/icons/mod_aai/"
local ICONPATH_KR = BioInd.modRoot .. "/graphics/icons/mod_krastorio/"
local ICONPATHMIPS = BioInd.modRoot .. "/graphics/icons/mips/"

local nitrogen = data.raw.fluid["kr-nitrogen"] and "kr-nitrogen" or "nitrogen"
local pellet_coke = data.raw.item["angels-pellet-coke"] and "angels-pellet-coke" or "pellet-coke"

data:extend({
  {
    type = "recipe",
    name = "bi-pellet-coke-2",
    icon = ICONPATH_BA .. "pellet_coke_b.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_BA .. "pellet_coke_b.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-g[bi-coke-coal]-2",
    energy_required = 4,
    ingredients = {},
    results = {{type="item", name=pellet_coke, amount=1}},
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    enabled = false,
  },

  -- fertilizer from sodium-hydroxide--
  {
    type = "recipe",
    name = "bi-fertilizer-2",
    icon = ICONPATH_BA .. "fertilizer_sodium_hydroxide.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_BA .. "fertilizer_sodium_hydroxide.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 5,
    ingredients = {
      {type = "fluid", name = nitrogen, amount = 10},
      {type = "item", name = "bi-ash", amount = 10}
    },
    results = {
      {type = "item", name = "fertilizer", amount = 5}
    },
    enabled = false,
                allow_as_intermediate = true,       -- Changed for 0.18.34/1.1.4
    always_show_made_in = true,         -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[bi-fertilizer]",
  },
})

---- Resin
if not data.raw.item["resin"] then

  data:extend({
    --- Resin Item
    {
      type = "item",
      name = "resin",
      icon = ICONPATH .. "bi_resin.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_resin.png",
          icon_size = 64,
        }
      },
      icon_mipmaps = 4,
      pictures = {
        { size = 64, filename = ICONPATHMIPS.."resin_1.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."resin_2.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."resin_3.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."resin_4.png", scale = 0.2 }
      },
      subgroup = "bio-bio-farm-raw",
      order = "a[bi]-a-bb[bi-resin]",
      stack_size = 200,
	  drop_sound = {
      filename = "__base__/sound/item/solid-fuel-inventory-move.ogg",
      volume = 0.7,
		},
	  inventory_move_sound = {
      filename = "__base__/sound/item/solid-fuel-inventory-move.ogg",
      volume = 0.7,
		},
      pick_sound = {
      filename = "__base__/sound/item/solid-fuel-inventory-pickup.ogg",
      volume = 0.7,
		},
    },

    --- Resin recipe - Wood
    {
      type = "recipe",
      name = "bi-resin-wood",
      localised_name = {"recipe-name.bi-resin-wood"},
      localised_description = {"recipe-description.bi-resin-wood"},
      icon = ICONPATH .. "bi_resin_wood.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_resin_wood.png",
          icon_size = 64,
        }
      },
      subgroup = "bio-bio-farm-raw",
      order = "a[bi]-a-bb[bi-2-resin-2-wood]",
      enabled = false,
      allow_as_intermediate = true,     -- Changed for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,       -- Changed for 0.18.34/1.1.4

      energy_required = 1,
      ingredients = {
         {type = "item", name = "wood", amount = 1}
      },
      results = {{type="item", name="resin", amount=1}},
      main_procuct = "",
      -- This is a custom property for use by "Krastorio 2" (it will change
      -- ingredients/results; used for wood/wood pulp)
      mod = "Bio_Industries_2",
    },
  })
  -- Order in table reflects order in display (Tech tree), so we remove the last
  -- recipes, add the new one, and re-add the removed recipes where they belong.
  for _, recipe in ipairs({"bi-woodpulp", "bi-resin-pulp", "bi-wood-from-pulp"}) do
    thxbob.lib.tech.remove_recipe_unlock("bi-tech-bio-farming", recipe)
  end
  for _, recipe in ipairs({"bi-woodpulp", "bi-resin-wood", "bi-resin-pulp", "bi-wood-from-pulp"}) do
    thxbob.lib.tech.add_recipe_unlock("bi-tech-bio-farming", recipe)
  end

elseif data.raw.recipe["bob-resin-wood"] then
  data.raw.recipe["bob-resin-wood"].icon = ICONPATH .. "bi_resin_wood.png"
  data.raw.recipe["bob-resin-wood"].icon_size = 64
end


 -- Pellet-Coke from Carbon - Bobs & Angels
if data.raw.item["solid-carbon"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.add_new_ingredient("bi-pellet-coke-2", {type = "item", name = "solid-carbon", amount = 10})
  data.raw.recipe["bi-coke-coal"].icon = ICONPATH_BA .. "pellet_coke_1.png"
  data.raw.recipe["bi-coke-coal"].icon_size = 64
  data.raw.recipe["bi-pellet-coke-2"].icon = ICONPATH_BA .. "pellet_coke_a.png"
  data.raw.recipe["bi-pellet-coke-2"].icon_size = 64
  data.raw.recipe["bi-pellet-coke"].icon = ICONPATH_BA .. "pellet_coke_c.png"
  data.raw.recipe["bi-pellet-coke"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-coal-processing-2", "bi-pellet-coke-2")
elseif data.raw.item["bob-carbon"] and mods["bobplates"] then
  thxbob.lib.recipe.add_new_ingredient ("bi-pellet-coke-2", {type = "item", name = "bob-carbon", amount = 10})
  data.raw.recipe["bi-coke-coal"].icon = ICONPATH_BA .. "pellet_coke_1.png"
  data.raw.recipe["bi-coke-coal"].icon_size = 64
  data.raw.recipe["bi-pellet-coke-2"].icon = ICONPATH_BA .. "pellet_coke_b.png"
  data.raw.recipe["bi-pellet-coke-2"].icon_size = 64
  data.raw.recipe["bi-pellet-coke"].icon = ICONPATH_BA .. "pellet_coke_c.png"
  data.raw.recipe["bi-pellet-coke"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-coal-processing-2", "bi-pellet-coke-2")
end


-- Update Wood Bricks icon to Angels
if data.raw.item["wood-bricks"] and mods["angelsbioprocessing"] then
  data.raw.recipe["bi-wood-fuel-brick"].icon = "__angelsbioprocessinggraphics__/graphics/icons/wood-bricks.png"
  data.raw.recipe["bi-wood-fuel-brick"].icon_size = 32
  data.raw.recipe["bi-wood-fuel-brick"].icons = {
      {
        icon = "__angelsbioprocessinggraphics__/graphics/icons/wood-bricks.png",
        icon_size = 32,
      }
    }
  data.raw.item["wood-bricks"].icon = "__angelsbioprocessinggraphics__/graphics/icons/wood-bricks.png"
  data.raw.item["wood-bricks"].icon_size = 32
end


--- Add fertilizer recipes if bob's or Angels
if data.raw.item["solid-sodium-hydroxide"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.add_new_ingredient("bi-fertilizer-2", {type = "item", name = "solid-sodium-hydroxide", amount = 10})
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-2", nitrogen, "gas-nitrogen")
  data.raw.recipe["bi-fertilizer-2"].icon = ICONPATH_BA .. "fertilizer_solid_sodium_hydroxide.png"
  data.raw.recipe["bi-fertilizer-2"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-fertilizer-2")
elseif data.raw.item["bob-sodium-hydroxide"] and mods["bobplates"] then
  thxbob.lib.recipe.add_new_ingredient("bi-fertilizer-2", {
    type = "item",
    name = "bob-sodium-hydroxide",
    amount = 10
  })
  thxbob.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-fertilizer-2")
end


-- If Angels, replace liquid air + nitrogen and with Angel's ingredients in recipes
if data.raw.fluid["gas-nitrogen"] and data.raw.fluid["gas-compressed-air"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-1", nitrogen, "gas-nitrogen")
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-2", nitrogen, "gas-nitrogen")
  thxbob.lib.recipe.replace_ingredient("bi-biomass-2", "liquid-air", "gas-compressed-air")
  thxbob.lib.recipe.replace_ingredient("bi-biomass-3", "liquid-air", "gas-compressed-air")
end

-- If Angels, replace icons for biomass-conversion-2 and bi_basic_gas_processing
if mods["angelspetrochem"] then
  local conversion = data.raw.recipe["bi-biomass-conversion-2"]
  conversion.icon = ICONPATH_BA .. "bio_conversion_2_angels.png"
  conversion.icons[1].icon = ICONPATH_BA .. "bio_conversion_2_angels.png"
  conversion.localised_name = {"recipe-name.bi-biomass-conversion-2-methane"}
  conversion.localised_description = {"recipe-description.bi-biomass-conversion-2-methane"}

  local gas_processing = data.raw.recipe["bi-basic-gas-processing"]
  gas_processing.icon = ICONPATH_BA .. "bi_basic_gas_processing_angels.png"
  gas_processing.icons[1].icon = ICONPATH_BA .. "bi_basic_gas_processing_angels.png"

end

-- If Angels, replace water with angels-water-yellow-waste
if data.raw.fluid["angels-water-yellow-waste"] and mods["angelspetrochem"] then
  -- Replace water with angels-water-yellow-waste in Algae Biomass conversion 4
  thxbob.lib.recipe.remove_result("bi-biomass-conversion-4", "water")
  thxbob.lib.recipe.add_result("bi-biomass-conversion-4", {
    type = "fluid",
    name = "angels-water-yellow-waste",
    amount = 40
  })
  -- Change recipe localizations
  data.raw.recipe["bi-biomass-conversion-4"].localised_name =
    {"recipe-name.bi-biomass-conversion-4-yellow-waste"}
  data.raw.recipe["bi-biomass-conversion-4"].localised_description =
    {"recipe-description.bi-biomass-conversion-4-yellow-waste"}
end


-- Krastorio2
if mods["Krastorio2"] or mods["Krastorio2-spaced-out"] then
  -- Replace liquid air with oxygen in Algae Biomass conversion 2 and 3
  thxbob.lib.recipe.replace_ingredient("bi-biomass-2", "liquid-air", "kr-oxygen")
  thxbob.lib.recipe.replace_ingredient("bi-biomass-3", "liquid-air", "kr-oxygen")
end


--- Make Bio Farm use glass if Bob's
if data.raw.item["bob-glass"] then
  thxbob.lib.recipe.replace_ingredient("bi-bio-farm", "copper-cable", "bob-glass")
end


--- Adding in some recipe's to use up Wood Pulp (Ash and Charcoal) and Crushed Stone
if mods["angelsrefining"] then
  data:extend({
    -- Charcoal and Crushed Stone Sink
    {
      type = "recipe",
      name = "bi-mineralized-sulfuric-waste",
      icon = ICONPATH_BA .. "bi_mineralized_sulfuric.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH_BA .. "bi_mineralized_sulfuric.png",
          icon_size = 64,
        }
      },
      category = "angels-liquifying",
      subgroup = "angels-water-treatment",
      energy_required = 2,
      ingredients = {
        {type = "fluid", name = "angels-water-purified", amount = 100},
        {type = "item", name = "stone-crushed", amount = 90},
        {type = "item", name = "wood-charcoal", amount = 30},
      },
      results= {
        {type = "fluid", name = "angels-water-yellow-waste", amount = 40},
         {type = "fluid", name = "angels-water-mineralized", amount = 60},
      },
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      order = "a[water-water-mineralized]-2",
    },

    -- Ash and Crushed Stone Sink
    {
      type = "recipe",
      name = "bi-slag-slurry",
      icon = ICONPATH_BA .. "bi_slurry.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH_BA .. "bi_slurry.png",
          icon_size = 64,
        }
      },
      category = "angels-liquifying",
      subgroup = "angels-liquifying",
      energy_required = 4,
      ingredients = {
        {type = "fluid", name = "angels-water-saline", amount = 50},
        {type = "item", name = "stone-crushed", amount = 90},
        {type = "item", name = "bi-ash", amount = 40},
      },
      results = {
        {type = "fluid", name = "angels-slag-slurry", amount = 100},
      },
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      order = "i [slag-processing-dissolution]-2",
    },
  })
  thxbob.lib.tech.add_recipe_unlock("angels-water-treatment", "bi-mineralized-sulfuric-waste")
  thxbob.lib.tech.add_recipe_unlock("slag-processing-1", "bi-slag-slurry")
end


--- Alternative Wooden-Board Recipe for Bob's Electronics
if data.raw.item["bob-wooden-board"] and mods["bobelectronics"] then
  data:extend({
    -- Wood - Press Wood
    {
      type = "recipe",
      name = "bi-press-wood",
      localised_name = {"recipe-name.bi-press-wood"},
      icon = ICONPATH_BA .. "bi_wooden_board_shiny.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH_BA .. "bi_wooden_board_shiny.png",
          icon_size = 64,
        }
      },
      subgroup = "bob-boards",
      order = "c-a1[wooden-board]",
      category = "electronics",
      energy_required = 1,
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      allow_as_intermediate = false,
	  allow_productivity = true,
      ingredients = {
        {type = "item", name = "bi-woodpulp", amount = 3},
        {type = "item", name = "resin", amount = 1},
      },
      results = {
        {type = "item", name = "bob-wooden-board", amount = 6}
      },
      -- This is a custom property for use by "Krastorio 2" (it will change
      -- ingredients/results; used for wood/wood pulp)
      mod = "Bio_Industries_2",
    },
  })
  thxbob.lib.tech.add_recipe_unlock("electronics", "bi-press-wood")


end


-- Replace Angels Charcoal Icon
if data.raw.recipe["wood-charcoal"] then
  data.raw.recipe["wood-charcoal"].icon = ICONPATH_BA .. "charcoal_pellets.png"
  data.raw.recipe["wood-charcoal"].icon_size = 64
  data.raw.recipe["wood-charcoal"].category = "biofarm-mod-smelting"
  data.raw.item["wood-charcoal"].icon = ICONPATH .. "charcoal.png"
  data.raw.item["wood-charcoal"].icon_size = 64
  data.raw.item["wood-charcoal"].fuel_emissions_multiplier = 1.05
end



-- Add recipe for sand from crushed stone if any other mod provides sand

if data.raw.item[data.raw.item["kr-sand"] and "kr-sand" or "sand"] or
   data.raw.item["biotech-sand"] or
   data.raw.item["solid-sand"] then

   BioInd.writeDebug("Generating recipe for sand from crushed stone!")
  -- General recipe for sand (will be adjusted later if necessary)
  data:extend({
    {
      type = "recipe",
      name = "bi-sand",
      icons = {
        {
          icon = ICONPATH_AAI .. "sand-aai.png",
          icon_size = 64,
          mip_maps = 1,
        }
      },
      category = "biofarm-mod-crushing",
      subgroup = "bio-bio-farm-raw",
      order = "a[bi]-a-z[bi-9-sand]",
      energy_required = 1,
      ingredients = {{type="item", name="stone-crushed", amount=2}},
      results = {{type="item", name=data.raw.item["kr-sand"] and "kr-sand" or "sand", amount=5}},
      main_product = "",
      enabled = false,
      allow_as_intermediate = true,     -- Changed for 0.18.34/1.1.4
      always_show_made_in = true,       -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },
  })

  local recipe = data.raw.recipe["bi-sand"]
  -- Adjust result for BioTech
  if mods["BioTech"] then
BioInd.writeDebug("Adjusting result for \"BioTech\" …")
    recipe.result = "biotech-sand"

  -- Adjust result for Angel's
  elseif mods["angelsrefining"] then
    -- Adjust result
BioInd.writeDebug("Adjusting result for \"angelsrefining\" …")
    recipe.result = "solid-sand"

  -- Adjust icon for Krastorio
  elseif mods["Krastorio2"] or mods["Krastorio2-spaced-out"] then
BioInd.writeDebug("Using Krastorio icon …")
    recipe.icons[1].icon = ICONPATH_KR .. "sand-Krastorio.png"
  end

  -- Add recipe to technology
BioInd.writeDebug("Add unlock for recipe bi-sand")
  thxbob.lib.tech.add_recipe_unlock("steel-processing", "bi-sand")

  -- Use alternative descriptions for stone crusher!
BioInd.writeDebug("Using alternative descriptions for \"bi-stone-crusher\"!")
  for _, t in ipairs({"furnace", "item", "recipe"}) do
    data.raw[t]["bi-stone-crusher"].localised_description =
      {"entity-description.bi-stone-crusher-sand"}
  end
end
