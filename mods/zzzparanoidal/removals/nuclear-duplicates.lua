-- Ядерное и топливно-воздушное оружие, которое дублирует paranoidal-true-nukes (решения пользователя 2026-11-15):
-- атомный артснаряд Bob, ядерный и термоядерный артснаряды Clowns, термоядерная бомба Clowns с исследованием,
-- огненная ракета Bob с боевой частью и огненный артснаряд Bob. Предметы, рецепты и исследования удаляются
-- (сохранений со сборкой 2.1 ещё нет). Исследование «Огненные артиллерийские снаряды» Bob остаётся: им теперь
-- открывается большая термобарическая боеголовка. Снаряды-прототипы остаются без ссылок.
-- Порядок: после всех правок цен и дерева, до пересборки переработки (иначе она построит рецепты удалённым).
if not mods["paranoidal-true-nukes"] then return end

local items = {
	"bob-atomic-artillery-shell", "artillery-shell-nuclear", "artillery-shell-thermonuclear", "thermonuclear-bomb",
	"bob-flame-rocket", "bob-flame-rocket-warhead", "bob-fire-artillery-shell",
}
local technologies = { "bob-atomic-artillery-shell", "thermonuclear-bomb", "bob-flame-rocket" }

local removed_items = {}
for _, name in ipairs(items) do
	for _, kind in ipairs({ "item", "ammo", "capsule" }) do
		if data.raw[kind] and data.raw[kind][name] then
			data.raw[kind][name] = nil
			removed_items[name] = true
		end
	end
end

-- Рецепты, у которых удалённый предмет среди ингредиентов или результатов.
local function mentions(list)
	for _, entry in pairs(list or {}) do
		if removed_items[entry.name or entry[1]] and (entry.type or "item") == "item" then return true end
	end
	return false
end
local removed_recipes = {}
for name, recipe in pairs(data.raw.recipe) do
	if mentions(recipe.ingredients) or mentions(recipe.results) then
		data.raw.recipe[name] = nil
		removed_recipes[name] = true
	end
end

local removed_technologies = {}
for _, name in ipairs(technologies) do
	if data.raw.technology[name] then
		data.raw.technology[name] = nil
		removed_technologies[name] = true
	end
end
for _, technology in pairs(data.raw.technology) do
	if technology.effects then
		local kept = {}
		for _, effect in ipairs(technology.effects) do
			if not (effect.type == "unlock-recipe" and removed_recipes[effect.recipe]) then kept[#kept + 1] = effect end
		end
		technology.effects = kept
	end
	if technology.prerequisites then
		local kept = {}
		for _, prerequisite in ipairs(technology.prerequisites) do
			if not removed_technologies[prerequisite] then kept[#kept + 1] = prerequisite end
		end
		technology.prerequisites = kept
	end
end
