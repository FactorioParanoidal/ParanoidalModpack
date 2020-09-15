-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobgreenhouse"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "greenhouse",
    type = "technology",
    flat_icon = true,
}

reskins.lib.create_icons_from_list({["bob-fertiliser"] = {}}, inputs)