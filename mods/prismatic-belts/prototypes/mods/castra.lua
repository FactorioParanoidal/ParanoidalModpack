local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["castra"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["military-transport-belt"] = {
		logistics_technology = {
			name = "military-transport-belt",
			base_tint = sprite_utils.colors.from_argb("FFDEDCF5"),
		},
		belt_icon = {
			base_tint = sprite_utils.colors.from_argb("FFDEDCF5"),
		},
		belt_animation_set = {
			base_tint = sprite_utils.colors.from_argb("FF6B6A75"),
			mask_tint = sprite_utils.colors.from_argb("FFB37D47"),
			tint_base_as_overlay = true,
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
