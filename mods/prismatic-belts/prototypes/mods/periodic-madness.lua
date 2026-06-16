local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not mods["periodic-madness"] then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["transport-belt"] = {
		preset = api.defines.belt_presets.standard,
		logistics_technology_name = "logistics",
	},
	["fast-transport-belt"] = {
		logistics_technology = {
			name = "logistics-2",
			structure_tint = sprite_utils.colors.from_argb("ffff4000"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("d1f36f37"),
		},
	},
	["pm-advanced-transport-belt"] = {
		preset = api.defines.belt_presets.fast,
		logistics_technology_name = "logistics-3",
	},
	["express-transport-belt"] = {
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("ff33b4ff"),
		},
		logistics_technology = {
			name = "pm-logistics-4",
		},
	},
	["pm-high-density-transport-belt"] = {
		logistics_technology = {
			name = "pm-logistics-5",
            structure_tint = sprite_utils.colors.from_argb("ff7b4cd9"),
		},
		belt_animation_set = {
			mask_tint = sprite_utils.colors.from_argb("d1d480ff"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
