function fillOmnimatterConfig(config)
if game.entity_prototypes["omnite"] then
   config["omnite"] = {
      type="resource-ore",
      
      allotment=60,
      spawns_per_region={min=1, max=1},
      richness=40000,
      size={min=10, max=50},
      min_amount = 150,
      
      starting={richness=300000, size=25, probability=1},
      
      multi_resource_chance=0,
      multi_resource={
      }
   } 
end
--if game.entity_prototypes["omniston"] then
-- config["omniston"] = {
--      type="resource-liquid",
--      minimum_amount=10000,
--      allotment=60,
--      spawns_per_region={min=1, max=1},
--      richness={min=30000, max=60000}, -- richness per resource spawn
--      size={min=2, max=3},
--      
--      starting={richness=20000, size=2, probability=1},
--      
--      multi_resource_chance=0.0,
--   }
--end
end