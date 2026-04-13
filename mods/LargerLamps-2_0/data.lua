-- DEADLOCK's LARGER LAMPS

-- Update prototypes access (Factorio 2.0+)
require("prototypes.item")
require("prototypes.entity")
require("prototypes.technology")

-- Include modularized recipe files for each lamp
require("prototypes.recipes.large_lamp_recipe")
require("prototypes.recipes.copper_lamp_recipe")
require("prototypes.recipes.electric_copper_lamp_recipe")
require("prototypes.recipes.floor_lamp_recipe")

-- Define recipe category for lamp-burning
data:extend({
    {
        type = "recipe-category",
        name = "lamp-burning"
    }
})

-- Ensure light renderer search radius is increased
local limit = 25
local utility_constants = data.raw["utility-constants"]

if utility_constants and utility_constants.default and utility_constants.default.light_renderer_search_distance_limit and utility_constants.default.light_renderer_search_distance_limit < limit then
    utility_constants.default.light_renderer_search_distance_limit = limit
end

-- Check if AAI mod is installed
if mods["aai-industry"] then
    -- Define aai-production category if AAI is installed
    if not data.raw["recipe-category"]["aai-production"] then
        data:extend({
            {
                type = "recipe-category",
                name = "aai-production",
            }
        })
    end

    -- Include AAI support
    require("prototypes.mods.aai_support")

    -- Update AAI machine to support the aai-production and basic-crafting categories
    if data.raw["assembling-machine"]["aai-industrial-assembler"] then
        -- Ensure "aai-production" is added if it doesn't already exist
        local categories = data.raw["assembling-machine"]["aai-industrial-assembler"].crafting_categories
        if not table.contains(categories, "aai-production") then
            table.insert(categories, "aai-production")
        end

        -- Ensure "basic-crafting" is added if it doesn't already exist
        if not table.contains(categories, "basic-crafting") then
            table.insert(categories, "basic-crafting")
        end
    end
end
