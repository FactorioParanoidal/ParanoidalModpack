local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["Belts_Pro"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["advanced-transport-belt"] = {
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF62E856"),
		},
	},
	["superior-transport-belt"] = {
		logistics_technology = {
			name = "superior-belts",
			structure_tint = sprite_utils.colors.from_argb("FFAA00CC"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFDE66FF"),
		},
	},
	["ultrasuperior-transport-belt"] = {
		logistics_technology = {
			name = "ultrasuperior-belts",
			structure_tint = sprite_utils.colors.from_argb("FFFF0080"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFCC3380"),
			arrow_tint = sprite_utils.colors.from_argb("FFFD0071"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
