require("names")
require("util")

local grids = {"none"}
local grid_default = grids[1]

if mods['bobvehicleequipment'] then
	grids = table_merge(grids, {"bob-locomotive", "bob-locomotive-2", "bob-locomotive-3", "bob-armoured-locomotive", "bob-armoured-locomotive-2"})
	grid_default = "bob-locomotive-3"
end

if mods['Krastorio2'] then
	grids = table_merge(grids, {"kr-locomotive-grid"})
	grid_default = "kr-locomotive-grid"
end

data:extend({
	-- startup settings
	{
		type = "bool-setting",
		name = setting_cheatsy_locs,
		setting_type = "startup",
		default_value = false,
		order = "a",
	},
	{
		type = "bool-setting",
		name = setting_cheatsy_wagons,
		setting_type = "startup",
		default_value = false,
		order = "b",
	},
	{
		type = "double-setting",
		name = setting_cheatsy_speed,
		setting_type = "startup",
		default_value = 259.2,
		minimum_value = 10,
		maximum_value = 7386.4,
		order = "c",
	},
	{
		type = "int-setting",
		name = setting_cheatsy_power,
		setting_type = "startup",
		default_value = 600,
		minimum_value = 100,
		maximum_value = 100000,
		order = "d",
	},
	{
		type = "double-setting",
		name = setting_cheatsy_braking,
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.1,
		maximum_value = 1000,
		order = "e",
	},
	{
		type = "bool-setting",
		name = setting_recycling,
		setting_type = "startup",
		default_value = true,
		order = "f",
	},
	{
		type = "string-setting",
		name = setting_equipment_grid,
		setting_type = "startup",
		default_value = grid_default,
		allowed_values = grids,
		hidden = #grids <= 1,
		order = "n",
	},
	-- runtime-global settings
	{
		type = "bool-setting",
		name = setting_return_partial_batteries,
		setting_type = "runtime-global",
		default_value = true,
		order = "a",
	},
})
