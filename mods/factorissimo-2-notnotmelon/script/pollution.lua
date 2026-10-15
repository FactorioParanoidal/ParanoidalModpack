local pollution_multipliers = {
    spores = 1.5,
    pollution = 1,
}

local CHUNK_OFFSETS = {{-16, -16}, {16, -16}, {-16, 16}, {16, 16}}

local function update_pollution(factory)
    local inside_surface = factory.inside_surface
    if not (inside_surface and inside_surface.valid) or not inside_surface.pollutant_type then return end

    local pollution = 0
    local inside_x, inside_y = factory.inside_x, factory.inside_y
    local chunk = {0, 0}
    for _, offset in ipairs(CHUNK_OFFSETS) do
        chunk[1], chunk[2] = inside_x + offset[1], inside_y + offset[2]
        local cp = inside_surface.get_pollution(chunk)
        if cp ~= 0 then
            inside_surface.pollute(chunk, -cp)
            pollution = pollution + cp
        end
    end

    if pollution == 0 then return end

    local outside_surface = factory.outside_surface
    if factory.built and outside_surface and outside_surface.valid then
        local pollutant_type = outside_surface.pollutant_type
        if not pollutant_type then return end

        local multiplier = pollution_multipliers[pollutant_type.name] or 1

        local pollution_to_release = (pollution + (factory.stored_pollution or 0)) * multiplier
        outside_surface.pollute({factory.outside_x, factory.outside_y}, pollution_to_release)
        factory.stored_pollution = 0
    else
        factory.stored_pollution = (factory.stored_pollution or 0) + pollution
    end
end

-- Every factory is handled once per 60 ticks: a quarter of them every 15 ticks, split by id.
-- storage.factories has holes (ids are not reused), so it is walked with pairs, never with #.
factorissimo.on_nth_tick(15, function(event)
    local group = (event.tick / 15) % 4
    for id, factory in pairs(storage.factories) do
        if id % 4 == group then update_pollution(factory) end
    end
end)
