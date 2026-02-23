-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["DeadlockCrating"] and not mods["IntermodalContainers"] then
	return
end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	make_icons = false,
	make_remnants = false,
}

local tier_map = {}

local root
if mods["IntermodalContainers"] then
	root = "__IntermodalContainers__"

	tier_map["ic-containerization-machine-1"] = { tier = 1 }
	tier_map["ic-containerization-machine-2"] = { tier = 2 }
	tier_map["ic-containerization-machine-3"] = { tier = 3 }
	tier_map["ic-containerization-machine-4"] = { tier = 4 }
	tier_map["ic-containerization-machine-5"] = { tier = 5 }
elseif mods["DeadlockCrating"] then
	root = "__DeadlockCrating__"

	tier_map["deadlock-crating-machine-1"] = { tier = 1 }
	tier_map["deadlock-crating-machine-2"] = { tier = 2 }
	tier_map["deadlock-crating-machine-3"] = { tier = 3 }
	tier_map["deadlock-crating-machine-4"] = { tier = 4 }
	tier_map["deadlock-crating-machine-5"] = { tier = 5 }
end

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
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = tweak_tint(reskins.lib.tiers.get_belt_tint(map.tier))

	reskins.lib.setup_standard_entity(name, map.tier, inputs)

	-- Retint the mask
	entity.graphics_set.animation.layers[2].tint = inputs.tint
	entity.graphics_set.working_visualisations[1].animation.tint = light_tint(inputs.tint)
	entity.graphics_set.working_visualisations[1].light.color = light_tint(inputs.tint)

	-- Icon handling
	---@type data.IconData[]
	local icons = {
		{
			icon = root .. "/graphics/icons/mipmaps/crating-icon-base.png",
			icon_size = 64,
			scale = 0.5,
		},
		{
			icon = root .. "/graphics/icons/mipmaps/crating-icon-mask.png",
			icon_size = 64,
			scale = 0.5,
			tint = inputs.tint,
		},
	}

	---@type DeferrableIconData
	local deferrable_icon = {
		name = entity.name,
		type_name = entity.type,
		icon_data = reskins.lib.tiers.add_tier_labels_to_icons(map.tier, icons),
		picture = reskins.lib.sprites.create_sprite_from_icons(icons, 1.0),
	}

	reskins.lib.icons.assign_deferrable_icon(deferrable_icon)

	-- Tech handling
	local technology = data.raw.technology[string.gsub(name, "machine%-", "")]
	if not technology then
		goto continue
	end

	technology.icons[2].tint = inputs.tint

	::continue::
end

-- Regenerate the crate icons with correct scaling.

local function crate_item_base_layer()
	return {
		icon = "__DeadlockCrating__/graphics/icons/mipmaps/crate.png",
		icon_size = 64,
		scale = 0.5,
	}
end

local function pack_crate_recipe_label()
	return {
		icon = "__DeadlockCrating__/graphics/icons/square/arrow-d-64.png",
		icon_size = 64,
		scale = 0.25,
		shift = { 0, 4 },
	}
end

local function unpack_crate_recipe_label()
	return {
		icon = "__DeadlockCrating__/graphics/icons/square/arrow-u-64.png",
		icon_size = 64,
		scale = 0.25,
		shift = { 0, -4 },
	}
end

local function update_crate_icons(name, icons, picture)
	local crate_item = data.raw.item[string.format("deadlock-crate-%s", name)]
	if crate_item then
		crate_item.icons = icons
		crate_item.pictures = picture
	end

	local pack_recipe = data.raw.recipe[string.format("deadlock-packrecipe-%s", name)]
	if pack_recipe then
		local pack_icons = util.copy(icons)
		table.insert(pack_icons, pack_crate_recipe_label())

		pack_recipe.icons = pack_icons
	end

	local unpack_recipe = data.raw.recipe[string.format("deadlock-unpackrecipe-%s", name)]
	if unpack_recipe then
		local unpack_icons = util.copy(icons)
		table.insert(unpack_icons, unpack_crate_recipe_label())

		unpack_recipe.icons = unpack_icons
	end
end

for name, _ in pairs(data.raw.item) do
	if not name:find("deadlock%-crate%-") then
		goto continue
	end

	local item_name = name:gsub("deadlock%-crate%-", "")
	local item = data.raw.item[item_name]
	if item then
		local icon_data = reskins.lib.icons.get_icon_from_prototype_by_reference(item)

		-- Get icon. Get tier. Clean icon. Rebuild icon. Add label. Update.
		local removed_tier_labels, removed_symbols, removed_letters

		icon_data, removed_tier_labels = reskins.lib.tiers.remove_tier_labels_from_icons(icon_data)
		icon_data, removed_symbols = reskins.lib.icons.remove_symbols_from_icons(icon_data)
		icon_data, removed_letters = reskins.lib.icons.remove_letters_from_icons(icon_data)

		icon_data = reskins.lib.icons.scale_icon(icon_data, 0.7, false)

		local crated_icons = reskins.lib.icons.combine_icons(false, crate_item_base_layer(), icon_data, removed_symbols, removed_letters, removed_tier_labels)
		local crated_picture = reskins.lib.sprites.create_sprite_from_icons(crated_icons, 1.0)

		update_crate_icons(item.name, crated_icons, crated_picture)
	end

	::continue::
end
