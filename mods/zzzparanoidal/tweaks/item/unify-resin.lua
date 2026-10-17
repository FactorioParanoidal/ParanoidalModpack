-- После OV.execute и поздних рецептурных правок: один предмет смолы, без ребаланса.
local old_name, new_name = "bob-resin", "resin"
local resin = data.raw.item[new_name]
if not (resin and data.raw.item[old_name]) then return end

local function replace_products(products)
	for _, product in pairs(products or {}) do
		if (product.type or "item") == "item" then
			if product.name == old_name then product.name = new_name end
			if product[1] == old_name then product[1] = new_name end
		end
	end
end

for _, recipe in pairs(data.raw.recipe) do
	replace_products(recipe.ingredients)
	replace_products(recipe.results)
	if recipe.main_product == old_name then recipe.main_product = new_name end
end

-- Добыча (включая bob-hardened-bile) и возможный предметный loot.
for _, prototypes in pairs(data.raw) do
	for _, prototype in pairs(prototypes) do
		if prototype.minable then
			replace_products(prototype.minable.results)
			if prototype.minable.result == old_name then prototype.minable.result = new_name end
		end
		for _, loot in pairs(prototype.loot or {}) do
			if loot.item == old_name then loot.item = new_name end
		end
	end
end

-- Не переименовываем recipe ID: сохраняются исследования и задания машин.
for _, name in ipairs({ "angels-solid-resin", "angels-bio-resin-wood-reprocessing" }) do
	local recipe = data.raw.recipe[name]
	if recipe then recipe.localised_name = { "item-name." .. new_name } end
end

-- У скрытых старых рецептов и растворения смолы остались явно заданные иконки кучки.
for _, name in ipairs({ "bob-resin-wood", "bob-resin-oil" }) do
	local recipe = data.raw.recipe[name]
	if recipe then
		recipe.icon = resin.icon
		recipe.icon_size = resin.icon_size
		recipe.icons = table.deepcopy(resin.icons)
	end
end
local liquification = data.raw.recipe["angels-bio-resin-resin-liquification"]
if liquification then
	for _, layer in pairs(liquification.icons or {}) do
		if layer.icon == "__bobplates__/graphics/icons/resin.png"
			or layer.icon == "__bobelectronics__/graphics/icons/resin.png" then
			-- Сохраняем размер и положение маленького ингредиента в составной иконке.
			layer.scale = (layer.scale or 1) * (layer.icon_size or 32) / resin.icon_size
			layer.icon, layer.icon_size = resin.icon, resin.icon_size
		end
	end
end

-- Angels собирает эту подсказку до нашей замены; не оставляем битый item-тег.
local function replace_description(value)
	if type(value) == "table" then
		for key, child in pairs(value) do value[key] = replace_description(child) end
	elseif type(value) == "string" then
		if value == "item-name." .. old_name then return "item-name." .. new_name end
		return (value:gsub("%[img=item/bob%-resin%]", "[img=item/resin]")
			:gsub("%[item=bob%-resin%]", "[item=resin]"))
	end
	return value
end
for _, tip in pairs(data.raw["tips-and-tricks-item"] or {}) do
	tip.localised_description = replace_description(tip.localised_description)
end

-- JSON item-migration переносит старые запасы и типизированные ссылки движка 1:1.
-- Самостоятельные angels-bio-resin / angels-liquid-resin не затрагиваются.
data.raw.item[old_name] = nil
