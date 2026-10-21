function fillTrickyOldNickConfig(config)

     -- Modify Nullius's iron ore config
     if config.nauvis["iron-ore"] then
         config.nauvis["iron-ore"].starting = nil
         config.nauvis["iron-ore"].allotment = 80
     end

     config.nauvis["nullius-fumarole"].multi_resource["nullius-nickel-ore"] = 2

     config.nauvis["nullius-nickel-ore"] = {
         type = "resource-ore",

         allotment = 28,
         spawns_per_region = {min=1, max=1},
         richness = 19000,
         size = {min=10, max=18},
             starting = {richness=1200, size = 25, probability = 1},
                 multi_resource_chance = 0.20,
                 multi_resource = {
                 ["iron-ore"] = 10,
                         ["nullius-fumarole"] = 1
         }
         }
end