for index, force in pairs(game.forces) do
	force.reset_recipes()
	force.reset_technologies()

	local tech = force.technologies
	local rec = force.recipes

	local colors = {
		{name = "red"},
		{name = "green"},
		{name = "blue"},
		{name = "orange"},
		{name = "yellow"},
		{name = "pink"},
		{name = "purple"},
		{name = "black"},
		{name = "brown"},
		{name = "cyan"},
		{name = "acid"}
	}

	if settings.startup["dectorio-painted-concrete"].value then
		if tech["dect-concrete-paint"].researched then
			for _, color in pairs(colors) do
				rec["dect-" .. color.name .. "-refined-concrete"].enabled = true
			end
		end
	end
end
