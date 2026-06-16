local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["ev-logistics"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["hyper-transport-belt"] = {
		logistics_technology = {
			name = "hyper-logistics",
			arrow_tint = sprite_utils.colors.from_argb("FFA673F2"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF9753f6"),
			arrow_tint = sprite_utils.colors.from_argb("FF6302f1"),
		},
		belt_icon = {
			arrow_tint = sprite_utils.colors.from_argb("FFA673F2"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
