-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["CircuitProcessing"] then return end
if not reskins.bobs then return end
if reskins.lib.setting("reskins-compatibility-do-circuitprocessing-circuit-style") == "off" then return end

-- Setup inputs
local inputs = {
    mod = "compatibility",
    group = "circuitprocessing",
    subgroup = "circuits",
    make_icon_pictures = false,
    flat_icon = true,
    tier_labels = false,
}

local circuits = {
    -- Basic Boards
    ["wooden-board"] = {mod = "bobs", group = "electronics", subgroup = "circuits"},
    ["phenolic-board"] = {mod = "bobs", group = "electronics", subgroup = "circuits"},
    ["fibreglass-board"] = {mod = "bobs", group = "electronics", subgroup = "circuits"},

    -- First stage intermediates
    ["circuit-board"] = {image = "circuit-board"}, -- 3
    ["superior-circuit-board"] = {image = "superior-circuit-board"}, -- 4
    ["multi-layer-circuit-board"] = {image = "multi-layer-circuit-board"}, -- 5

    -- Second stage intermediates, direct ingredients to mainline finished products
    ["cp-electronic-circuit-board"] = {image = "basic-electronic-board"}, -- 2
    ["cp-advanced-circuit-board"] = {image = "electronic-circuit-board"}, -- 3
    ["cp-processing-board"] = {image = "electronic-logic-board"}, -- 4
    ["cp-advanced-processing-board"] = {image = "electronic-processing-board"}, -- 5

    -- Mainline finished products
    ["basic-circuit-board"] = {image = "basic-circuit-board"}, -- 1
    ["electronic-circuit"] = {image = "electronic-circuit"}, -- 2
    ["advanced-circuit"] = {image = "advanced-circuit"}, -- 3
    ["processing-unit"] = {image = "processing-unit"}, -- 4
    ["advanced-processing-unit"] = {image = "advanced-processing-unit"}, -- 5
}

reskins.lib.create_icons_from_list(circuits, inputs)