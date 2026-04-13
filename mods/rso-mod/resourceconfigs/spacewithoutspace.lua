function fillSpaceAgeWithoutSpaceConfig(config)

config.nauvis["calcite"] =
{
    type="resource-ore",

    allotment=60,

    spawns_per_region={min=1, max=1},
    size={min=10, max=20},
    richness=6000,
    min_amount=100,
}

config.nauvis["tungsten-ore"] =
{
    type="resource-ore",

    allotment=60,

    spawns_per_region={min=1, max=1},
    size={min=20, max=30},
    richness=15000,
    min_amount=300,
}

config.nauvis["sulfuric-acid-geyser"] =
{
    type="resource-liquid",
    minimum_amount=60000,
    allotment=60,
    spawns_per_region={min=1, max=2},
    richness={min=200000, max=400000}, -- richness per resource spawn
    size={min=3, max=6},
}

config.nauvis["fluorine-vent"] =
{
    type="resource-liquid",
    minimum_amount=30000,
    allotment=70,
    spawns_per_region={min=1, max=2},
    richness={min=50000, max=100000}, -- richness per resource spawn
    size={min=2, max=5},
}

config.nauvis["lithium-brine"] =
{
    type="resource-liquid",
    minimum_amount=50000,
    allotment=70,
    spawns_per_region={min=1, max=2},
    richness={min=100000, max=500000}, -- richness per resource spawn
    size={min=2, max=5},
}

config.nauvis["gleba_enemy_base"] =
{
    type="entity",
    force="enemy",
    clear_range = {6, 6},

    spawns_per_region={min=2,max=4},
    size={min=2,max=4},
    size_per_region_factor=0.4,
    richness=1,

    absolute_probability=settings.global["rso-enemy-chance"].value, -- chance to spawn in region
    probability_distance_factor=1.15, -- relative increase per region
    max_probability_distance_factor=3.0, -- absolute value

    bases =
	{
        ["gleba-spawner-small"] = {allotment = 50},
        ["gleba-spawner"] =
        {
            allotment = 50,
            min_distance = 3,
            allotment_distance_factor=1.3,
        }
    },
}

end