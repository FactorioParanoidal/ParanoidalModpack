if data.raw.item["thorium-fuel-cell"] then
  table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
  local plate="angels-plate-lead"
  if mods["bobplates"] then
    plate="lead-plate"
  end
  clowns.functions.replace_ing("thorium-fuel-cell","iron-plate",plate,"ing")
  clowns.functions.replace_ing("thorium-mixed-oxide","iron-plate",plate,"ing")
  clowns.functions.replace_ing("mixed-oxide","iron-plate",plate,"ing")
  clowns.functions.add_to_table("thorium-nuclear-fuel-reprocessing",{type="item", name=plate, amount=5},"res")
    --table.insert(data.raw.recipe["thorium-nuclear-fuel-reprocessing"].ingredients,{type="item", name=plate, amount=5})
  clowns.functions.replace_ing("radiothermal-fuel","iron-plate",plate,"ing")
else
	angelsmods.functions.OV.add_unlock("nuclear-fuel-reprocessing-2","advanced-nuclear-fuel-reprocessing-2")
  angelsmods.functions.OV.add_unlock("nuclear-fuel-reprocessing-2","advanced-nuclear-fuel-reprocessing|b")
end
angelsmods.functions.make_void("water-radioactive-waste", "water")
if mods["angelsindustries"] then
  --update nuclear cells
  clowns.functions.replace_ing("angels-advanced-mixed-oxide-reprocessing","uranium-235","35%-uranium","res")
  --lower plutonium returns on thorium reprocessing
  angelsmods.functions.OV.patch_recipes({
    {name = "advanced-thorium-nuclear-fuel-reprocessing|b", results = {{"plutonium-239", 2}}},
    {name = "advanced-thorium-nuclear-fuel-reprocessing", results = {{"thorium-232", 0}}},
    {name = "thorium-mixed-oxide", results={{"angels-thorium-fuel-cell", 2}, {"thorium-fuel-cell", 0}}},
    {name = "clowns-centrifuging-20%-hexafluoride", results = {{type = "item", name = "uranium-234", amount = 1, probability = 0.000055}}},
  })
  data.raw.recipe["advanced-thorium-nuclear-fuel-reprocessing"].localised_name={"recipe-name.advanced-clowns-amox-reprocessing"}
end