for _,item in pairs ({
    {name = "burner-turbine", capacity = 20},
    {name = "fuel-processor", capacity = 20},
    {name = "industrial-furnace", capacity = 10},
    {name = "processed-fuel", capacity = 20 * 100},
    {name = "electric-motor", capacity = 400},
    {name = "motor", capacity = 800},
    {name = "concrete-wall", capacity = 50},
    {name = "steel-wall", capacity = 25},
    {name = "logistic-robot", capacity = 50},
    {name = "construction-robot", capacity = 50},
}) do
    data.raw["item"][item.name].weight = 1000000/item.capacity
end

local boiler_surface_conditions = data.raw["boiler"]["boiler"].surface_conditions
data.raw["burner-generator"]["burner-turbine"].surface_conditions = boiler_surface_conditions
data.raw["assembling-machine"]["fuel-processor"].surface_conditions = boiler_surface_conditions
data.raw["assembling-machine"]["burner-assembling-machine"].surface_conditions = boiler_surface_conditions
if mods["space-age"] then
    table.insert(data.raw["assembling-machine"]["burner-assembling-machine"].crafting_categories, "pressing")
    table.insert(data.raw["assembling-machine"]["burner-assembling-machine"].crafting_categories, "electronics")
    data.raw.recipe["small-iron-electric-pole"].category = "electronics"
end
