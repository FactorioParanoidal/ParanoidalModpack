-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.revamp.items) then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "revamp",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediates = {
    ["brine"] = {type = "fluid", subgroup = "fluids"},
    ["ammoniated-brine"] = {type = "fluid", subgroup = "fluids"},
    ["heat-shield-tile"] = {type = "item"},
}

-- Items and recipes shared with other mods within Bob's suite
if not mods["bobplates"] then
    intermediates["solid-fuel-from-sour-gas"] = {type = "recipe", group = "plates", subgroup = "recipes"}
end

reskins.lib.create_icons_from_list(intermediates, inputs)

local composite_recipes = {
    ["ammonium-chloride-recycling"] = {["ammonium-chloride"] = {}, ["ammonia"] = {type = "fluid", scale = 0.375, shift = {-10, 11}}, ["calcium-chloride"] = {scale = 0.375, shift = {10, 11}}},
}

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end