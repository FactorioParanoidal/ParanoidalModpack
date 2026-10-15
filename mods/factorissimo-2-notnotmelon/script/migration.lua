-- Fix common migration issues.

factorissimo.on_event(factorissimo.events.on_init(), function()
    for _, factory in pairs(storage.factories) do
        -- Fix issues when forces are deleted.
        if not factory.force or not factory.force.valid then
            factory.force = game.forces.player
        end

        -- Fix issues when quality prototypes are removed. Factories are immune to quality (Paranoidal).
        if not factory.quality or not factory.quality.valid then
            factory.quality = prototypes.quality.normal
        end

        -- Clean deprecated data.
        factory.original_planet = nil
    end
end)
