local function copy_entity(_type, name, new_name)
	return flib.copy_prototype(data.raw[_type][name], new_name)
end

local salvaged_mining_drill_entity = copy_entity("mining-drill", "burner-mining-drill", "salvaged-mining-drill")

salvaged_mining_drill_entity.mining_speed = 0.1

if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
	local salvaged_radar = copy_entity("radar", "radar", "salvaged-radar")
	salvaged_radar.energy_consumption = "250kW"
	salvaged_radar.energy_per_sector = "10MJ"
	salvaged_radar.energy_per_nearby_scan = "250kJ"
	salvaged_radar.max_distance_of_sector_revealed = 0
	salvaged_radar.max_distance_of_nearby_sector_revealed = 0
	data:extend(
		{
			salvaged_radar
		}
	)
end
data:extend(
	{
		salvaged_mining_drill_entity
	}
)
--извлечённые пакеты для извлечённой лаборатории, дальше только своим ходом
data.raw["lab"]["salvaged-lab"].inputs = {"salvaged-automation-science-pack"}
