function fillEnhancedRecipesConfig(config)

	if game.active_mods["enhanced_recipes"] then
	
		config["bauxite-ore"] =
		{
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=5000,
			size={min=15, max=20},
		}
	end
end