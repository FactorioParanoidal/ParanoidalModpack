local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["quantum-belts"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["quantum-belt"] = {
		logistics_technology = { name = "quantum-logistics" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFD92EE5"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
