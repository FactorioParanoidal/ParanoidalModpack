-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobelectronics"] then return end
if reskins.lib.setting("reskins-bobs-do-bobelectronics-circuit-style") == "off" then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "electronics",
    make_icon_pictures = false,
    flat_icon = true,
    tier_labels = false,
}

-- Sets up circuits to use material colors
local circuits = {
    -- Boards
    ["wooden-board"] = {subgroup = "circuits"},
    ["phenolic-board"] = {subgroup = "circuits"},
    ["fibreglass-board"] = {subgroup = "circuits"},

    -- Circuits, standard coloring
    ["basic-circuit-board"] = {subgroup = "circuits"},
    ["circuit-board"] = {subgroup = "circuits"},
    ["superior-circuit-board"] = {subgroup = "circuits"},
    ["multi-layer-circuit-board"] = {subgroup = "circuits"},

    ["electronic-circuit"] = {subgroup = "circuits"},
    ["advanced-circuit"] = {subgroup = "circuits"},
    ["processing-unit"] = {subgroup = "circuits"},
    ["advanced-processing-unit"] = {subgroup = "circuits"},
}

-- Fetch relevant settings
local circuit_color_style = reskins.lib.setting("reskins-bobs-do-bobelectronics-circuit-style")
local tier_mapping = reskins.lib.setting("reskins-lib-tier-mapping")
local custom_color = reskins.lib.setting("reskins-lib-customize-tier-colors")

local function circuit_picture_extras(name)
    return
    {
        {
            filename = reskins.bobs.directory.."/graphics/icons/electronics/circuits-custom/"..name.."/"..name.."-circuitry.png",
            size = 64,
            mipmaps = 4,
            scale = 0.25,
        }
    }
end

-- Check if we're using tier or vanilla coloring
if circuit_color_style == "colored-tier" then
    if custom_color then
        -- Intermediates
        circuits["basic-circuit-board"] = {subgroup = "circuits-custom", tier = 1, prog_tier = 2, icon_name = "basic-circuit-board", icon_picture_extras = circuit_picture_extras("basic-circuit-board"), flat_icon = false, make_icon_pictures = true}
        circuits["circuit-board"] = {subgroup = "circuits-custom", tier = 2, prog_tier = 3, icon_name = "circuit-board", icon_picture_extras = circuit_picture_extras("circuit-board"), flat_icon = false, make_icon_pictures = true}
        circuits["superior-circuit-board"] = {subgroup = "circuits-custom", tier = 3, prog_tier = 4, icon_name = "superior-circuit-board", icon_picture_extras = circuit_picture_extras("superior-circuit-board"), flat_icon = false, make_icon_pictures = true}
        circuits["multi-layer-circuit-board"] = {subgroup = "circuits-custom", tier = 4, prog_tier = 5, icon_name = "multi-layer-circuit-board", icon_picture_extras = circuit_picture_extras("multi-layer-circuit-board"), flat_icon = false, make_icon_pictures = true}

        -- Completed
        circuits["electronic-circuit"] = {subgroup = "circuits-custom", tier = 1, prog_tier = 2, icon_name = "electronic-circuit", icon_picture_extras = circuit_picture_extras("electronic-circuit"), flat_icon = false, make_icon_pictures = true}
        circuits["advanced-circuit"] = {subgroup = "circuits-custom", tier = 2, prog_tier = 3, icon_name = "advanced-circuit", icon_picture_extras = circuit_picture_extras("advanced-circuit"), flat_icon = false, make_icon_pictures = true}
        circuits["processing-unit"] = {subgroup = "circuits-custom", tier = 3, prog_tier = 4, icon_name = "processing-unit", icon_picture_extras = circuit_picture_extras("processing-unit"), flat_icon = false, make_icon_pictures = true}
        circuits["advanced-processing-unit"] = {subgroup = "circuits-custom", tier = 4, prog_tier = 5, icon_name = "advanced-processing-unit", icon_picture_extras = circuit_picture_extras("advanced-processing-unit"), flat_icon = false, make_icon_pictures = true}
    else
        if tier_mapping == "traditional-map" then
            circuits["basic-circuit-board"] = {subgroup = "circuits-name"}
            circuits["circuit-board"] = {subgroup = "circuits-name"}
            circuits["superior-circuit-board"] = {subgroup = "circuits-name"}
            circuits["multi-layer-circuit-board"] = {subgroup = "circuits-name"}

            circuits["electronic-circuit"] = {subgroup = "circuits-name"}
            circuits["advanced-circuit"] = {subgroup = "circuits-name"}
            circuits["processing-unit"] = {subgroup = "circuits-name"}
            circuits["advanced-processing-unit"] = {subgroup = "circuits-name"}
        elseif tier_mapping == "progression-map" then
            circuits["basic-circuit-board"] = {subgroup = "circuits-progression"}
            circuits["circuit-board"] = {subgroup = "circuits-progression"}
            circuits["superior-circuit-board"] = {subgroup = "circuits-progression"}
            circuits["multi-layer-circuit-board"] = {subgroup = "circuits-progression"}

            circuits["electronic-circuit"] = {subgroup = "circuits-progression"}
            circuits["advanced-circuit"] = {subgroup = "circuits-progression"}
            circuits["processing-unit"] = {subgroup = "circuits-progression"}
            circuits["advanced-processing-unit"] = {subgroup = "circuits-progression"}
        end
    end
elseif circuit_color_style == "colored-vanilla" then
    circuits["basic-circuit-board"] = {subgroup = "circuits-vanilla"}
    circuits["circuit-board"] = {subgroup = "circuits-vanilla"}
    circuits["superior-circuit-board"] = {subgroup = "circuits-vanilla"}
    circuits["multi-layer-circuit-board"] = {subgroup = "circuits-vanilla"}

    circuits["electronic-circuit"] = {subgroup = "circuits-vanilla"}
    circuits["advanced-circuit"] = {subgroup = "circuits-vanilla"}
    circuits["processing-unit"] = {subgroup = "circuits-vanilla"}
    circuits["advanced-processing-unit"] = {subgroup = "circuits-vanilla"}
end

-- Check for circuit processing, and remap the circuits if present
if mods["CircuitProcessing"] then
    -- Transcribe to the new names
    circuits["cp-electronic-circuit-board"] = util.copy(circuits["electronic-circuit"])
    circuits["cp-advanced-circuit-board"] = util.copy(circuits["advanced-circuit"])
    circuits["cp-processing-board"] = util.copy(circuits["processing-unit"])
    circuits["cp-advanced-processing-board"] = util.copy(circuits["advanced-processing-unit"])

    -- Map to the image to use
    circuits["cp-electronic-circuit-board"].image = "electronic-circuit"
    circuits["cp-advanced-circuit-board"].image = "advanced-circuit"
    circuits["cp-processing-board"].image = "processing-unit"
    circuits["cp-advanced-processing-board"].image = "advanced-processing-unit"

    -- Clear old mappings
    circuits["electronic-circuit"] = nil
    circuits["advanced-circuit"] = nil
    circuits["processing-unit"] = nil
    circuits["advanced-processing-unit"] = nil
end

reskins.lib.create_icons_from_list(circuits, inputs)