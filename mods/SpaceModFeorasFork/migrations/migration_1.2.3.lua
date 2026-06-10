if settings.startup["SpaceX-no-ir"].value == false and script.active_mods["IndustrialRevolution3"] then
	for _, force in pairs(game.forces) do
		if
			force.technologies["space-fluid-tanks"].researched or force.technologies["exploration-satellite"].researched
		then
			if force.recipes["spaceship-fuel"] then
				force.recipes["spaceship-fuel"].enabled = true
			end
		end
	end
end
