-- Слоты модулей старших сборщиков (решение пользователя 2026-10-31, лестница качества): девять модулей
-- качества в АМ9 поднимали почти каждый крафт на ступень. Стоит после всех правок машин.
local slots = {
	["assembling-machine-7"] = 5,
	["assembling-machine-8"] = 6,
	["assembling-machine-9"] = 7,
	["electronics-machine-4"] = 6,
	["electronics-machine-5"] = 7,
}
local changed = {}
for name, count in pairs(slots) do
	local machine = data.raw["assembling-machine"][name]
	if machine then
		machine.module_slots = count
		changed[#changed + 1] = name .. "=" .. count
	end
end
table.sort(changed)
log("Paranoidal module slots of top assemblers: " .. table.concat(changed, ", "))
