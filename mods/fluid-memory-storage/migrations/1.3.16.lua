local shared = require "shared"

for i, unit_data in pairs(storage.units or {}) do
	if not unit_data.lag_id or unit_data.lag_id > shared.update_slots - 1 then
		unit_data.lag_id = math.random(0, shared.update_slots - 1)
	end
end
