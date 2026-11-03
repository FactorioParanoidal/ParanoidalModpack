for _, factory in pairs(storage.factories or {}) do
    if factory.radar.valid then
        factory.radar.disabled_by_script = false -- Factorio 2.1: LuaEntity::active is read-only
    end
end
storage.hidden_radars = nil
