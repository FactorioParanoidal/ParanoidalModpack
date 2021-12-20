-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
-- Angel's Smelting
require("prototypes.entity.smelting.pipe")

-- Angel's Refining
require("prototypes.entity.refining.liquefier")

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.items.bioprocessing-modules")
require("prototypes.items.refining")
require("prototypes.items.smelting.ores")

-- angelspetrochem at this version or earlier do icon work in data-final-fixes
if reskins.lib.migration.is_newer_version(mods["angelspetrochem"], "0.9.19") then
    require("prototypes.items.petrochem")
    require("prototypes.items.petrochem.sulfur")
end

-- angelssmelting at this version or earlier does icon work in data-final-fixes
if reskins.lib.migration.is_newer_version(mods["angelssmelting"], "0.6.16") then
    require("prototypes.items.smelting")
end

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY
----------------------------------------------------------------------------------------------------
require("prototypes.technology.bioprocessing-modules")
-- require("prototypes.technology.refining-updates")
require("prototypes.technology.smelting-updates")

----------------------------------------------------------------------------------------------------
-- COMPATIBILITY
----------------------------------------------------------------------------------------------------
require("prototypes.compatibility.bobselectronics")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("angels", "data-updates")