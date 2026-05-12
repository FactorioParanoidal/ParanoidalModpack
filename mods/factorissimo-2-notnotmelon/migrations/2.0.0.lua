require "__factorissimo-2-notnotmelon__.script.electricity"

for _, pole in ipairs(storage.middleman_power_poles or {}) do
    if pole ~= 0 then pole.destroy() end
end
storage.middleman_power_poles = nil

for _, factory in pairs(storage.factories) do
    for _, inside_power_pole in pairs(factory.inside_power_poles or {}) do
        if inside_power_pole and inside_power_pole.valid then
            inside_power_pole.destroy()
        end
    end
    factory.inside_power_poles = nil
    factory.middleman_id = nil
    factory.direct_connection = nil

    factorissimo.update_power_connection(factory)
end

storage.surface_factory_counters = nil
storage.middleman_circuit_connectors = nil
storage.spidertrons = nil
