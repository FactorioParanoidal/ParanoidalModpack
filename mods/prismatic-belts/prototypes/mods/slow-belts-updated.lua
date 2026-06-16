local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["slow-belts-updated"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["slowest-belt"] = {
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFDF8CBF"),
		},
	},
	["slower-belt"] = {
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FFDD9370"),
		},
	},
	["slow-belt"] = {
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("FF6D77B9"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
