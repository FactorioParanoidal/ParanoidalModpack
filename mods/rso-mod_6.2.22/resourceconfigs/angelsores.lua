function fillAngelsOresConfig(config)
   if game.entity_prototypes["angels-ore1"] then
   config["angels-ore1"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=15000,
      size={min=20, max=25},
      min_amount = 150,
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore2"] = 3,
      }
   }
   
	if settings.startup["angels-starting-resource-ore1"].value then
      config["angels-ore1"].starting={richness=12000, size=20, probability=1}
	end
   
      config["angels-ore2"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore3"] = 3,
      }
   }

   	if settings.startup["angels-starting-resource-ore2"].value then
      config["angels-ore2"].starting={richness=10000, size=15, probability=1}
	end

      config["angels-ore3"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=15000,
      size={min=20, max=25},
      min_amount = 150,
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore4"] = 3,
      }
   }
   
   	if settings.startup["angels-starting-resource-ore3"].value then
      config["angels-ore3"].starting={richness=12000, size=20, probability=1}
	end
   
      config["angels-ore4"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore5"] = 3,
      }
   }
   
   	if settings.startup["angels-starting-resource-ore4"].value then
      config["angels-ore4"].starting={richness=10000, size=15, probability=1}
	end
   
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
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore6"] = 3,
      }
   }

   	if settings.startup["angels-starting-resource-ore5"].value then
      config["angels-ore5"].starting={richness=8000, size=20, probability=1}
	end
   
      config["angels-ore6"] = {
      type="resource-ore",
      
      allotment=40,
      spawns_per_region={min=1, max=1},
      richness=12000,
      size={min=15, max=20},
      min_amount = 150,
      
      multi_resource_chance=0.30,
      multi_resource={
         ["angels-ore1"] = 3,
      }
   }
   
   	if settings.startup["angels-starting-resource-ore6"].value then
      config["angels-ore6"].starting={richness=8000, size=20, probability=1}
	end
   
   end
   
   if game.entity_prototypes["angels-natural-gas"] then
   config["angels-natural-gas"] = {
      type="resource-liquid",
      minimum_amount=4000, -- reduced from 10k
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness={min=4000, max=12000}, -- richness per resource spawn --reduced from 10k and 30k
      size={min=2, max=3},
      
      starting={richness=4000, size=1, probability=1}, --reduced from 20k to 4k for spawn are to bring it inline with the oil spawn, reduced size from 2 to 1, now about 1-2x that of the oil spawn
      
      multi_resource_chance=0.20,
      multi_resource={
         ["crude-oil"] = 4,
      }
   }
   
   config["crude-oil"].allotment=60
   config["crude-oil"].spawns_per_region={min=1, max=1}
   config["crude-oil"].size={min=2, max=6} --increased max from 4 to 6
   
   end   
end