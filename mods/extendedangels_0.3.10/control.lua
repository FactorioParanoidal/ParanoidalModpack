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

    if technologies["phosphorus-processing-2"].researched then 
      recipes["solid-disodium-phosphate"].enabled = true
      recipes["solid-tetrasodium-pyrophosphate"].enabled = true
    end
    
    if technologies["water-treatment-5"].researched then 
      recipes["hydro-plant-4"].enabled = true
      recipes["salination-plant-3"].enabled = true
      end

    if technologies["angels-tungsten-smelting-3"].researched then
      recipes["solid-tungsten-trioxide-smelting"].enabled = true
      recipes["pellet-tungsten-smelting-2"].enabled = true
      recipes["solid-sodium-tungstate-smelting"].enabled = true
      recipes["casting-powder-tungsten-3"].enabled = true
    end
  if game.active_mods["angelsbioprocessing"] then
    if technologies["bio-arboretum-2"].researched then 
      recipes["bio-generator-temperate-2"].enabled = true
      recipes["bio-generator-swamp-2"].enabled = true
      recipes["bio-generator-desert-2"].enabled = true
      recipes["bio-arboretum-2"].enabled = true
      end
  
    if technologies["bio-arboretum-3"].researched then 
      recipes["bio-generator-temperate-3"].enabled = true
      recipes["bio-generator-swamp-3"].enabled = true
      recipes["bio-generator-desert-3"].enabled = true
      recipes["bio-arboretum-3"].enabled = true
    end

    if technologies["bio-refugium-butchery-2"].researched then
      recipes["bio-butchery-2"].enabled = true
    end
      
    if technologies["bio-refugium-fish-2"].researched then
      recipes["bio-refugium-fish-2"].enabled = true
    end

    if technologies["bio-refugium-puffer-2"].researched then
      recipes["bio-refugium-puffer-2"].enabled = true
    end

    if technologies["bio-refugium-biter-2"].researched then
      recipes["bio-refugium-biter-2"].enabled = true
    end


    if technologies["bio-refugium-biter-3"].researched then
      recipes["bio-refugium-biter-3"].enabled = true
    end
      if technologies["bio-refugium-biter-3"].researched then
        recipes["crop-farm-2"].enabled = true
        recipes["composter-2"].enabled = true
        recipes["bio-processor-2"].enabled = true

    end
  end
  end
end)