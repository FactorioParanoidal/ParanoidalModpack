
-- check research
for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	if technologies["railway"].researched then
		recipes["bbr-rail-wood"].enabled = true
		recipes["bbr-rail-iron"].enabled = true
		recipes["bbr-rail-brick"].enabled = true
	end

--[[
	if technologies["electric-energy-distribution-1"].researched then
		recipes["bbr-medium-electric-pole"].enabled = true
		recipes["bbr-big-electric-pole"].enabled = true
	end
]]--

end
