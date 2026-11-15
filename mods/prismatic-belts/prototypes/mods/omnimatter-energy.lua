local api = require("prototypes.api")
local sprite_utils = {
	icons = require("__reskins-sprite-utils__.icons"),
	colors = require("__reskins-sprite-utils__.colors"),
}

if not mods["omnimatter_energy"] then
	return
end

local transport_belts = {
	["basic-transport-belt"] = {
		mask_tint = sprite_utils.colors.from_argb("D17D7D7D"),
		logistics_technology = "logistics-0",
	},
}

local is_reskin_adaptation_needed = mods["reskins-library"] and not (reskins.bobs and (reskins.bobs.triggers.logistics.entities == false))
if is_reskin_adaptation_needed then
	transport_belts["basic-transport-belt"].tier = 0

	transport_belts["basic-transport-belt"].mask_tint = reskins.lib.tiers.get_belt_tint(0)
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

-- Apply recipe icon fixes, as Omnienergy does not set main_product for the single-item belt recipes
-- and so the icons do not automatically resolve.
local recipes = {
    "basic-transport-belt",
    "transport-belt",
}

for _, name in pairs(recipes) do
    local item = data.raw.item[name]
    if not item then goto continue end

    local recipe = data.raw.recipe[name]
    if not recipe then goto continue end

    recipe.icons = item.icons

    ::continue::
end