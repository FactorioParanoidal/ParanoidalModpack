-- Fix common migration issues.

factorissimo.on_event(factorissimo.events.on_init(), function()
    for _, factory in pairs(storage.factories) do
        -- Fix issues when forces are deleted.
        if not factory.force or not factory.force.valid then
            factory.force = game.forces.player
        end

        -- Fix issues when quality prototypes are removed.
        if not factory.quality or not factory.quality.valid then
            if factory.building and factory.building.valid then
                factory.quality = factory.building.quality
            else
                factory.quality = prototypes.quality.normal
            end
        end

        -- Clean deprecated data.
        factory.original_planet = nil
    end
end)
