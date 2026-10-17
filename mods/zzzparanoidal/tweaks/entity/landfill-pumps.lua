-- Beta 8: насосы ставятся на отсыпку, как у воды. Без скрипта: отсыпка получает свой слой,
-- который правило «впереди вода» принимает наравне с водой. Покрытие поверх отсыпки заменяет
-- клетку и слоя не имеет — новый насос на нём не ставится; уже построенный продолжает работать.
local LAYER = "paranoidal-pump-landfill"
local landfill = data.raw.tile.landfill
if not landfill then return end

data:extend({ { type = "collision-layer", name = LAYER } })
landfill.collision_mask.layers[LAYER] = true

for _, pump in pairs(data.raw["offshore-pump"]) do
	local accepts_landfill = false
	if not pump.hidden then
		for _, rule in pairs(pump.tile_buildability_rules or {}) do
			local required = rule.required_tiles and rule.required_tiles.layers
			if required and required.water_tile then
				required[LAYER] = true
				accepts_landfill = true
			end
		end
	end
	-- У отсыпки нет жидкости клетки: насос без фильтра качает воду явно.
	if accepts_landfill and not pump.fluid_box.filter then
		pump.fluid_box.filter = "water"
	end
end
