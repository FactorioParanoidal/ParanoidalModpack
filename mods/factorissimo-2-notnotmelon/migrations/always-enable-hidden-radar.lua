for _, factory in pairs(storage.factories or {}) do
    if factory.radar.valid then
        factory.radar.active = true
    end
end
storage.hidden_radars = nil
