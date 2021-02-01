-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["electricboiler"] then return end

local entities = {
    ["electric-boiler"] = {tier = 1, order = "electric-boiler-1"},
    ["electric-boiler-2"] = {tier = 2},
    ["electric-boiler-3"] = {tier = 3},
    ["electric-boiler-4"] = {tier = 4},
    ["electric-boiler-5"] = {tier = 5},
}

local technology = "electric-boiler"