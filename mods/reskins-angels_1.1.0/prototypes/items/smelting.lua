-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Setup inputs and constants
local inputs = {
    mod = "angels",
    group = "smelting",
    make_icon_pictures = false,
    flat_icon = true,
}

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

-- Check to see if reskinning needs to be done.
if not mods["angelssmelting"] then
    -- Handle the few composite recipes that fall through the cracks
    local composite_recipes = {
        -- Lead
        ["angelsore5-crushed-smelting"] = {["lead-plate"] = {}, ["angels-ore5-crushed"] = {scale = scale, shift = shift}}, -- Crushed rubyte

        -- Tin
        ["angelsore6-crushed-smelting"] = {["tin-plate"] = {}, ["angels-ore6-crushed"] = {scale = scale, shift = shift}}, -- Crushed bobmonium
    }

    for name, sources in pairs(composite_recipes) do
        reskins.lib.composite_existing_icons(name, "recipe", sources)
    end

    return
end

local intermediaries = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediaries
    ----------------------------------------------------------------------------------------------------
    -- Vanilla Plates
    ["copper-plate"] = {icon_filename = "__base__/graphics/icons/copper-plate.png", icon_size = 64, icon_mipmaps = 4},
    ["iron-plate"] = {subgroup = "plates", image = "angels-plate-iron"},
    ["steel-plate"] = {icon_filename = "__base__/graphics/icons/steel-plate.png", icon_size = 64, icon_mipmaps = 4},

    -- Pure Angels Plates
    ["angels-plate-aluminium"] = {subgroup = "plates"},
    ["angels-plate-chrome"] = {subgroup = "plates"},
    ["angels-plate-cobalt"] = {subgroup = "plates"},
    ["angels-plate-glass"] = {mod = "lib", group = "shared", subgroup = "items", image = "glass"},
    ["angels-plate-gold"] = {mod = "lib", group = "shared", subgroup = "items", image = "gold-plate"},
    ["angels-plate-hot-iron"] = {subgroup = "plates"}, --[[make_icon_pictures = true, icon_picture_extras = {{
        filename = reskins.angels.directory.."/graphics/icons/smelting/plates/angels-plate-hot-iron-light.png",
        blend_mode = "additive-soft",
        draw_as_light = true,
        size = 64,
        mipmap_count = 4,
        scale = 0.25,
    }}},]]--
    ["angels-plate-iron"] = {subgroup = "plates"},
    ["angels-plate-lead"] = {subgroup = "plates"},
    ["angels-plate-manganese"] = {subgroup = "plates"},
    ["angels-plate-nickel"] = {subgroup = "plates"},
    ["angels-plate-platinum"] = {subgroup = "plates"},
    ["angels-plate-silver"] = {subgroup = "plates"},
    ["angels-plate-steel"] = {icon_filename = "__base__/graphics/icons/steel-plate.png", icon_size = 64, icon_mipmaps = 4},
    ["angels-plate-tin"] = {subgroup = "plates"},
    ["angels-plate-titanium"] = {subgroup = "plates"},
    ["angels-plate-tungsten"] = {subgroup = "plates"},
    ["angels-plate-zinc"] = {subgroup = "plates"},

    -- Bob's Plates
    ["aluminium-plate"] = {subgroup = "plates", image = "angels-plate-aluminium"},
    ["bronze-alloy"] = {subgroup = "plates"},
    ["brass-alloy"] = {subgroup = "plates"},
    ["cobalt-plate"] = {subgroup = "plates", image = "angels-plate-cobalt"},
    ["cobalt-steel-alloy"] = {subgroup = "plates"},
    ["glass"] = {mod = "lib", group = "shared", subgroup = "items"}, -- Shared with Bobs
    ["gold-plate"] = {mod = "lib", group = "shared", subgroup = "items"}, -- Shared with Bobs
    ["gunmetal-alloy"] = {subgroup = "plates"},
    ["invar-alloy"] = {subgroup = "plates"},
    ["lead-plate"] = {subgroup = "plates", image = "angels-plate-lead"},
    ["nickel-plate"] = {subgroup = "plates", image = "angels-plate-nickel"},
    ["nitinol-alloy"] = {subgroup = "plates"},
    ["silver-plate"] = {subgroup = "plates", image = "angels-plate-silver"},
    ["tin-plate"] = {subgroup = "plates", image = "angels-plate-tin"},
    ["titanium-plate"] = {subgroup = "plates", image = "angels-plate-titanium"},
    ["tungsten-plate"] = {subgroup = "plates", image = "angels-plate-tungsten"},
    ["zinc-plate"] = {subgroup = "plates", image = "angels-plate-zinc"},

    -- Pure Angels Wires
    ["angels-wire-gold"] = {mod = "lib", group = "shared", subgroup = "items", image = "gilded-copper-cable"},
    ["angels-wire-platinum"] = {subgroup = "intermediaries"},
    ["angels-wire-silver"] = {subgroup = "intermediaries"},
    ["angels-wire-tin"] = {subgroup = "intermediaries"},

    -- Wires
    ["copper-cable"] = {icon_filename = "__base__/graphics/icons/copper-cable.png", icon_size = 64, icon_mipmaps = 4},
    ["gilded-copper-cable"] = {mod = "lib", group = "shared", subgroup = "items"},
    ["tinned-copper-cable"] = {subgroup = "intermediaries", image = "angels-wire-tin"},

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Plates
    ["angels-plate-glass-1"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(1, inputs.group)}, -- "1"
    ["angels-plate-glass-2"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(2, inputs.group)}, -- "2"
    ["angels-plate-glass-3"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(3, inputs.group)}, -- "3"

    -- ["angels-bronze-alloy"] = {}, -- Inherit
    -- ["angels-plate-brass"] = {}, -- Inherit
    -- ["angels-plate-gunmetal"] = {}, -- Inherit
}

