

function BI_Functions.lib.allow_productivity(recipe_name)
	if data.raw.recipe[recipe_name] then
		for i, module in pairs(data.raw.module) do
			if module.limitation and module.effect.productivity then
				table.insert(module.limitation, recipe_name)
			end
		end
	end
end
