for _,burner_roboport_data in pairs(storage.burner_roboports or {}) do
    local roboport = burner_roboport_data.roboport
    roboport.update_connections()
end
