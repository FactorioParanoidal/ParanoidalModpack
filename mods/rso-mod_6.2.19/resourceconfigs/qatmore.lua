function fillQatmoreConfig(config)

	local function checkOre(name)
		local data = game.entity_prototypes[name]
		if data and data.autoplace_specification then
			return true
		end
		return false
	end

	config["fluorite-ore"] = {
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount=300,
		
		multi_resource_chance=0.40,
		multi_resource={
			["stone"] = 3,
			["bauxite-ore"] = 3,
			["quartz"] = 2,
			["tungsten-ore"] = 2,
			["rutile-ore"] = 2,
		}
	}

  if checkOre("meteoric-iron-ore") then
	config["meteoric-iron-ore"] = {
		type="resource-ore",
		
		allotment=25,
		spawns_per_region={min=0, max=1},
		richness=30000,
		size={min=15, max=30},
		min_amount=150,
		
       starting={richness=30000, size=15, probability=0},

		multi_resource_chance=0.2,
		multi_resource={
			["iron-ore"] = 1,
			["nickel-ore"] = 1,
		}
	}
  end

  if checkOre("okloite") then
	config["okloite"] = {
		type="resource-ore",
		
		allotment=10,
		spawns_per_region={min=0, max=1},
		richness=16000,
		size={min=8, max=12},
		min_amount=1000,
		
       starting={richness=16000, size=8, probability=0},

		multi_resource_chance=0.8,
		multi_resource={
			["tungsten-ore"] = 5,
			["uranium-ore"] = 4,
			["thorium-ore"] = 1,
		}
	}
  end

  if checkOre("cryolite-ore") then
	config["cryolite-ore"] = {
		type="resource-ore",
		
		allotment=20,
		spawns_per_region={min=0, max=1},
		richness=4000,
		size={min=5, max=20},
		min_amount=500,

       starting={richness=4000, size=5, probability=0},
		
		multi_resource_chance=0.40,
		multi_resource={
			["bauxite-ore"] = 3,
			["fluorite-ore"] = 3,
		}
	}
  end

  if checkOre("chalcopyrite-ore") then
	config["chalcopyrite-ore"] = {
		type="resource-ore",
		
		allotment=25,
		spawns_per_region={min=0, max=1},
		richness=15000,
		size={min=20, max=30},
		min_amount=300,
		
       starting={richness=15000, size=20, probability=0},

		multi_resource_chance=0.20,
		multi_resource={
			["iron-ore"] = 3,
			["copper-ore"] = 3,
		}
	}
  end

end