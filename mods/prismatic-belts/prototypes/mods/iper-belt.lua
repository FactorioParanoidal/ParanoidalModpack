local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["iper-belt"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["iper-transport-belt"] = {
		logistics_technology = {
			name = "iper-transport-belts",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF5D65D9"),
			arrow_tint = sprite_utils.colors.from_argb("FF2B3DF1"),
		},
		belt_icon = {
			arrow_tint = sprite_utils.colors.from_argb("FFa6acff"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
