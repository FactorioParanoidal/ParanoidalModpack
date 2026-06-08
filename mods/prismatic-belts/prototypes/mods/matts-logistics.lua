local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["matts-logistics"] then
	return
end

local default_animation_set = {
	base_tint = sprite_utils.colors.from_argb("FF737373"),
	tint_base_as_overlay = false,
}

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["ultra-fast-transport-belt"] = {
		logistics_technology = {
			name = "logistics-4",
		},
		belt_animation_set = util.merge({ default_animation_set, {
			mask_tint = sprite_utils.colors.from_argb("FF74CC66"),
		} }),
	},
	["extreme-fast-transport-belt"] = {
		logistics_technology = {
			name = "logistics-5",
		},
		belt_animation_set = util.merge({ default_animation_set, {
			mask_tint = sprite_utils.colors.from_argb("FFCC7E66"),
		} }),
	},
	["ultra-express-transport-belt"] = {
		logistics_technology = {
			name = "logistics-6",
		},
		belt_animation_set = util.merge({ default_animation_set, {
			mask_tint = sprite_utils.colors.from_argb("FF8F66CC"),
		} }),
	},
	["extreme-express-transport-belt"] = {
		logistics_technology = {
			name = "logistics-7",
		},
		belt_animation_set = util.merge({ default_animation_set, {
			mask_tint = sprite_utils.colors.from_argb("FF667ACC"),
		} }),
	},
	["ultimate-transport-belt"] = {
		logistics_technology = {
			name = "logistics-8",
		},
		belt_animation_set = util.merge({
			default_animation_set,
			{
				mask_tint = sprite_utils.colors.from_argb("FF737373"),
				arrow_tint = sprite_utils.colors.from_argb("FFB3B3B3"),
			},
		}),
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
