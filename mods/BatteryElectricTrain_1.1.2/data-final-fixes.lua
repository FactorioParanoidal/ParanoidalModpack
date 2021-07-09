require("names")

if settings.startup[setting_cheatsy_wagons].value then
	local max_speed = settings.startup[setting_cheatsy_speed].value * 1.15 / 216 -- 1/216 = 1000 / 3600 / 60; 1.15 = max fuel bonus

	local function setspeed(type)
		local wagons = data.raw[type]

		for _, wagon in pairs(wagons) do
			if wagon.max_speed and wagon.max_speed < max_speed then
				wagon.max_speed = max_speed
			end
		end
	end

	setspeed("artillery-wagon")
	setspeed("cargo-wagon")
	setspeed("fluid-wagon")
end
