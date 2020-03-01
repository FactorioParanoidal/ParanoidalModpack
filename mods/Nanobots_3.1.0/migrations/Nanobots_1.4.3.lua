--Nano sounds were not removed properly, clean them up here. This can result in excessive memory/loading
--times on bigger saves. After loading save and reload map to bring memory down to a more reasonable level.
for _, surface in pairs(game.surfaces) do
    for _, explosion in pairs(surface.find_entities_filtered{type="explosion"}) do
        if explosion.name:find("^nano%-sound") then
            explosion.destroy()
        end
    end
end
