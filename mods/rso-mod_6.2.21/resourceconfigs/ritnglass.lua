function fillRitnGlassConfig(config)
	
	config["silica-sand"] =
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=11000,
		size={min=15, max=20},
		min_amount=250,

		starting={richness=6000, size=16, probability=1},
	}
end