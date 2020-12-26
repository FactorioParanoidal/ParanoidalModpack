-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Compatibility with ShinyBobGFX/ShinyAngelGFX
if mods["ShinyBobGFX"] or mods["ShinyAngelGFX"] then
    require("shiny-compatibility")
end

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
require("prototypes.entity.base.nuclear-reactor")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("lib", "data-updates")