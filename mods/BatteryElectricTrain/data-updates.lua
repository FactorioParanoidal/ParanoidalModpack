require("names")

if settings.startup[setting_cheatsy_wagons].value then
	local max_speed = settings.startup[setting_cheatsy_speed].value * 1.15 / 216 -- 1/216 = 1000 / 3600 / 60; 1.15 = max fuel bonus
	local braking_factor = settings.startup[setting_cheatsy_braking].value

	local function setspeed(type)
		for _, wagon in pairs(data.raw[type]) do
			if wagon.max_speed and wagon.max_speed < max_speed then
				wagon.max_speed = max_speed
			end
			if wagon.braking_force then wagon.braking_force = wagon.braking_force * braking_factor end
			if wagon.braking_power then wagon.braking_power = wagon.braking_power * braking_factor end
		end
	end

	setspeed("artillery-wagon")
	setspeed("cargo-wagon")
	setspeed("fluid-wagon")
end

local loc = data.raw["locomotive"][name_locomotive]
if loc.equipment_grid and not data.raw["equipment-grid"][loc.equipment_grid] then
	log("Equipment grid type '"..loc.equipment_grid.."' configured for battery-electric locomotives doesn't exist. Choose a different type in the mod settings and report to the mod author.")
	loc.equipment_grid = nil
end
