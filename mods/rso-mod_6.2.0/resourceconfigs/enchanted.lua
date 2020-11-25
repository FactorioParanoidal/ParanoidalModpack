function fillEnchantedConfig(config)

	if game.active_mods["EnchantedNuclear"] then
		config["thorium-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=15},
			min_amount=300,
		}
	end
	
	if game.active_mods["EnchantedElectronics"] then
		config["tin-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=7000,
			size={min=15, max=20},
			min_amount=300,
		}
	end

	if game.active_mods["EnchantedIndustries"] then
		config["chromium-ore"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=15, max=20},
			min_amount=300,
		}
		config["nickel-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=7000,
			size={min=10, max=15},
			min_amount=300,
		}
		config["aluminum-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=7000,
			size={min=15, max=20},
			min_amount=300,
		}
		config["shale"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=15, max=20},
			min_amount=300,
		}
		end
		
end