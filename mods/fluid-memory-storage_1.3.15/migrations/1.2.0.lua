for _, unit_data in pairs(global.units or {}) do
	if unit_data.item and not unit_data.temperature then
		unit_data.temperature = 15
	end
end