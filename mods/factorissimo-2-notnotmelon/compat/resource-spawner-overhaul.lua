factorissimo.on_event(factorissimo.events.on_init(), function()
    if not remote.interfaces["RSO"] then return end

    for surface_index, _ in pairs(storage.surface_factories or {}) do
        local surface = game.get_surface(surface_index)
        if surface then pcall(remote.call, "RSO", "ignoreSuface", surface.name) end
    end
end)
