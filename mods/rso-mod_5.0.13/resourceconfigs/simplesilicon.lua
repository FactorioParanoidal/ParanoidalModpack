function fillSimpleSiliconConfig(config)   

	local data = game.entity_prototypes["SiSi-quartz-ore"]
	
	if data and data.autoplace_specification then
		config["SiSi-quartz-ore"] = {
			type="resource-ore",
		   
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 250,
		}
	end
end