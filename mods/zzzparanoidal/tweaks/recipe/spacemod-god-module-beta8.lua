-- Beta 8 normal: 10 god-module-5 для двигателя, 1 для командного центра.
-- Согласованная замена ингредиента на bob-god-module-productivity; сам модуль не меняем.
-- После OV.execute и osmium-патчей, до финального flowfix.
if mods["SpaceModFeorasFork"] and data.raw.module["bob-god-module-productivity"] then
	local ingredients = {
		["ftl-drive"] = {
			{ type = "item", name = "low-density-structure", amount = 100 },
			{ type = "item", name = "bob-god-module-productivity", amount = 10 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 500 },
			{ type = "item", name = "clowns-plate-osmium", amount = 100 },
		},
		["command"] = {
			{ type = "item", name = "plastic-bar", amount = 200 },
			{ type = "item", name = "low-density-structure", amount = 100 },
			{ type = "item", name = "bob-god-module-productivity", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 100 },
			{ type = "item", name = "clowns-plate-osmium", amount = 100 },
		},
	}
	for name, list in pairs(ingredients) do
		if data.raw.recipe[name] then
			data.raw.recipe[name].ingredients = list
		end
	end
end
