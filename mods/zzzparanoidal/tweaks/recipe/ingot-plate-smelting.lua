-- Пластина из слитка в печи (решение пользователя 2026-10-31, лестница качества). Литьё идёт через расплав,
-- а жидкость качества не несёт: у алюминия, титана, серебра, золота, кобальта, платины и стали качество
-- обрывалось на расплаве (не больше 2–4 бросков модулей по цепочке против 7–13 у железа и меди). Печь
-- переносит качество слитка в пластину. Выход хуже литья (там 1 слиток = 1 пластина): востребованные
-- металлы 7 -> 4, остальные 5 -> 3. Обратного рецепта нет (переплавка пластин в расплав скрыта,
-- anti-exploit п. 1), петли не возникает. Открывается вместе с первым рецептом слитка.
local raw = data.raw

local metals = {
	-- востребованные (сотни рецептов-потребителей)
	{ingot = "angels-ingot-steel", plate = "steel-plate", ingots = 7, plates = 4},
	{ingot = "angels-ingot-titanium", plate = "bob-titanium-plate", ingots = 7, plates = 4},
	{ingot = "angels-ingot-aluminium", plate = "bob-aluminium-plate", ingots = 7, plates = 4},
	-- остальные (единицы–десятки потребителей)
	{ingot = "angels-ingot-silver", plate = "bob-silver-plate", ingots = 5, plates = 3},
	{ingot = "angels-ingot-gold", plate = "bob-gold-plate", ingots = 5, plates = 3},
	{ingot = "angels-ingot-cobalt", plate = "bob-cobalt-plate", ingots = 5, plates = 3},
	{ingot = "angels-ingot-platinum", plate = "angels-plate-platinum", ingots = 5, plates = 3},
}

local function layers(item)
	if item.icons then return table.deepcopy(item.icons) end
	return {{icon = item.icon, icon_size = item.icon_size or 64}}
end

-- Иконка пластины, слиток уменьшенно в левом верхнем углу (как у рецептов плавки Paranoidal).
local function recipe_icons(plate, ingot)
	local icons = layers(plate)
	for _, layer in ipairs(layers(ingot)) do
		local size = layer.icon_size or 64
		layer.scale = (layer.scale or 32 / size) * 0.4375
		local shift = layer.shift or {0, 0}
		layer.shift = {(shift[1] or shift.x or 0) * 0.4375 - 10, (shift[2] or shift.y or 0) * 0.4375 - 10}
		icons[#icons + 1] = layer
	end
	return icons
end

-- Число всех предков технологии (ранняя технология — меньше предков).
local ancestor_count = {}
local function ancestors(name)
	if ancestor_count[name] then return ancestor_count[name] end
	local seen, stack, count = {[name] = true}, {name}, 0
	while #stack > 0 do
		local technology = raw.technology[table.remove(stack)]
		for _, prerequisite in pairs(technology and technology.prerequisites or {}) do
			if not seen[prerequisite] then
				seen[prerequisite] = true
				count = count + 1
				stack[#stack + 1] = prerequisite
			end
		end
	end
	ancestor_count[name] = count
	return count
end

-- Технология, которая открывает первый рецепт слитка (нескрытая и не выключенная).
local function unlocking_technology(ingot)
	local producers = {}
	for name, recipe in pairs(raw.recipe) do
		for _, result in pairs(recipe.results or {}) do
			if result.name == ingot and recipe.category ~= "recycling" then producers[name] = true end
		end
	end
	local found
	for name, technology in pairs(raw.technology) do
		if not technology.hidden and technology.enabled ~= false then
			for _, effect in pairs(technology.effects or {}) do
				if effect.type == "unlock-recipe" and producers[effect.recipe] then
					-- Детерминированно: из подходящих — с наименьшим числом предков, затем по имени.
					local depth = ancestors(name)
					if not found or depth < found.depth or (depth == found.depth and name < found.name) then
						found = {name = name, depth = depth}
					end
				end
			end
		end
	end
	return found and found.name
end

-- Модули как у прочих рецептов без продуктивности (prototypes/modules-beta8.lua уже отработал): все категории,
-- кроме модулей с продуктивностью.
local productivity_categories = {productivity = true, ["raw-productivity"] = true, god = true}
local module_categories = {}
for category in pairs(raw["module-category"]) do
	if not productivity_categories[category] then module_categories[#module_categories + 1] = category end
end
table.sort(module_categories)

local added = {}
for _, metal in ipairs(metals) do
	local ingot, plate = raw.item[metal.ingot], raw.item[metal.plate]
	local technology_name = ingot and plate and unlocking_technology(metal.ingot)
	if technology_name then
		local name = "paranoidal-" .. metal.plate .. "-from-ingot"
		data:extend({{
			type = "recipe",
			name = name,
			category = "smelting",
			subgroup = plate.subgroup,
			order = (plate.order or "") .. "-z",
			enabled = false,
			energy_required = 3.2 * metal.plates,
			ingredients = {{type = "item", name = metal.ingot, amount = metal.ingots}},
			results = {{type = "item", name = metal.plate, amount = metal.plates}},
			icons = recipe_icons(plate, ingot),
			allow_productivity = false,
			allowed_module_categories = table.deepcopy(module_categories),
			allow_decomposition = false,
		}})
		local technology = raw.technology[technology_name]
		technology.effects = technology.effects or {}
		table.insert(technology.effects, {type = "unlock-recipe", recipe = name})
		added[#added + 1] = name .. " (" .. metal.ingots .. "->" .. metal.plates .. ", " .. technology_name .. ")"
	else
		log("Paranoidal ingot->plate: skipped " .. metal.plate .. " (no item or no unlocking technology)")
	end
end
log("Paranoidal ingot->plate smelting recipes (" .. #added .. "): " .. table.concat(added, ", "))
