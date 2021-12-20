-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Final set of overrides
require("prototypes.functions.overrides-final-fixes")

-- Mods
require("prototypes.mods.bio-industries") -- Bio Industries does a lot of work on icons in data-final-fixes
require("prototypes.mods.mini-machines") -- Mini-machines sets up machines in data-final-fixes
require("prototypes.mods.deadlock-crating") -- DeadlockCrating sets up machines in data-final-fixes
require("prototypes.mods.deadlock-stacking-addons.science-packs") -- Stack items and recipes are generated in data-final-fixes
require("prototypes.mods.angels-smelting-extended.angels-smelting-extended-items")
require("prototypes.mods.spaceblock") -- Spaceblock matter furnace is setup in data-final-fixes

-- Assign deferred icons
reskins.lib.assign_deferred_icons("compatibility", "data-final-fixes")