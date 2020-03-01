
if mods.bobplates then
if mods.angelspetrochem then
  for recipeName,_ in pairs(data.raw["recipe"]) do
    if data.raw.recipe[recipeName].category == "electrolysis" then
        data.raw.recipe[recipeName].category = "petrochem-electrolyser"
    end
  end

data.raw.recipe["electrolyser"].hidden = true
data.raw["assembling-machine"]["electrolyser"].minable = {hardness = 0.2, mining_time = 0.5, result = "angels-electrolyser"}

data.raw.technology["electrolysis-1"].enabled = false
data.raw.technology["electrolysis-2"].enabled = false

bobmods.lib.tech.remove_prerequisite("steel-processing", "electrolysis-1") --DrD
--bobmods.lib.tech.remove_prerequisite("steel-processing", "chemical-processing-1") --DrD
bobmods.lib.tech.remove_prerequisite("deuterium-processing", "electrolysis-1") --DrD

bobmods.lib.tech.remove_prerequisite("nickel-processing", "electrolysis-1") --DrD

--bobmods.lib.tech.remove_prerequisite("cobalt-processing", "chemical-processing-1") --DrD
--bobmods.lib.tech.remove_prerequisite("lithium-processing", "chemical-processing-1") --DrD

bobmods.lib.tech.remove_prerequisite("zinc-processing", "electrolysis-1")
bobmods.lib.tech.remove_prerequisite("cobalt-processing", "electrolysis-1")
bobmods.lib.tech.remove_prerequisite("lithium-processing", "electrolysis-1")
bobmods.lib.tech.remove_prerequisite("battery-3", "electrolysis-2")
bobmods.lib.tech.remove_prerequisite("chemical-processing-2", "electrolysis-2")

end
end

