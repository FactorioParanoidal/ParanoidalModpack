-- Quality switched off: the mod adds nothing (see scripts/switches.lua).
if not require("scripts.switches").quality() then return end

require("prototypes.utils")
require("prototypes.quality-base")
require("prototypes.qualities")
