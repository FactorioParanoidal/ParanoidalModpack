------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Set mod name
OSM.mod = "Offshore P.U.M.P.S."

-- Local functions host
local OSM_local = require("utils.lib")

-- Prevent collision mask mismatch
OSM_local.fix_collision_mask()

-- Replace recipe tech/result/ingredient and make vanilla offshore pump minable
OSM.lib.technology_remove_unlock("offshore-pump")
OSM.lib.recipe_replace_ingredient("offshore-pump", "offshore-pump-1")
OSM.lib.recipe_replace_result("offshore-pump", "offshore-pump-1")
data.raw["offshore-pump"]["offshore-pump"].minable.result = "offshore-pump-1"

OSM.mod = nil