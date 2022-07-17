MergingChests = { }

MergingChests.AllTypesModName = "WideChestsAllTypes"
MergingChests.UnlimitedModName = "WideChestsUnlimited"
MergingChests.LogisticModName = "WideChestsLogistic"

MergingChests.BobLogisticModName = "boblogistics"
MergingChests.BobPlatesModName = "bobplates"
MergingChests.DyWorldModName = "DyWorld-Dynamics"
MergingChests.NulliusModName = "nullius"

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

if MergingChests.CheckMod(MergingChests.LogisticModName) then
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
end

if MergingChests.CheckMod(MergingChests.BobLogisticModName) and MergingChests.CheckMod(MergingChests.BobPlatesModName) then
	MergingChests.MergableChestIdToData["brass-chest"] = {
		id = "brass-chest",
		name = "Brass Chest",
		type = "bob-brass",
		additional_properties = {
			icon = "__boblogistics__/graphics/icons/brass-chest.png",
			icon_size = 32
		}
	}
	MergingChests.MergableChestIdToData["titanium-chest"] = {
		id = "titanium-chest",
		name = "Titanium Chest",
		type = "bob-titanium",
		additional_properties = {
			icon = "__boblogistics__/graphics/icons/titanium-chest.png",
			icon_size = 32
		}
	}
end

if MergingChests.CheckMod(MergingChests.DyWorldModName) then
	MergingChests.MergableChestIdToData["small-storage"] = {
		id = "small-storage",
		name = "DyWorld Wood Storage Chest",
		type = "dyworld-small-1",
		additional_properties = {
			icon = "__base__/graphics/icons/wooden-chest.png",
			icon_size = 64
		}
	}
	MergingChests.MergableChestIdToData["small-storage-2"] = {
		id = "small-storage-2",
		name = "DyWorld Iron Storage Chest",
		type = "dyworld-small-2",
		additional_properties = {
			icon = "__base__/graphics/icons/iron-chest.png",
			icon_size = 64
		}
	}
	MergingChests.MergableChestIdToData["small-storage-3"] = {
		id = "small-storage-3",
		name = "DyWorld Steel Storage Chest",
		type = "dyworld-small-3",
		additional_properties = {
			icon = "__base__/graphics/icons/steel-chest.png",
			icon_size = 64
		}
	}
end

if MergingChests.CheckMod(MergingChests.NulliusModName) then
	MergingChests.MergableChestIdToData["nullius-small-chest-1"] = {
		id = "wooden-chest",
		name = "Nullius Small Storage Chest 1",
		type = "nullius-small-1",
		additional_properties = {
			icon = "__base__/graphics/icons/wooden-chest.png",
			icon_size = 64
		}
	}
	MergingChests.MergableChestIdToData["nullius-small-chest-2"] = {
		id = "iron-chest",
		name = "Nullius Small Storage Chest 2",
		type = "nullius-small-2",
		additional_properties = {
			icon = "__base__/graphics/icons/iron-chest.png",
			icon_size = 64
		}
	}
	MergingChests.MergableChestIdToData["nullius-small-chest-3"] = {
		id = "steel-chest",
		name = "Nullius Small Storage Chest 3",
		type = "nullius-small-3",
		additional_properties = {
			icon = "__base__/graphics/icons/steel-chest.png",
			icon_size = 64
		}
	}
	if MergingChests.CheckMod(MergingChests.LogisticModName) then
		MergingChests.MergableChestIdToData["nullius-small-supply-chest-1"] = {
			id = "nullius-small-supply-chest-1",
			type = "nullius-small-logistic-passive-1",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
				icon_size = 64,
				logistic_mode = "passive-provider"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-supply-chest-2"] = {
			id = "logistic-chest-passive-provider",
			type = "nullius-small-logistic-passive-2",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
				icon_size = 64,
				logistic_mode = "passive-provider"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-dispatch-chest-1"] = {
			id = "nullius-small-dispatch-chest-1",
			type = "nullius-small-logistic-active-1",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
				icon_size = 64,
				logistic_mode = "active-provider"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-dispatch-chest-2"] = {
			id = "logistic-chest-active-provider",
			type = "nullius-small-logistic-active-2",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-active-provider.png",
				icon_size = 64,
				logistic_mode = "active-provider"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-storage-chest-1"] = {
			id = "nullius-small-storage-chest-1",
			type = "nullius-small-logistic-storage-1",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-storage.png",
				icon_size = 64,
				logistic_mode = "storage",
				max_logistic_slots = 1
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-storage-chest-2"] = {
			id = "logistic-chest-storage",
			type = "nullius-small-logistic-storage-2",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-storage.png",
				icon_size = 64,
				logistic_mode = "storage",
				max_logistic_slots = 1
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-buffer-chest-1"] = {
			id = "nullius-small-buffer-chest-1",
			type = "nullius-small-logistic-buffer-1",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-buffer.png",
				icon_size = 64,
				logistic_mode = "buffer"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-buffer-chest-2"] = {
			id = "logistic-chest-buffer",
			type = "nullius-small-logistic-buffer-2",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-buffer.png",
				icon_size = 64,
				logistic_mode = "buffer"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-demand-chest-1"] = {
			id = "nullius-small-demand-chest-1",
			type = "nullius-small-logistic-requester-1",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-requester.png",
				icon_size = 64,
				logistic_mode = "requester"
			}
		}
		MergingChests.MergableChestIdToData["nullius-small-demand-chest-2"] = {
			id = "logistic-chest-requester",
			type = "nullius-small-logistic-requester-2",
			logistic = true,
			additional_properties = {
				icon = "__base__/graphics/icons/logistic-chest-requester.png",
				icon_size = 64,
				logistic_mode = "requester"
			}
		}
	end
end
