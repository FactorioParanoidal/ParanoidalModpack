local function addingMiningdrillbits()

  --KaoExtended.recipe.addtorecipe("bi_recipe_giga_wooden_chest", {"basic-structure-components", 5})

  KaoExtended.recipe.addtorecipe("burner-mining-drill", {"mining-drill-bit-mk0", 1})
  bobmods.lib.recipe.remove_ingredient ("burner-mining-drill", "iron-plate")
  
  KaoExtended.recipe.addtorecipe("electric-mining-drill", {"mining-drill-bit-mk1", 1})
  bobmods.lib.recipe.remove_ingredient ("burner-mining-drill", "iron-plate")
  
  KaoExtended.recipe.addtorecipe("bob-mining-drill-1", {"mining-drill-bit-mk2", 1})
  bobmods.lib.recipe.remove_ingredient ("bob-mining-drill-1", "iron-gear-wheel")
	
  KaoExtended.recipe.addtorecipe("bob-mining-drill-2", {"mining-drill-bit-mk3", 1})
  
  KaoExtended.recipe.addtorecipe("bob-mining-drill-3", {"mining-drill-bit-mk4", 1})
  bobmods.lib.recipe.remove_ingredient ("bob-mining-drill-3", "titanium-plate")
  
  KaoExtended.recipe.addtorecipe("bob-mining-drill-4", {"mining-drill-bit-mk5", 1})
  bobmods.lib.recipe.remove_ingredient ("bob-mining-drill-4", "tungsten-carbide")
  
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-1", {"mining-drill-bit-mk2", 1})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-2", {"mining-drill-bit-mk3", 1})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-3", {"mining-drill-bit-mk4", 1})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-4", {"mining-drill-bit-mk5", 1})
  
  
  KaoExtended.recipe.addtorecipe("seafloor-pump", {"mining-drill-bit-mk2", 1})

end



addingMiningdrillbits()