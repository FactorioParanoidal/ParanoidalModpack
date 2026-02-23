-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
require("prototypes.entity.petrochem-updates")

-- Angel's Smelting
require("prototypes.entity.smelting.pipe")

-- Angel's Refining
require("prototypes.entity.refining.liquefier")

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.items.refining-updates")
require("prototypes.items.smelting.ores")
require("prototypes.items.petrochem")
require("prototypes.items.petrochem.sulfur")
require("prototypes.items.smelting-updates")

-- Second pass
require("prototypes.items.refining-secondary-updates")

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY
----------------------------------------------------------------------------------------------------
-- require("prototypes.technology.refining-updates")
require("prototypes.technology.smelting-updates")

----------------------------------------------------------------------------------------------------
-- GUI Modifications
----------------------------------------------------------------------------------------------------
-- FIXME: This is a temporary disablement of the item group icons, until new ones are created.
-- require("prototypes.item-group.item-group")
