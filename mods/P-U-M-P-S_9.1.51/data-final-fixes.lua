------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Local functions host
local OSM_local = require("utils.lib")
local OSM_anim = require("utils.animation")

-- Prevent collision mask mismatch
OSM_local.fix_collision_mask()

-- Replace recipe tech/result/ingredient and make vanilla offshore pump minable
OSM.lib.technology.remove_unlock("offshore-pump")
OSM.lib.recipe.replace_ingredient("offshore-pump", "offshore-pump-1")
OSM.lib.recipe.replace_result("offshore-pump", "offshore-pump-1")
data.raw["offshore-pump"]["offshore-pump"].minable = {mining_time = 0.1, result = "offshore-pump-1"}

-- Make upgradable
if settings.startup ["osm-pumps-enable-power"].value == true then
	data.raw["assembling-machine"]["offshore-pump-1"].next_upgrade = "offshore-pump-2-placeholder"
	data.raw["assembling-machine"]["offshore-pump-2"].next_upgrade = "offshore-pump-3-placeholder"
	data.raw["assembling-machine"]["offshore-pump-3"].next_upgrade = "offshore-pump-4-placeholder"
else
	data.raw["offshore-pump"]["offshore-pump-1"].next_upgrade = "offshore-pump-2"
	data.raw["offshore-pump"]["offshore-pump-2"].next_upgrade = "offshore-pump-3"
	data.raw["offshore-pump"]["offshore-pump-3"].next_upgrade = "offshore-pump-4"
end
