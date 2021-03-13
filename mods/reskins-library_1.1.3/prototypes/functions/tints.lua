-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- The intention of this script is to determine belt tints, and make them available to anything using belt tints.

-- Shift the rgb values of a given tint by shift amount, and optionally adjust the alpha value
function reskins.lib.adjust_tint(tint, shift, alpha)
    local adjusted_tint = {}

    -- Adjust the tint
    adjusted_tint.r = tint.r + shift
    adjusted_tint.g = tint.g + shift
    adjusted_tint.b = tint.b + shift
    adjusted_tint.a = alpha or tint.a

    -- Check boundary conditions
    if adjusted_tint.r > 1 then
        adjusted_tint.r = 1
    elseif adjusted_tint.r < 0 then
        adjusted_tint.r = 0
    end

    if adjusted_tint.g > 1 then
        adjusted_tint.g = 1
    elseif adjusted_tint.g < 0 then
        adjusted_tint.g = 0
    end

    if adjusted_tint.b > 1 then
        adjusted_tint.b = 1
    elseif adjusted_tint.b < 0 then
        adjusted_tint.b = 0
    end

    return adjusted_tint
end

-- Adjust the alpha value of a given tint
function reskins.lib.adjust_alpha(tint, alpha)
    local adjusted_tint = {r = tint.r, g = tint.g, b = tint.b, a = alpha}
    return adjusted_tint
end

-- This function prepares a given tint for entities that use a base and mask layer instead of a base, mask, and highlights layer
-- Primarily this means belt-related entities
-- TODO: Replace this with HSV-based correction at some point
function reskins.lib.belt_mask_tint(tint)
    -- Define correction constants
    local color_shift = 40/255
    local alpha = 0.82

    -- Color correct the tint
    local belt_mask_tint = reskins.lib.adjust_tint(tint, color_shift, alpha)

    return belt_mask_tint
end

-- SETUP ENTITY COLORS
-- Determine which set of colors to use
if settings.startup["reskins-lib-customize-tier-colors"].value == true then
    -- Setup custom colors
    reskins.lib.tint_index = {
        [0] = util.color(settings.startup["reskins-lib-custom-colors-tier-0"].value),
        [1] = util.color(settings.startup["reskins-lib-custom-colors-tier-1"].value),
        [2] = util.color(settings.startup["reskins-lib-custom-colors-tier-2"].value),
        [3] = util.color(settings.startup["reskins-lib-custom-colors-tier-3"].value),
        [4] = util.color(settings.startup["reskins-lib-custom-colors-tier-4"].value),
        [5] = util.color(settings.startup["reskins-lib-custom-colors-tier-5"].value),
        [6] = util.color(settings.startup["reskins-lib-custom-colors-tier-6"].value),
    }
    -- Use Angel color presets
elseif reskins.lib.setting("reskins-angels-use-angels-tier-colors") then
    reskins.lib.tint_index = {
        -- Core Angel's set
        [1] = util.color("595959"), -- Gray
        [2] = util.color("2957cc"),
        [3] = util.color("cc2929"),
        [4] = util.color("ccae29"),

        -- Pending
        [0] = util.color("262626"),
        [5] = util.color("23de55"),
        [6] = util.color("ff7700"),
    }
else
    -- Use default (Bob) color presets
    reskins.lib.tint_index = {
        [0] = util.color("4d4d4d"),
        [1] = util.color("de9400"),
        [2] = util.color("c20600"),
        [3] = util.color("0099ff"), -- 1b87c2
        [4] = util.color("a600bf"),
        [5] = util.color("23de55"),
        [6] = util.color("ff7700"),
    }
end

-- SETUP BELT COLORS
-- Determine which set of colors to use
if settings.startup["reskins-lib-customize-tier-colors"].value == true then
    reskins.lib.belt_tint_index = {
        [0] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-0"].value)),
        [1] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-1"].value)),
        [2] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-2"].value)),
        [3] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-3"].value)),
        [4] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-4"].value)),
        [5] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-5"].value)),
        [6] = reskins.lib.belt_mask_tint(util.color(settings.startup["reskins-lib-custom-colors-tier-6"].value)),
    }
elseif reskins.lib.setting("reskins-angels-use-angels-tier-colors") and reskins.lib.setting("reskins-angels-belts-use-angels-tier-colors") then
    reskins.lib.belt_tint_index = {
        -- Core Angel's set
        [1] = reskins.lib.belt_mask_tint(util.color("595959")), -- Gray
        [2] = reskins.lib.belt_mask_tint(util.color("2957cc")), -- Blue
        [3] = reskins.lib.belt_mask_tint(util.color("cc2929")), -- Red
        [4] = reskins.lib.belt_mask_tint(util.color("ccae29")), -- Yellow

        -- Pending
        [0] = reskins.lib.belt_mask_tint(util.color("262626")),
        [5] = reskins.lib.belt_mask_tint(util.color("23de55")),
        [6] = reskins.lib.belt_mask_tint(util.color("ff7700")),
    }
else
    reskins.lib.belt_tint_index = {
        [0] = reskins.lib.belt_mask_tint(util.color("4d4d4d")),
        [1] = reskins.lib.belt_mask_tint(util.color("de9400")),
        [2] = reskins.lib.belt_mask_tint(util.color("c20600")),
        [3] = reskins.lib.belt_mask_tint(util.color("0099ff")), -- 1b87c2
        [4] = reskins.lib.belt_mask_tint(util.color("a600bf")),
        [5] = reskins.lib.belt_mask_tint(util.color("23de55")),
        [6] = reskins.lib.belt_mask_tint(util.color("ff7700")),
    }
end

-- Check if we're using an alternative tier-0 color for belts
if reskins.lib.setting("reskins-bobs-do-basic-belts-separately") == true then
    reskins.lib.belt_tint_index[0] = reskins.lib.belt_mask_tint(util.color(reskins.lib.setting("reskins-bobs-basic-belts-color")))
end