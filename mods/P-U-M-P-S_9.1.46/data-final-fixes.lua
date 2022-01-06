------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Local functions host
local OSM_local = require("utils.lib")
local OSM_anim = require("utils.animation")

-- Prevent collision mask mismatch
OSM_local.fix_collision_mask()

-- Make vanilla offshore pump minable
data.raw["offshore-pump"]["offshore-pump"].minable = {mining_time = 0.1, result = "offshore-pump-1"}

-- Make upgradable
if settings.startup ["enable-power"].value == true then
	data.raw["assembling-machine"]["offshore-pump-1"].next_upgrade = "offshore-pump-2-placeholder"
	data.raw["assembling-machine"]["offshore-pump-2"].next_upgrade = "offshore-pump-3-placeholder"
	data.raw["assembling-machine"]["offshore-pump-3"].next_upgrade = "offshore-pump-4-placeholder"
else
	data.raw["offshore-pump"]["offshore-pump-1"].next_upgrade = "offshore-pump-2"
	data.raw["offshore-pump"]["offshore-pump-2"].next_upgrade = "offshore-pump-3"
	data.raw["offshore-pump"]["offshore-pump-3"].next_upgrade = "offshore-pump-4"
end
