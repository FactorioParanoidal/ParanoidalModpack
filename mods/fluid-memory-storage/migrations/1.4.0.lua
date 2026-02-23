if not storage.units then return end

local fixed = {}
local delete = {}
for i, unit_data in pairs(storage.units) do
	if unit_data.container and unit_data.entity and unit_data.entity.valid then
		unit_data.container = nil
		fixed[unit_data.entity.unit_number] = unit_data
		delete[#delete + 1] = i
	end
end

for k, v in pairs(fixed) do
	storage.units[k] = v
end

for _, i in pairs(delete) do
	storage.units[i] = nil
end
