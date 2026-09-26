-- Три оставшихся отличия ингредиентов компонентов SpaceMod от Beta 8 normal.
-- После Bob/Clowns и OV.execute; время, выход, категории и модули не меняем.
if not mods["SpaceModFeorasFork"] then return end

local ingredients = {
	["fuel-cell"] = {
		{ type = "item", name = "rocket-fuel", amount = 500 },
		{ type = "item", name = "low-density-structure", amount = 100 },
		{ type = "item", name = "bob-titanium-plate", amount = 100 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 100 },
		{ type = "item", name = "clowns-plate-osmium", amount = 100 },
	},
	["astrometrics"] = {
		{ type = "item", name = "low-density-structure", amount = 100 },
		{ type = "item", name = "bob-speed-module-5", amount = 50 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 300 },
		{ type = "item", name = "clowns-plate-osmium", amount = 100 },
	},
	["drydock-assembly"] = {
		{ type = "item", name = "assembly-robot", amount = 50 },
		{ type = "item", name = "low-density-structure", amount = 100 },
		{ type = "item", name = "bob-solar-panel-large-3", amount = 200 },
		{ type = "item", name = "bob-roboport-4", amount = 10 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 200 },
	},
}
for name, list in pairs(ingredients) do
	if data.raw.recipe[name] then
		data.raw.recipe[name].ingredients = list
	end
end
