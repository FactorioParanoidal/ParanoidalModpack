-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Setup ore flotation cell recipes
for _, recipe_data in pairs(data.raw.recipe) do
    if recipe_data.category == "ore-refining-t2" then
        local primary, secondary = util.color("0"), util.color("0")

        -- Retrieve the ingredients
        local ingredients = recipe_data.normal and recipe_data.normal.ingredients or recipe_data.ingredients or recipe_data.expensive and recipe_data.expensive.ingredients

        -- Extract the ingredient fluid color
        for _, ingredient in pairs(ingredients) do
            if ingredient.type == "fluid" then
                local fluid = data.raw.fluid[ingredient.name]
                primary = fluid and fluid.base_color

                goto next
            end
        end

        ::next::

        -- Retrieve the results
        local results = recipe_data.normal and recipe_data.normal.results or recipe_data.results or recipe_data.expensive and recipe_data.expensive.results

        -- Extract the result fluid color
        for _, result in pairs(results) do
            if result.type == "fluid" then
                local fluid = data.raw.fluid[result.name]
                secondary = fluid and fluid.base_color

                goto finish
            end
        end

        ::finish::

        -- Assign colors
        recipe_data.crafting_machine_tint = {primary = primary, secondary = secondary}
    end
end