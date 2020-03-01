function fillLeighzerScienceOres(config)
	
	local function getConfigForScienceOres()
		return { --same config as iron ore
			type="resource-ore",

			allotment=100,
			spawns_per_region={min=1, max=1},
			richness=20000,

			size={min=20, max=30},
			min_amount=300,

			starting={richness=8000, size=25, probability=1},

			multi_resource_chance=0.20, 
			multi_resource={
				["iron-ore"] = 2,
				['copper-ore'] = 4,
				["coal"] = 4,
				["stone"] = 4,
			}
		}
	end

	if game.entity_prototypes["automation-science-ore"] then
		config["automation-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["logistic-science-ore"] then
		config["logistic-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["military-science-ore"] then
		config["military-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["chemical-science-ore"] then
		config["chemical-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["production-science-ore"] then
		config["production-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["utility-science-ore"] then
		config["utility-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["space-science-ore"] then
		config["space-science-ore"] = getConfigForScienceOres()
	end

	if game.entity_prototypes["advanced-logistic-science-ore"] then
		config["advanced-logistic-science-ore"] = getConfigForScienceOres()
	end
end