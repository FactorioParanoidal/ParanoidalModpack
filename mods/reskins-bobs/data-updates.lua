-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
-- Bob's Assembly
require("prototypes.entity.assembly-updates")

-- Bob's Greenhouse
require("prototypes.entity.greenhouse.greenhouse") -- Nauvis Day tries to operate on Bob's Greenhouse in data-updates, need to execute after

-- Bob's Power
require("prototypes.entity.power.nuclear-reactor") -- Bob reskins in data-updates

-- Bob's Ores
require("prototypes.entity.ores.ores-updates")

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.item.electronics.circuits") -- Bob has circuit coloring in data-updates
require("prototypes.item.plates.battery") -- Bob has some battery updates in data-updates

----------------------------------------------------------------------------------------------------
-- TECHNOLOGIES
----------------------------------------------------------------------------------------------------
require("prototypes.technology.electronics-updates")
require("prototypes.technology.power-updates")
require("prototypes.technology.revamp-updates") -- Bob does tech updates in data-updates
require("prototypes.technology.technology-updates") -- Bob does tech updates in data-updates
require("prototypes.technology.warfare-updates") -- Bob does tech updates in data-updates

----------------------------------------------------------------------------------------------------
-- GUI Modifications
----------------------------------------------------------------------------------------------------
-- require("prototypes.item-group.item-group")

-- Assign deferred icons
reskins.lib.assign_deferred_icons("bobs", "data-updates")