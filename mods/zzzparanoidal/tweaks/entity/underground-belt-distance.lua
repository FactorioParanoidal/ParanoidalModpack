-- Длины тоннелей подземных лент (дамп 1.1 Oberhaul: basic/fast/express; turbo/ultimate — тиры Bob's).
-- На data-updates, чтобы show-max-underground-distance (печёт индикатор дальности в data-final-fixes)
-- читал уже финальные значения.
local function set_ug_distance(name, dist)
	local ug = data.raw["underground-belt"][name]
	if ug then
		ug.max_distance = dist
	end
end

set_ug_distance("bob-basic-underground-belt", 5)
set_ug_distance("fast-underground-belt", 11)
set_ug_distance("express-underground-belt", 17)
set_ug_distance("turbo-underground-belt", 23)
set_ug_distance("bob-ultimate-underground-belt", 27)
