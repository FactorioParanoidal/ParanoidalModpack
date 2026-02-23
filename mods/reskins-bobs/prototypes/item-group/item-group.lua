-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local item_groups = {
	["bob-logistics"] = { related_item_group = "logistics" },
	["bob-fluid-products"] = {},
	["bob-resource-products"] = {},
	["bob-intermediate-products"] = { related_item_group = "intermediate-products" },
	["bob-gems"] = {},
}

local function set_item_group_icon(prototype_name)
	local item_group = data.raw["item-group"][prototype_name]
	if not item_group then
		return
	end

	item_group.icon = "__reskins-bobs__/graphics/item-group/" .. prototype_name .. ".png"
	item_group.icon_size = 128
end

for prototype_name, params in pairs(item_groups) do
	-- Check if the group(s) exist(s), if not, skip this iteration
	if params.related_item_group then
		if data.raw["item-group"][prototype_name] and data.raw["item-group"][params.related_item_group] then
			set_item_group_icon(prototype_name)
			set_item_group_icon(params.related_item_group)
		end
	else
		if data.raw["item-group"][prototype_name] then
			set_item_group_icon(prototype_name)
		end
	end
end
