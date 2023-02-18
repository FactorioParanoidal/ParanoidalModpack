
-- check research
for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	if technologies["railway"].researched then
		recipes["bbr-rail-brick"].enabled = true
	end
end