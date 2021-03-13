-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

--[[ TODO:
0. Move compatibility features into this mod
--> Centralize belt tier/color handling, have it determined in a central location and then have the entities all be mapped to a given tier and pull the tint information from there
--> Have belt color and tier determined in library initial functions, Angels/Bobs/Compat can then pull from whatever is set in that location

1. Mini-machine symbol for icons
2. Circuit-processing circuit color overrides
3. Circuit-processing full uniqueness
4. Chromatic belts

]]--

-- Core functions
require("prototypes.functions.functions")
require("prototypes.functions.circuitprocessing-sprites")

-- Mods
require("prototypes.mods.classic-beacon")
require("prototypes.mods.classic-mining-drill")
-- require("prototypes.mods.electricboiler")
require("prototypes.mods.loaderredux")
require("prototypes.mods.miniloader")
require("prototypes.mods.semi-classic-mining-drill")
require("prototypes.mods.vanilla-loaders-hd")