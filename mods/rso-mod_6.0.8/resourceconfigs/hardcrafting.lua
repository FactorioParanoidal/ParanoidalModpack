function fillHardCraftingConfig(config)

	config["rich-copper-ore"] =
	{
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=15},
		min_amount=300,

		starting={richness=5000, size=25, probability=1},
	}
	
	if game.entity_prototypes["rich-iron-ore"] then
		config["rich-iron-ore"] =
		{
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=10, max=15},
			min_amount = 300,
			
			starting={richness=5000, size=25, probability=1},
		}
	end

	if game.entity_prototypes["oil-sand"] then
		config["oil-sand"] =
		{
			type="resource-liquid",
			minimum_amount=240000,
			allotment=80,
			spawns_per_region={min=1, max=2},
			richness={min=240000, max=400000}, -- richness per resource spawn
			size={min=3, max=6},
		}
	end
end