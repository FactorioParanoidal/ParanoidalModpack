for _, surface in pairs(game.surfaces) do
	for _, e in pairs(surface.find_entities_filtered{name = 'factory-circuit-connector'}) do
		e.operable = false
	end
end
