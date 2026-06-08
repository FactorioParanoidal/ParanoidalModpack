local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["factorioplus"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["basic-transport-belt"] = {
		logistics_technology = { name = "logistics-basic" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("D17D7D7D"),
		},
	},
	["turbo-transport-belt"] = {
		logistics_technology = { name = "logistics-4" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF8AE58A"),
		},
	},
	["supersonic-transport-belt"] = {
		logistics_technology = { name = "logistics-5" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFCC8BE4"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
