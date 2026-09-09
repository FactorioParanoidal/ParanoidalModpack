-- PCPRedux (PetrochemPlus) объявляет свой item "solid-sodium-nitrate" — имя, под которым
-- предмет жил в Angels 1.1 (в дампе 1.1 предмет один, поля от PCPRedux: он перекрывал
-- ангеловский). angelspetrochem 2.0 переименовал его в "angels-solid-sodium-nitrate"
-- (angelspetrochem/migrations/angelspetrochem_2.0.0.json), поэтому объявление PCPRedux
-- перестало быть перекрытием и создаёт второй предмет с тем же названием
-- ("Sodium Nitrate" против "Sodium nitrate").
--
-- 1.1-цепочка при этом разорвана: sodium-nitrate-synthesis (PCPRedux) кормит только
-- nitrous-oxide-synthesis-2, а Angels-рецепты (nitric gasses / nitric acid) видят лишь
-- свой предмет. Сводим обратно в один; предметы в сейвах переносит
-- migrations/zzzparanoidal_8.1.9.json.
--
-- Апстрим: Pezzawinkle/PezsMods (баг живой в master). Гард снимет фикс сам, когда
-- в PCPRedux ссылки перейдут на angels-solid-sodium-nitrate.

local OLD = "solid-sodium-nitrate"
local NEW = "angels-solid-sodium-nitrate"

if not (data.raw.item[OLD] and data.raw.item[NEW]) then
	return
end

bobmods.lib.recipe.replace_ingredient_in_all(OLD, NEW)

-- аналога replace_result_in_all в boblibrary нет: результаты правим сами, обе формы записи
for _, recipe in pairs(data.raw.recipe) do
	for _, result in pairs(recipe.results or {}) do
		if result.name == OLD then
			result.name = NEW
		elseif result[1] == OLD then
			result[1] = NEW
		end
	end
end

data.raw.item[OLD] = nil
