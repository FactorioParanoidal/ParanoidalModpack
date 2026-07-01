---
--- Migration script for wind_turbine data structure refactoring
--- Converts array-based structure to named field structure

local function migrate_wind_turbine_structure()
    if not storage.wind_turbines then
        log("No wind_turbines data found, skipping migration")
        return
    end
    
    local migrated_count = 0
    local total_count = 0
    
    for registration_number, wind_turbine in pairs(storage.wind_turbines) do
        total_count = total_count + 1
        -- Old format: {entity, name, position, surface}
        -- New format: {entity = entity, name = name, position = position, surface = surface}
        local migrated_turbine = {
            entity = wind_turbine[1],
            name = wind_turbine[2],
            position = wind_turbine[3],
            surface = wind_turbine[4]
        }

        -- Replace the old structure with the new one
        storage.wind_turbines[registration_number] = migrated_turbine
        migrated_count = migrated_count + 1
    end
    
    log("Migration completed: " .. migrated_count .. " wind turbines migrated")
end

-- Execute migration
log("start migration to 2.2.0")
migrate_wind_turbine_structure()
log("migration to 2.2.0 finished")
