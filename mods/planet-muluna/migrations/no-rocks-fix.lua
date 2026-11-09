for _,force in pairs(game.forces) do
    if force.technologies["muluna-greenhouses"].researched == true then
        force.technologies["wood-gas-processing"].researched = true
    end
end