for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	if technologies["orbital-autonomous-fabricators"].researched then
		for i, effect in pairs(technologies["orbital-autonomous-fabricators"].effects) do
			if effect.recipe == "rare-earth-ore-delivery" then
				recipes["rare-earth-ore-delivery"].enabled = true
			end
		end
	end
end
