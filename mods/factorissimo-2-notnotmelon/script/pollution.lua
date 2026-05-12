local pollution_multipliers = {
    spores = 1.5,
    pollution = 1,
}

local function update_pollution(factory)
    local inside_surface = factory.inside_surface
    if not inside_surface.valid or not inside_surface.pollutant_type then return end

    local chunk
    local pollution, cp = 0, 0
    local inside_x, inside_y = factory.inside_x, factory.inside_y

    chunk = {inside_x - 16, inside_y - 16}
    cp = inside_surface.get_pollution(chunk)
    if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
    pollution = pollution + cp

    chunk = {inside_x + 16, inside_y - 16}
    cp = inside_surface.get_pollution(chunk)
    if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
    pollution = pollution + cp

    chunk = {inside_x - 16, inside_y + 16}
    cp = inside_surface.get_pollution(chunk)
    if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
    pollution = pollution + cp

    chunk = {inside_x + 16, inside_y + 16}
    cp = inside_surface.get_pollution(chunk)
    if cp ~= 0 then inside_surface.pollute(chunk, -cp) end
    pollution = pollution + cp

    if pollution == 0 then return end

    local outside_surface = factory.outside_surface
    if factory.built and outside_surface.valid then
        local pollutant_type = outside_surface.pollutant_type
        if not pollutant_type then return end
        pollutant_type = pollutant_type.name

        local multiplier = pollution_multipliers[pollutant_type] or 1

        local pollution_to_release = (pollution + factory.stored_pollution) * multiplier
        outside_surface.pollute({factory.outside_x, factory.outside_y}, pollution_to_release)
        factory.stored_pollution = 0
    else
        factory.stored_pollution = factory.stored_pollution + pollution
    end
end

factorissimo.on_nth_tick(15, function(event)
    local factories = storage.factories
    for i = (event.tick % 4 + 1), #factories, 4 do
        local factory = factories[i]
        if factory ~= nil then update_pollution(factory) end
    end
end)
