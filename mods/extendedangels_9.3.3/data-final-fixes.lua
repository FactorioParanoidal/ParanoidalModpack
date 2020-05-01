
local perviousbuilding = {

  "algae-farm-4",
  "bio-generator-temperate-2",
  "bio-generator-temperate-3",
  "bio-generator-swamp-2",
  "bio-generator-swamp-3",
  "bio-generator-desert-2",
  "bio-generator-desert-3",
  "bio-arboretum-2",
  "bio-arboretum-3",
  "gas-refinery-4",
  "advanced-chemical-plant-3",
  "angels-air-filter-3",
  "angels-air-filter-4",
  "hydro-plant-4",
  "salination-plant-3",
  "washing-plant-3",
  "washing-plant-4",
  "ore-crusher-4",
  "ore-floatation-cell-4",
  "ore-leaching-plant-4",
  "ore-refinery-3",
  "crystallizer-3",
  "filtration-unit-3",
}

data.raw.recipe["pellet-tungsten-smelting"]=nil
data.raw.recipe["tungsten-carbide"]=nil
data.raw.recipe["tungsten-carbide-2"]=nil
data.raw.recipe["copper-tungsten-alloy"]=nil

local recipeList={
  "pellet-tungsten-smelting",
  "tungsten-carbide",
  "tungsten-carbide-2",
  "copper-tungsten-alloy"
}
for _,recipe in pairs(recipeList) do
  data.raw.recipe[recipe]=nil
  for _, module in pairs(data.raw.module) do
    if module.limitation then
      for j,limit in pairs(module.limitation) do
        if limit == recipe then
          table.remove(module.limitation,j)
          break
        end
      end
    end
  end
end

if mods["angelsindustries"] then
  if settings.startup["angels-enable-components"].value or settings.startup["angels-enable-tech"].value then
    require("prototypes.recipes.angels-components")
    local OV = angelsmods.functions.OV
    rep_con_mats()
    OV.execute()
    for n,_ in pairs(perviousbuilding) do 
      table.remove(data.raw["recipe"][_]["normal"].ingredients,1); 
      table.remove(data.raw["recipe"][_]["expensive"].ingredients,1); 
    end
    if settings.startup["angels-return-ingredients"].value then
      add_minable_results()
      OV.execute()
    end
  end
end
