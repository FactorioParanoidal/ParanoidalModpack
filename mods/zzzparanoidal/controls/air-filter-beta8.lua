-- Extended Angels 0.6.9 на configuration change привязывает фильтр IV к химии IV.
-- ПР-029: согласуем общее состояние force с открытием Beta 8, не правим чужой handler.
-- Существующая optional dependency extendedangels ставит наш обработчик после его.
return function()
	if not script.active_mods["extendedangels"] then return end
	for _, force in pairs(game.forces) do
		local recipe = force.recipes["angels-air-filter-4"]
		local technology = force.technologies["angels-nitrogen-processing-4"]
		if recipe and technology then recipe.enabled = technology.researched end
	end
end
