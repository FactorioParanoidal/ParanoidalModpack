local shared = require 'shared'

for i, unit_data in pairs(global.units or {}) do
	if unit_data.lag_id and unit_data.lag_id > shared.update_slots - 1 then
		unit_data.lag_id = math.random(0, shared.update_slots - 1)
	end
end
