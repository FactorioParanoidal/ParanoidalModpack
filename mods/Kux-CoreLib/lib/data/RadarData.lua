local futil = require("__core__/lualib/util")
---@class KuxCoreLib.RadarData

---@class KuxCoreLib.RadarData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.RadarData
local RadarData= {
	__class  = "KuxCoreLib.RadarData",
	__guid   = "{147056a9-bb45-4f57-b66b-1df4f3321cfd}",
	__origin = "Kux-CoreLib/lib/data/RadarData.lua",
}
if not KuxCoreLib.__classUtils.ctor(RadarData) then return self end
---------------------------------------------------------------------------------------------------

---Calculates energy_per_nearby_scan and energy_per_sector based on the given time and energy_usage
---@param radar data.RadarPrototype
---@param time? double time (s) per sector (default=200)
function RadarData.calcEnergyByScanTime(radar, time)
	if not time then time = 200 end
	local energy_usage = futil.parse_energy(radar.energy_usage)*60 -- z. B. "300kW" => 300,000 W
	local standard_energy_per_nearby_scan = 250000 -- Standard value: (250 kJ) in joules
	local standard_energy_usage = 300000 -- Standard value: (300 kW) in W
	local standard_time = 200 -- Default time in seconds
	local time_per_nearby_scan = 1 -- Seconds between two nearby_scans

	local scaled_energy_per_nearby_scan = standard_energy_per_nearby_scan
		* (energy_usage / standard_energy_usage)
		* (standard_time / time)

	local total_energy = energy_usage * time
	local energy_for_nearby_scans = time * scaled_energy_per_nearby_scan
	local energy_per_sector = total_energy - energy_for_nearby_scans

	radar.energy_per_nearby_scan = scaled_energy_per_nearby_scan.."J";
	radar.energy_per_sector = energy_per_sector.."J";
end

---------------------------------------------------------------------------------------------------
return RadarData