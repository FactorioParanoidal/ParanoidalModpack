for i, unit_data in pairs(global.units or {}) do
	if unit_data.type then
		if unit_data.type == 'fluid' then
			unit_data.powersource.destroy()
			unit_data.combinator.destroy()
			unit_data.entity.destroy()
			global.units[i] = nil
		else
			unit_data.type = nil
		end
	end
end