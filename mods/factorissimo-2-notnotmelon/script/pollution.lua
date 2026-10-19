local pollution_multipliers = {
    spores = 1.5,
    pollution = 1,
}

-- Factory centres lie on chunk corners. The chunks covered by the interior (walls included) are collected:
-- 4 for buildings 1-3, 16 for building 4 (Paranoidal, 90x90 inside). Cached by interior size.
local chunk_offsets_cache = {}
local function chunk_offsets(inside_size)
    local offsets = chunk_offsets_cache[inside_size]
    if offsets then return offsets end
    local half = inside_size / 2 + 1
    local first, last = math.floor(-half / 32), math.floor((half - 1) / 32)
    offsets = {}
    for cx = first, last do
        for cy = first, last do
            offsets[#offsets + 1] = {cx * 32 + 16, cy * 32 + 16}
        end
    end
    chunk_offsets_cache[inside_size] = offsets
    return offsets
end

--- Moves the pollution of the interior outside. Returns the pollution taken from the interior (nil when unknown).
local function update_pollution(factory)
    local inside_surface = factory.inside_surface
    if not (inside_surface and inside_surface.valid) or not inside_surface.pollutant_type then return nil end

    local pollution = 0
    local inside_x, inside_y = factory.inside_x, factory.inside_y
    local chunk = {0, 0}
    for _, offset in ipairs(chunk_offsets(factory.layout and factory.layout.inside_size or 30)) do
        chunk[1], chunk[2] = inside_x + offset[1], inside_y + offset[2]
        local cp = inside_surface.get_pollution(chunk)
        if cp ~= 0 then
            inside_surface.pollute(chunk, -cp)
            pollution = pollution + cp
        end
    end

    if pollution == 0 then return 0 end

    local outside_surface = factory.outside_surface
    if factory.built and outside_surface and outside_surface.valid then
        local pollutant_type = outside_surface.pollutant_type
        if not pollutant_type then return pollution end

        local multiplier = pollution_multipliers[pollutant_type.name] or 1

        local pollution_to_release = (pollution + (factory.stored_pollution or 0)) * multiplier
        outside_surface.pollute({factory.outside_x, factory.outside_y}, pollution_to_release)
        factory.stored_pollution = 0
    else
        factory.stored_pollution = (factory.stored_pollution or 0) + pollution
    end
    return pollution
end

-- Every factory is handled once per 60 ticks: a quarter of them every 15 ticks, split by id.
-- storage.factories has holes (ids are not reused), so it is walked with pairs, never with #.
-- The same pass samples the state of the factory (script/stats.lua).
factorissimo.on_nth_tick(15, function(event)
    local tick = event.tick
    local group = (tick / 15) % 4
    local sample_factory = factorissimo.sample_factory
    for id, factory in pairs(storage.factories) do
        if id % 4 == group then
            sample_factory(factory, update_pollution(factory), tick)
        end
    end
end)
