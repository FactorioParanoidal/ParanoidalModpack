function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local offshore_pump_types = {
    "offshore-mk0-pump", "offshore-pump", "offshore-mk2-pump", 
    "offshore-mk3-pump", "offshore-mk4-pump", "seafloor-pump", 
    "seafloor-pump-2", "seafloor-pump-3"
}

for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = {"offshore-mk0-pump-output", "offshore-pump-output", "offshore-mk2-pump-output", "offshore-mk3-pump-output", "offshore-mk4-pump-output", "seafloor-pump-output", "seafloor-pump-2-output", "seafloor-pump-3-output"}}) do
        local position = entity.position
        local direction = entity.direction
        local force = entity.force

        -- -- Удаление старой сущности (пока не надо)
        -- entity.destroy()

        -- Определение соответствующей сущности без суффикса "-output"
        local base_name = string.gsub(entity.name, "-output", "")

        -- Создание новой сущности, соответствующей без суффикса "-output"
        if table.contains(offshore_pump_types, base_name) then
            surface.create_entity{
                name = base_name,
                position = position,
                direction = direction,
                force = force
            }
            if base_name ~= "offshore-mk0-pump" then
                surface.create_entity{
                    name = "hidden-electric-pole",
                    position = position,
                    direction = direction,
                    force = force
                }
            end
        end
    end
end
