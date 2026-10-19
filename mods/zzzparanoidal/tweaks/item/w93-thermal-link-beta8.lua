-- ПР-046: только связь уже существующего оборудования W93 с предметом в API 2.0.
local name = "w93-modular-gun-tlaser"
local item = data.raw.item[name]
if item and data.raw["active-defense-equipment"][name] then
	item.place_as_equipment_result = name
end
