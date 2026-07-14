-- Длины тоннелей подземных труб.
-- Пластик = ровно два участка железной/медной трубы встык (замена 2-в-1): два участка по D
-- перекрывают 2*D + 1 тайлов (D на каждый + 1 тайл стыка между ними), при базовых D=10 → 21.
-- На data-updates, чтобы show-max-underground-distance (печёт индикатор дальности в data-final-fixes)
-- читал уже финальное значение, иначе подсветка следующего участка не совпадёт с реальной дальностью.
local function pipe_ug_connection(name)
	local pipe = data.raw["pipe-to-ground"][name]
	if not pipe or not pipe.fluid_box then return nil end
	for _, connection in pairs(pipe.fluid_box.pipe_connections) do
		if connection.max_underground_distance then
			return connection
		end
	end
end

local iron = pipe_ug_connection("pipe-to-ground") -- железная = медная по дальности
local plastic = pipe_ug_connection("bob-plastic-pipe-to-ground")
if iron and plastic then
	plastic.max_underground_distance = iron.max_underground_distance * 2 + 1
end
