-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.mining.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "inserters",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {
    -- ["long-inserters-1"] = {},
    -- ["long-inserters-2"] = {},
    -- ["near-inserters"] = {},
    -- ["more-inserters-1"] = {},
    -- ["more-inserters-2"] = {},
}

-- For non-overhaul condition, long-handed inserters are unlocked by this technology
if reskins.lib.setting("bobmods-logistics-inserteroverhaul") ~= true then
    -- technologies["long-inserters-1"] = nil
end

reskins.lib.create_icons_from_list(technologies, inputs)