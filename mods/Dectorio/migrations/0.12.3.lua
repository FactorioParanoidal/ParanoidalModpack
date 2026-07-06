for index, force in pairs(game.forces) do
	force.reset_recipes()
	force.reset_technologies()

	local rec = force.recipes
	
	if settings.startup["dectorio-walls"].value then
		rec["dect-wood-wall"].enabled = true
	end
end
