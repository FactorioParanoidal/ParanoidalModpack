-- Без SpaceXGAR2: те же предметы на вкладку «Покорение космоса», что он ставил в data-final-fixes.
-- В начале data-final-fixes, до раскладок меню, как прежде.
if mods["SpaceXGAR2"] then return end

for name, subgroup in pairs({
	["rocket-fuel"] = "space-exploration-a",
	["low-density-structure"] = "space-exploration-a",
	["rocket-control-unit"] = "space-exploration-a",
	["satellite"] = "space-exploration-a",
	["rocket-silo"] = "space-exploration-b",
}) do
	local item = data.raw.item[name]
	if item then item.subgroup = subgroup end
end
