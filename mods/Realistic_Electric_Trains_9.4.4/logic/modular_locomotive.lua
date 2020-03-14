--modular_locomotive.lua
--Defines utility methods for the modular locomotive

local speed_module_speed = 0.15
local speed_module_power_factor = 1.5
local prod_module_acceleration = 0.2
local prod_module_power_factor = 1.7
local effi_module_power_factor = 0.5
local battery_module_storage = 40000000 -- 40MJ


function get_module_string(s, p, e, b)
	local string = ""
	for n = 1, s do string = string .. "s" end
	for n = 1, p do string = string .. "p" end
	for n = 1, e do string = string .. "e" end
	for n = 1, b do string = string .. "b" end
	return string
end

function get_module_stats(s, p, e, b)
	return {
		speed = 1 + s * speed_module_speed,
		acceleration = 1 + p * prod_module_acceleration,
		storage = b * battery_module_storage,
		power = speed_module_power_factor ^ s *
				prod_module_power_factor ^ p *
				effi_module_power_factor ^ e
	}
end

function get_module_counts(locomotive)
	local grid = locomotive.grid
	if grid then
		local contents = grid.get_contents()
		return {
			s = contents["ret-train-speed-module"] or 0,
			p = contents["ret-train-productivity-module"] or 0,
			e = contents["ret-train-efficiency-module"] or 0,
			b = contents["ret-train-battery-module"] or 0
		}
	else
		return {s = 0, p = 0, e = 0, b = 0}
	end
end
