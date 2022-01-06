--------------------------
---- data-updates.lua ----
--------------------------

-- Local functions host
local OSM_local = require("utils.lib")
local OSM_anim = require("utils.animation")

-- Apply overrides
require("prototypes.override.bob-updates")

require("prototypes.override.bob-overrides")

for _, technology in pairs(data.raw.technology) do
	if technology.effects then
		local effects = technology.effects

		if effects then
			for _, effect in pairs(effects) do
				if effect.type == "unlock-recipe" and effect.recipe == "offshore-pump" then
					OSM.lib.technology.replace_unlock("offshore-pump", "offshore-pump-1")
					OSM.lib.technology.remove_unlock("offshore-pump-1", "fluid-handling")
				end
			end
		end
	end
end

-- Replace recipe result/ingredient
OSM.lib.recipe.replace_ingredient("offshore-pump", "offshore-pump-1")
OSM.lib.recipe.replace_result("offshore-pump", "offshore-pump-1")

-- Ground water pumpjacks
if (mods["reskins-bobs"] and (reskins.bobs and reskins.bobs.triggers.mining.entities)) then

	-- Reskin entities
	OSM_local.pumpjack_entity_tiering()

	-- Reskin icons
	OSM_local.pumpjack_icon_tiering()
end