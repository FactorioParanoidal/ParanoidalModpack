for index, force in pairs(game.forces) do
	force.reset_recipes()
	force.reset_technologies()

	local tech = force.technologies
	local rec = force.recipes

	if settings.startup["dectorio-concrete"].value then
		if tech["concrete"].researched then
			rec["dect-concrete-grid"].enabled = true
		end
	end
end
