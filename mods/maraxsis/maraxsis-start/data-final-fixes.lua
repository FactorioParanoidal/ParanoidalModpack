local utils = require "__any-planet-start__.utils"
local asteroid_util = require "__space-age__.prototypes.planet.asteroid-spawn-definitions"

utils.set_prerequisites("sp-spidertron-automation", {"processing-unit", "tungsten-steel", "electric-engine", "bulk-inserter", "fluid-handling"})
utils.add_recipes("sp-spidertron-automation", {"maraxsis-diesel-submarine"})
utils.set_packs("sp-spidertron-automation", {"automation-science-pack", "logistic-science-pack"}, 100, 30)

if mods["Rocs-Hardcore-Demolishers"] then
    local utils = require("__any-planet-start__.utils")
    utils.add_recipes("foundry", {
        "concrete-from-molten-iron",
        "casting-steel",
    })
end

data.raw.planet.maraxsis.asteroid_spawn_definitions, data.raw.planet.nauvis.asteroid_spawn_definitions = data.raw.planet.nauvis.asteroid_spawn_definitions, data.raw.planet.maraxsis.asteroid_spawn_definitions
for _, space_connection in pairs(data.raw["space-connection"]) do
    local function connects_to(planet)
        return space_connection.from == planet or space_connection.to == planet
    end

    if connects_to("hyarion") then
        goto continue -- do not overrite bismuth asteroids
    end

    if connects_to("maraxsis") then
        space_connection.asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus)
    end

    ::continue::
end

local sacrifice = table.deepcopy(data.raw.recipe["electromagnetic-plant"])
table.insert(sacrifice.ingredients, {
    type = "item",
    name = "maraxsis-a-breath-of-fresh-air",
    amount = 1,
})
sacrifice.name = sacrifice.name .. "-sacrifice"
sacrifice.main_product = "electromagnetic-plant"
sacrifice.categories = {"crafting"}
sacrifice.localised_name = {"entity-name.electromagnetic-plant"}
data:extend{sacrifice}
table.insert(data.raw.technology["electromagnetic-plant"].effects, 1, {
    type = "unlock-recipe",
    recipe = sacrifice.name
})
data.raw.recipe["electromagnetic-plant"].categories = {"electromagnetics"}

-- if a tech has space science but does not have hydraulic science, add hydraulic science
for _, technology in pairs(data.raw.technology) do
    if technology.hidden then goto continue end
    if type(technology.unit) ~= "table" then goto continue end
    if type(technology.unit.ingredients) ~= "table" then goto continue end

    local has_hyd = false
    local has_space = false
    local count_to_insert = 1

    for _, ingredient in pairs(technology.unit.ingredients) do
        if type(ingredient) == "table" then
            if ingredient[1] == "space-science-pack" then
                has_space = true
                count_to_insert = ingredient[2]
            elseif ingredient[1] == "hydraulic-science-pack" then
                has_hyd = true 
            end
        end
    end

    if has_hyd == false and has_space == true and table_size(technology.unit.ingredients) >= 3 then
        table.insert(technology.unit.ingredients, {"hydraulic-science-pack", count_to_insert})
    end

    ::continue::
end