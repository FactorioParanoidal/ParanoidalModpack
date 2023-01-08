-- Copyright (c) 2022 Kirazy
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

local function check_for_preferred_item(primary, secondary)
    if data.raw.item[primary] then return primary else return secondary end
end

-- Check to see if reskinning needs to be done.
if not mods["angelssmelting"] then
    -- Handle the few composite recipes that fall through the cracks
    local composite_recipes = {
        -- Lead plates
        ["angelsore5-crushed-smelting"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["angels-ore5-crushed"] = {scale = scale, shift = shift}}, -- Crushed rubyte

        -- Tin plates
        ["angelsore6-crushed-smelting"] = {[check_for_preferred_item("tin-plate", "angels-plate-tin")] = {}, ["angels-ore6-crushed"] = {scale = scale, shift = shift}}, -- Crushed bobmonium
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
    ["angels-plate-hot-iron"] = {subgroup = "plates"},
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

    -- Sheet Coils from Angel's Extended Smelting and Compression
    ["angels-roll-bronze"] = {subgroup = "rolls"},
    ["angels-roll-invar"] = {subgroup = "rolls"},
    ["angels-roll-nitinol"] = {subgroup = "rolls"},
    ["angels-roll-cobalt-steel"] = {subgroup = "rolls"},
    ["angels-roll-brass"] = {subgroup = "rolls"},
    ["angels-roll-gunmetal"] = {subgroup = "rolls"},

    -- Rods
    ["iron-stick"] = {icon_filename = "__base__/graphics/icons/iron-stick.png", icon_size = 64, icon_mipmaps = 4}, -- Put the icon back
    -- ["angels-rod-steel"]

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Plates
    ["angels-plate-glass-1"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(1, inputs.group)}, -- "1"
    ["angels-plate-glass-2"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(2, inputs.group)}, -- "2"
    ["angels-plate-glass-3"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "glass", icon_extras = reskins.angels.num_tier(3, inputs.group)}, -- "3"

    -- Angel's Extended Smelting and Compression Sheet Coils
    ["angels-roll-brass-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-brass", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-brass-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-brass", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-bronze-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-bronze", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-bronze-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-bronze", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-cobalt-steel-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt-steel", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-cobalt-steel-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-cobalt-steel", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-gunmetal-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gunmetal", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-gunmetal-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-gunmetal", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-invar-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-invar", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-invar-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-invar", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-nitinol-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nitinol", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-nitinol-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-nitinol", icon_extras = reskins.angels.num_tier(2, inputs.group)},

    ["angels-roll-tungsten-casting"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tungsten", icon_extras = reskins.angels.num_tier(1, inputs.group)},
    ["angels-roll-tungsten-casting-fast"] = {type = "recipe", subgroup = "rolls", image = "angels-roll-tungsten", icon_extras = reskins.angels.num_tier(2, inputs.group)},
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

    -- Bob Warefare Armor
    intermediates["heavy-armor-3"] = {type = "armor", subgroup = "armor"}
    intermediates["bob-power-armor-mk4"] = {type = "armor", subgroup = "armor"}
    intermediates["bob-power-armor-mk5"] = {type = "armor", subgroup = "armor"}
end

reskins.lib.create_icons_from_list(intermediates, inputs)

local composite_recipes = {
    ----------------------------------------------------------------------------------------------------
    -- PLATES
    ----------------------------------------------------------------------------------------------------
    -- Aluminium
    ["angels-plate-aluminium"] = {[check_for_preferred_item("aluminium-plate", "angels-plate-aluminium")] = {}, ["liquid-molten-aluminium"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten aluminium
    ["angels-roll-aluminium-converting"] = {[check_for_preferred_item("aluminium-plate", "angels-plate-aluminium")] = {}, ["angels-roll-aluminium"] = {scale = scale, shift = shift}}, -- Aluminium sheet coil

    -- Chrome
    ["angels-plate-chrome"] = {["angels-plate-chrome"] = {}, ["liquid-molten-chrome"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten chrome
    ["angels-roll-chrome-converting"] = {["angels-plate-chrome"] = {}, ["angels-roll-chrome"] = {scale = scale, shift = shift}}, -- Chrome sheet coil

    -- Cobalt
    ["angels-plate-cobalt"] = {[check_for_preferred_item("cobalt-plate", "angels-plate-cobalt")] = {}, ["liquid-molten-cobalt"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten cobalt
    ["angels-roll-cobalt-converting"] = {[check_for_preferred_item("cobalt-plate", "angels-plate-cobalt")] = {}, ["angels-roll-cobalt"] = {scale = scale, shift = shift}}, -- Cobalt sheet coil

    -- Copper
    ["angelsore3-crushed-smelting"] = {["copper-plate"] = {}, ["angels-ore3-crushed"] = {scale = scale, shift = shift}}, -- Crushed stiratite
    ["copper-plate"] = {["copper-plate"] = {}, ["copper-ore"] = {scale = scale, shift = shift}}, -- Copper ore
    ["angels-plate-copper"] = {["copper-plate"] = {}, ["liquid-molten-copper"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten copper
    ["angels-roll-copper-converting"] = {["copper-plate"] = {}, ["angels-roll-copper"] = {scale = scale, shift = shift}}, -- Copper sheet coil
    ["angels-copper-pebbles-smelting"] = {["copper-plate"] = {}, ["angels-copper-pebbles"] = {scale = scale, shift = shift}}, -- Copper pebbles
    ["angels-copper-nugget-smelting"] = {["copper-plate"] = {}, ["angels-copper-nugget"] = {scale = scale, shift = shift}}, -- Copper nuggets

    -- Glass
    ["quartz-glass"] = {["glass"] = {}, ["quartz"] = {scale = scale, shift = shift}}, -- Silicon ore

    -- Gold
    ["angels-plate-gold"] = {[check_for_preferred_item("gold-plate", "angels-plate-gold")] = {}, ["liquid-molten-gold"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten gold
    ["angels-roll-gold-converting"] = {[check_for_preferred_item("gold-plate", "angels-plate-gold")] = {}, ["angels-roll-gold"] = {scale = scale, shift = shift}}, -- Gold sheet coil

    -- Invar
    ["angels-plate-invar"] = {["invar-alloy"] = {}, ["liquid-molten-invar"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten invar
    ["invar-alloy"] = {["invar-alloy"] = {}, [check_for_preferred_item("nickel-plate", "angels-plate-nickel")] = {scale = scale, shift = {-6, -10}}, ["iron-plate"] = {scale = scale, shift = shift}}, -- Nickel/Iron plates

    -- Iron
    ["angelsore1-crushed-smelting"] = {["iron-plate"] = {}, ["angels-ore1-crushed"] = {scale = scale, shift = shift}}, -- Crushed saphirite
    ["iron-plate"] = {["iron-plate"] = {}, ["iron-ore"] = {scale = scale, shift = shift}}, -- Iron ore
    ["angels-plate-iron"] = {["iron-plate"] = {}, ["liquid-molten-iron"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten iron
    ["angels-roll-iron-converting"] = {["iron-plate"] = {}, ["angels-roll-iron"] = {scale = scale, shift = shift}}, -- Iron sheet coil
    ["angels-iron-pebbles-smelting"] = {["iron-plate"] = {}, ["angels-iron-pebbles"] = {scale = scale, shift = shift}}, -- Iron pebbles
    ["angels-iron-nugget-smelting"] = {["iron-plate"] = {}, ["angels-iron-nugget"] = {scale = scale, shift = shift}}, -- Iron nuggets

    -- Lead
    ["lead-plate"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["lead-ore"] = {scale = scale, shift = shift}}, -- Lead ore
    ["angels-plate-lead"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["liquid-molten-lead"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten lead
    ["angels-roll-lead-converting"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["angels-roll-lead"] = {scale = scale, shift = shift}}, -- Lead sheet coil
    ["silver-from-lead"] = {[check_for_preferred_item("lead-plate", "angels-plate-lead")] = {}, ["silver-ore"] = {scale = scale, shift = shift}},

    -- Manganese
    ["angels-plate-manganese"] = {["angels-plate-manganese"] = {}, ["liquid-molten-manganese"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten manganese
    ["angels-roll-manganese-converting"] = {["angels-plate-manganese"] = {}, ["angels-roll-manganese"] = {scale = scale, shift = shift}}, -- Manganese sheet coil

    -- Nickel
    ["angels-plate-nickel"] = {[check_for_preferred_item("nickel-plate", "angels-plate-nickel")] = {}, ["liquid-molten-nickel"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten nickel
    ["angels-roll-nickel-converting"] = {[check_for_preferred_item("nickel-plate", "angels-plate-nickel")] = {}, ["angels-roll-nickel"] = {scale = scale, shift = shift}}, -- Nickel sheet roll

    -- Nitinol
    ["angels-plate-nitinol"] = {["nitinol-alloy"] = {}, ["liquid-molten-nitinol"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten nitinol

    -- Platinum
    ["angels-plate-platinum"] = {["angels-plate-platinum"] = {}, ["liquid-molten-platinum"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten platinum
    ["angels-roll-platinum-converting"] = {["angels-plate-platinum"] = {}, ["angels-roll-platinum"] = {scale = scale, shift = shift}}, -- Platinum sheet coil

    -- Silver
    ["silver-plate"] = {[check_for_preferred_item("silver-plate", "angels-plate-silver")] = {}, ["silver-ore"] = {scale = scale, shift = shift}}, -- Silver ore
    ["angels-plate-silver"] = {[check_for_preferred_item("silver-plate", "angels-plate-silver")] = {}, ["liquid-molten-silver"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten silver
    ["angels-roll-silver-converting"] = {[check_for_preferred_item("silver-plate", "angels-plate-silver")] = {}, ["angels-roll-silver"] = {scale = scale, shift = shift}}, -- Silver sheet coil

    -- Steel plate
    ["steel-plate"] = {["angels-plate-hot-iron"] = {}, ["iron-plate"] = {scale = scale, shift = shift}}, -- Hot-Iron plate
    ["angels-plate-steel-pre-heating"] = {["steel-plate"] = {}, ["angels-plate-hot-iron"] = {scale = scale, shift = shift}},
    ["angels-plate-steel"] = {["steel-plate"] = {}, ["liquid-molten-steel"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten steel
    ["angels-roll-steel-converting"] = {["steel-plate"] = {}, ["angels-roll-steel"] = {scale = scale, shift = shift}}, -- Steel sheet coil

    -- Tin
    ["tin-plate"] = {[check_for_preferred_item("tin-plate", "angels-plate-tin")] = {}, ["tin-ore"] = {scale = scale, shift = shift}}, -- Tin ore
    ["angels-plate-tin"] = {[check_for_preferred_item("tin-plate", "angels-plate-tin")] = {}, ["liquid-molten-tin"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten tin
    ["angels-roll-tin-converting"] = {[check_for_preferred_item("tin-plate", "angels-plate-tin")] = {}, ["angels-roll-tin"] = {scale = scale, shift = shift}}, -- Tin sheet coil

    -- Titanium
    ["angels-plate-titanium"] = {[check_for_preferred_item("titanium-plate", "angels-plate-titanium")] = {}, ["liquid-molten-titanium"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten titanium
    ["angels-roll-titanium-converting"] = {[check_for_preferred_item("titanium-plate", "angels-plate-titanium")] = {}, ["angels-roll-titanium"] = {scale = scale, shift = shift}}, -- Titanium sheet coil

    -- Zinc
    ["angels-plate-zinc"] = {[check_for_preferred_item("zinc-plate", "angels-plate-zinc")] = {}, ["liquid-molten-zinc"] = {type = "fluid", scale = scale, shift = shift}}, -- Molten Zinc
    ["angels-roll-zinc-converting"] = {[check_for_preferred_item("zinc-plate", "angels-plate-zinc")] = {}, ["angels-roll-zinc"] = {scale = scale, shift = shift}}, -- Zinc sheet coil

    ----------------------------------------------------------------------------------------------------
    -- Intermediates
    ----------------------------------------------------------------------------------------------------
    -- Copper cable
    ["copper-cable"] = {["copper-cable"] = {}, ["copper-plate"] = {scale = scale, shift = shift}}, -- Copper plate
    ["angels-wire-coil-copper-converting"] = {["copper-cable"] = {}, ["angels-wire-coil-copper"] = {scale = scale, shift = shift}}, -- Copper wire coil

    -- Gold cable
    ["angels-wire-gold"] = {[check_for_preferred_item("gilded-copper-cable", "angels-wire-gold")] = {}, [check_for_preferred_item("gold-plate", "angels-plate-gold")] = {scale = scale, shift = shift}}, -- Gold plate
    ["angels-wire-coil-gold-converting"] = {[check_for_preferred_item("gilded-copper-cable", "angels-wire-gold")] = {}, ["angels-wire-coil-gold"] = {scale = scale, shift = shift}}, -- Gold wire coil

    -- Silver cable
    ["basic-silvered-copper-wire"] = {["angels-wire-silver"] = {}, [check_for_preferred_item("silver-plate", "angels-plate-silver")] = {scale = scale, shift = shift}}, -- Silver plate
    ["angels-wire-coil-silver-converting"] = {["angels-wire-silver"] = {}, ["angels-wire-coil-silver"] = {scale = scale, shift = shift}}, -- Silver wire coil

    -- Platinum cable
    ["basic-platinated-copper-wire"] = {["angels-wire-platinum"] = {}, ["angels-plate-platinum"] = {scale = scale, shift = shift}}, -- Platinum plate
    ["angels-wire-coil-platinum-converting"] = {["angels-wire-platinum"] = {}, ["angels-wire-coil-platinum"] = {scale = scale, shift = shift}}, -- Platinum wire coil

    -- Tin cable
    ["basic-tinned-copper-wire"] = {[check_for_preferred_item("tinned-copper-cable", "angels-wire-tin")] = {}, [check_for_preferred_item("tin-plate", "angels-plate-tin")] = {scale = scale, shift = shift}}, -- Tin plate
    ["angels-wire-coil-tin-converting"] = {[check_for_preferred_item("tinned-copper-cable", "angels-wire-tin")] = {}, ["angels-wire-coil-tin"] = {scale = scale, shift = shift}}, -- Tin wire coil

    -- Insulated cable (Angel's Extended Smelting and Compression)
    ["angels-wire-coil-insulated-converting"] = {["insulated-cable"] = {}, ["angels-wire-coil-insulated"] = {shift = shift, scale = scale}},

    -- Solder
    ["angels-solder-mixture-smelting"] = {[check_for_preferred_item("solder", "angels-solder")] = {}, ["angels-solder-mixture"] = {scale = scale, shift = shift}},
    ["angels-solder"] = {[check_for_preferred_item("solder", "angels-solder")] = {}, ["liquid-molten-solder"] = {type = "fluid", scale = scale, shift = shift}},
    ["angels-roll-solder-converting"] = {[check_for_preferred_item("solder", "angels-solder")] = {}, ["angels-roll-solder"] = {scale = scale, shift = shift}},

    -- Rods
    ["angels-rod-iron-plate"] = {["iron-stick"] = {}, ["iron-plate"] = {scale = scale, shift = shift}},
    ["angels-rod-stack-iron-converting"] = {["iron-stick"] = {}, ["angels-rod-stack-iron"] = {scale = scale, shift = shift}},
    ["angels-rod-steel-plate"] = {["angels-rod-steel"] = {}, ["steel-plate"] = {scale = scale, shift = shift}},
    -- ["angels-rod-stack-steel-converting"] = {["angels-rod-steel"] = {}, ["angels-rod-stack-steel"] = {scale = scale, shift = shift}},
}

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