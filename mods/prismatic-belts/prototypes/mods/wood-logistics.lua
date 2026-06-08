local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["wood-logistics"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["wood-transport-belt"] = {
		logistics_technology = {
			name = "wood-logistics",
			structure_tint = sprite_utils.colors.from_argb("FFA15A40"),
			arrow_tint = sprite_utils.colors.from_argb("FFAE7E6A"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFAE7E6A"),
			arrow_tint = sprite_utils.colors.from_argb("FF864828"),
			arrow_blend_mode = "normal",
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
