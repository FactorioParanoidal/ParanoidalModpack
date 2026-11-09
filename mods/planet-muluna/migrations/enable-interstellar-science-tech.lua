for _,force in pairs(game.forces) do
    if force.technologies["interstellar-science-pack"] and force.technologies["interstellar-science-pack"].enabled == false then
        force.technologies["interstellar-science-pack"].enabled = true
    end
end