-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.enemies.items) then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "enemies",
    make_icon_pictures = false,
    flat_icon = true,
}

local items = {
    ["alien-artifact"] = {subgroup = "artifacts"},
    ["alien-artifact-blue"] = {subgroup = "artifacts"},
    ["alien-artifact-green"] = {subgroup = "artifacts"},
    ["alien-artifact-orange"] = {subgroup = "artifacts"},
    ["alien-artifact-purple"] = {subgroup = "artifacts"},
    ["alien-artifact-red"] = {subgroup = "artifacts"},
    ["alien-artifact-yellow"] = {subgroup = "artifacts"},

    ["small-alien-artifact"] = {subgroup = "artifacts"},
    ["small-alien-artifact-blue"] = {subgroup = "artifacts"},
    ["small-alien-artifact-green"] = {subgroup = "artifacts"},
    ["small-alien-artifact-orange"] = {subgroup = "artifacts"},
    ["small-alien-artifact-purple"] = {subgroup = "artifacts"},
    ["small-alien-artifact-red"] = {subgroup = "artifacts"},
    ["small-alien-artifact-yellow"] = {subgroup = "artifacts"},
}

reskins.lib.create_icons_from_list(items, inputs)