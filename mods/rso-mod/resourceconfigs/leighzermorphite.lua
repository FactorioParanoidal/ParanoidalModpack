function fillLeighzerMorphiteConfig(config)

config["morphite-ore"] = {
    type="resource-ore",

    allotment=100, 
    spawns_per_region={min=1, max=1}, 
    richness=30000,

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