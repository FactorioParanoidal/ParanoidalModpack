-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Core functions
require("prototypes.functions.functions")
require("prototypes.functions.circuit-sprites")

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
-- Bob's Modules
require("prototypes.entity.modules.beacon-module-slots")

-- Bob's Ores
require("prototypes.entity.ores.ores")

----------------------------------------------------------------------------------------------------
-- COMPATIBILITY
----------------------------------------------------------------------------------------------------
-- Compatibility with ShinyBobGFX (requires must be done in data-updates)
if mods["ShinyBobGFX"] then return end

-- No ShinyBobGFX, so conduct requires in data
require("shiny-bob-compatibility")