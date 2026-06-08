local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not (mods["promethium-belts"] or mods["promethium-belts-rebalance"]) then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["promethium-transport-belt"] = {
		logistics_technology = {
			name = "promethium-transport-belt",
			structure_tint = sprite_utils.colors.from_argb("FFFF1AF4"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFDD5FC1"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
