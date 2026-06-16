local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["RandomFactorioThings"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["nuclear-transport-belt"] = {
		logistics_technology = {
			name = "nuclear-logistics",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF00FF00"),
		},
	},
	["plutonium-transport-belt"] = {
		logistics_technology = {
			name = "plutonium-logistics",
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("DE00E1FF"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
