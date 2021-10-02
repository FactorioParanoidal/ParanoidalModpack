-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Adjust mud water fluid colors
local fluids = {
    ["water-viscous-mud"] = util.color("6a492c"),
    ["water-heavy-mud"] = util.color("554c42"),
    ["water-concentrated-mud"] = util.color("404f58"),
    ["water-light-mud"] = util.color("2a516d"),
    ["water-thin-mud"] = util.color("155483")
}

-- Revise fluid tints
for name, tint in pairs(fluids) do
    local fluid = data.raw.fluid[name]
    if fluid then
        fluid.base_color = tint
        fluid.flow_color = {0.7, 0.7, 0.7}
    end
end

-- Setup clarifier recipes
for _, recipe_data in pairs(data.raw.recipe) do
    if recipe_data.category == "angels-water-void" then
        local ingredient = data.raw.fluid[(recipe_data.ingredients and recipe_data.ingredients[1]) and recipe_data.ingredients[1].name]

        if ingredient then
            recipe_data.crafting_machine_tint = {primary = ingredient.base_color}
        end
    end
end