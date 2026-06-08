local api = require("prototypes.api")
local sprite_utils = { icons = require("__reskins-sprite-utils__.icons") }

-- Periodic Madness re-sequences the belts.
if mods["periodic-madness"] then
	return
end

local transport_belts = {
	["transport-belt"] = {
		logistics_technology_name = "logistics",
		belt_sprites = api.defines.belt_sprites.standard,
		belt_preset = api.defines.belt_presets.standard,
	},
	["fast-transport-belt"] = {
		logistics_technology_name = "logistics-2",
		belt_sprites = api.defines.belt_sprites.fast,
		belt_preset = api.defines.belt_presets.fast,
	},
	["express-transport-belt"] = {
		logistics_technology_name = "logistics-3",
		belt_sprites = api.defines.belt_sprites.fast,
		belt_preset = api.defines.belt_presets.express,
	},
}

local is_reskin_adaptation_needed = mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false))
if is_reskin_adaptation_needed then
	transport_belts["transport-belt"].tier = 1
	transport_belts["fast-transport-belt"].tier = 2
	transport_belts["express-transport-belt"].tier = 3

	if reskins.lib.settings.get_value("reskins-lib-customize-tier-colors") then
		transport_belts["transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(1)
		transport_belts["fast-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(2)
		transport_belts["express-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(3)
	end
end

for name, options in pairs(transport_belts) do
	local entity = data.raw["transport-belt"][name]
	if not entity then
		goto continue
	end

	local preset = api.get_preset(options.belt_preset)

	---@type data.IconData[]
	local icon_data = options.mask_tint and api.get_transport_belt_icon({
		mask_tint = options.mask_tint,
	}) or { preset.icon }

	---@type DeferrableIconData
	local deferrable_icon = {
		name = entity.name,
		type_name = entity.type,
		icon_data = icon_data,
	}

	if is_reskin_adaptation_needed then
		-- Append tier labels for reskins-library
		local do_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") == true
		deferrable_icon.icon_data = do_labels and reskins.lib.tiers.add_tier_labels_to_icons(options.tier, icon_data) or icon_data
		deferrable_icon.pictures = do_labels and reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0) or nil
	end

	sprite_utils.icons.assign_deferrable_icon(deferrable_icon)

	local animation_set = options.mask_tint and api.get_transport_belt_animation_set({
		mask_tint = options.mask_tint,
		belt_sprites = options.belt_sprites,
	}) or preset.belt_animation_set
	api.apply_belt_animation_set_and_update_related_connectables(entity, animation_set, {
		mask_tint = options.mask_tint or preset.tint,
	})

	if options.mask_tint then
		api.create_or_update_remnants(entity.name, { mask_tint = options.mask_tint })
	else
		local remnants = data.raw["corpse"][entity.name .. "-remnants"]

		if remnants then
			remnants.icons = entity.icons
			remnants.icon = entity.icon
			remnants.icon_size = entity.icon_size
			remnants.animation = preset.remnants_animation
		end
	end

	---@type DeferrableIconData
	local assignable_tech_icon = {
		name = options.logistics_technology_name,
		type_name = "technology",
		icon_data = options.mask_tint and api.get_transport_belt_technology_icon({
			mask_tint = options.mask_tint,
		}) or { preset.technology_icon },
	}
	sprite_utils.icons.assign_deferrable_icon(assignable_tech_icon)

	::continue::
end
