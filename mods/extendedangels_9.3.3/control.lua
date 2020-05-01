script.on_configuration_changed( function(conf)
for index, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes
  

    recipes["washing-plant-3"].enabled = technologies["water-washing-3"].researched
    recipes["advanced-chemical-plant-3"].enabled = technologies["angels-advanced-chemistry-4"].researched
    recipes["powder-zinc"].enabled = technologies["angels-zinc-smelting-2"].researched
    recipes["gas-argon"].enabled = technologies["angels-nitrogen-processing-1"].researched
    recipes["angels-air-filter-3"].enabled = technologies["angels-nitrogen-processing-3"].researched
    recipes["angels-air-filter-4"].enabled = technologies["angels-nitrogen-processing-4"].researched
    

    if technologies["bio-aboretum-2"] then 
      recipes["bio-generator-temperate-2"].enabled = technologies["bio-aboretum-2"].researched
      recipes["bio-generator-swamp-2"].enabled = technologies["bio-aboretum-2"].researched
      recipes["bio-generator-desert-2"].enabled = technologies["bio-aboretum-2"].researched
      recipes["bio-arboretum-2"].enabled = technologies["bio-aboretum-2"].researched
      end

    if technologies["bio-aboretum-3"] then 
      recipes["bio-generator-temperate-3"].enabled = technologies["bio-aboretum-3"].researched
      recipes["bio-generator-swamp-3"].enabled = technologies["bio-aboretum-3"].researched
      recipes["bio-generator-desert-3"].enabled = technologies["bio-aboretum-3"].researched
      recipes["bio-arboretum-3"].enabled = technologies["bio-aboretum-3"].researched
      end


    if technologies["phosphorus-processing-2"] then 
    recipes["solid-disodium-phosphate"].enabled = technologies["phosphorus-processing-2"].researched
    recipes["solid-tetrasodium-pyrophosphate"].enabled = technologies["phosphorus-processing-2"].researched
    end
    
    if technologies["water-treatment-5"] then 
      recipes["hydro-plant-4"].enabled = technologies["water-treatment-5"].researched
      recipes["salination-plant-3"].enabled = technologies["water-treatment-5"].researched
      end

    if technologies["angels-tungsten-smelting-3"].researched then
        recipes["solid-tungsten-trioxide-smelting"].enabled = true
        recipes["pellet-tungsten-smelting-2"].enabled = true
        recipes["solid-sodium-tungstate-smelting"].enabled = true
        recipes["casting-powder-tungsten-3"].enabled = true
    end
      
  end
end)