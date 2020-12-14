require("init-settings")

local allowedChestNames = { }
for _, data in pairs(MergingChests.MergableChestIdToData) do
	table.insert(allowedChestNames, data.name)
end

data:extend(
{
	{
		name = "mergable-chest-name",
		type = "string-setting",
		setting_type = "startup",
		default_value = MergingChests.MergableChestIdToData["steel-chest"].name,
		allowed_values = allowedChestNames,
		per_user = false,
		order = "1"
	},
	{
		name = "max-chest-width",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 2,
		default_value = 42,
		per_user = false,
		order = "2"
	},
	{
		name = "max-chest-height",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 2,
		default_value = 42,
		per_user = false,
		order = "3"
	},
	{
		name = "max-chest-area",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 2,
		default_value = 1600,
		per_user = false,
		order = "4"
	},
	{
		name = "whitelist-chest-sizes",
		type = "string-setting",
		setting_type = "startup",
		default_value = "NxN",
		allow_blank = true,
		per_user = false,
		order = "5"
	},
	{
		name = "inventory-size-multiplier",
		type = "double-setting",
		setting_type = "startup",
		minimum_value = 0,
		default_value = 1.0,
		per_user = false,
		order = "6"
	},
	{
		name = "inventory-size-limit",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 1,
		maximum_value = 65535,
		default_value = 1000,
		per_user = false,
		order = "7"
	},
	{
		name = "sprite-decal-chance",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 0,
		maximum_value = 100,
		default_value = 15,
		per_user = false,
		order = "8"
	},
	{
		name = "warehouse-threshold",
		type = "int-setting",
		setting_type = "startup",
		minimum_value = 2,
		default_value = 5,
		per_user = false,
		order = "9"
	},
})


