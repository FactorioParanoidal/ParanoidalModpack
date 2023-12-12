_table.each(GAME_MODES, function(mode)
	_table.each(data.raw["recipe"], function(recipe)
		local modedRecipe = Utils.getModedObject(recipe, mode)
		modedRecipe.enabled = false
	end)
end)
