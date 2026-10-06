-- Морской насос Angels 2.0 (бесплатные 1500 воды/с) отсутствовал в Beta 8: новых не строить.
-- Прототипы сущностей сохраняются, чтобы уже поставленные насосы в сейвах продолжали работать.
local NAME = "angels-sea-pump"

local recipe = data.raw.recipe[NAME]
if recipe then
	recipe.enabled = false
	recipe.hidden = true
end

local item = data.raw.item[NAME]
if item then item.hidden = true end

for _, entity in pairs({ data.raw["offshore-pump"][NAME .. "-placeable"], data.raw["mining-drill"][NAME] }) do
	entity.hidden = true
end

for _, technology in pairs(data.raw.technology) do
	local effects = technology.effects or {}
	for index = #effects, 1, -1 do
		if effects[index].type == "unlock-recipe" and effects[index].recipe == NAME then
			table.remove(effects, index)
		end
	end
end
