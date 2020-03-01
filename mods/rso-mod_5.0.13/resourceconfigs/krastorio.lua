function fillKrastorioConfig(config)

config["kr-sand"] = {
    type="resource-ore",
    allotment=80,
    spawns_per_region={min=1, max=1},
    richness=30000,
    size={min=20, max=30}, 
    min_amount=300,

    starting={richness=8000, size=25, probability=1}
}

config["kr-gold"] = {
    type="resource-ore",
    allotment=60,
    spawns_per_region={min=1, max=1},
    richness=25000,
    size={min=10, max=25}, 
    min_amount=250,

    starting={richness=8000, size=25, probability=1}
}

config["menarite"] = {
    type="resource-liquid",
    minimum_amount=200000,
    allotment=50,
    spawns_per_region={min=1, max=1},
    richness={min=2000000, max=5000000}, -- richness per resource spawn
    size={min=1, max=1},
    useOreScaling = true
}

config["imersite"] = {
    type="resource-liquid",
    minimum_amount=150000,
    allotment=25,
    spawns_per_region={min=1, max=1},
    richness={min=1500000, max=3750000}, -- richness per resource spawn
    size={min=1, max=1},
    useOreScaling = true
}
end