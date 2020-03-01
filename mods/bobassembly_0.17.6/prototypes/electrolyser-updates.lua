if settings.startup["bobmods-assembly-electrolysers"].value and 
  data.raw.technology["electrolysis-1"] and
  data.raw.item["electrolyser"] and
  data.raw["recipe-category"]["electrolysis"]
then

-- data.raw["assembling-machine"]["electrolyser"].next_upgrade = "electrolyser-2" --DrD

if data.raw.item["glass"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-2", "plastic-bar", "glass")
  bobmods.lib.tech.add_prerequisite("electrolyser-3", "plastics")
else
  bobmods.lib.tech.add_prerequisite("electrolyser-2", "plastics")
end

--if data.raw.item["stone-pipe"] then  bobmods.lib.recipe.replace_ingredient("electrolyser-2", "pipe", "stone-pipe") end


if data.raw.item["invar-alloy"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-3", "iron-plate", "invar-alloy")
  bobmods.lib.tech.add_prerequisite("electrolyser-3", "invar-processing")
end

if data.raw.item["tungsten-plate"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-3", "steel-plate", "tungsten-plate")
  bobmods.lib.tech.add_prerequisite("electrolyser-3", "tungsten-processing")
end

if data.raw.item["plastic-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-3", "pipe", "plastic-pipe")
end



if data.raw.item["silicon-nitride"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-4", "plastic-bar", "silicon-nitride")
  bobmods.lib.tech.add_prerequisite("electrolyser-4", "ceramics")
end

if data.raw.item["nitinol-alloy"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-4", "iron-plate", "nitinol-alloy")
  bobmods.lib.tech.add_prerequisite("electrolyser-4", "nitinol-processing")
end

if data.raw.item["copper-tungsten-alloy"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-4", "steel-plate", "copper-tungsten-alloy")
  bobmods.lib.tech.add_prerequisite("electrolyser-4", "tungsten-alloy-processing")
end

if data.raw.item["advanced-processing-unit"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-4", "processing-unit", "advanced-processing-unit")
end

if data.raw.item["ceramic-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser-4", "pipe", "ceramic-pipe")
end

bobmods.lib.tech.add_prerequisite("electrolyser-4", "advanced-electronics-3")


if settings.startup["bobmods-assembly-limits"].value == true then
  data.raw["assembling-machine"]["electrolyser"].ingredient_count = 4
  data.raw["assembling-machine"]["electrolyser-2"].ingredient_count = 6
  data.raw["assembling-machine"]["electrolyser-3"].ingredient_count = 8
  data.raw["assembling-machine"]["electrolyser-4"].ingredient_count = 10
end
end
