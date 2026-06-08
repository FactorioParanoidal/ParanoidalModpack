local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not (mods["Krastorio2"] or mods["Krastorio2-spaced-out"]) then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["kr-advanced-transport-belt"] = {
		logistics_technology = {
			name = "kr-logistic-4",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("d13ade21"),
		},
	},
	["kr-superior-transport-belt"] = {
		logistics_technology = {
			name = "kr-logistic-5",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("d1a30bd6"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
