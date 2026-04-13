-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
-- if not reskins.bobs then return end
if not mods["deadlock-beltboxes-loaders"] then
	return
end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then
	return
end

-- Set input parameters
local inputs = {
	base_entity_name = "underground-belt",
	mod = "compatibility",
	particles = { ["medium"] = 3, ["small"] = 2 },
	make_icons = false,
	make_remnants = false,
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
	["basic-transport-belt-loader"] = { tier = 0, is_loader = true, set_type = reskins.lib.defines.belt_sprites.standard },
	["transport-belt-loader"] = { tier = 1, is_loader = true, set_type = reskins.lib.defines.belt_sprites.standard },
	["fast-transport-belt-loader"] = { tier = 2, is_loader = true, set_type = reskins.lib.defines.belt_sprites.express },
	["express-transport-belt-loader"] = { tier = 3, is_loader = true, set_type = reskins.lib.defines.belt_sprites.express },
	["turbo-transport-belt-loader"] = { tier = 4, is_loader = true, set_type = reskins.lib.defines.belt_sprites.express },
	["ultimate-transport-belt-loader"] = { tier = 5, is_loader = true, set_type = reskins.lib.defines.belt_sprites.express },
	["basic-transport-belt-beltbox"] = { tier = 0, set_type = reskins.lib.defines.belt_sprites.standard },
	["transport-belt-beltbox"] = { tier = 1, set_type = reskins.lib.defines.belt_sprites.standard },
	["fast-transport-belt-beltbox"] = { tier = 2, set_type = reskins.lib.defines.belt_sprites.express },
	["express-transport-belt-beltbox"] = { tier = 3, set_type = reskins.lib.defines.belt_sprites.express },
	["turbo-transport-belt-beltbox"] = { tier = 4, set_type = reskins.lib.defines.belt_sprites.express },
	["ultimate-transport-belt-beltbox"] = { tier = 5, set_type = reskins.lib.defines.belt_sprites.express },
}

local function light_tint(tint)
	local white = 0.95
	return { r = (tint.r + white) / 2, g = (tint.g + white) / 2, b = (tint.b + white) / 2 }
end

local function tweak_tint(tint)
	local hsl_tint = reskins.lib.RGBtoHSL(tint)
	hsl_tint.s = (hsl_tint.s - 0.1 >= 0) and hsl_tint.s - 0.1 or 0
	-- hsl_tint.l = (hsl_tint.l - 0.2 >= 0) and hsl_tint.l - 0.2 or 0

	return reskins.lib.HSLtoRGB(hsl_tint)
end

-- Reskin entities
for name, map in pairs(tier_map) do
	-- Determine type
	if map.is_loader then
		inputs.type = "loader-1x1"
	else
		inputs.type = "furnace"
	end

	---@type data.FurnacePrototype|data.Loader1x1Prototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = tweak_tint(reskins.lib.tiers.get_belt_tint(map.tier))

	reskins.lib.setup_standard_entity(name, map.tier, inputs)

	---@type data.IconData[]
	local icon_data
	if map.is_loader then
		---@cast entity data.Loader1x1Prototype

		-- Retint the mask
		entity.structure.direction_in.sheets[3].tint = inputs.tint
		entity.structure.direction_out.sheets[3].tint = inputs.tint

		-- Apply belt set
		-- entity.belt_animation_set = reskins.lib.sprites.belts.get_belt_animation_set(map.set_type, inputs.tint)

		icon_data = {
			{
				icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-base.png",
				icon_size = 64,
				scale = 0.5,
			},
			{
				icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-mask.png",
				icon_size = 64,
				scale = 0.5,
				tint = inputs.tint,
			},
		}
	else
		---@cast entity data.FurnacePrototype

		-- Retint the mask
		entity.graphics_set.animation.layers[2].tint = inputs.tint
		entity.graphics_set.working_visualisations[1].animation.tint = light_tint(inputs.tint)
		entity.graphics_set.working_visualisations[1].light.color = light_tint(inputs.tint)

		icon_data = {
			{
				icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-base.png",
				icon_size = 64,
				scale = 0.5,
			},
			{
				icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-mask.png",
				icon_size = 64,
				scale = 0.5,
				tint = inputs.tint,
			},
		}
	end

	---@type DeferrableIconData
	local deferrable_icon = {
		name = entity.name,
		type_name = entity.type,
		icon_data = reskins.lib.tiers.add_tier_labels_to_icons(map.tier, icon_data),
		pictures = reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0),
	}

	reskins.lib.icons.assign_deferrable_icon(deferrable_icon)

	::continue::
end

-- Technology
local tech_map = {
	["basic-transport-belt-beltbox"] = 0,
	["deadlock-stacking-1"] = 1,
	["deadlock-stacking-2"] = 2,
	["deadlock-stacking-3"] = 3,
	["deadlock-stacking-4"] = 4,
	["deadlock-stacking-5"] = 5,
}

-- Reskin technologies
for name, tier in pairs(tech_map) do
	if data.raw.technology[name] then
		---@type DeferrableIconData
		local deferrable_icon = {
			name = name,
			type_name = "technology",
			icon_data = reskins.lib.icons.add_missing_icons_defaults({
				{
					icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/beltbox-icon-base-128.png",
					icon_size = 128,
				},
				{
					icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/beltbox-icon-mask-128.png",
					icon_size = 128,
					tint = reskins.lib.tiers.get_belt_tint(tier),
				},
			}, true),
		}

		reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
	end
end
