for i, force in pairs(game.forces) do 
	if force.technologies["steel-processing"].researched then 
		force.recipes["mini-steel-chest"].enabled = true
	end
    if force.technologies["construction-robotics"].researched then 
        force.recipes["mini-logistic-chest-passive-provider"].enabled = true
        force.recipes["mini-logistic-chest-storage"].enabled = true
    end
    if force.technologies["logistic-system"].researched then 
        force.recipes["logistic-chest-active-provider"].enabled = true
        force.recipes["logistic-chest-buffer"].enabled = true
        force.recipes["logistic-chest-requester"].enabled = true
    end
end