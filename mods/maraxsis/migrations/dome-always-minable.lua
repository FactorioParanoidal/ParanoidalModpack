--- Make all existing Pressure Domes mineable. Previously, they weren't if they
--- had entities inside.
for _, pressure_dome_data in pairs(storage.pressure_domes or {}) do
    for _, collision_box in pairs(pressure_dome_data.collision_boxes or {}) do
        if collision_box.valid then
            collision_box.minable_flag = true
        end
    end
end
