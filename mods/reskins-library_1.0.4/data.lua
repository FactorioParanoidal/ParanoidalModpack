-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Core functions
require("prototypes.functions")
require("prototypes.functions.entity-rescaling")
require("prototypes.functions.icon-handling")
require("prototypes.label-items")

-- Compatibility with ShinyBobGFX/ShinyAngelGFX (requires must be done in data-updates)
if mods["ShinyBobGFX"] or mods["ShinyAngelGFX"] then return end

-- No ShinyBobGFX/ShinyAngelGFX, so conduct requires in data
require("shiny-compatibility")