if mods["reskins-bobs"] then
    intermediaries["tungsten-carbide"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "plates", image = "tungsten-carbide", icon_extras = reskins.angels.num_tier(1, inputs.group)} -- "1"
    intermediaries["tungsten-carbide-2"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "plates", image = "tungsten-carbide", icon_extras = reskins.angels.num_tier(2, inputs.group)} -- "2"
end

-- Check if we're using Angel's material colors
if reskins.lib.setting("reskins-angels-use-angels-material-colors") then
    -- Gears
    intermediaries["cobalt-steel-gear-wheel"] = {subgroup = "gears"}
    intermediaries["nitinol-gear-wheel"] = {subgroup = "gears"}
    intermediaries["titanium-gear-wheel"] = {subgroup = "gears"}
    intermediaries["tungsten-gear-wheel"] = {subgroup = "gears"}

    -- Bearing Balls
    intermediaries["ceramic-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediaries["cobalt-steel-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediaries["nitinol-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediaries["titanium-bearing-ball"] = {subgroup = "bearing-balls"}

    -- Bearings
    intermediaries["ceramic-bearing"] = {subgroup = "bearings"}
    intermediaries["cobalt-steel-bearing"] = {subgroup = "bearings"}
    intermediaries["nitinol-bearing"] = {subgroup = "bearings"}
    intermediaries["titanium-bearing"] = {subgroup = "bearings"}
end

reskins.lib.create_icons_from_list(intermediaries, inputs)

local composite_recipes = {
    ----------------------------------------------------------------------------------------------------
    -- PLATES
    ----------------------------------------------------------------------------------------------------
    -- Aluminium
    ["angels-plate-aluminium"] = {["aluminium-plate"] = {}, ["liquid-molten-aluminium"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten aluminium
    ["angels-roll-aluminium-converting"] = {["aluminium-plate"] = {}, ["angels-roll-aluminium"] = {scale = scale, shift = shift}}, -- Aluminium sheet coil

    -- Chrome
    ["angels-plate-chrome"] = {["angels-plate-chrome"] = {}, ["liquid-molten-chrome"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten chrome
    ["angels-roll-chrome-converting"] = {["angels-plate-chrome"] = {}, ["angels-roll-chrome"] = {scale = scale, shift = shift}}, -- Chrome sheet coil

    -- Cobalt
    ["angels-plate-cobalt"] = {["cobalt-plate"] = {}, ["liquid-molten-cobalt"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten cobalt
    ["angels-roll-cobalt-converting"] = {["cobalt-plate"] = {}, ["angels-roll-cobalt"] = {scale = scale, shift = shift}}, -- Cobalt sheet coil

    -- Copper
    ["angelsore3-crushed-smelting"] = {["copper-plate"] = {}, ["angels-ore3-crushed"] = {scale = scale, shift = shift}}, -- Crushed stiratite
    ["copper-plate"] = {["copper-plate"] = {}, ["copper-ore"] = {scale = scale, shift = shift}}, -- Copper ore
    ["angels-plate-copper"] = {["copper-plate"] = {}, ["liquid-molten-copper"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten copper
    ["angels-roll-copper-converting"] = {["copper-plate"] = {}, ["angels-roll-copper"] = {scale = scale, shift = shift}}, -- Copper sheet coil

    -- Glass
    ["quartz-glass"] = {["glass"] = {}, ["quartz"] = {scale = scale, shift = shift}}, -- Silicon ore

    -- Gold
    ["angels-plate-gold"] = {["gold-plate"] = {}, ["liquid-molten-gold"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten gold
    ["angels-roll-gold-converting"] = {["gold-plate"] = {}, ["angels-roll-gold"] = {scale = scale, shift = shift}}, -- Gold sheet coil

    -- Invar
    ["angels-plate-invar"] = {["invar-alloy"] = {}, ["liquid-molten-invar"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten invar
    ["invar-alloy"] = {["invar-alloy"] = {}, ["nickel-plate"] = {scale = scale, shift = {-6, -10}}, ["iron-plate"] = {scale = scale, shift = shift}}, -- Nickel/Iron plates

    -- Iron
    ["angelsore1-crushed-smelting"] = {["iron-plate"] = {}, ["angels-ore1-crushed"] = {scale = scale, shift = shift}}, -- Crushed saphirite
    ["iron-plate"] = {["iron-plate"] = {}, ["iron-ore"] = {scale = scale, shift = shift}}, -- Iron ore
    ["angels-plate-iron"] = {["iron-plate"] = {}, ["liquid-molten-iron"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten iron
    ["angels-roll-iron-converting"] = {["iron-plate"] = {}, ["angels-roll-iron"] = {scale = scale, shift = shift}}, -- Iron sheet coil

    -- Lead
    ["angelsore5-crushed-smelting"] = {["lead-plate"] = {}, ["angels-ore5-crushed"] = {scale = scale, shift = shift}}, -- Crushed rubyte
    ["lead-plate"] = {["lead-plate"] = {}, ["lead-ore"] = {scale = scale, shift = shift}}, -- Lead ore
    ["angels-plate-lead"] = {["lead-plate"] = {}, ["liquid-molten-lead"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten lead
    ["angels-roll-lead-converting"] = {["lead-plate"] = {}, ["angels-roll-lead"] = {scale = scale, shift = shift}}, -- Lead sheet coil
    ["silver-from-lead"] = {["lead-plate"] = {}, ["silver-ore"] = {scale = scale, shift = shift}},

    -- Manganese
    ["angels-plate-manganese"] = {["angels-plate-manganese"] = {}, ["liquid-molten-manganese"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten manganese
    ["angels-roll-manganese-converting"] = {["angels-plate-manganese"] = {}, ["angels-roll-manganese"] = {scale = scale, shift = shift}}, -- Manganese sheet coil

    -- Nickel
    ["angels-plate-nickel"] = {["nickel-plate"] = {}, ["liquid-molten-nickel"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten nickel
    ["angels-roll-nickel-converting"] = {["nickel-plate"] = {}, ["angels-roll-nickel"] = {scale = scale, shift = shift}}, -- Nickel sheet roll

    -- Nitinol
    ["angels-plate-nitinol"] = {["nitinol-alloy"] = {}, ["liquid-molten-nitinol"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten nitinol

    -- Platinum
    ["angels-plate-platinum"] = {["angels-plate-platinum"] = {}, ["liquid-molten-platinum"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten platinum
    ["angels-roll-platinum-converting"] = {["angels-plate-platinum"] = {}, ["angels-roll-platinum"] = {scale = scale, shift = shift}}, -- Platinum sheet coil

    -- Silver
    ["silver-plate"] = {["silver-plate"] = {}, ["silver-ore"] = {scale = scale, shift = shift}}, -- Silver ore
    ["angels-plate-silver"] = {["silver-plate"] = {}, ["liquid-molten-silver"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten silver
    ["angels-roll-silver-converting"] = {["silver-plate"] = {}, ["angels-roll-silver"] = {scale = scale, shift = shift}}, -- Silver sheet coil

    -- Steel plate
    ["steel-plate"] = {["angels-plate-hot-iron"] = {}, ["iron-plate"] = {scale = scale, shift = shift}}, -- Hot-Iron plate
    ["angels-plate-steel-pre-heating"] = {["steel-plate"] = {}, ["angels-plate-hot-iron"] = {scale = scale, shift = shift}},
    ["angels-plate-steel"] = {["steel-plate"] = {}, ["liquid-molten-steel"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten steel
    ["angels-roll-steel-converting"] = {["steel-plate"] = {}, ["angels-roll-steel"] = {scale = scale, shift = shift}}, -- Steel sheet coil

    -- Tin
    ["angelsore6-crushed-smelting"] = {["tin-plate"] = {}, ["angels-ore6-crushed"] = {scale = scale, shift = shift}}, -- Crushed bobmonium
    ["tin-plate"] = {["tin-plate"] = {}, ["tin-ore"] = {scale = scale, shift = shift}}, -- Tin ore
    ["angels-plate-tin"] = {["tin-plate"] = {}, ["liquid-molten-tin"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten tin
    ["angels-roll-tin-converting"] = {["tin-plate"] = {}, ["angels-roll-tin"] = {scale = scale, shift = shift}}, -- Tin sheet coil

    -- Titanium
    ["angels-plate-titanium"] = {["titanium-plate"] = {}, ["liquid-molten-titanium"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten titanium
    ["angels-roll-titanium-converting"] = {["titanium-plate"] = {}, ["angels-roll-titanium"] = {scale = scale, shift = shift}}, -- Titanium sheet coil

    -- Zinc
    ["angels-plate-zinc"] = {["zinc-plate"] = {}, ["liquid-molten-zinc"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten Zinc
    ["angels-roll-zinc-converting"] = {["zinc-plate"] = {}, ["angels-roll-zinc"] = {scale = scale, shift = shift}}, -- Zinc sheet coil

    ----------------------------------------------------------------------------------------------------
    -- Intermediaries
    ----------------------------------------------------------------------------------------------------
    -- Copper cable
    ["copper-cable"] = {["copper-cable"] = {}, ["copper-plate"] = {scale = scale, shift = shift}}, -- Copper plate
    ["angels-wire-coil-copper-converting"] = {["copper-cable"] = {}, ["angels-wire-coil-copper"] = {scale = scale, shift = shift}}, -- Copper wire coil

    -- Gold cable
    ["angels-wire-gold"] = {["gilded-copper-cable"] = {}, ["gold-plate"] = {scale = scale, shift = shift}}, -- Gold plate
    ["angels-wire-coil-gold-converting"] = {["gilded-copper-cable"] = {}, ["angels-wire-coil-gold"] = {scale = scale, shift = shift}}, -- Gold wire coil

    -- Silver cable
    ["basic-silvered-copper-wire"] = {["angels-wire-silver"] = {}, ["silver-plate"] = {scale = scale, shift = shift}}, -- Silver plate
    ["angels-wire-coil-silver-converting"] = {["angels-wire-silver"] = {}, ["angels-wire-coil-silver"] = {scale = scale, shift = shift}}, -- Silver wire coil

    -- Platinum cable
    ["basic-platinated-copper-wire"] = {["angels-wire-platinum"] = {}, ["angels-plate-platinum"] = {scale = scale, shift = shift}}, -- Platinum plate
    ["angels-wire-coil-platinum-converting"] = {["angels-wire-platinum"] = {}, ["angels-wire-coil-platinum"] = {scale = scale, shift = shift}}, -- Platinum wire coil

    -- Tin cable
    ["basic-tinned-copper-wire"] = {["tinned-copper-cable"] = {}, ["tin-plate"] = {scale = scale, shift = shift}}, -- Tin plate
    ["angels-wire-coil-tin-converting"] = {["tinned-copper-cable"] = {}, ["angels-wire-coil-tin"] = {scale = scale, shift = shift}}, -- Tin wire coil
}

-- Handle the Pure Angels case
if not mods["bobplates"] then
    -- Aluminum
    composite_recipes["angels-plate-aluminium"] = {["angels-plate-aluminium"] = {}, ["liquid-molten-aluminium"] = {type = "fluid", scale = scale, shift = shift}} -- Molten aluminium
    composite_recipes["angels-roll-aluminium-converting"] = {["angels-plate-aluminium"] = {}, ["angels-roll-aluminium"] = {scale = scale, shift = shift}} -- Aluminium sheet coil

    -- Cobalt
    composite_recipes["angels-plate-cobalt"] = {["angels-plate-cobalt"] = {}, ["liquid-molten-cobalt"] = {type = "fluid", scale = scale, shift = shift}} -- Molten cobalt
    composite_recipes["angels-roll-cobalt-converting"] = {["angels-plate-cobalt"] = {}, ["angels-roll-cobalt"] = {scale = scale, shift = shift}} -- Cobalt sheet coil

    -- Lead
    composite_recipes["angelsore5-crushed-smelting"] = {["angels-plate-lead"] = {}, ["angels-ore5-crushed"] = {scale = scale, shift = shift}} -- Crushed rubyte
    composite_recipes["angels-plate-lead"] = {["angels-plate-lead"] = {}, ["liquid-molten-lead"] = {type = "fluid", scale = scale, shift = shift}} -- Molten lead
    composite_recipes["angels-roll-lead-converting"] = {["angels-plate-lead"] = {}, ["angels-roll-lead"] = {scale = scale, shift = shift}} -- Lead sheet coil

    -- Gold
    composite_recipes["angels-plate-gold"] = {["angels-plate-gold"] = {}, ["liquid-molten-gold"] = {type = "fluid", scale = scale, shift = shift}} -- Molten gold
    composite_recipes["angels-roll-gold-converting"] = {["angels-plate-gold"] = {}, ["angels-roll-gold"] = {scale = scale, shift = shift}} -- Gold sheet coil
    composite_recipes["angels-wire-coil-gold-converting"] = {["angels-wire-gold"] = {}, ["angels-wire-coil-gold"] = {scale = scale, shift = shift}} -- Gold wire coil
    composite_recipes["angels-wire-gold"] = {["angels-wire-gold"] = {}, ["angels-plate-gold"] = {scale = scale, shift = shift}} -- Gold plate

    -- Nickel
    composite_recipes["angels-plate-nickel"] = {["angels-plate-nickel"] = {}, ["liquid-molten-nickel"] = {type = "fluid", scale = scale, shift = shift}} -- Molten nickel
    composite_recipes["angels-roll-nickel-converting"] = {["angels-plate-nickel"] = {}, ["angels-roll-nickel"] = {scale = scale, shift = shift}} -- Nickel sheet roll

    -- Silver
    composite_recipes["angels-plate-silver"] = {["angels-plate-silver"] = {}, ["liquid-molten-silver"] = {type = "fluid", scale = scale, shift = shift}} -- Molten silver
    composite_recipes["angels-roll-silver-converting"] = {["angels-plate-silver"] = {}, ["angels-roll-silver"] = {scale = scale, shift = shift}} -- Silver sheet coil
    composite_recipes["basic-silvered-copper-wire"] = {["angels-wire-silver"] = {}, ["angels-plate-silver"] = {scale = scale, shift = shift}} -- Silver plate

    -- Tin
    composite_recipes["angelsore6-crushed-smelting"] = {["angels-plate-tin"] = {}, ["angels-ore6-crushed"] = {scale = scale, shift = shift}} -- Crushed bobmonium
    composite_recipes["angels-plate-tin"] = {["angels-plate-tin"] = {}, ["liquid-molten-tin"] = {type = "fluid", scale = scale, shift = shift}} -- Molten tin
    composite_recipes["angels-roll-tin-converting"] = {["angels-plate-tin"] = {}, ["angels-roll-tin"] = {scale = scale, shift = shift}} -- Tin sheet coil
    composite_recipes["basic-tinned-copper-wire"] = {["angels-wire-tin"] = {}, ["angels-plate-tin"] = {scale = scale, shift = shift}} -- Tin plate
    composite_recipes["angels-wire-coil-tin-converting"] = {["angels-wire-tin"] = {}, ["angels-wire-coil-tin"] = {scale = scale, shift = shift}} -- Tin wire coil

    -- Titanium
    composite_recipes["angels-plate-titanium"] = {["angels-plate-titanium"] = {}, ["liquid-molten-titanium"] = {type = "fluid", scale = scale, shift = shift}} -- Molten titanium
    composite_recipes["angels-roll-titanium-converting"] = {["angels-plate-titanium"] = {}, ["angels-roll-titanium"] = {scale = scale, shift = shift}} -- Titanium sheet coil

    -- Zinc
    composite_recipes["angels-plate-zinc"] = {["angels-plate-zinc"] = {}, ["liquid-molten-zinc"] = {type = "fluid", scale = scale, shift = shift}} -- Molten Zinc
    composite_recipes["angels-roll-zinc-converting"] = {["angels-plate-zinc"] = {}, ["angels-roll-zinc"] = {scale = scale, shift = shift}} -- Zinc sheet coil
end

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end