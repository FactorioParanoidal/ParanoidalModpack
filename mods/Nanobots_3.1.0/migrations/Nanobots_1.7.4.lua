for _, force in pairs(game.forces) do
    if force.recipes["roboport-interface"] then force.recipes["roboport-interface"].enabled = force.technologies["roboport-interface"].researched end
    for _, surface in pairs(game.surfaces) do
        for _, interface in pairs(surface.find_entities_filtered{name="roboport-interface-cc"}) do
            interface.destroy()
        end
    end
end
