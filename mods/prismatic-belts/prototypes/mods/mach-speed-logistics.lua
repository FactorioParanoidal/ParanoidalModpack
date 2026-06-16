local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["mach-speed-logistics"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["mach-transport-belt"] = {
		logistics_technology = {
			name = "mach-speed-logistics",
			structure_tint = sprite_utils.colors.from_argb("FFB800CC")
		},
		belt_animation_set = {
			base_tint = sprite_utils.colors.from_argb("FF404040"),
			mask_tint = sprite_utils.colors.from_argb("D1A11EAB"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
