for _,force in pairs(game.forces) do
    if force.technologies["muluna-advanced-boiler"].researched == true then
        force.technologies["muluna-steam-crusher"].researched = true
    end
end