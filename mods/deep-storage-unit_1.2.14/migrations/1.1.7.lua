for _, unit_data in pairs(global.units or {}) do
	unit_data.type = unit_data.type or 'item'
end