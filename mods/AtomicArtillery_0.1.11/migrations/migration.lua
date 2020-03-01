for index, force in pairs(game.forces) do
	local technologies = force.technologies;
	local recipes = force.recipes;
	recipes["atomic-artillery-shell"].enabled = technologies["atomic-bomb"].researched
end