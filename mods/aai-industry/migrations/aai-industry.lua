for _, force in pairs(game.forces) do
	if force.technologies["concrete"] and force.technologies["concrete"].researched then
        force.recipes["concrete-wall"].enabled = true
	end
end