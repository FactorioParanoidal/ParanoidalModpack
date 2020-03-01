if settings.startup["bobmods-assembly-multipurposefurnaces"].value and
  data.raw["item-subgroup"]["bob-smelting-machine"] and
  data.raw["recipe-category"]["chemical-furnace"] and
  data.raw["recipe-category"]["mixing-furnace"] and
  data.raw.technology["alloy-processing-2"] and
  data.raw.technology["chemical-processing-3"]
then

data.raw["assembling-machine"]["chemical-furnace"].next_upgrade = "electric-chemical-mixing-furnace"
data.raw["assembling-machine"]["electric-mixing-furnace"].next_upgrade = "electric-chemical-mixing-furnace"


if data.raw.item["invar-alloy"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace", "steel-plate", "invar-alloy")
  bobmods.lib.tech.add_prerequisite("multi-purpose-furnace-1", "invar-processing")
end

if data.raw.item["tungsten-plate"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace", "stone-brick", "tungsten-plate")
  bobmods.lib.tech.add_prerequisite("multi-purpose-furnace-1", "tungsten-processing")
end



if data.raw.item["tungsten-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace", "pipe", "tungsten-pipe")
end

if data.raw.item["copper-tungsten-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace-2", "pipe", "copper-tungsten-pipe")
elseif data.raw.item["tungsten-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace-2", "pipe", "tungsten-pipe")
end


if data.raw.item["copper-tungsten-alloy"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace-2", "steel-plate", "copper-tungsten-alloy")
  bobmods.lib.tech.add_prerequisite("multi-purpose-furnace-2", "tungsten-alloy-processing")
end

if data.raw.item["tungsten-carbide"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace-2", "stone-brick", "tungsten-carbide")
  bobmods.lib.tech.add_prerequisite("multi-purpose-furnace-2", "tungsten-alloy-processing")
end

if data.raw.item["advanced-processing-unit"] then
  bobmods.lib.recipe.replace_ingredient("electric-chemical-mixing-furnace-2", "processing-unit", "advanced-processing-unit")
  bobmods.lib.tech.add_prerequisite("multi-purpose-furnace-2", "advanced-electronics-3")
end

if settings.startup["bobmods-assembly-limits"].value == true then
  data.raw["assembling-machine"]["electric-chemical-mixing-furnace"].ingredient_count = 6
  data.raw["assembling-machine"]["electric-chemical-mixing-furnace-2"].ingredient_count = 8

  data.raw["assembling-machine"]["chemical-boiler"].ingredient_count = 2
  data.raw["assembling-machine"]["chemical-steel-furnace"].ingredient_count = 4
  data.raw["assembling-machine"]["chemical-furnace"].ingredient_count = 4

  data.raw["assembling-machine"]["mixing-furnace"].ingredient_count = 2
  data.raw["assembling-machine"]["mixing-steel-furnace"].ingredient_count = 4
  data.raw["assembling-machine"]["electric-mixing-furnace"].ingredient_count = 4
end
end



