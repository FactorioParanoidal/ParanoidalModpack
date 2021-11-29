MergingChests = { }

MergingChests.AllTypesModName = "WideChestsAllTypes"
MergingChests.UnlimitedModName = "WideChestsUnlimited"
MergingChests.LogisticModName = "WideChestsLogistic"

MergingChests.BobLogisticModName = "boblogistics"
MergingChests.BobPlatesModName = "bobplates"

function MergingChests.CheckMod(mod)
	return (mods or script.active_mods)[mod]
end

MergingChests.MergableChestIdToData = { }
MergingChests.MergableChestIdToData["wooden-chest"] = {
	id = "wooden-chest",
	name = "Wooden Chest",
	type = "wooden",
	additional_properties = {
		icon = "__base__/graphics/icons/wooden-chest.png",
		icon_size = 64
	}
}
MergingChests.MergableChestIdToData["iron-chest"] = {
	id = "iron-chest",
	name = "Iron Chest",
	type = "iron",
	additional_properties = {
		icon = "__base__/graphics/icons/iron-chest.png",
		icon_size = 64
	}
}
MergingChests.MergableChestIdToData["steel-chest"] = {
	id = "steel-chest",
	name = "Steel Chest",
	type = "steel",
	additional_properties = {
		icon = "__base__/graphics/icons/steel-chest.png",
		icon_size = 64
	}
}

MergingChests.MergableChestIdToData["logistic-chest-passive-provider"] = {
	id = "logistic-chest-passive-provider",
	type = "logistic-passive",
	logistic = true,
	additional_properties = {
		icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
		icon_size = 64,
		logistic_mode = "passive-provider"
	}
}
MergingChests.MergableChestIdToData["logistic-chest-active-provider"] = {
	id = "logistic-chest-active-provider",
	type = "logistic-active",
	logistic = true,
	additional_properties = {
		icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
		icon_size = 64,
		logistic_mode = "active-provider"
	}
}
MergingChests.MergableChestIdToData["logistic-chest-storage"] = {
	id = "logistic-chest-storage",
	type = "logistic-storage",
	logistic = true,
	additional_properties = {
		icon = "__base__/graphics/icons/logistic-chest-storage.png",
		icon_size = 64,
		logistic_mode = "storage",
		max_logistic_slots = 1
	}
}
MergingChests.MergableChestIdToData["logistic-chest-buffer"] = {
	id = "logistic-chest-buffer",
	type = "logistic-buffer",
	logistic = true,
	additional_properties = {
		icon = "__base__/graphics/icons/logistic-chest-buffer.png",
		icon_size = 64,
		logistic_mode = "buffer"
	}
}
MergingChests.MergableChestIdToData["logistic-chest-requester"] = {
	id = "logistic-chest-requester",
	type = "logistic-requester",
	logistic = true,
	additional_properties = {
		icon = "__base__/graphics/icons/logistic-chest-requester.png",
		icon_size = 64,
		logistic_mode = "requester"
	}
}

if MergingChests.CheckMod(MergingChests.BobLogisticModName) and MergingChests.CheckMod(MergingChests.BobPlatesModName) then
	MergingChests.MergableChestIdToData["brass-chest"] = {
		id = "brass-chest",
		name = "Brass Chest",
		type = "brass",
		additional_properties = {
			icon = "__boblogistics__/graphics/icons/brass-chest.png",
			icon_size = 32
		}
	}
	MergingChests.MergableChestIdToData["titanium-chest"] = {
		id = "titanium-chest",
		name = "Titanium Chest",
		type = "titanium",
		additional_properties = {
			icon = "__boblogistics__/graphics/icons/titanium-chest.png",
			icon_size = 32
		}
	}
end

if MergingChests.CheckMod("DyWorld-Dynamics") then
	MergingChests.MergableChestIdToData["small-storage"] = {
		id = "small-storage",
		name = "DyWorld Wood Storage Chest",
		type = "wood",
		additional_properties = {
			icon = "__base__/graphics/entity/wooden-chest/wooden-chest.png",
			icon_size = 32
		}
	}
	MergingChests.MergableChestIdToData["small-storage-2"] = {
		id = "small-storage-2",
		name = "DyWorld Iron Storage Chest",
		type = "iron",
		additional_properties = {
			icon = "__base__/graphics/entity/iron-chest/iron-chest.png",
			icon_size = 32
		}
	}
	MergingChests.MergableChestIdToData["small-storage-3"] = {
		id = "small-storage-3",
		name = "DyWorld Steel Storage Chest",
		type = "steel",
		additional_properties = {
			icon = "__base__/graphics/entity/steel-chest/steel-chest.png",
			icon_size = 32
		}
	}
end
