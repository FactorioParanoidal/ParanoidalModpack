local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["AdvancedBeltsSA"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["extreme-belt"] = {
		logistics_technology = {
			name = "extreme-logistics",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF2BFFE6"),
		},
	},
	["ultimate-belt"] = {
		logistics_technology = {
			name = "ultimate-logistics",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFF7F4D"),
		},
	},
	["high-speed-belt"] = {
		logistics_technology = {
			name = "high-speed-logistics",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFF12BFF"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
