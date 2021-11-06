local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATHMIPS = BioInd.modRoot .. "/graphics/icons/mips/"

data:extend({
--###############################################################################################
{
    type = "recipe",
    name = "bi-pellet-coke-2",
    icons = 
    {
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/pellet_coke.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__angelspetrochem__/graphics/icons/solid-carbon.png",
      icon_size = 32, icon_mipmaps = 1, scale = 0.5, shift = {-8, 8}}
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-g[bi-coke-coal]-2",
    energy_required = 4,
    ingredients = {},
    result = "pellet-coke",
    result_count = 1,
    always_show_made_in = true,
    allow_decomposition = true,
    allow_as_intermediate = false,
    enabled = false,
},
--###############################################################################################
-- fertilizer from sodium-hydroxide
  {
    type = "recipe",
    name = "bi-fertilizer-2",
    icons = 
    {
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__angelspetrochem__/graphics/icons/solid-sodium-hydroxide.png",
      icon_size = 32, icon_mipmaps = 1, scale = 0.25, shift = {-8, 8}},
    },
  category = "chemistry",
    energy_required = 5,
    ingredients = 
    {
      {type = "fluid", name = "nitrogen", amount = 10},
      {type = "item", name = "bi-ash", amount = 10}
    },
    results = {{type = "item", name = "fertilizer", amount = 5}},
    enabled = false,
    allow_as_intermediate = true,  
    always_show_made_in = true,    
    allow_decomposition = true,    
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[bi-fertilizer]",
  },
})
--###############################################################################################
-- Resin
if not data.raw.item["resin"] then

  data:extend({
    --- Resin Item
    {
      type = "item",
      name = "resin",
      icon = ICONPATH .. "bi_resin.png",
      icon_size = 64,
      icon_mipmaps = 4,
      pictures = 
      {
        { size = 64, filename = ICONPATHMIPS.."Resin_1.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."Resin_2.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."Resin_3.png", scale = 0.2 },
        { size = 64, filename = ICONPATHMIPS.."Resin_4.png", scale = 0.2 }
      },
      subgroup = "bio-bio-farm-raw",
      order = "a[bi]-a-bb[bi-resin]",
      stack_size = 200
    },
  })
end
--###############################################################################################
 -- Pellet-Coke from Carbon - Bobs & Angels
