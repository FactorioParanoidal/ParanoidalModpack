local api = require("prototypes.api")
local sprite_utils = { colors = require("__reskins-sprite-utils__.colors") }

if not (mods["exotic-space-industries"] or mods["exotic-space-industries-remembrance"]) then
	return
end

---@type PrismaticBelts.TransportBeltInputsMapping
local transport_belt_inputs_map = {
	["ei-neo-belt"] = {
		logistics_technology = { name = "ei-neo-logistics" },
		belt_animation_set = {
			base_tint = sprite_utils.colors.from_argb("FF575769"),
			mask_tint = sprite_utils.colors.from_argb("FFC34DFF"),
			arrow_tint = sprite_utils.colors.from_argb("FFAC00E5"),
			tint_base_as_overlay = true,
		},
	},
}

api.transform_belts_and_related_connectables(transport_belt_inputs_map)
