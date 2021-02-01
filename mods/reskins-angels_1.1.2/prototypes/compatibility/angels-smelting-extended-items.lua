-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angels-smelting-extended"] then return end

----------------------------------------------------------------------------------------------------
-- ITEMS AND RECIPES
----------------------------------------------------------------------------------------------------
-- Fix ASE-sand-die and ASE-metal-die
data.raw.item["ASE-sand-die"].icons = {{
    icon = "__angelssmelting__/graphics/icons/expendable-mold.png",
    icon_size = 32,
    icon_mipmaps = 1,
}}

data.raw.item["ASE-metal-die"].icons = {{
    icon = "__angelssmelting__/graphics/icons/non-expendable-mold.png",
    icon_size = 32,
    icon_mipmaps = 1,
}}

local function composite_recipe_builder(recipe_table, recipe_name, composites)
    -- Build the composite recipe entry
    local configuration = {
        [composites[1]] = {},
        [composites[2]] = {scale = reskins.angels.constants.recipe_corner_scale, shift = {-10, -10}},
    }

    if composites[3] then
        configuration[composites[3]] = {scale = reskins.angels.constants.recipe_corner_scale, shift = {10, -10}}
    end

    -- Check for liquids and set type parameter
    for _, name in pairs(composites) do
        if string.find(name, "liquid") then
            configuration[name].type = "fluid"
        end
    end

    -- Assign to the recipe table
    recipe_table[recipe_name] = configuration
end

local composite_recipes = {}

local recipe_list = {
    -- Plate composite recipes
    ["angels-plate-tungsten"] = {"tungsten-plate", "casting-powder-tungsten"},
    ["angels-roll-tungsten-converting"] = {"tungsten-plate", "angels-roll-tungsten"},
    ["angels-roll-invar-converting"] = {"invar-alloy", "angels-roll-invar"},
    ["angels-roll-nitinol-converting"] = {"nitinol-alloy", "angels-roll-nitinol"},
    ["angels-plate-cobalt-steel"] = {"cobalt-steel-alloy", "liquid-molten-cobalt-steel"},
    ["angels-roll-cobalt-steel-converting"] = {"cobalt-steel-alloy", "angels-roll-cobalt-steel"},
    ["angels-plate-cobalt-steel-1"] = {"cobalt-steel-alloy", "liquid-molten-iron", "liquid-molten-cobalt"},
    ["angels-plate-cobalt-steel-2"] = {"cobalt-steel-alloy", "liquid-molten-steel", "liquid-molten-cobalt"},
    ["angels-plate-brass"] = {"brass-alloy", "liquid-molten-brass"},
    ["angels-roll-brass-converting"] = {"brass-alloy", "angels-roll-brass"},
    ["angels-plate-bronze"] = {"bronze-alloy", "liquid-molten-bronze"},
    ["angels-roll-bronze-converting"] = {"bronze-alloy", "angels-roll-bronze"},
    ["angels-plate-gunmetal"] = {"gunmetal-alloy", "liquid-molten-gunmetal"},
    ["angels-roll-gunmetal-converting"] = {"gunmetal-alloy", "angels-roll-gunmetal"},
}

-- Build composite table entries for the assorted recipes
for name, composites in pairs(recipe_list) do
    composite_recipe_builder(composite_recipes, name, composites)
end

-- Setup gears and related recipes
local gear_materials = {
    "iron",
    "titanium",
    "steel",
    "tungsten",
    "nitinol",
    "cobalt-steel",
    "brass",
}

-- Build composite table entries for the gear materials
for _, material in pairs(gear_materials) do
    if material == "tungsten" then
        composite_recipe_builder(composite_recipes, "angels-"..material.."-gear-wheel-casting", {material.."-gear-wheel", "casting-powder-"..material})
    else
        composite_recipe_builder(composite_recipes, "angels-"..material.."-gear-wheel-casting", {material.."-gear-wheel", "liquid-molten-"..material})
    end

    composite_recipe_builder(composite_recipes, "ASE-"..material.."-gear-casting-expendable", {material.."-gear-wheel", "ASE-sand-die"})
    composite_recipe_builder(composite_recipes, "ASE-"..material.."-gear-casting-advanced", {material.."-gear-wheel", "ASE-metal-die"})
end

-- Build the composite icons
for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end

-- Fix Mad Clown's brass casting recipe sorting
if data.raw["item-subgroup"]["angels-brass-casting"] and data.raw.recipe["angels-brass-smelting-4"] then
    data.raw.recipe["angels-brass-smelting-4"].order = "d"
    data.raw.recipe["angels-brass-smelting-4"].subgroup = "angels-brass-casting"
end