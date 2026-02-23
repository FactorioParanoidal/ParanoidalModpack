-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

if not mods["deadlock-beltboxes-loaders"] then
	return
end

---@returns data.IconData
local function stack_item_base_layer()
	return {
		icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/blank.png",
		icon_size = 32,
		scale = 1,
	}
end

---@returns data.IconData
local function stack_recipe_label()
	return {
		icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/arrow-d-64.png",
		icon_size = 64,
		scale = 0.25,
	}
end

---@returns data.IconData
local function unstack_recipe_label()
	return {
		icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/arrow-u-64.png",
		icon_size = 64,
		scale = 0.25,
	}
end

---
---Builds the base stacked icon for a Deadlock stacked item/recipe from the given `icon_data`.
---
---@param icon_data data.IconData[] # An array of `IconData` objects.
---@return data.IconData[] # A stacked icon built from a copy of `icon_data`.
local function build_stacked_icons(icon_data)
	---@type data.IconData[]
	local stacked_icons = { stack_item_base_layer() }

	local scaled_icon_data = reskins.lib.icons.scale_icon(icon_data, 0.85, false)

	for i = 1, -1, -1 do
		for _, icon_datum in pairs(scaled_icon_data) do
			local icon_datum_copy = util.copy(icon_datum)
			icon_datum_copy.shift = util.add_shift(icon_datum_copy.shift or { 0, 0 }, { 0, i * 3 })

			table.insert(stacked_icons, icon_datum_copy)
		end
	end

	return stacked_icons
end

---
---Updates the item and recipes associated with the given `name`.
---
---@param name string # The name of the item to update.
---@param icons data.IconData[] # The icons to assign to the item and recipes.
---@param picture data.Sprite # The picture to assign to the item.
local function update_stack_icons(name, icons, picture)
	local stack_item = data.raw.item[string.format("deadlock-stack-%s", name)]
	if stack_item then
		stack_item.icons = icons
		stack_item.pictures = picture
	end

	local stack_recipe = data.raw.recipe[string.format("deadlock-stacks-stack-%s", name)]
	if stack_recipe then
		local stack_icons = util.copy(icons)
		table.insert(stack_icons, stack_recipe_label())

		stack_recipe.icons = stack_icons
	end

	local unstack_recipe = data.raw.recipe[string.format("deadlock-stacks-unstack-%s", name)]
	if unstack_recipe then
		local unstack_icons = util.copy(icons)
		table.insert(unstack_icons, unstack_recipe_label())

		unstack_recipe.icons = unstack_icons
	end
end

local type_names_to_check = {
	"item",
	"tool",
	"module",
	"capsule",
	"ammo",
}

local name_exception_patterns = {
	"science%-pack",
}

for name, _ in pairs(data.raw.item) do
	if not name:find("deadlock%-stack%-") then
		goto continue
	end

	local item_name = name:gsub("deadlock%-stack%-", "")

	for _, exception in pairs(name_exception_patterns) do
		if item_name:find(exception) then
			goto continue
		end
	end

	local item
	for _, type_name in pairs(type_names_to_check) do
		item = data.raw[type_name][item_name]
		if item then
			break
		end
	end

	if item then
		local icon_data = reskins.lib.icons.get_icon_from_prototype_by_reference(item)

		-- Get icon. Get tier. Clean icon. Rebuild icon. Add label. Update.
		local removed_tier_labels, removed_symbols, removed_letters

		icon_data, removed_tier_labels = reskins.lib.tiers.remove_tier_labels_from_icons(icon_data)
		icon_data, removed_symbols = reskins.lib.icons.remove_symbols_from_icons(icon_data)
		icon_data, removed_letters = reskins.lib.icons.remove_letters_from_icons(icon_data)

		local built_icons = build_stacked_icons(icon_data)

		local stacked_icons = reskins.lib.icons.combine_icons(false, built_icons, removed_symbols, removed_letters, removed_tier_labels)
		local stacked_picture = reskins.lib.sprites.create_sprite_from_icons(built_icons, 1.0)

		update_stack_icons(item.name, stacked_icons, stacked_picture)
	end

	::continue::
end
