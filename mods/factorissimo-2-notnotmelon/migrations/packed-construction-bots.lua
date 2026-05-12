for _, factory in pairs(storage.factories or {}) do
    if factory.roboport_upgrade then
        factory.roboport_upgrade.num_robots_requested = factory.roboport_upgrade.num_robots_requested or 0
    end
end
