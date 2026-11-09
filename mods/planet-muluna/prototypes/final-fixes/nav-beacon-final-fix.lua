if settings.startup["enable-nav-beacon"].value == true then
    local satellite_radars = data.raw["mod-data"]["muluna-satellite-radar"].data
    for _,radar_data in pairs(satellite_radars.entities) do
        local radar = data.raw["radar"][radar_data.name]
        local tooltips = radar.custom_tooltip_fields
        
        tooltips[1] ={
            name = {"tooltip.muluna-satellite-radar-scan-energy"},
            quality_header = "quality-tooltip.decreases",
            value = {"tooltip-value.muluna-satellite-radar-scan-energy",tostring(radar_data.energy_per_scan)},
            order = 2,
            quality_values = {}
        } 
        tooltips[2] = {
            name = {"tooltip.muluna-satellite-radar-scan-size"},
            quality_header = "quality-tooltip.increases",
            value = {"tooltip-value.muluna-satellite-radar-scan-size",tostring(radar_data.scan_area)},
            order = 1,
            quality_values = {},
        }
        local scan_energy = tooltips[1]
        local scan_size = tooltips[2]
        if feature_flags["quality"] then
            for _,quality in pairs(data.raw["quality"]) do
            scan_energy.quality_values[quality.name] = 
                {
                    "tooltip-value.muluna-satellite-radar-scan-energy",
                    string.format("%.0f",helpers.evaluate_expression(
                        satellite_radars.energy_per_scan_expression,
                        {base = radar_data.energy_per_scan, quality_level = quality.level}
                    ))
                }
            scan_size.quality_values[quality.name] = 
                {
                    "tooltip-value.muluna-satellite-radar-scan-size",
                    tostring(helpers.evaluate_expression(
                        satellite_radars.scan_size_expression,
                        {base = radar_data.scan_area, quality_level = quality.level}
                    ))
                }
            end
        end
        
    end
end