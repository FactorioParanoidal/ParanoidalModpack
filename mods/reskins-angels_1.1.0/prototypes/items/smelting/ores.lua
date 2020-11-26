-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angelssmelting"] then return end

local inputs = {
    directory = reskins.angels.directory,
    mod = "angels",
    group = "smelting",
}

reskins.lib.parse_inputs(inputs)

local ores = {
    -- ["angels-ore2"] = {}, -- Jivolite
    -- ["angels-ore4"] = {}, -- Crotinnium
    -- ["chrome-ore"] = {},
    ["lead-ore"] = {},
    -- ["manganese-ore"] = {},
    -- ["platinum-ore"] = {},
    ["rutile-ore"] = {}, -- Titanium (dark purple)
    ["thorium-ore"] = {make_glow = true}, -- Even though Angel's now fixed the issue, we make it green in AR:BM and need to put it back
    ["tin-ore"] = {variations = 8}, -- (green)
}

if reskins.lib.setting("reskins-angels-use-vanilla-style-ores") then
    table.insert(ores, {
        -- ["angels-ore1"] = {}, -- Saphirite
        -- ["angels-ore3"] = {}, -- Stiratite
        -- ["angels-ore5"] = {}, -- Rubyte
        -- ["angels-ore6"] = {}, -- Bobmonium
    })
end

-- Check if we're using Angel's material colors
if reskins.lib.setting("reskins-angels-use-angels-material-colors") == false then
    ores["lead-ore"] = {mod = "lib", group = "shared"}
    ores["tin-ore"] = {mod = "lib", group = "shared", variations = 8}
end

if not mods["bobores"] or not mods["reskins-bobs"] then
    ores["bauxite-ore"] = {mod = "lib", group = "shared", variations = 8}
    ores["cobalt-ore"] = {mod = "lib", group = "shared"}
    ores["gold-ore"] = {mod = "lib", group = "shared"}
    ores["nickel-ore"] = {mod = "lib", group = "shared"} -- 408073
    ores["quartz"] = {mod = "lib", group = "shared"} -- 999999
    ores["silver-ore"] = {mod = "lib", group = "shared"}
    ores["tungsten-ore"] = {mod = "lib", group = "shared", variations = 8}
    ores["zinc-ore"] = {mod = "lib", group = "shared"}
end

for name, params in pairs(ores) do
    -- Fetch entity
    local item = data.raw.item[name]

    -- Check if item exists, if not, skip this iteration
    if not item then goto continue end

    -- Fetch mod information
    local mod = params.mod or inputs.mod
    local group = params.group or inputs.group

    -- Setup icons
    inputs.icon = reskins[mod].directory.."/graphics/icons/"..group.."/ores/"..name.."/"..name..".png"
    inputs.icon_picture = reskins.lib.ore_icon_pictures(mod, group, name, params.variations or 4)

    reskins.lib.assign_icons(name, inputs)

    -- Label to skip to next iteration
    ::continue::
end

-- Setup recipe bases
local sorting_icon = {
    icon = "__angelsrefining__/graphics/icons/sort-icon.png",
    icon_size = 32,
    icon_mipmaps = 1,
}

local sludge_icons = {
    {
        icon = "__angelsrefining__/graphics/icons/angels-liquid/liquid-recipe-base.png",
        icon_size = 600,
        icon_mipmaps = 1,
        tint = util.color("404040b2"),
    },
    {
        icon = "__angelsrefining__/graphics/icons/angels-liquid/liquid-recipe-top.png",
        icon_size = 600,
        icon_mipmaps = 1,
        tint = util.color("ca6311"),
    },
    {
        icon = "__angelsrefining__/graphics/icons/angels-liquid/liquid-recipe-mid.png",
        icon_size = 600,
        icon_mipmaps = 1,
        tint = util.color("613414"),
    },
    {
        icon = "__angelsrefining__/graphics/icons/angels-liquid/liquid-recipe-bot.png",
        icon_size = 600,
        icon_mipmaps = 1,
        tint = util.color("613414"),
    }
}

local shift = {10, 10}
local scale = 0.5

