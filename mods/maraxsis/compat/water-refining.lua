-- https://github.com/notnotmelon/maraxsis/issues/352

if not mods["Water-refining"] then return end

local water_barrels = {
    "mineral-water-barrel",
    "dirty-water-barrel",
}

for _, barrel in pairs(water_barrels) do
    data.raw.item[barrel].fuel_acceleration_multiplier = nil
    data.raw.item[barrel].fuel_top_speed_multiplier = nil
    data.raw.item[barrel].fuel_emissions_multiplier = nil
    data.raw.item[barrel].fuel_glow_color = nil
end