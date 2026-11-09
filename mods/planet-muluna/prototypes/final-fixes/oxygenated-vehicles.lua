local surface_property_lib = require("__PlanetsLib__.lib.surface-property-lib")
local categories = {"car","spider-vehicle","locomotive"}

local new_nuclear_fuel_category = "muluna-nuclear-chemical-fuel"

data.raw["item"]["rocket-fuel"].muluna_oxygenated_fuel = true

local changed_items = {
    "nuclear-fuel",
}

for _,item in pairs(data.raw.item) do
    if item.muluna_oxygenated_fuel == true then
        Muluna.rro.soft_insert(changed_items,item.name)
    end
end

for _,item in pairs(changed_items) do
    Muluna.rro.soft_insert(data.raw["item"][item].fuel_categories,"muluna-oxygenated-fuel")
end



for _,category in pairs(categories) do
    local setting = "muluna-runtime-vehicle-replacement"
    if category == "locomotive" then
        setting = "muluna-runtime-locomotive-replacement"
    end
    for _,vehicle in pairs(data.raw[category]) do
        if (not vehicle.PlanetsLib_do_not_generate_variants) and 
        (not vehicle.surface_conditions or surface_property_lib.fits_surface_conditions(vehicle,"muluna")) and 
        vehicle.energy_source.type == "burner" and 
        vehicle.energy_source.fuel_categories and Muluna.rro.contains_any(vehicle.energy_source.fuel_categories,{"chemical","kr-vehicle-fuel"}) then
            local new_energy_source = table.deepcopy(vehicle.energy_source)
            new_energy_source.fuel_categories = {"muluna-oxygenated-fuel"}
            new_energy_source.burnt_inventory_size = new_energy_source.burnt_inventory_size or 2
            vehicle.fast_replaceable_group = vehicle.fast_replaceable_group or vehicle.name
            local new_placeable_by = data.raw.item[vehicle.name] and {{item = vehicle.name, count =1}} or nil
            local item_name = data.raw["item-with-entity-data"][vehicle.name] and vehicle.name or nil
            --error(vehicle.name .. " " .. item_name)
            local new_vehicle = PlanetsLib.create_planet_entity_variant("muluna",vehicle,
                {
                    
                    energy_source = new_energy_source,
                    placeable_by = new_placeable_by
                },
                setting,
                item_name
            )
            
        end
        
        

    end
end
