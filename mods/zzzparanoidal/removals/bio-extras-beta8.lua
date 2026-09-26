-- Пользовательская Beta 8: этих дополнительных BI-маршрутов не было в загруженной сборке.
-- После OV.execute и переноса отдельных BI-исследований. Прототипы/runtime не удаляем.
-- Топливо, pellet-coke, солнечные объекты и котёл остаются за границей этой пачки.
if not mods["Bio_Industries_2"] then return end
local excluded = {
	["bi-arboretum"] = true,
	["bi-arboretum-r1"] = true,
	["bi-arboretum-r2"] = true,
	["bi-arboretum-r3"] = true,
	["bi-arboretum-r4"] = true,
	["bi-arboretum-r5"] = true,
	["bi-seed-bomb-basic"] = true,
	["bi-seed-bomb-standard"] = true,
	["bi-seed-bomb-advanced"] = true,
	["bi-bio-cannon"] = true,
	["bi-bio-cannon-proto-ammo"] = true,
	["bi-bio-cannon-basic-ammo"] = true,
	["bi-bio-cannon-poison-ammo"] = true,
	["bi-resin-wood"] = true,
	["bi-stone-brick"] = true,
	["bi-liquid-air"] = true,
	["bi-nitrogen"] = true,
	["bi-sulfur"] = true,
	["bi-crushed-stone-2"] = true,
	["bi-crushed-stone-3"] = true,
	["bi-crushed-stone-4"] = true,
	["bi-crushed-stone-5"] = true,
}
for name in pairs(excluded) do
	local recipe = data.raw.recipe[name]
	if recipe then
		recipe.enabled = false
		recipe.hidden = true
		recipe.hide_from_player_crafting = true
	end
end
for _, technology in pairs(data.raw.technology) do
	if technology.max_level ~= "infinite" then
		for index = #(technology.effects or {}), 1, -1 do
			local effect = technology.effects[index]
			-- bi-acid в Beta 8 существовал disabled без unlock: не скрываем сам старый рецепт.
			if effect.type == "unlock-recipe" and (excluded[effect.recipe] or effect.recipe == "bi-acid") then
				table.remove(technology.effects, index)
			end
		end
	end
end
local cannon = data.raw.technology["bi-tech-bio-cannon"]
if cannon and cannon.max_level ~= "infinite" then
	cannon.enabled = false
	cannon.hidden = true
end
-- Только уникальные предметы исключённых маршрутов; общие смола, удобрения и сера остаются.
for _, name in ipairs({
	"bi-arboretum-area", "bi-bio-cannon", "bi-seed-bomb-basic", "bi-seed-bomb-standard",
	"bi-seed-bomb-advanced", "bi-bio-cannon-proto-ammo", "bi-bio-cannon-basic-ammo", "bi-bio-cannon-poison-ammo",
}) do
	local item = data.raw.item[name] or data.raw.ammo[name]
	if item then item.hidden = true end
end
-- Служебные HeroTurretRedux 1:1 требуют уже имеющуюся биопушку и не открываются наукой.
-- Их рецепты, ранги и сущности не меняем; получение исходной пушки закрыто выше.
