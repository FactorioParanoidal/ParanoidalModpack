function fillPeaceConfig(config)
	
	config["alien-ore"] = {
		type="resource-ore",
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=3000,
		size={min=14, max=18},
		min_amount=20,
		
		multi_resource_chance=0.2,
		multi_resource={
			['copper-ore'] = 1,
			['iron-ore'] = 1,
		}
	}
	
end