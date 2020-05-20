for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	if technologies["asteroid-mining"].researched then
		recipes["copper-dropship-unboxing"].enabled = false
		recipes["iron-dropship-unboxing"].enabled = false
		recipes["random-dropship-unboxing"].enabled = true
	end

	if technologies["orbital-autonomous-fabricators"].researched then
		recipes["aluminium-plate-delivery"].enabled = true
		recipes["titanium-plate-delivery"].enabled = true
	end

	for index, value in ipairs(technologies) do
		if value == "extremely-advanced-material-processing" then
			if recipes["radioisotope-thermoelectric-generator-thorium"] then
				recipes["radioisotope-thermoelectric-generator-thorium"].enabled = true
			end
		end
	end
end
