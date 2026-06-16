local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["5dim_transport"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["5d-transport-belt-04"] = {
		logistics_technology = {
			name = "logistics-4",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFFA8F9"),
		},
	},
	["5d-transport-belt-05"] = {
		logistics_technology = {
			name = "logistics-5",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF58FF4F"),
		},
	},
	["5d-transport-belt-06"] = {
		logistics_technology = {
			name = "logistics-6",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFB18E77"),
		},
	},
	["5d-transport-belt-07"] = {
		logistics_technology = {
			name = "logistics-7",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFA168C7"),
		},
	},
	["5d-transport-belt-08"] = {
		logistics_technology = {
			name = "logistics-8",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFCDCDCB"),
		},
	},
	["5d-transport-belt-09"] = {
		logistics_technology = {
			name = "logistics-9",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFF9736"),
		},
	},
	["5d-transport-belt-10"] = {
		logistics_technology = {
			name = "logistics-10",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF9A9BFF"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
