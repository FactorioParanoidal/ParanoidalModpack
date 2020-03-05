-------------------------------------------------------------------------------
--[[Vehicle Grids]]--
-------------------------------------------------------------------------------
--Add generic equipment grids to vehicles
-- Code modified from:
--[[
    "name": "VehicleGrid",
    "version": "0.1.2",
    "title": "Vehicle Grid",
    "author": "Optera",
    "contact": "https://forums.factorio.com/memberlist.php?mode=viewprofile&u=21729",
    "description": "Adds an equipment grid to any base or modded vehicle without grid.\ncars 8x8, tanks 12x10, locomotives 10x8, wagons 10x6",
 --]]

if settings.startup["picker-generic-vehicle-grids"].value then
    data:extend{
        {
            type = "equipment-grid",
            name = "car-equipment-grid",
            width = 8,
            height = 8,
            equipment_categories = {"armor"}
        },
        {
            type = "equipment-grid",
            name = "tank-equipment-grid",
            width = 12,
            height = 10,
            equipment_categories = {"armor"}
        },
        {
            type = "equipment-grid",
            name = "loco-equipment-grid",
            width = 10,
            height = 8,
            equipment_categories = {"armor"}
        },
        {
            type = "equipment-grid",
            name = "wagon-equipment-grid",
            width = 10,
            height = 6,
            equipment_categories = {"armor"}
        }
    }

    for _, entity in pairs(data.raw["car"]) do
        if entity.name:find("tank") then
            entity.equipment_grid = entity.equipment_grid or "tank-equipment-grid"
        else
            entity.equipment_grid = entity.equipment_grid or "car-equipment-grid"
        end
    end

    for _, entity in pairs(data.raw["locomotive"]) do
        entity.equipment_grid = entity.equipment_grid or "loco-equipment-grid"
    end

    for _, entity in pairs(data.raw["cargo-wagon"]) do
        entity.equipment_grid = entity.equipment_grid or "wagon-equipment-grid"
    end

    for _, entity in pairs(data.raw["fluid-wagon"]) do
        entity.equipment_grid = entity.equipment_grid or "wagon-equipment-grid"
    end
end
