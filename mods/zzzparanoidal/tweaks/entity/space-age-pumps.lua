-- Ветка Space Age (ПР-078/079): береговой насос качает жидкость своей клетки, как в Космической эпохе.
-- Фильтр «вода» (pumps-stats-1_1.lua, landfill-pumps.lua) давал воду на лаве, аммиачном и нефтяном океанах и лаве
-- Мошайна (прогон test-runs/sa-w1-audit2-20261108): на планетах не было лавы, аммиачного раствора и тяжёлой нефти из
-- клеток, зато была бесплатная вода. Отсыпка получает жидкость «вода», поэтому насос на ней качает воду, как и раньше:
-- дома всё по-прежнему. Донные насосы Angels дают ил из любой жидкой клетки, поэтому работают только при давлении
-- Наувиса и Глебы (1000–2000; там жидкие клетки — вода). Без Космической эпохи ничего не делает.
local filter = data.paranoidal_space_age_filter
if not filter then return end

for _, pump in pairs(data.raw["offshore-pump"]) do
	if pump.fluid_box and pump.fluid_box.filter == "water" then pump.fluid_box.filter = nil end
end

local landfill = data.raw.tile.landfill
if landfill then landfill.fluid = "water" end

for _, name in ipairs({ "angels-seafloor-pump", "paranoidal-seafloor-pump-2", "paranoidal-seafloor-pump-3" }) do
	local pump = data.raw["offshore-pump"][name]
	if pump then pump.surface_conditions = { { property = "pressure", min = 1000, max = 2000 } } end
end
