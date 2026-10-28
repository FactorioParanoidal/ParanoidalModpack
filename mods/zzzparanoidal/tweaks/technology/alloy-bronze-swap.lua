-- «Изготовление сплавов» и «Улучшенное сплавление бронзы 1» меняются местами в дереве:
-- каждая встаёт на место другой вместе со связями этого места (вверх и вниз).
-- Бронзовые трубы из пластин открываются раньше литья труб. После всех правок дерева.
local technologies = data.raw.technology
local alloy, bronze = "bob-alloy-processing", "angels-bronze-smelting-1"
local swap = { [alloy] = bronze, [bronze] = alloy }

local function swapped(list, self)
	local result, seen = {}, {}
	for _, name in ipairs(list or {}) do
		name = swap[name] or name
		if name ~= self and not seen[name] then
			seen[name] = true
			result[#result + 1] = name
		end
	end
	return result
end

if technologies[alloy] and technologies[bronze] then
	local alloy_prerequisites = technologies[alloy].prerequisites
	local bronze_prerequisites = technologies[bronze].prerequisites
	for name, technology in pairs(technologies) do
		if technology.prerequisites and not swap[name] then
			technology.prerequisites = swapped(technology.prerequisites, name)
		end
	end
	technologies[alloy].prerequisites = swapped(bronze_prerequisites, alloy)
	technologies[bronze].prerequisites = swapped(alloy_prerequisites, bronze)
else
	log("alloy-bronze-swap: нет " .. alloy .. " или " .. bronze)
end
