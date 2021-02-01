-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.items.refining")
require("prototypes.items.petrochem")
require("prototypes.items.petrochem.sulfur")
require("prototypes.items.smelting")

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY
----------------------------------------------------------------------------------------------------
-- require("prototypes.technology.smelting-final-fixes")

----------------------------------------------------------------------------------------------------
-- COMPATIBILITY
----------------------------------------------------------------------------------------------------
require("prototypes.compatibility.angels-smelting-extended-items")
require("prototypes.compatibility.bobselectronics")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("angels", "data-final-fixes")