local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not (mods["UltimateBelts"] or mods["UltimateBeltsSpaceAge"] or mods["NovasUltimateBelts"] or mods["UltimateBeltsSpaceAgeFork"]) then
	return
end

local default_base_tint = sprite_utils.colors.from_argb("FF404040")

---@type PrismaticBelts.TransportBeltIconInputs
local default_belt_icon = {
	use_three_arrow_variant = true,
}

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["ultra-fast-belt"] = {
		logistics_technology = {
			name = "ultra-fast-logistics",
		},
		belt_icon = default_belt_icon,
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("FF00B30C"),
		},
		forced_connectable_belt_entities = {
			{ name = "ultra-fast-splitter", type_name = "splitter" },
		},
	},
	["extreme-fast-belt"] = {
		logistics_technology = {
			name = "extreme-fast-logistics",
			arrow_tint = { 0.2, 0.2, 0.2, 0 },
		},
		belt_icon = util.merge({ default_belt_icon, { arrow_tint = { 0.2, 0.2, 0.2, 0 } } }),
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("FFE00000"),
			arrow_tint = sprite_utils.colors.from_argb("FF555555"),
		},
	},
	["ultra-express-belt"] = {
		logistics_technology = {
			name = "ultra-express-logistics",
			arrow_tint = { 0.2, 0.2, 0.2, 0 },
		},
		belt_icon = util.merge({ default_belt_icon, { arrow_tint = { 0.2, 0.2, 0.2, 0 } } }),
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("E83604B5"),
			arrow_tint = sprite_utils.colors.from_argb("FF555555"),
		},
	},
	["extreme-express-belt"] = {
		logistics_technology = {
			name = "extreme-express-logistics",
			arrow_tint = { 0.2, 0.2, 0.2, 0 },
		},
		belt_icon = util.merge({ default_belt_icon, { arrow_tint = { 0.2, 0.2, 0.2, 0 } } }),
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("FF002BFF"),
			arrow_tint = sprite_utils.colors.from_argb("FF555555"),
		},
	},
	["ultimate-belt"] = {
		logistics_technology = {
			name = "ultimate-logistics",
		},
		belt_icon = default_belt_icon,
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("D100FFDD"),
		},
		forced_connectable_belt_entities = {
			{ name = "original-ultimate-splitter", type_name = "splitter" },
			{ name = "original-ultimate-underground-belt", type_name = "underground-belt" },
		},
	},
	["original-ultimate-belt"] = {
		logistics_technology = {
			name = "original-ultimate-logistics",
		},
		belt_icon = default_belt_icon,
		belt_animation_set = {
			base_tint = default_base_tint,
			mask_tint = sprite_utils.colors.from_argb("D100FFDD"),
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
