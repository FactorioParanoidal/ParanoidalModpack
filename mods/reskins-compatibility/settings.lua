-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

if mods["extendedangels"] then
	data:extend({
		{
			type = "bool-setting",
			name = "reskins-compatibility-extendedangels-warehouse-tiering",
			setting_type = "startup",
			default_value = true,
		},
	})
end
