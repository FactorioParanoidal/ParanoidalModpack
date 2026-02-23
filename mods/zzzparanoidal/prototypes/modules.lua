--Удаляем из игры имбовые сельскохозяйственные модули, их рецепты и технологии
if mods["Transport_Drones"] then -- фикс совместимости с модом (скрываем, а не удаляем)
	if data.raw.module["angels-bio-yield-module"] then
		data.raw["recipe"]["angels-bio-yield-module"].hidden = true
		data.raw["technology"]["angels-bio-yield-module"] = nil

		data.raw["recipe"]["angels-bio-yield-module-2"].hidden = true
		data.raw["technology"]["angels-bio-yield-module-2"] = nil

		data.raw["recipe"]["angels-bio-yield-module-3"].hidden = true
		data.raw["technology"]["angels-bio-yield-module-3"] = nil

		if data.raw.module["angels-bio-yield-module-4"] then
			data.raw["recipe"]["angels-bio-yield-module-4"].hidden = true
			data.raw["technology"]["angels-bio-yield-module-4"] = nil

			data.raw["recipe"]["angels-bio-yield-module-5"].hidden = true
			data.raw["technology"]["angels-bio-yield-module-5"] = nil

			data.raw["recipe"]["angels-bio-yield-module-5"].hidden = true
			data.raw["technology"]["angels-bio-yield-module-5"] = nil

			data.raw["recipe"]["angels-bio-yield-module-5"].hidden = true
			data.raw["technology"]["angels-bio-yield-module-5"] = nil

			data.raw["recipe"]["angels-bio-yield-module-5"].hidden = true
			data.raw["technology"]["angels-bio-yield-module-5"] = nil
		end
	end
else -- удаляем всё
	if data.raw.module["angels-bio-yield-module"] then
		data.raw.module["angels-bio-yield-module"] = nil
		data.raw.recipe["angels-bio-yield-module"] = nil
		data.raw.recipe["angels-bio-yield-module-recycling"] = nil
		data.raw.technology["angels-bio-yield-module"] = nil
		data.raw.module["angels-bio-yield-module-2"] = nil
		data.raw.recipe["angels-bio-yield-module-2"] = nil
		data.raw.recipe["angels-bio-yield-module-2-recycling"] = nil
		data.raw.technology["angels-bio-yield-module-2"] = nil
		data.raw.module["angels-bio-yield-module-3"] = nil
		data.raw.recipe["angels-bio-yield-module-3"] = nil
		data.raw.recipe["angels-bio-yield-module-3-recycling"] = nil
		data.raw.technology["angels-bio-yield-module-3"] = nil

		if data.raw.module["angels-bio-yield-module-4"] then
			data.raw.module["angels-bio-yield-module-4"] = nil
			data.raw.module["angels-bio-yield-module-5"] = nil
			data.raw.module["angels-bio-yield-module-5"] = nil
			data.raw.module["angels-bio-yield-module-5"] = nil
			data.raw.module["angels-bio-yield-module-5"] = nil

			data.raw.recipe["angels-bio-yield-module-4"] = nil
			data.raw.recipe["angels-bio-yield-module-4-recycling"] = nil
			data.raw.recipe["angels-bio-yield-module-5"] = nil
			data.raw.recipe["angels-bio-yield-module-5-recycling"] = nil
			data.raw.recipe["angels-bio-yield-module-5"] = nil
			data.raw.recipe["angels-bio-yield-module-6-recycling"] = nil
			data.raw.recipe["angels-bio-yield-module-5"] = nil
			data.raw.recipe["angels-bio-yield-module-7-recycling"] = nil
			data.raw.recipe["angels-bio-yield-module-5"] = nil
			data.raw.recipe["angels-bio-yield-module-8-recycling"] = nil

			data.raw.technology["angels-bio-yield-module-4"] = nil
			data.raw.technology["angels-bio-yield-module-5"] = nil
			data.raw.technology["angels-bio-yield-module-5"] = nil
			data.raw.technology["angels-bio-yield-module-5"] = nil
			data.raw.technology["angels-bio-yield-module-5"] = nil
		end
	end
end
