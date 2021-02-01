-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Assign deferred icons
reskins.lib.assign_deferred_icons("bobs", "data-final-fixes")

----------------------------------------------------------------------------------------------------
-- COMPATIBILITY
----------------------------------------------------------------------------------------------------
require("prototypes.compatibility.mini-machines") -- This must be called after icons are handled
require("prototypes.compatibility.deadlock-crating") -- DeadlockCrating sets up machines in data-final-fixes
require("prototypes.compatibility.deadlock-stacking-addons")