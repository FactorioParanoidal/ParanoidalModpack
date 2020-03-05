for _, force in pairs(game.forces) do
    if force.technologies["construction-robotics"] and force.technologies["construction-robotics"].researched then
        if force.recipes["roboport-interface"] then force.recipes["roboport-interface"].enabled=true end
    end
end
