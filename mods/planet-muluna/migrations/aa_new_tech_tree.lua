for _,force in pairs(game.forces) do 
    if force.technologies["planet-discovery-muluna"].researched == true then
        if force.technologies["wood-gas-processing"].researched == true then
            force.technologies["muluna-greenhouses"].researched = true
            force.technologies["muluna-wood-cultivation"].researched = true
            --force.technologies["muluna-anorthite-processing"].researched = true
        end

        if force.technologies["muluna-anorthite-processing"].researched == true then
            force.technologies["muluna-alumina-processing"].researched = true
            force.technologies["muluna-aluminum-processing"].researched = true
            force.technologies["muluna-alice-propellant"].researched = true
        end

        if force.technologies["oxide-asteroid-crushing"].researched == true then
            force.technologies["muluna-oxygen"].researched = true
            
        end

        if force.technologies["carbonic-asteroid-crushing"].researched == true then
            force.technologies["muluna-advanced-boiler"].researched = true
            
        end

        
    end
end