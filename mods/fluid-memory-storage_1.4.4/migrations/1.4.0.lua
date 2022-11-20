if not global.units then return end

local fixed = {}
local delete = {}
for i, unit_data in pairs(global.units) do
	if unit_data.container and unit_data.entity and unit_data.entity.valid then
		unit_data.container = nil
		fixed[unit_data.entity.unit_number] = unit_data
		delete[#delete + 1] = i
	end
end

for k, v in pairs(fixed) do
	global.units[k] = v
end

for _, i in pairs(delete) do
	global.units[i] = nil
end
