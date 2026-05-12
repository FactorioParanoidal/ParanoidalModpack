function factorissimo.build_greenhouse_upgrade(factory)
    local force = factory.force
    if not force.valid then return end
    if not factory.inside_surface.valid or not factory.outside_surface.valid then return end

    local has_tech = force.technologies["factory-upgrade-greenhouse"] and force.technologies["factory-upgrade-greenhouse"].researched
    if not has_tech then
        factory.inside_surface.set_property("solar-power", 0)
        return
    end

    local parent_planet_name = factory.outside_surface.name:gsub("%-factory%-floor$", "")
    local parent_planet = game.planets[parent_planet_name]
    if not parent_planet then return end
    local parent_solar_power = parent_planet.surface.get_property("solar-power") or 1
    factory.inside_surface.set_property("solar-power", parent_solar_power / 2)
end
