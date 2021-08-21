--------------------------
---- data-updates.lua ----
--------------------------

-- Apply overrides
require("prototypes.override.bob-overrides")
--require("prototypes.override.angel-overrides")

-- Do Kirazy's business in a very clumsy way
--local pumpjack_tiering = require("utils.animation").pumpjack_tiering
local assign_icon_tier = require("utils.lib").assign_icon_tier

local entity_type =
{
	"offshore-pump",
	"assembling-machine"
}

-- Offshore pumps
if (mods["reskins-bobs"] and (reskins.bobs and reskins.bobs.triggers.logistics.entities)) then

	-- Setup entity host
	local tier_map_offshore =
	{
		["offshore-pump-1"] = {1},
		["offshore-pump-2"] = {2},
		["offshore-pump-3"] = {3},
		["offshore-pump-4"] = {4}
	}
	-- Reskin icons
	for name, map in pairs(tier_map_offshore) do
		for _, type in pairs(entity_type) do
			assign_icon_tier(name, type, map)
		end
	end
end

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
	-- Set icon paths
	local mask = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-mask.png"
	local highlights = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-highlights.png"

	-- Reskin entities
pumpjack_tiering()

	-- Reskin icons
	for name, map in pairs(tier_map_pumpjacks) do
		for _, type in pairs(entity_type) do
			assign_icon_tier(name, type, map, mask, highlights)
		end
	end
end
]]--