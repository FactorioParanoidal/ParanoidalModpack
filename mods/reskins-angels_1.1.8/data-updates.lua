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
require("prototypes.entity.refining.liquifier")

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.items.bioprocessing-modules")
require("prototypes.items.smelting.ores")

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY
----------------------------------------------------------------------------------------------------
require("prototypes.technology.bioprocessing-modules")
require("prototypes.technology.smelting-updates")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("angels", "data-updates")