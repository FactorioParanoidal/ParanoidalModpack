-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.revamp.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "revamp",
    type = "technology",
}

local technologies = {
    -- ["pumpjack"] = {group = "mining", tier = 1}, -- pumpjack 1

    -- ["solid-fuel"] = {}, -- Solid fuels! all of the, black/white
    -- ["hydrazine"] = {}, -- Hydrazine, enriched fuel block from hydrazine
    -- ["rtg"] = {}, -- radio thermoelec gen, fluids, powders
    -- ["heat-shield"] = {}, -- also need to do item, heat-shield-tile
}

reskins.lib.create_icons_from_list(technologies, inputs)