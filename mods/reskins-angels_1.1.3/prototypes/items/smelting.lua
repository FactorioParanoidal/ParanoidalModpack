-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.items) then return end

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

local intermediates = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediates
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
    ["angels-wire-platinum"] = {subgroup = "intermediates"},
    ["angels-wire-silver"] = {subgroup = "intermediates"},
    ["angels-wire-tin"] = {subgroup = "intermediates"},

    -- Wires
    ["copper-cable"] = {icon_filename = "__base__/graphics/icons/copper-cable.png", icon_size = 64, icon_mipmaps = 4},
    ["gilded-copper-cable"] = {mod = "lib", group = "shared", subgroup = "items"},
    ["tinned-copper-cable"] = {subgroup = "intermediates", image = "angels-wire-tin"},

    -- Miscellaneous
    ["solder"] = {mod = "lib", group = "shared", subgroup = "items"},
    ["angels-solder"] = {mod = "lib", group = "shared", subgroup = "items", image = "solder"},
    ["angels-silicon-wafer"] = {mod = "lib", group = "shared", subgroup = "items", image = "silicon-wafer"},
    ["solid-lime"] = {subgroup = "intermediates"},
    ["angels-quartz-crucible"] = {subgroup = "intermediates"},

    -- Ingots
    ["ingot-aluminium"] = {subgroup = "ingots/aluminium"},
    ["ingot-chrome"] = {subgroup = "ingots/chrome"},
    ["ingot-cobalt"] = {subgroup = "ingots/cobalt"},
    ["ingot-copper"] = {subgroup = "ingots/copper"},
    ["ingot-gold"] = {subgroup = "ingots/gold"},
    ["ingot-iron"] = {subgroup = "ingots/iron"},
    ["ingot-steel"] = {subgroup = "ingots/steel"},
    ["ingot-lead"] = {subgroup = "ingots/lead"},
    ["ingot-manganese"] = {subgroup = "ingots/manganese"},
    ["ingot-nickel"] = {subgroup = "ingots/nickel"},
    ["ingot-platinum"] = {subgroup = "ingots/platinum"},
    ["ingot-silicon"] = {subgroup = "ingots/silicon"},
    ["ingot-silver"] = {subgroup = "ingots/silver"},
    ["ingot-tin"] = {subgroup = "ingots/tin"},
    ["ingot-titanium"] = {subgroup = "ingots/titanium"},
    ["ingot-zinc"] = {subgroup = "ingots/zinc"},

    -- Pellets
    ["pellet-aluminium"] = {subgroup = "pellets"},
    ["pellet-chrome"] = {subgroup = "pellets"},
    ["pellet-cobalt"] = {subgroup = "pellets"},
    ["pellet-copper"] = {subgroup = "pellets"},
    ["pellet-gold"] = {subgroup = "pellets"},
    ["pellet-iron"] = {subgroup = "pellets"},
    ["pellet-lead"] = {subgroup = "pellets"},
    ["pellet-manganese"] = {subgroup = "pellets"},
    ["pellet-nickel"] = {subgroup = "pellets"},
    ["pellet-platinum"] = {subgroup = "pellets"},
    ["pellet-silica"] = {subgroup = "pellets"},
    ["pellet-silver"] = {subgroup = "pellets"},
    ["pellet-tin"] = {subgroup = "pellets"},
    ["pellet-titanium"] = {subgroup = "pellets"},
    ["pellet-tungsten"] = {subgroup = "pellets"},
    ["pellet-zinc"] = {subgroup = "pellets"},

    -- Sheet Coils
    ["angels-roll-aluminium"] = {subgroup = "rolls"},
    ["angels-roll-chrome"] = {subgroup = "rolls"},
    ["angels-roll-cobalt"] = {subgroup = "rolls"},
    ["angels-roll-copper"] = {subgroup = "rolls"},
    ["angels-roll-gold"] = {subgroup = "rolls"},
    ["angels-roll-iron"] = {subgroup = "rolls"},
    ["angels-roll-lead"] = {subgroup = "rolls"},
    ["angels-roll-manganese"] = {subgroup = "rolls"},
    ["angels-roll-nickel"] = {subgroup = "rolls"},
    ["angels-roll-platinum"] = {subgroup = "rolls"},
    ["angels-roll-silver"] = {subgroup = "rolls"},
    ["angels-roll-tin"] = {subgroup = "rolls"},
    ["angels-roll-titanium"] = {subgroup = "rolls"},
    ["angels-roll-tungsten"] = {subgroup = "rolls"},
    ["angels-roll-zinc"] = {subgroup = "rolls"},
    ["angels-roll-steel"] = {subgroup = "rolls"},

    -- Sheet Coils from Angel's Extended Smelting and Compression
    ["angels-roll-bronze"] = {subgroup = "rolls"},
    ["angels-roll-invar"] = {subgroup = "rolls"},
    ["angels-roll-nitinol"] = {subgroup = "rolls"},
    ["angels-roll-cobalt-steel"] = {subgroup = "rolls"},
    ["angels-roll-brass"] = {subgroup = "rolls"},
    ["angels-roll-gunmetal"] = {subgroup = "rolls"},

    -- Wire Coils / Glass Fiber
    ["angels-wire-coil-copper"] = {subgroup = "wire-coils"},
    ["angels-wire-coil-gold"] = {subgroup = "wire-coils"},
    ["angels-wire-coil-platinum"] = {subgroup = "wire-coils"},
    ["angels-wire-coil-silver"] = {subgroup = "wire-coils"},
    ["angels-wire-coil-tin"] = {subgroup = "wire-coils"},
    ["angels-coil-glass-fiber"] = {subgroup = "wire-coils"},

    -- Molten Fluids
    ["liquid-molten-aluminium"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-chrome"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-cobalt"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-copper"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-glass"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-gold"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-iron"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-lead"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-manganese"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-nickel"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-platinum"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-silicon"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-silver"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-concrete"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-tin"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-titanium"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-zinc"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-steel"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-solder"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-bronze"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-invar"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-nitinol"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-cobalt-steel"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-brass"] = {type = "fluid", subgroup = "liquid-material"},
    ["liquid-molten-gunmetal"] = {type = "fluid", subgroup = "liquid-material"},

    -- Powders
    ["powder-aluminium"] = {subgroup = "powders/aluminium"},
    ["casting-powder-tungsten"] = {subgroup = "powders/tungsten-mixture", image = "powder-tungsten-mixture"},
    ["powder-chrome"] = {subgroup = "powders/chrome"},
    ["powder-cobalt"] = {subgroup = "powders/cobalt"},
    ["powder-copper"] = {subgroup = "powders/copper"},
    ["powder-gold"] = {subgroup = "powders/gold"},
    ["powder-iron"] = {subgroup = "powders/iron"},
    ["powder-steel"] = {subgroup = "powders/steel"},
    ["powder-lead"] = {subgroup = "powders/lead"},
    ["powder-manganese"] = {subgroup = "powders/manganese"},
    ["powder-nickel"] = {subgroup = "powders/nickel"},
    ["powder-platinum"] = {subgroup = "powders/platinum"},
    ["silicon-powder"] = {subgroup = "powders/silicon", image = "powder-silicon"},
    ["powder-silver"] = {subgroup = "powders/silver"},
    ["powder-tin"] = {subgroup = "powders/tin"},
    ["powder-titanium"] = {subgroup = "powders/titanium"},
    ["powdered-tungsten"] = {subgroup = "powders/tungsten", image = "powder-tungsten"},
    ["powder-zinc"] = {subgroup = "powders/zinc"},

    -- Processed Ores
    ["processed-aluminium"] = {subgroup = "processed-ores"},
    ["processed-chrome"] = {subgroup = "processed-ores"},
    ["processed-cobalt"] = {subgroup = "processed-ores"},
    ["processed-copper"] = {subgroup = "processed-ores"},
    ["processed-gold"] = {subgroup = "processed-ores"},
    ["processed-iron"] = {subgroup = "processed-ores"},
    ["processed-lead"] = {subgroup = "processed-ores"},
    ["processed-manganese"] = {subgroup = "processed-ores"},
    ["processed-nickel"] = {subgroup = "processed-ores"},
    ["processed-platinum"] = {subgroup = "processed-ores"},
    ["processed-silica"] = {subgroup = "processed-ores"},
    ["processed-silver"] = {subgroup = "processed-ores"},
    ["processed-tin"] = {subgroup = "processed-ores"},
    ["processed-titanium"] = {subgroup = "processed-ores"},
    ["processed-tungsten"] = {subgroup = "processed-ores"},
    ["processed-zinc"] = {subgroup = "processed-ores"},

    -- Rods
    -- ["angels-rod-iron"]
    -- ["angels-rod-steel"]

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Plates
    ["angels-plate-glass-1"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(1, inputs.group)}, -- "1"
    ["angels-plate-glass-2"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(2, inputs.group)}, -- "2"
    ["angels-plate-glass-3"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(3, inputs.group)}, -- "3"

    -- Ingots
    -- ["solid-aluminium-oxide-smelting"] = {type = "recipe", subgroup = "ingots", image = "ingot-aluminium", icon_extras = reskins.angels.num_tier(1, inputs.group)},

    ["chrome-ore-smelting"] = {type = "recipe", subgroup = "ingots/chrome", image = "ingot-chrome", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-chrome-smelting"] = {type = "recipe", subgroup = "ingots/chrome", image = "ingot-chrome", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["solid-chrome-oxide-smelting"] = {type = "recipe", subgroup = "ingots/chrome", image = "ingot-chrome", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["cobalt-ore-smelting"] = {type = "recipe", subgroup = "ingots/cobalt", image = "ingot-cobalt", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["solid-cobalt-oxide-smelting"] = {type = "recipe", subgroup = "ingots/cobalt", image = "ingot-cobalt", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["copper-ore-smelting"] = {type = "recipe", subgroup = "ingots/copper", image = "ingot-copper", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-copper-smelting"] = {type = "recipe", subgroup = "ingots/copper", image = "ingot-copper", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["anode-copper-smelting"] = {type = "recipe", subgroup = "ingots/copper", image = "ingot-copper", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["gold-ore-smelting"] = {type = "recipe", subgroup = "ingots/gold", image = "ingot-gold", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["cathode-gold-smelting"] = {type = "recipe", subgroup = "ingots/gold", image = "ingot-gold", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["iron-ore-smelting"] = {type = "recipe", subgroup = "ingots/iron", image = "ingot-iron", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-iron-smelting"] = {type = "recipe", subgroup = "ingots/iron", image = "ingot-iron", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["pellet-iron-smelting"] = {type = "recipe", subgroup = "ingots/iron", image = "ingot-iron", icon_extras = reskins.angels.num_tier(3, inputs.group)},
    ["solid-iron-hydroxide-smelting"] = {type = "recipe", subgroup = "ingots/iron", image = "ingot-iron", icon_extras = reskins.angels.num_tier(4, inputs.group)},

    -- ["ingot-iron-smelting"] = {type = "recipe", subgroup = "ingots/steel", image = "ingot-steel", icon_extras = reskins.angels.num_tier(1, inputs.group)},

    ["lead-ore-smelting"] = {type = "recipe", subgroup = "ingots/lead", image = "ingot-lead", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["solid-lead-oxide-smelting"] = {type = "recipe", subgroup = "ingots/lead", image = "ingot-lead", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["anode-lead-smelting"] = {type = "recipe", subgroup = "ingots/lead", image = "ingot-lead", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["manganese-ore-smelting"] = {type = "recipe", subgroup = "ingots/manganese", image = "ingot-manganese", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["cathode-manganese-smelting"] = {type = "recipe", subgroup = "ingots/manganese", image = "ingot-manganese", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["nickel-ore-smelting"] = {type = "recipe", subgroup = "ingots/nickel", image = "ingot-nickel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["cathode-nickel-smelting"] = {type = "recipe", subgroup = "ingots/nickel", image = "ingot-nickel", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["solid-nickel-carbonyl-smelting"] = {type = "recipe", subgroup = "ingots/nickel", image = "ingot-nickel", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["platinum-ore-smelting"] = {type = "recipe", subgroup = "ingots/platinum", image = "ingot-platinum", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-platinum-smelting"] = {type = "recipe", subgroup = "ingots/platinum", image = "ingot-platinum", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["solid-ammonium-chloroplatinate-smelting"] = {type = "recipe", subgroup = "ingots/platinum", image = "ingot-platinum", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["silicon-ore-smelting"] = {type = "recipe", subgroup = "ingots/silicon", image = "ingot-silicon", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["liquid-trichlorosilane-smelting"] = {type = "recipe", subgroup = "ingots/silicon", image = "ingot-silicon", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["gas-silane-smelting"] = {type = "recipe", subgroup = "ingots/silicon", image = "ingot-silicon", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["silver-ore-smelting"] = {type = "recipe", subgroup = "ingots/silver", image = "ingot-silver", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["solid-silver-nitrate-smelting"] = {type = "recipe", subgroup = "ingots/silver", image = "ingot-silver", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["cathode-silver-smelting"] = {type = "recipe", subgroup = "ingots/silver", image = "ingot-silver", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["tin-ore-smelting"] = {type = "recipe", subgroup = "ingots/tin", image = "ingot-tin", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-tin-smelting"] = {type = "recipe", subgroup = "ingots/tin", image = "ingot-tin", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["pellet-tin-smelting"] = {type = "recipe", subgroup = "ingots/tin", image = "ingot-tin", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["sponge-titanium-smelting"] = {type = "recipe", subgroup = "ingots/titanium", image = "ingot-titanium", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["pellet-titanium-smelting"] = {type = "recipe", subgroup = "ingots/titanium", image = "ingot-titanium", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["zinc-ore-smelting"] = {type = "recipe", subgroup = "ingots/zinc", image = "ingot-zinc", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["processed-zinc-smelting"] = {type = "recipe", subgroup = "ingots/zinc", image = "ingot-zinc", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["cathode-zinc-smelting"] = {type = "recipe", subgroup = "ingots/zinc", image = "ingot-zinc", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    -- Sheet Coils
    ["roll-aluminium-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-aluminium", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-aluminium-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-aluminium", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-chrome-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-chrome", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-chrome-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-chrome", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-cobalt-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-cobalt-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-copper-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-copper", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-copper-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-copper", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-gold-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gold", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-gold-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gold", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-iron-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-iron", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-iron-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-iron", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-lead-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-lead", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-lead-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-lead", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-manganese-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-manganese", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-manganese-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-manganese", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-nickel-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nickel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-nickel-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nickel", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-platinum-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-platinum", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-platinum-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-platinum", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-silver-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-silver", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-silver-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-silver", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-tin-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tin", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-tin-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tin", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-titanium-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-titanium", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-titanium-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-titanium", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["roll-zinc-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-zinc", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["roll-zinc-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-zinc", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-tungsten-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tungsten", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-tungsten-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tungsten", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-steel-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-steel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-steel-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-steel", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-bronze-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-bronze", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-bronze-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-bronze", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-invar-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-invar", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-invar-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-invar", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-nitinol-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nitinol", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-nitinol-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nitinol", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-cobalt-steel-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt-steel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-cobalt-steel-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt-steel", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-brass-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-brass", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-brass-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-brass", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-gunmetal-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gunmetal", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-gunmetal-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gunmetal", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    -- Wire coils
    ["angels-wire-coil-copper-casting"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-copper", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-wire-coil-copper-casting-fast"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-copper", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-wire-coil-gold-casting"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-gold", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-wire-coil-gold-casting-fast"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-gold", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-wire-coil-platinum-casting"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-platinum", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-wire-coil-platinum-casting-fast"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-platinum", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-wire-coil-silver-casting"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-silver", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-wire-coil-silver-casting-fast"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-silver", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-wire-coil-tin-casting"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-tin", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-wire-coil-tin-casting-fast"] = {type = "recipe", subgroup = "wire-coils", image = "angels-wire-coil-tin", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    -- Molten Fluids
    ["molten-aluminium-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["molten-aluminium-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["molten-aluminium-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-aluminium", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["molten-chrome-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-chrome"},

    ["molten-cobalt-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-cobalt"},

    ["molten-copper-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-copper"},

    ["molten-glass-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-glass"},

    ["molten-gold-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-gold"},

    ["molten-iron-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-iron", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["molten-iron-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-iron", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["molten-iron-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-iron", icon_extras = reskins.angels.num_tier(3, inputs.group)},
    ["molten-iron-smelting-4"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-iron", icon_extras = reskins.angels.num_tier(4, inputs.group)},
    ["molten-iron-smelting-5"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-iron", icon_extras = reskins.angels.num_tier(5, inputs.group)},

    ["molten-lead-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-lead"},

    ["molten-manganese-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-manganese"},

    ["molten-nickel-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-nickel"},

    ["molten-platinum-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-platinum"},

    ["molten-silicon-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-silicon"},

    ["molten-silver-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-silver"},

    ["concrete-mixture-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-concrete", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["concrete-mixture-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-concrete", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["molten-tin-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-tin"},

    ["molten-titanium-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-titanium", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["molten-titanium-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-titanium", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["molten-titanium-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-titanium", icon_extras = reskins.angels.num_tier(3, inputs.group)},
    ["molten-titanium-smelting-4"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-titanium", icon_extras = reskins.angels.num_tier(4, inputs.group)},
    ["molten-titanium-smelting-5"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-titanium", icon_extras = reskins.angels.num_tier(5, inputs.group)},

    ["molten-zinc-smelting"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-zinc"},

    ["molten-steel-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-steel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["molten-steel-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-steel", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["molten-steel-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-steel", icon_extras = reskins.angels.num_tier(3, inputs.group)},
    ["molten-steel-smelting-4"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-steel", icon_extras = reskins.angels.num_tier(4, inputs.group)},
    ["molten-steel-smelting-5"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-steel", icon_extras = reskins.angels.num_tier(5, inputs.group)},

    ["angels-solder-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-solder", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-solder-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-solder", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["angels-solder-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-solder", icon_extras = reskins.angels.num_tier(3, inputs.group)},
    ["angels-solder-smelting-4"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-solder", icon_extras = reskins.angels.num_tier(4, inputs.group)},

    ["angels-bronze-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-bronze", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-bronze-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-bronze", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["angels-bronze-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-bronze", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["angels-invar-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-invar"},

    ["angels-nitinol-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-nitinol"},

    ["angels-cobalt-steel-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-cobalt-steel"},

    ["angels-brass-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-brass", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-brass-smelting-2"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-brass", icon_extras = reskins.angels.num_tier(2, inputs.group)},
    ["angels-brass-smelting-3"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-brass", icon_extras = reskins.angels.num_tier(3, inputs.group)},

    ["angels-gunmetal-smelting-1"] = {type = "recipe", subgroup = "liquid-material", image = "liquid-molten-gunmetal"},

    -- Powders
    ["gas-tungsten-hexafluoride-smelting"] = {type = "recipe", subgroup = "powders/tungsten", image = "powder-tungsten", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["solid-ammonium-paratungstate-smelting"] = {type = "recipe", subgroup = "powders/tungsten", image = "powder-tungsten", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["casting-powder-tungsten-1"] = {type = "recipe", subgroup = "powders/tungsten-mixture", image = "powder-tungsten-mixture", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["casting-powder-tungsten-2"] = {type = "recipe", subgroup = "powders/tungsten-mixture", image = "powder-tungsten-mixture", icon_extras = reskins.angels.num_tier(2, inputs.group)},
}

if mods["reskins-bobs"] then
    intermediates["tungsten-carbide"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "plates", image = "tungsten-carbide", icon_extras = reskins.angels.num_tier(1, inputs.group)} -- "1"
    intermediates["tungsten-carbide-2"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "plates", image = "tungsten-carbide", icon_extras = reskins.angels.num_tier(2, inputs.group)} -- "2"
end

-- Check if we're using Angel's material colors
if reskins.lib.setting("reskins-angels-use-angels-material-colors") then
    -- Gears
    intermediates["cobalt-steel-gear-wheel"] = {subgroup = "gears"}
    intermediates["nitinol-gear-wheel"] = {subgroup = "gears"}
    intermediates["titanium-gear-wheel"] = {subgroup = "gears"}
    intermediates["tungsten-gear-wheel"] = {subgroup = "gears"}

    -- Bearing Balls
    intermediates["ceramic-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediates["cobalt-steel-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediates["nitinol-bearing-ball"] = {subgroup = "bearing-balls"}
    intermediates["titanium-bearing-ball"] = {subgroup = "bearing-balls"}

    -- Bearings
    intermediates["ceramic-bearing"] = {subgroup = "bearings"}
    intermediates["cobalt-steel-bearing"] = {subgroup = "bearings"}
    intermediates["nitinol-bearing"] = {subgroup = "bearings"}
    intermediates["titanium-bearing"] = {subgroup = "bearings"}
end

reskins.lib.create_icons_from_list(intermediates, inputs)

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
    -- Intermediates
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

    -- Solder
    ["angels-solder-mixture-smelting"] = {["solder"] = {}, ["angels-solder-mixture"] = {scale = scale, shift = shift}},
    ["angels-solder"] = {["solder"] = {}, ["liquid-molten-solder"] = {type = "fluid", scale = scale, shift = shift}},
    ["angels-roll-solder-converting"] = {["solder"] = {}, ["angels-roll-solder"] = {scale = scale, shift = shift}},

    -- Rods
    ["angels-rod-iron-plate"] = {["angels-rod-iron"] = {}, ["iron-plate"] = {scale = scale, shift = shift}},
    -- ["angels-rod-stack-iron-converting"] = {["angels-rod-iron"] = {}, ["angels-rod-stack-iron"] = {scale = scale, shift = shift}},
    ["angels-rod-steel-plate"] = {["angels-rod-steel"] = {}, ["steel-plate"] = {scale = scale, shift = shift}},
    -- ["angels-rod-stack-steel-converting"] = {["angels-rod-steel"] = {}, ["angels-rod-stack-steel"] = {scale = scale, shift = shift}},
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

if not mods["bobelectronics"] then
    -- Solder
    composite_recipes["angels-solder-mixture-smelting"] = {["angels-solder"] = {}, ["angels-solder-mixture"] = {scale = scale, shift = shift}}
    composite_recipes["angels-solder"] = {["angels-solder"] = {}, ["liquid-molten-solder"] = {type = "fluid", scale = scale, shift = shift}}
    composite_recipes["angels-roll-solder-converting"] = {["angels-solder"] = {}, ["angels-roll-solder"] = {scale = scale, shift = shift}}
end

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end

-- Make variations for ingots
if reskins.lib.setting("reskins-angels-use-item-variations") then
    local ingot_variations = {
        "aluminium",
        "chrome",
        "cobalt",
        "copper",
        "gold",
        "iron",
        "steel",
        "lead",
        "manganese",
        "nickel",
        "platinum",
        "silicon",
        "silver",
        "tin",
        "titanium",
        "zinc",
    }

    for _, ingot in pairs(ingot_variations) do
        local item = data.raw.item["ingot-"..ingot]
        if not item then goto continue end

        -- Setup initial pictures table with primary icon
        item.pictures = {
            {
                filename = reskins.angels.directory.."/graphics/icons/smelting/ingots/"..ingot.."/ingot-"..ingot..".png",
                size = 64,
                mipmap_count = 4,
                scale = 0.25,
            }
        }

        for i = 1, 8, 1 do
            table.insert(item.pictures, {
                filename = reskins.angels.directory.."/graphics/icons/smelting/ingots/"..ingot.."/ingot-"..ingot.."-"..i..".png",
                size = 64,
                mipmap_count = 4,
                scale = 0.25,
            })
        end

        ::continue::
    end
end

-- Make variations for powders
local powder_variations = {
    ["powder-aluminium"] = "aluminium",
    ["casting-powder-tungsten"] = "tungsten-mixture",
    ["powder-chrome"] = "chrome",
    ["powder-cobalt"] = "cobalt",
    ["powder-copper"] = "copper",
    ["powder-gold"] = "gold",
    ["powder-iron"] = "iron",
    ["powder-steel"] = "steel",
    ["powder-lead"] = "lead",
    ["powder-manganese"] = "manganese",
    ["powder-nickel"] = "nickel",
    ["powder-platinum"] = "platinum",
    ["silicon-powder"] = "silicon",
    ["powder-silver"] = "silver",
    ["powder-tin"] = "tin",
    ["powder-titanium"] = "titanium",
    ["powdered-tungsten"] = "tungsten",
    ["powder-zinc"] = "zinc",
}

for powder, material in pairs(powder_variations) do
    local item = data.raw.item[powder]
    if not item then goto continue end

    -- Setup initial pictures table
    item.pictures = {}

    for i = 1, 6, 1 do
        table.insert(item.pictures, {
            filename = reskins.angels.directory.."/graphics/icons/smelting/powders/"..material.."/powder-"..material.."-"..i..".png",
            size = 64,
            mipmap_count = 4,
            scale = 0.25,
        })
    end

    ::continue::
end

-- Clear recipe icons
local recipes = {
    "aluminium-processed-processing",
    "zinc-processed-processing",
    "bauxite-ore-processing",
    "zinc-ore-processing",
}

for _, name in pairs(recipes) do
    local recipe = data.raw.recipe[name]
    if not recipe then goto continue end

    recipe.icon = nil
    recipe.icons = nil

    ::continue::
end