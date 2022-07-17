function fillApmConfig(config)

	if game.active_mods["apm_nuclear"] or game.active_mods["apm_nuclear_ldinc"] then
		config["thorium-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=10, max=15},
			min_amount=300,
		}
	end
end