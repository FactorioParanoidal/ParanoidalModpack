local shared = require 'shared'

local next = 0
for i, unit_data in pairs(global.units or {}) do
	if unit_data.lag_id == nil then
		unit_data.lag_id = next
		next = next + 1
		if next == shared.update_rate - 1 then
			next = 0
		end
	end
end