local composite_recipes = {
    -- Ore Sorting Machine Recipes
    ["angelsore-crushed-mix3-processing"] = {["base"] = {icon = sorting_icon}, ["lead-ore"] = {shift = shift, scale = scale}}, -- Lead
    ["angelsore-crushed-mix4-processing"] = {["base"] = {icon = sorting_icon}, ["tin-ore"] = {shift = shift, scale = scale}}, -- Tin
    ["angelsore-chunk-mix1-processing"] = {["base"] = {icon = sorting_icon}, ["quartz"] = {shift = shift, scale = scale}}, -- Silicon
    ["angelsore-chunk-mix2-processing"] = {["base"] = {icon = sorting_icon}, ["nickel-ore"] = {shift = shift, scale = scale}}, -- Nickel
    ["angelsore-chunk-mix3-processing"] = {["base"] = {icon = sorting_icon}, ["bauxite-ore"] = {shift = shift, scale = scale}}, -- Aluminium
    ["angelsore-chunk-mix4-processing"] = {["base"] = {icon = sorting_icon}, ["zinc-ore"] = {shift = shift, scale = scale}}, -- Zinc
    -- ["angelsore-chunk-mix5-processing"] = {["base"] = {icon = sorting_icon}, ["fluorite-ore"] = {shift = shift, scale = scale}}, -- Fluorite
    -- ["angelsore-chunk-mix6-processing"] = {["base"] = {icon = sorting_icon}, ["manganese-ore"] = {shift = shift, scale = scale}}, -- Manganese?

    ["angelsore-crystal-mix1-processing"] = {["base"] = {icon = sorting_icon}, ["rutile-ore"] = {shift = shift, scale = scale}}, -- Titanium
    ["angelsore-crystal-mix2-processing"] = {["base"] = {icon = sorting_icon}, ["gold-ore"] = {shift = shift, scale = scale}}, -- Gold
    ["angelsore-crystal-mix3-processing"] = {["base"] = {icon = sorting_icon}, ["cobalt-ore"] = {shift = shift, scale = scale}}, -- Cobalt
    ["angelsore-crystal-mix4-processing"] = {["base"] = {icon = sorting_icon}, ["silver-ore"] = {shift = shift, scale = scale}}, -- Silver
    ["angelsore-crystal-mix5-processing"] = {["base"] = {icon = sorting_icon}, ["uranium-ore"] = {shift = shift, scale = scale}}, -- Uranium
    ["angelsore-crystal-mix6-processing"] = {["base"] = {icon = sorting_icon}, ["thorium-ore"] = {shift = shift, scale = scale}}, -- Thorium

    ["angelsore-pure-mix1-processing"] = {["base"] = {icon = sorting_icon}, ["tungsten-ore"] = {shift = shift, scale = scale}}, -- Tungsten
    -- ["angelsore-pure-mix2-processing"] = {["base"] = {icon = sorting_icon}, ["platinum-ore"] = {shift = shift, scale = scale}}, -- Platinum
    -- ["angelsore-pure-mix3-processing"] = {["base"] = {icon = sorting_icon}, ["chrome-ore"] = {shift = shift, scale = scale}}, -- Chrome?
}

-- Build Crystalizer slag processing recipes
local slag_processing_list = {
    "slag-processing-2",
    "slag-processing-3",
    "slag-processing-4",
    "slag-processing-5",
    "slag-processing-6",
    "slag-processing-7",
    "slag-processing-8",
    "slag-processing-9",
}

if mods["SeaBlock"] then
    table.insert(slag_processing_list, "slag-processing-1")
end

local slag_recipe_shifts = {
    {-11.5, 12},
    {11.5, 12},
    {0, 12}
}

for _, name in pairs(slag_processing_list) do
    -- Check the recipe exists
    local recipe = data.raw.recipe[name]
    if not recipe then goto continue end

    local recipe_results = recipe.normal.results or recipe.results

    -- Build icon overlays based on recipe ingredients
    if recipe_results[1].name ~= "angels-void" then
        local shift_index = 1

        -- Setup base layer
        composite_recipes[name] = {["base"] = {icons = sludge_icons}}

        -- Build icon overlays based on recipe products
        for _, product in pairs(recipe_results) do
            composite_recipes[name][product.name] = {shift = slag_recipe_shifts[shift_index], scale = 0.32}
            shift_index = shift_index + 1
        end
    end

    ::continue::
end

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end