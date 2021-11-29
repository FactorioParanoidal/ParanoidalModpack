function fillDarkMatterConfig(config)
	
	local oreName = nil
	if game.entity_prototypes["tenemut"] then
		oreName = "tenemut"
	end
	if game.active_mods["dark-matter-replicators-18"] then
		oreName = "dmr18-tenemut"
	end
	
	if oreName ~= nil then
		config[oreName] = {
			type="resource-ore",
			
			allotment=40,
			
			spawns_per_region={min=1, max=1},
			size={min=5, max=8},
			richness=13500,
			
			starting={richness=8000, size=7, probability=1},
		}
	end
end