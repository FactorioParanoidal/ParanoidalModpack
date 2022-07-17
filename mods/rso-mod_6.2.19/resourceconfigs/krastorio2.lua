function fillKrastorio2Config(config)

    config["rare-metals"] = 
    {
        type="resource-ore",
        allotment=60,
        spawns_per_region={min=1, max=1},
        richness=20000,
        size={min=10, max=26}, 
        min_amount=275,

        starting={richness=3500, size=10, probability=1},

        multi_resource_chance=0.20,
        multi_resource=
        {
            ["iron-ore"] = 4,
            ['copper-ore'] = 2,
            ["uranium-ore"] = 2,
            ["stone"] = 4,
        }
    }

    config["mineral-water"] = 
    {
        type="resource-liquid",
        minimum_amount=100000,
        allotment=60,
        spawns_per_region={min=1, max=2},
        richness={min=100000, max=200000},
        size={min=2, max=5},
    }

	if game.active_mods["bztungsten"] then
		config["mineral-water"].starting = {richness=150000, size=1, probability=1}
	end

    config["imersite"] = 
    {
        type="resource-liquid",
        minimum_amount=150000,
        allotment=45,
        spawns_per_region={min=1, max=1},
        richness={min=1500000, max=3500000},
        size={min=1, max=1},
        useOreScaling = true
    }

end