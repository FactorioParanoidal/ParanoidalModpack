-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Core functions
require("prototypes.functions")

-- Compatibility with ShinyBobGFX (requires must be done in data-updates)
if mods["ShinyBobGFX"] then return end

-- No ShinyBobGFX, so conduct requires in data
require("shiny-bob-compatibility")