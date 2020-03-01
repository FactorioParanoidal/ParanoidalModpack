for _, force in pairs(game.forces) do
    if force.name ~= 'neutral' then
        for _, surface in pairs(game.surfaces) do
            for _, ent in pairs(surface.find_entities_filtered {force = force}) do
                if ent.valid then
                    ent.update_connections()
                end
            end
        end
    end
end
game.print('Updating all connections.')
