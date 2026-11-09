--Custom mod data for control stage

local rocket_part_recipe_data = {
    type = "mod-data",
    name = "Planetslib-planet-rocket-part-recipe",
    data_type = "recipe",
    data = {
        default = "rocket-part", --Used for surfaces not specified.
    }
}

local lock_silo_recipe_data = {
    type = "mod-data",
    name = "Planetslib-planet-lock-rocket-silos",
    data_type = "recipe",
    data = {
        default = nil, --Used for surfaces not specified. Mods that add new optional rocket part recipes should set the default to false.
    }
}


data:extend{rocket_part_recipe_data,lock_silo_recipe_data}
local blacklisted_planets = { --Planets with their own system for replacing rocket part recipes.
    "muluna",
    "maraxsis",
}
for _,planet in pairs(blacklisted_planets) do
    PlanetsLib.assign_rocket_part_recipe(planet,"_other")
end
-- For other mods, data.raw["mod-data"]["Planetslib-rocket-part-recipe"].data["muluna"] = "rocket-part-muluna"