if data.raw.item["solid-carbon"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.add_new_ingredient("bi-pellet-coke-2", {type = "item", name = "solid-carbon", amount = 5}) --DrD 10
  data.raw.recipe["bi-coke-coal"].icon = ICONPATH .. "pellet_coke_1.png"
  data.raw.recipe["bi-coke-coal"].icon_size = 64
  data.raw.recipe["bi-pellet-coke-2"].icon = ICONPATH .. "pellet_coke_a.png"
  data.raw.recipe["bi-pellet-coke-2"].icon_size = 64
  data.raw.recipe["bi-pellet-coke"].icon = ICONPATH .. "pellet_coke_c.png"
  data.raw.recipe["bi-pellet-coke"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-coal-processing-2", "bi-pellet-coke-2")
elseif data.raw.item["carbon"] and mods["bobplates"] then
  thxbob.lib.recipe.add_new_ingredient ("bi-pellet-coke-2", {type = "item", name = "carbon", amount = 6}) --DrD 10
  data.raw.recipe["bi-coke-coal"].icon = ICONPATH .. "pellet_coke_1.png"
  data.raw.recipe["bi-coke-coal"].icon_size = 64
  data.raw.recipe["bi-pellet-coke-2"].icon = ICONPATH .. "pellet_coke_b.png"
  data.raw.recipe["bi-pellet-coke-2"].icon_size = 64
  data.raw.recipe["bi-pellet-coke"].icon = ICONPATH .. "pellet_coke_c.png"
  data.raw.recipe["bi-pellet-coke"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-coal-processing-2", "bi-pellet-coke-2")
end

--- Add fertilizer recipes if bob's or Angels
if data.raw.item["solid-sodium-hydroxide"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.add_new_ingredient("bi-fertilizer-2", {type = "item", name = "solid-sodium-hydroxide", amount = 10})
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-2", "nitrogen", "gas-nitrogen")
  data.raw.recipe["bi-fertilizer-2"].icon = ICONPATH .. "fertilizer_solid_sodium_hydroxide.png"
  data.raw.recipe["bi-fertilizer-2"].icon_size = 64
  thxbob.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-fertilizer-2")
elseif data.raw.item["sodium-hydroxide"] and mods["bobplates"] then
  thxbob.lib.recipe.add_new_ingredient("bi-fertilizer-2", {
    type = "item",
    name = "sodium-hydroxide",
    amount = 10
  })
  thxbob.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-fertilizer-2")
end


-- If Angels, replace liquid air + nitrogen and with Angel's ingredients in recipes
if data.raw.fluid["gas-nitrogen"] and data.raw.fluid["gas-compressed-air"] and mods["angelspetrochem"] then
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-1", "nitrogen", "gas-nitrogen")
  thxbob.lib.recipe.replace_ingredient("bi-fertilizer-2", "nitrogen", "gas-nitrogen")
  thxbob.lib.recipe.replace_ingredient("bi-biomass-2", "liquid-air", "gas-compressed-air")
  thxbob.lib.recipe.replace_ingredient("bi-biomass-3", "liquid-air", "gas-compressed-air")
end

-- If Angels, replace water with water-yellow-waste
if data.raw.fluid["water-yellow-waste"] and mods["angelspetrochem"] then
  -- Replace water with water-yellow-waste in Algae Biomass conversion 4
  thxbob.lib.recipe.remove_result("bi-biomass-conversion-4", "water")
  thxbob.lib.recipe.add_result("bi-biomass-conversion-4", {
    type = "fluid",
    name = "water-yellow-waste",
    amount = 40
  })
end

--- Make Bio Farm use glass if Bob's
if data.raw.item.glass  then
  thxbob.lib.recipe.replace_ingredient("bi-bio-farm", "copper-cable", "glass")
end

--- Adding in some recipe's to use up Wood Pulp (Ash and Charcoal) and Crushed Stone
if mods["angelsrefining"] then
  data:extend({
    -- Charcoal and Crushed Stone Sink
    {
      type = "recipe",
      name = "bi-mineralized-sulfuric-waste",
      icon = ICONPATH .. "bi_mineralized_sulfuric.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_mineralized_sulfuric.png",
          icon_size = 64,
        }
      },
      category = "liquifying",
      subgroup = "water-treatment",
      energy_required = 2,
      ingredients = {
        {type = "fluid", name = "water-purified", amount = 100},
        {type = "item", name = "stone-crushed", amount = 70}, --DrD 90
        {type = "item", name = "wood-charcoal", amount = 30},
      },
      results= {
        {type = "fluid", name = "water-yellow-waste", amount = 40},
         {type = "fluid", name = "water-mineralized", amount = 60},
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
      icon = ICONPATH .. "bi_slurry.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_slurry.png",
          icon_size = 64,
        }
      },
      category = "liquifying",
      subgroup = "liquifying",
      energy_required = 4,
      ingredients = {
        {type = "fluid", name = "water-saline", amount = 50},
        {type = "item", name = "stone-crushed", amount = 40}, --DrD 90
        {type = "item", name = "bi-ash", amount = 40},
      },
      results = {
        {type = "fluid", name = "slag-slurry", amount = 100},
      },
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      order = "i [slag-processing-dissolution]-2",
    },
  })
  thxbob.lib.tech.add_recipe_unlock("water-treatment", "bi-mineralized-sulfuric-waste")
  thxbob.lib.tech.add_recipe_unlock("slag-processing-1", "bi-slag-slurry")
end


--- Alternative Wooden-Board Recipe for Bob's Electronics
if data.raw.item["wooden-board"] and mods["bobelectronics"] then
  data:extend({
    -- Wood - Press Wood
    {
      type = "recipe",
      name = "bi-press-wood",
      localised_name = {"recipe-name.bi-press-wood"},
      icon = ICONPATH .. "bi_wooden_board.png",
      icon_size = 64,
      subgroup = "bob-boards",
      order = "c-a1[wooden-board]",
      category = "electronics",
      energy_required = 1,
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      allow_as_intermediate = false,
      ingredients = {
        {type = "item", name = "bi-woodpulp", amount = 7},
        {type = "item", name = "resin", amount = 1},
      },
      results = {
        {type = "item", name = "wooden-board", amount = 2}
      },
    },
  })
  thxbob.lib.tech.add_recipe_unlock("electronics", "bi-press-wood")

  if mods["ShinyBobGFX"] or mods["ShinyBobGFX_Continued"] then
    data.raw["recipe"]["bi-press-wood"].icon = ICONPATH .. "bi_wooden_board_shiny.png"
    data.raw["recipe"]["bi-press-wood"].icon_size = 64
  end
end


-- Replace Angels Charcoal Icon
if data.raw.recipe["wood-charcoal"] then
  data.raw.recipe["wood-charcoal"].icon = ICONPATH .. "charcoal_pellets.png"
  data.raw.recipe["wood-charcoal"].icon_size = 64
  data.raw.recipe["wood-charcoal"].category = "biofarm-mod-smelting"
  data.raw.item["wood-charcoal"].icon = ICONPATH .. "charcoal.png"
  data.raw.item["wood-charcoal"].icon_size = 64
  data.raw.item["wood-charcoal"].fuel_emissions_multiplier = 1.05
end


--###############################################################################################
-- Add recipe for sand from crushed stone if any other mod provides sand
if data.raw.item["sand"] or
   data.raw.item["biotech-sand"] or
   data.raw.item["solid-sand"] then

-- General recipe for sand (will be adjusted later if necessary)
  data:extend({
    {
      type = "recipe",
      name = "bi-sand",
      icons = 
      {
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/sand.png",
        icon_size = 64, icon_mipmaps = 1},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/crushed-stone.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
      },
      category = "biofarm-mod-crushing",
      subgroup = "bio-bio-farm-raw",
      order = "a[bi]-a-z[bi-9-sand]",
      energy_required = 1,
      ingredients = {{"stone-crushed", 2}},
      result = "sand",
      result_count = 5,
      enabled = false,
      allow_as_intermediate = true,
      always_show_made_in = true,
      allow_decomposition = true,
    },
  })
--###############################################################################################

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
end

  -- Use alternative descriptions for stone crusher!
BioInd.writeDebug("Using alternative descriptions for \"bi-stone-crusher\"!")
  for _, t in ipairs({"furnace", "item", "recipe"}) do
    data.raw[t]["bi-stone-crusher"].localised_description =
      {"entity-description.bi-stone-crusher-sand"}
  end
end