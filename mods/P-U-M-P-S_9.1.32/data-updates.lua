--------------------------
---- data-updates.lua ----
--------------------------

-- Apply overrides
--require("prototypes.override.bob-water-miner-updates")
require("prototypes.override.bob-overrides")
--require("prototypes.override.angel-overrides")

-- Do Kirazy's business in a very clumsy way
--local pumpjack_tiering = require("utils.animation").pumpjack_tiering
local assign_icon_tier = require("utils.lib").assign_icon_tier

-- Ground water pumpjacks
--[[
if (mods["reskins-bobs"] and (reskins.bobs and reskins.bobs.triggers.mining.entities)) then

	-- Setup entity host
	local tier_map_pumpjacks=
	{
		["water-pumpjack-1"] = {1},
		["water-pumpjack-2"] = {2},
		["water-pumpjack-3"] = {3},
		["water-pumpjack-4"] = {4},
		["water-pumpjack-5"] = {5}
	}
	-- Set inputs
	local type = "assembling-machine"
	local mask = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-mask.png"
	local highlights = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-highlights.png"

	-- Reskin entities
pumpjack_tiering()

	-- Reskin icons
	for name, map in pairs(tier_map_pumpjacks) do
		if data.raw.item[name] then
			assign_icon_tier(name, type, map, mask, highlights)
		end
	end
end
]]--