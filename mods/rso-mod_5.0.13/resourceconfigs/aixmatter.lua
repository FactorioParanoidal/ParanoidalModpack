function fillAiXMatterConfig(config)   
    config["ax-matter-ore"] = {
        type="resource-ore",
       
        allotment=40,
        spawns_per_region={min=1, max=1},
        richness=6000,
        size={min=10, max=15},
        min_amount=300,
        starting={richness=8000, size=25, probability=1},
    }
   
    config["ax-liquid-matter"] = {
        type="resource-liquid",
        minimum_amount=240000,
        allotment=70,
        spawns_per_region={min=1, max=2},
        richness={min=240000, max=400000},
        size={min=2, max=5},
        starting={richness=400000, size=2, probability=1},
    }
end