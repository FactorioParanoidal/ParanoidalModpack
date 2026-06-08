local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["rapid-belts-t4"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["rapid-transport-belt"] = {
		logistics_technology = { name = "logistics-4" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFD1E595"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
