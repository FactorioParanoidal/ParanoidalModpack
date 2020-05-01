MergingChests = { }

local active_mods = mods or script.active_mods

MergingChests.MergableChestIdToData = { }
MergingChests.MergableChestIdToData["wooden-chest"] = {
	id = "wooden-chest",
	name = "Wooden Chest",
	type = "wooden",
	icon = "__base__/graphics/icons/wooden-chest.png",
	iconSize = 64
}
MergingChests.MergableChestIdToData["iron-chest"] = {
	id = "iron-chest",
	name = "Iron Chest",
	type = "iron",
	icon = "__base__/graphics/icons/iron-chest.png",
	iconSize = 64
}
MergingChests.MergableChestIdToData["steel-chest"] = {
	id = "steel-chest",
	name = "Steel Chest",
	type = "steel",
	icon = "__base__/graphics/icons/steel-chest.png",
	iconSize = 64
}

local active_mods = mods or script.active_mods
if active_mods["boblogistics"] and active_mods["bobplates"] then
	MergingChests.MergableChestIdToData["brass-chest"] = {
		id = "brass-chest",
		name = "Brass Chest",
		type = "brass",
		icon = "__boblogistics__/graphics/icons/brass-chest.png",
		iconSize = 32
	}
	MergingChests.MergableChestIdToData["titanium-chest"] = {
		id = "titanium-chest",
		name = "Titanium Chest",
		type = "titanium",
		icon = "__boblogistics__/graphics/icons/titanium-chest.png",
		iconSize = 32
	}
end