function fillQatmoreConfig(config)

	local function checkOre(name)
		local data = prototypes.entity[name]
		if data and data.autoplace_specification then
			return true
		end
		return false
	end

  config.nauvis["bob-thorium-ore"].allotment = 50
  config.nauvis["bob-tin-ore"].starting.size = 20
  config.nauvis["bob-tin-ore"].starting.richness = 20000
  if settings.startup["bobmods-ores-startinggroundwater"].value == true then
    config.nauvis["bob-ground-water"].starting.richness = 1000000
  end

	config.nauvis["fluorite-ore"] = {
		type="resource-ore",
		
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount=300,
		
		multi_resource_chance=0.40,
		multi_resource={
			["bob-gem-ore"] = 4,
			["stone"] = 3,
			["bob-quartz"] = 2,
			["bob-tungsten-ore"] = 2,
			["bob-rutile-ore"] = 2,
		}
	}

  if checkOre("meteoric-iron-ore") then
    config.nauvis["meteoric-iron-ore"] = {
      type="resource-ore",
      
      allotment=30,
      spawns_per_region={min=0, max=1},
      richness=30000,
      size={min=15, max=25},
      min_amount=150,
      
        starting={richness=30000, size=15, probability=0.05},

      multi_resource_chance=0.2,
      multi_resource={
        ["iron-ore"] = 1,
        ["bob-nickel-ore"] = 1,
      }
    }
  end

  if checkOre("okloite") then
    config.nauvis["okloite"] = {
      type="resource-ore",
      
      allotment=20,
      spawns_per_region={min=0, max=1},
      richness=20000,
      size={min=8, max=12},
      min_amount=1000,
      
        starting={richness=16000, size=8, probability=0},

      multi_resource_chance=0.8,
      multi_resource={
        ["bob-tungsten-ore"] = 5,
        ["uranium-ore"] = 4,
        ["bob-thorium-ore"] = 1,
      }
    }
  end

  if checkOre("cryolite-ore") then
    config.nauvis["cryolite-ore"] = {
      type="resource-ore",
      
      allotment=30,
      spawns_per_region={min=0, max=1},
      richness=4000,
      size={min=5, max=20},
      min_amount=500,

        starting={richness=4000, size=5, probability=0},
      
      multi_resource_chance=0.40,
      multi_resource={
        ["bob-bauxite-ore"] = 3,
        ["fluorite-ore"] = 3,
      }
    }
  end

  if checkOre("chalcopyrite-ore") then
    config.nauvis["chalcopyrite-ore"] = {
      type="resource-ore",
      
      allotment=30,
      spawns_per_region={min=0, max=1},
      richness=15000,
      size={min=20, max=30},
      min_amount=300,
      
        starting={richness=15000, size=20, probability=0.05},

      multi_resource_chance=0.20,
      multi_resource={
        ["iron-ore"] = 3,
        ["copper-ore"] = 3,
        ["bob-zinc-ore"] = 3,
      }
    }
  end

end