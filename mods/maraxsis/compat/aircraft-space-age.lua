if data.raw.car["cargo-plane"] then -- checks if Aircraft-space-age is loaded.
    local aircraft_surface_conditions = serpent.line(data.raw.car["cargo-plane"].surface_conditions)

    if aircraft_surface_conditions then
        for _, car in pairs(data.raw.car) do
            if serpent.line(car.surface_conditions) == aircraft_surface_conditions then
                PlanetsLib.restrict_surface_conditions(car, {property = "pressure", max = 50000})
            end
        end
    end
end