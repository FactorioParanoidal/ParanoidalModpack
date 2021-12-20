-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.industries.items) then return end

-- Setup inputs and constants
local inputs = {
    mod = "angels",
    group = "industries",
    make_icon_pictures = false,
    flat_icon = true,
}

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

-- Check to see if reskinning needs to be done.
if not mods["angelsindustries"] then return end

local function make_item_light_layer(name)
    return
    {
        {
            draw_as_light = true,
            blend_mode = "additive",
            size = 64,
            filename = reskins.angels.directory.."/graphics/icons/industries/nuclear/"..name..".png",
            scale = 0.25,
            tint = {r = 0.3, g = 0.3, b = 0.3, a = 0.3},
            mipmap_count = 4
        }
    }
end

local intermediates = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediates
    ----------------------------------------------------------------------------------------------------
    -- Nuclear fuel cells
    ["angels-deuterium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["AMOX-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["angels-thorium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["angels-uranium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["uranium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},

    -- Nuclear fuel
    ["angels-nuclear-fuel"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel")}},
    ["angels-nuclear-fuel-2"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel")}},


    -- Nuclear isotopes
    ["americium-241"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("americium-241")},
    ["curium-245"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("curium-245")},
    ["neptunium-240"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("neptunium-240")},
    ["plutonium-240"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("plutonium-240")},
    ["thorium-232"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("thorium-232")},
    ["uranium-234"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("uranium-234")},
    ["uranium-235"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = make_item_light_layer("uranium-235")},
}

reskins.lib.create_icons_from_list(intermediates, inputs)