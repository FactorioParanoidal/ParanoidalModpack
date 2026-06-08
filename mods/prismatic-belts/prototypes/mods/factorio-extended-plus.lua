local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not (mods["FactorioExtended-Plus-Transport"] or mods["FactorioExtended-Plus-Transport2"]) then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["rapid-transport-belt-mk1"] = {
		logistics_technology = {
			name = "logistics-4",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("D12CD529"),
		},
	},
	["rapid-transport-belt-mk2"] = {
		logistics_technology = {
			name = "logistics-5",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("D19A2CC9"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
