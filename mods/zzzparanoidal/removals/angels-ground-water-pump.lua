-- Скважина грунтовых вод Angels (бесплатная вода без водоёма) выведена из игры ещё в Beta 8:
-- рецепт скрыт в tweaks/recipe/pumps.lua, открытие убрано в tweaks/technology/pumps.lua.
-- Здесь прячутся оставшиеся страницы предмета и здания (Факториопедия, выбор сигналов и фильтров).
-- Прототипы сохраняются: control.lua Angels ссылается на имя, а уже поставленные скважины в сейвах
-- продолжают работать.
local NAME = "angels-ground-water-pump"

local recipe = data.raw.recipe[NAME]
if recipe then
	recipe.enabled = false
	recipe.hidden = true
end

local item = data.raw.item[NAME]
if item then item.hidden = true end

local entity = data.raw["offshore-pump"][NAME]
if entity then entity.hidden = true end

for _, technology in pairs(data.raw.technology) do
	local effects = technology.effects or {}
	for index = #effects, 1, -1 do
		if effects[index].type == "unlock-recipe" and effects[index].recipe == NAME then
			table.remove(effects, index)
		end
	end
end
