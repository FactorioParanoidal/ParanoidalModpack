local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["BetterBelts"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["BetterBelts_ultra-transport-belt"] = {
		logistics_technology = {
			name = "BetterBelts_ultra-class",
			structure_tint = sprite_utils.colors.from_argb("FF14CC14"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF40CB4A"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
