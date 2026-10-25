-- Paranoidal fork: links that need prototypes created by other mods' data-updates (barrels) or late checks.
local P = require("prototypes.paranoidal.lib")

-- Alien blood is exported in the build's barrels (Yuoki canisters were removed): 10 barrels -> 1 Reputation.
if data.raw.item["ye_blood-barrel"] then
	data:extend({
		{
			type = "recipe",
			name = "ye-export-blood",
			category = "yuoki-stargate",
			energy_required = 5,
			enabled = false,
			ingredients = { { type = "item", name = "ye_blood-barrel", amount = 10 } },
			results = {
				{ type = "item", name = "y-fame", amount = 1 },
				{ type = "item", name = "barrel", amount = 10, ignored_by_productivity = 10, ignored_by_stats = 10 },
			},
			main_product = "y-fame",
			subgroup = "y-stargate-4",
			order = "e-blood",
		},
	})
else
	log("Yuoki (Paranoidal): ye_blood-barrel not found, blood export not created")
end

-- YI suit grids, one step above the power armor each suit improves (recipes and stats: armor.lua).
local grids = { y_armor_grid_a = { 9, 9 }, y_armor_grid_b = { 10, 10 }, y_armor_grid_c = { 11, 11 },
	y_walker_grid = { 12, 12 }, y_walker_grid_b = { 13, 13 } }
for name, size in pairs(grids) do
	local grid = P.entity("equipment-grid", name)
	grid.width, grid.height = size[1], size[2]
end
