function fillLeighzerScienceBottling(config)
	local function getConfigForScienceBottling()
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

	config["sand-ore"] = getConfigForScienceBottling() -- sand will always be enabled

	if game.entity_prototypes["precursore-ore"] then -- this is an optional ore used to further complicate science production
		config["precursore-ore"] = getConfigForScienceBottling()
	end
end