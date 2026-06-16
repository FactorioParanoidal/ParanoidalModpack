local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["beyond-belts"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["bb-hyper-belt"] = {
		logistics_technology = { name = "bb-hyper-logistics" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF2EE5D0"),
		},
	},
	["bb-extreme-belt"] = {
		logistics_technology = { name = "bb-extreme-logistics" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFFF7040"),
		},
	},
	["bb-ultimate-belt"] = {
		logistics_technology = { name = "bb-ultimate-logistics" },
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFF04DFF"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
