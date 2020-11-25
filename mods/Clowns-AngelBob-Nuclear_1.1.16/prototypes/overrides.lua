if data.raw.item["thorium-fuel-cell"] then
  table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
  local plate="angels-plate-lead"
  if mods["bobplates"] then
    plate="lead-plate"
  end
  clowns.functions.replace_ing("thorium-fuel-cell","iron-plate",plate,"ing")
  clowns.functions.replace_ing("thorium-mixed-oxide","iron-plate",plate,"ing")
  clowns.functions.replace_ing("mixed-oxide","iron-plate",plate,"ing")
  clowns.functions.add_to_table("thorium-nuclear-fuel-reprocessing",{type="item", name=plate, amount=5},"ing")
    --table.insert(data.raw.recipe["thorium-nuclear-fuel-reprocessing"].ingredients,{type="item", name=plate, amount=5})
  clowns.functions.replace_ing("radiothermal-fuel","iron-plate",plate,"ing")
else
	table.insert(data.raw["technology"]["nuclear-fuel-reprocessing-2"].effects, {type = "unlock-recipe", recipe = "advanced-nuclear-fuel-reprocessing-2"})
end
angelsmods.functions.make_void("water-radioactive-waste", "water")


