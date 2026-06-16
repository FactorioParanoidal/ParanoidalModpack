local api = require("prototypes.api")
local migration = require("__flib__.migration")
local sprite_utils = {
	icons = require("__reskins-sprite-utils__.icons"),
	colors = require("__reskins-sprite-utils__.colors"),
}

if not mods["boblogistics"] then
	return
end

local transport_belts = {
	["bob-basic-transport-belt"] = {
		mask_tint = sprite_utils.colors.from_argb("D17D7D7D"),
		logistics_technology = "logistics-0",
	},
	["bob-turbo-transport-belt"] = {
		mask_tint = sprite_utils.colors.from_argb("D1A510E5"),
		logistics_technology = "logistics-4",
	},
	["bob-ultimate-transport-belt"] = {
		mask_tint = sprite_utils.colors.from_argb("D116F263"),
		logistics_technology = "logistics-5",
	},
}

local function is_same_or_newer(version, version_to_compare_with)
	local v1 = migration.format_version(version)
	local v2 = migration.format_version(version_to_compare_with)

	if v1 and v2 then
		return v1 >= v2
	end
	return nil
end

if is_same_or_newer(mods["boblibrary"], "2.1.0") then
	transport_belts["turbo-transport-belt"] = transport_belts["bob-turbo-transport-belt"]
end

local is_reskin_adaptation_needed = mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false))
if is_reskin_adaptation_needed then
	transport_belts["bob-basic-transport-belt"].tier = 0
	transport_belts["bob-turbo-transport-belt"].tier = 4
	transport_belts["bob-ultimate-transport-belt"].tier = 5

	transport_belts["bob-basic-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(0)
	transport_belts["bob-turbo-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(4)
	transport_belts["bob-ultimate-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(5)
end

-- Setup all the entities to use the updated belt animation sets
for name, options in pairs(transport_belts) do
	local entity = data.raw["transport-belt"][name]
	if not entity then
		goto continue
	end

	local icon_data = api.get_transport_belt_icon({
		mask_tint = options.mask_tint,
	})

	---@type DeferrableIconData
	local assignable_belt_icon = {
		name = entity.name,
		type_name = entity.type,
		icon_data = icon_data,
	}

	if is_reskin_adaptation_needed then
		-- Append tier labels for reskins-library
		local do_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") == true
		assignable_belt_icon.icon_data = do_labels and reskins.lib.tiers.add_tier_labels_to_icons(options.tier, icon_data) or icon_data
		assignable_belt_icon.pictures = do_labels and reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0) or nil
	end

	sprite_utils.icons.assign_deferrable_icon(assignable_belt_icon)

	local animation_set = api.get_transport_belt_animation_set({
		mask_tint = options.mask_tint,
		belt_sprites = api.defines.belt_sprites.turbo,
	})
	api.apply_belt_animation_set_and_update_related_connectables(entity, animation_set)

	api.create_or_update_remnants(entity.name, { mask_tint = options.mask_tint })

	---@type DeferrableIconData
	local assignable_tech_icon = {
		name = options.logistics_technology,
		type_name = "technology",
		icon_data = api.get_transport_belt_technology_icon({ mask_tint = options.mask_tint }),
	}
	sprite_utils.icons.assign_deferrable_icon(assignable_tech_icon)

	::continue::
end
