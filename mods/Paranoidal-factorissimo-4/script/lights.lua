local PERMABLACK_SURFACES = {
    ["tenebris-factory-floor"] = true,
    ["maraxsis-trench-factory-floor"] = true,
}

function factorissimo.build_lights_upgrade(factory)
    if not factory.inside_surface.valid then return end
    local force = factory.force
    if not force.valid then return end
    local has_tech = force.technologies["factory-interior-upgrade-lights"].researched

    if PERMABLACK_SURFACES[factory.inside_surface.name] then
        has_tech = false
        factory.inside_surface.brightness_visual_weights = {r = 1, g = 1, b = 1}
        factory.inside_surface.min_brightness = 0
    end

    factory.inside_surface.daytime = has_tech and 1 or 0.5
    factory.inside_surface.freeze_daytime = true
end
