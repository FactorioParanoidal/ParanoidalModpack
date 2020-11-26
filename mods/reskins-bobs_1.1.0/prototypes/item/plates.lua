-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobplates"] then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "plates",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediaries
    ----------------------------------------------------------------------------------------------------
    -- Plates
    ["aluminium-plate"] = {subgroup = "plates"},
    ["brass-alloy"] = {subgroup = "plates"},
    ["bronze-alloy"] = {subgroup = "plates"},
    ["cobalt-plate"] = {subgroup = "plates"},
    ["cobalt-steel-alloy"] = {subgroup = "plates"},
    ["copper-tungsten-alloy"] = {subgroup = "plates"},
    ["gold-plate"] = {mod = "lib", group = "shared", subgroup = "items"}, -- Shared with Angels
    ["gunmetal-alloy"] = {subgroup = "plates"},
    ["invar-alloy"] = {subgroup = "plates"},
    ["lead-plate"] = {subgroup = "plates"},
    ["lithium"] = {subgroup = "plates"},
    ["nickel-plate"] = {subgroup = "plates"},
    ["nitinol-alloy"] = {subgroup = "plates"},
    -- ["silicon-plate"] = {subgroup = "plates"},
    ["silver-plate"] = {subgroup = "plates"},
    ["solder-alloy"] = {subgroup = "plates"}, -- Shared with Bob's Electronics
    ["tin-plate"] = {subgroup = "plates"},
    ["titanium-plate"] = {subgroup = "plates"},
    ["tungsten-carbide"] = {subgroup = "plates"},
    ["tungsten-plate"] = {subgroup = "plates"},
    ["zinc-plate"] = {subgroup = "plates"},
    ["alien-orange-alloy"] = {subgroup = "plates"},
    ["alien-blue-alloy"] = {subgroup = "plates"},

    -- Bearings
    ["ceramic-bearing"] = {subgroup = "bearings"},
    ["cobalt-steel-bearing"] = {subgroup = "bearings"},
    ["nitinol-bearing"] = {subgroup = "bearings"},
    ["steel-bearing"] = {subgroup = "bearings"},
    ["titanium-bearing"] = {subgroup = "bearings"},

    -- Bearing Balls
    ["ceramic-bearing-ball"] = {subgroup = "bearing-balls"},
    ["cobalt-steel-bearing-ball"] = {subgroup = "bearing-balls"},
    ["nitinol-bearing-ball"] = {subgroup = "bearing-balls"},
    ["steel-bearing-ball"] = {subgroup = "bearing-balls"},
    ["titanium-bearing-ball"] = {subgroup = "bearing-balls"},

    -- Gear Wheels
    ["brass-gear-wheel"] = {subgroup = "gears"},
    ["cobalt-steel-gear-wheel"] = {subgroup = "gears"},
    ["nitinol-gear-wheel"] = {subgroup = "gears"},
    ["steel-gear-wheel"] = {subgroup = "gears"},
    ["titanium-gear-wheel"] = {subgroup = "gears"},
    ["tungsten-gear-wheel"] = {subgroup = "gears"},

    -- Nuclear
    ["plutonium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["thorium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["thorium-plutonium-fuel-cell"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["deuterium-fuel-cell"] = {subgroup = "nuclear", image = "deuterium-fuel-cell-pink", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["deuterium-fuel-cell-2"] = {subgroup = "nuclear", image = "deuterium-fuel-cell-2-pink", make_icon_pictures = true, icon_picture_extras = {reskins.lib.lit_icon_pictures_layer("lib", "fuel-cell")}},
    ["used-up-thorium-fuel-cell"] = {subgroup = "nuclear"},
    ["used-up-deuterium-fuel-cell"] = {subgroup = "nuclear", image = "used-up-deuterium-fuel-cell-pink"},
    ["plutonium-239"] = {subgroup = "nuclear", make_icon_pictures = true, icon_picture_extras = {{
        draw_as_light = true,
        blend_mode = "additive",
        size = 64,
        filename = reskins.bobs.directory.."/graphics/icons/plates/nuclear/plutonium-239.png",
        scale = 0.25,
        tint = {r = 0.3, g = 0.3, b = 0.3, a = 0.3},
        mipmap_count = 4
    }}},
    ["thorium-232"] = {subgroup = "nuclear"},

    -- Fluids
    ["liquid-fuel"] = {type = "fluid", subgroup = "fluids"},
    ["ferric-chloride-solution"] = {type = "fluid", subgroup = "fluids"}, -- Shared with Bob's Electronics
    ["lithia-water"] = {type = "fluid", subgroup = "fluids", defer_to_data_updates = true}, -- Shared with Bob's Ores, Angels
    ["alien-acid"] = {type = "fluid", subgroup = "fluids"},
    ["alien-explosive"] = {type = "fluid", subgroup = "fluids"},
    ["alien-fire"] = {type = "fluid", subgroup = "fluids"},
    ["alien-poison"] = {type = "fluid", subgroup = "fluids"},

    -- Miscellaneous Items
    ["glass"] = {mod = "lib", group = "shared", subgroup = "items"},
    ["carbon"] = {subgroup = "items"},
    ["rubber"] = {mod = "lib", group = "shared", subgroup = "items"}, -- Shared with Bob's Electronics, Angels
    ["resin"] = {subgroup = "items"}, -- Shared with Bob's Electronics
    ["enriched-fuel"] = {subgroup = "items"},

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Plates
    ["cobalt-oxide-from-copper"] = {type = "recipe", subgroup = "recipes"},
    ["silver-from-lead"] = {type = "recipe", subgroup = "recipes"},

    -- Nuclear
    ["thorium-processing"] = {type = "recipe", subgroup = "recipes"},
    ["thorium-fuel-reprocessing"] = {type = "recipe", subgroup = "recipes"},
    ["deuterium-fuel-reprocessing"] = {type = "recipe", subgroup = "recipes", image = "deuterium-fuel-reprocessing-pink"},
    ["bobingabout-enrichment-process"] = {type = "recipe", subgroup = "recipes"},

    -- Solid Fuels
    ["solid-fuel-from-hydrogen"] = {type = "recipe", subgroup = "recipes"},
    ["solid-fuel-from-sour-gas"] = {type = "recipe", subgroup = "recipes"}, -- Shared with Bob's Revamp
    ["enriched-fuel-from-hydrazine"] = {type = "recipe", subgroup = "recipes"},
    ["enriched-fuel-from-liquid-fuel"] = {type = "recipe", subgroup = "recipes"},

    -- Chemicals and Fluids
    -- ["sulfuric-nitric-acid"] = {type = "recipe", subgroup = "recipes"},
    -- ["pure-water"] = {type = "recipe", subgroup = "recipes"},
    -- ["pure-water-from-lithia"] = {type = "recipe", subgroup = "recipes"},
    ["coal-cracking"] = {type = "recipe", subgroup = "recipes"}, -- Shared with Bob's Electronics
    ["petroleum-gas-cracking"] = {type = "recipe", subgroup = "recipes"},

    -- Wood
    ["bob-resin-wood"] = {type = "recipe", subgroup = "recipes"}, -- Shared with Bob's Electronics
    ["bob-resin-oil"] = {type = "recipe", subgroup = "recipes"}, -- Shared with Bob's Electronics
    ["synthetic-wood"] = {type = "recipe", subgroup = "recipes"}, -- Shared with Bob's Electronics
}

-- Handle deuterium color
if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
    intermediaries["deuterium-fuel-cell"].image = "deuterium-fuel-cell-blue"
    intermediaries["deuterium-fuel-cell-2"].image = "deuterium-fuel-cell-2-blue"
    intermediaries["used-up-deuterium-fuel-cell"].image = "used-up-deuterium-fuel-cell-blue"
end

-- Handle nuclear update
if reskins.lib.setting("bobmods-plates-nuclearupdate") == true then
    intermediaries["nuclear-fuel-reprocessing"] = {type = "recipe", subgroup = "recipes", defer_to_data_updates = true}

    -- Handle deuterium's default process color
    if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
        intermediaries["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-blue"
    end
else
    intermediaries["thorium-fuel-reprocessing"].image = "thorium-fuel-reprocessing-alternate"

    -- Handle deuterium's alternate process color
    if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
        intermediaries["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-alternate-blue"
    else
        intermediaries["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-alternate-pink"
    end

end

reskins.lib.create_icons_from_list(intermediaries, inputs)

-- One-off fixes
if data.raw.item["nickel-plate"] then
    reskins.lib.clear_icon_specification("bob-nickel-plate", "recipe")
end