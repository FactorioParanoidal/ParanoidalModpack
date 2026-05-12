for _, surface in pairs(game.surfaces) do
    if surface.name:find("%-factory%-floor$") then
        for _, force in pairs(game.forces) do
            if force.technologies["factory-interior-upgrade-lights"].researched then
                surface.daytime = 1
                break
            end
        end
    end
end
