local rro = Muluna.rro
if data.raw["recipe"]["vgal-uranium-235-space-science-pack"] then
    data.raw["recipe"]["vgal-uranium-235-space-science-pack"].surface_conditions = 
    data.raw["recipe"]["space-science-pack"].surface_conditions
    data.raw["recipe"]["vgal-uranium-235-space-science-pack"].results[1].amount = 
    data.raw["recipe"]["space-science-pack"].results[1].amount*10
end

local recipes = {
    {"vgal-solid-fuel-sulfuric-acid-carbon","carbonic-asteroid-crushing"},
    {"vgal-carbon-sulfur-lubricant","carbonic-asteroid-crushing"},
    {"vgal-ammonia-plastic-bar","planet-discovery-aquilo"},
    {"vgal-coal-crushing","muluna-advanced-boiler"},
    {"vgal-ammonia-water-crude-oil","planet-discovery-aquilo"}
}

for _,recipe in pairs(recipes) do
    if data.raw["recipe"][recipe[1]] then
        rro.cut_paste(data.raw["technology"]["space-platform"].effects,data.raw["technology"][recipe[2]].effects,{type = "unlock-recipe",recipe = recipe[1]})
    end
end
-- if data.raw["recipe"]["vgal-solid-fuel-sulfuric-acid-carbon"] then
--     rro.cut_paste(data.raw["space-platform"].effects,{type = "unlock-recipe",recipe = recipe})
-- end