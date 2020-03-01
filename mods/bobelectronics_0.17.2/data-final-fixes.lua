bobmods.lib.recipe.replace_ingredient_in_all("basic-electronic-circuit-board", "electronic-circuit")
bobmods.lib.recipe.replace_ingredient_in_all("electronic-circuit-board", "advanced-circuit")
bobmods.lib.recipe.replace_ingredient_in_all("electronic-processing-board", "processing-unit")
bobmods.lib.recipe.replace_ingredient_in_all("electronic-processing-board-2", "advanced-processing-unit")

if data.raw.item["basic-electronic-circuit-board"] then
  data.raw.item["basic-electronic-circuit-board"] = nil
end

if data.raw.item["electronic-circuit-board"] then
  data.raw.item["electronic-circuit-board"] = nil
end

if data.raw.item["electronic-processing-board"] then
  data.raw.item["electronic-processing-board"] = nil
end

if data.raw.item["electronic-processing-board-2"] then
  data.raw.item["electronic-processing-board-2"] = nil
end
