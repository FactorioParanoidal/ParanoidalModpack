-- Деревянный столб уже доступен со старта (start-menu-beta8).
-- Железная опора остаётся открытием electricity: согласованное отличие от Beta 8.
local technology = data.raw.technology["electricity"]
if technology and technology.effects then
	for index = #technology.effects, 1, -1 do
		local effect = technology.effects[index]
		if effect.type == "unlock-recipe" and effect.recipe == "small-electric-pole" then
			table.remove(technology.effects, index)
		end
	end
end
