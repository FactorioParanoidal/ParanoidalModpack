
-- check research
for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	if technologies["rail-power-system"] and technologies["rail-power-system"].researched then
		recipes["bbr-rail-electric-wood"].enabled = true
		recipes["bbr-rail-electric-iron"].enabled = true
		recipes["bbr-rail-electric-brick"].enabled = true
	end

end
