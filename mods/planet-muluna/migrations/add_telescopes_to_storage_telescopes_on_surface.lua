if not storage.telescopes_on_surface then storage.telescopes_on_surface = {} end
for i,telescope in pairs(storage.telescopes) do
    local entity = telescope["assembling-machine"]
    if entity.valid then 
        if not storage.telescopes_on_surface[entity.surface.name] then storage.telescopes_on_surface[entity.surface.name] = {} end
        storage.telescopes_on_surface[entity.surface.name][entity.unit_number] = true
        Muluna.update_telescope_daytime(telescope)
    else
        storage.telescopes[i] = nil
    end
    
end