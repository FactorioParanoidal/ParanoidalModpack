function fillPyAlternativeEnergyConfig(config)
	local nauvisConfig = config.nauvis
	
	nauvisConfig["antimonium"] =
	{
		type="resource-ore",

		allotment=80, 
		spawns_per_region={min=1, max=1}, 
		richness=25000,

		size={min=20, max=30}, 
		min_amount=250,
	}

	nauvisConfig["ree"] =
	{
		type="resource-ore",

		allotment=80, 
		spawns_per_region={min=1, max=1}, 
		richness=25000,

		size={min=20, max=30}, 
		min_amount=250,
	}

	config.nauvis["geothermal-crack"] =
	{
		type = "resource-liquid", 
		minimum_amount = 40000, 
		allotment = 50, 
		spawns_per_region = {min = 1, max = 1}, 
		richness = {min = 50000, max = 100000}, 
		size = {min = 1, max = 1}, 
		useOreScaling = true,

		starting =
		{
			richness = 75000, 
			size = 1,
			probability = 1 
		}
	}
end