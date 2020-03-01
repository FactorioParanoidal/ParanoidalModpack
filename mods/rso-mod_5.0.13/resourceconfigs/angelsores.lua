function fillAngelsOresConfig(config)
   if game.entity_prototypes["angels-ore1"] then
   config["angels-ore1"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=15000,
      size={min=20, max=25},
      min_amount = 150,
      
      starting={richness=12000, size=20, probability=1},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore2"] = 3,
      }
   }
      config["angels-ore2"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      starting={richness=4000, size=15, probability=0},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore3"] = 3,
      }
   }
      config["angels-ore3"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=15000,
      size={min=20, max=25},
      min_amount = 150,
      
      starting={richness=12000, size=20, probability=1},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore4"] = 3,
      }
   }
      config["angels-ore4"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      starting={richness=4000, size=15, probability=0},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore5"] = 3,
      }
   }
      config["angels-fissure"] = {
      type="resource-liquid",
      minimum_amount=100000,
      allotment=40,
      spawns_per_region={min=1, max=1},
      richness={min=75000, max=200000}, -- richness per resource spawn
      size={min=1, max=3},
      
   }
   end
   if game.entity_prototypes["angels-ore5"] then
      config["angels-ore5"] = {
      type="resource-ore",
      
      allotment=40,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      starting={richness=8000, size=20, probability=1},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore6"] = 3,
      }
   }
      config["angels-ore6"] = {
      type="resource-ore",
      
      allotment=40,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      starting={richness=8000, size=20, probability=1},
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore1"] = 3,
      }
   }
   end
   
   if game.entity_prototypes["angels-natural-gas"] then
   config["angels-natural-gas"] = {
      type="resource-liquid",
      minimum_amount=100000,
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness={min=100000, max=300000}, -- richness per resource spawn
      size={min=2, max=3},
      
      starting={richness=200000, size=2, probability=1},
      
      multi_resource_chance=0.20,
      multi_resource={
         ["crude-oil"] = 4,
      }
   }
   
   config["crude-oil"].allotment=60
   config["crude-oil"].spawns_per_region={min=1, max=1}
   config["crude-oil"].size={min=2, max=3}
   
   end   
end