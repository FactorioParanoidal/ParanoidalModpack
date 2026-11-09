--- rocket-parts.lua
-- @module scripts.rocket-parts.lua
-- @pragma nostrip
-- @author Nicholas Gower(MeteorSwarm)

local Public = {}

local surface_properties_lib = require("lib.surface-property-lib")


--- On building a rocket silo, if the silo is vanilla-like, its recipe is replaced if it was placed on a surface
--- that according to "Planetslib-planet-rocket-part-recipe"(mod-data), should be replaced.
--- Forked from NotNotMelon's [rocket silo code](https://github.com/notnotmelon/maraxsis/blob/main/scripts/project-seadragon.lua) for Maraxsis.
-- @param event table
function Public.on_built_rocket_silo(event)
    
    local entity = event.entity
    if not entity.valid then return end
    if entity.type ~= "rocket-silo" and (entity.type ~= "entity-ghost" or entity.ghost_type ~= "rocket-silo") then return end
    local prototype = entity.name == "entity-ghost" and entity.ghost_prototype or entity.prototype

    if not prototype.crafting_categories["rocket-building"] then return end
    if prototype.fixed_recipe then return end -- Paranoidal fork: silos keep their fixed recipe
    local rocket_part_recipe_data = prototypes.mod_data["Planetslib-planet-rocket-part-recipe"].data
    local lock_rocket_silo_data = prototypes.mod_data["Planetslib-planet-lock-rocket-silos"].data
    local recipe, lock_silo
    if rocket_part_recipe_data[entity.surface.name] then
        recipe = rocket_part_recipe_data[entity.surface.name]
    else 
        recipe = rocket_part_recipe_data["default"]
    end

    local lock_override = lock_rocket_silo_data[entity.surface.name]
    if lock_override ~= nil then
        lock_silo = lock_override
    elseif lock_rocket_silo_data["default"] ~= nil then
        lock_silo = lock_rocket_silo_data["default"]
    else
        local multiple_recipes_possible = surface_properties_lib.multiple_rocket_parts_can_be_crafted_in_vanilla_silo(entity.surface)
        lock_silo = not multiple_recipes_possible
    end
    

    if recipe == "_other" then return end --If planet excluded from planetlib script, do nothing, let other planet mod handle rocket part recipe assignment.

    entity.set_recipe(recipe)
    if entity.recipe_locked == false then
        entity.recipe_locked = lock_silo
    end
    
end


--Based on code from Maraxsis' project-seadragon, but altered to be more general using 2.0.58's mod-data prototype 

return Public

