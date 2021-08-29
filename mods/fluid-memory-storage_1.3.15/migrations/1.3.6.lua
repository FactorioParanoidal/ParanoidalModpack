for _, unit_data in pairs(global.units or {}) do
	unit_data.comfortable = 0.5 * unit_data.entity.fluidbox.get_capacity(1)
end