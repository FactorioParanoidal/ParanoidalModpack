-- Beta 8 normal: натрий/крафт-варка и бумага III по ПР-041. Катализаторы/свойства 2.0 сохранены.
local sodium = data.raw.recipe["angels-solid-sodium"]
if sodium then
	for _, product in ipairs(sodium.results or {}) do
		if product.type == "fluid" and product.name == "steam" then
			product.name = "angels-water-purified"
		end
	end
end
local cooking = data.raw.recipe["angels-kraft-cooking-washing"]
if cooking then
	for _, product in ipairs(cooking.results or {}) do
		if product.name == "angels-solid-wood-pulp" then product.amount = 30 end
	end
end

-- Новый в 2.0 распад гипохлорита не имел аналога в Beta 8; старый потребитель — монохлорамин.
-- Предметы/старые производители соли и кислорода не отключаются.
local decomposition = data.raw.recipe["angels-solid-sodium-hypochlorite-decomposition"]
if decomposition then
	decomposition.enabled = false
	decomposition.hidden = true
end
-- ПР-041: старые три жидких входа помещаются в существующих усовершенствованных химзаводах.
local paper = data.raw.recipe["angels-solid-paper-3"]
if paper then
	paper.category = "angels-advanced-chemistry"
	paper.energy_required = 4
	local ingredients = {}
	for _, ingredient in ipairs(paper.ingredients or {}) do
		if ingredient.type ~= "fluid" or ingredient.name ~= "angels-gas-oxygen" then
			ingredients[#ingredients + 1] = ingredient
		end
	end
	table.insert(ingredients, 3, { type = "fluid", name = "angels-gas-oxygen", amount = 60 })
	paper.ingredients = ingredients

	-- Остальные входы/выходы уже совпадают; сохраняем их текущие метаданные.
	local results = {}
	for _, product in ipairs(paper.results or {}) do
		if product.name == "angels-solid-paper" then product.amount = 6 end
		if product.type ~= "fluid" or product.name ~= "angels-gas-oxygen" then
			results[#results + 1] = product
		end
	end
	paper.results = results
end
