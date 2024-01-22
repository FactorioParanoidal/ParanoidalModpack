-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.items) then return end

-- Setup inputs and constants
local inputs = {
    mod = "angels",
    group = "refining",
    make_icon_pictures = false,
    flat_icon = true,
}

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

-- TODO: https://github.com/kirazy/reskins-angels/issues/16 Improve handling of refining->smelting->refining icon processing

local intermediates = {}

reskins.lib.create_icons_from_list(intermediates, inputs)

local function check_for_preferred_item(primary, secondary)
    if data.raw.item[primary] then return primary else return secondary end
end

local composite_recipes = {
    -- Lead plates
    ["angelsore5-crushed-smelting"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["angels-ore5-crushed"] = {scale = scale, shift = shift}}, -- Crushed rubyte

    -- Tin plates
    ["angelsore6-crushed-smelting"] = {[check_for_preferred_item("tin-plate", "angels-plate-tin")] = {}, ["angels-ore6-crushed"] = {scale = scale, shift = shift}}, -- Crushed bobmonium
}

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end