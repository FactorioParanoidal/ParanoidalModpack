-- Ветка Space Age (ПР-079, пользователь 2026-11-09): прохождение после ракеты, сплетённое из всех планет сборки.
-- 1. Мулуна — ворота системы. После ускорителей платформы открыта только она; «Звёздная картография» (после
--    межзвёздного пакета) даёт рецепты звёздных карт, карту делает сборочный автомат данных на Мулуне из межзвёздных
--    пакетов и астрономических данных. Создание карты исследует «Звёздная карта: <планета>», без неё открытие планеты
--    недоступно, а само открытие стоит ещё и межзвёздных пакетов. Перелёты с Наувиса идут через орбиту Мулуны
--    (planet-muluna: настройка override-space-connection включена принудительно).
-- 2. Пакеты планет берут детали другой планеты и дома. Количества здесь — до цен: space-age-prices (сразу после этого
--    файла) умножает ингредиенты пакетов на 5, как у всех пакетов планет.
-- 3. Заводы планет делают домашние цепочки Bob/Angels: у завода своя категория рецептов, её получают подходящие по трубам
--    домашние рецепты (последней, основная категория рецепта не меняется). Общие категории не годятся: «crushing» умеет
--    персонаж, «muluna-greenhouse» — домашний химический завод. Литейная, электромагнитный завод и биокамера (+50 %
--    продуктивности) берут только рецепты без продуктивности, и у них максимальная продуктивность 0 (решение
--    пользователя: бонус на домашних рецептах не нужен; базовый бонус машины действует и на рецепт без продуктивности —
--    прогон sa-w1-weave-test1-20261109, — а maximum_productivity рецепта ограничивает его). Дома у этих рецептов
--    продуктивности нет и не было: модули и маяки её не дают, машин с базовым бонусом их категорий нет; рецепты, на
--    которые действует исследование продуктивности, в такие заводы не берутся.
-- Без Космической эпохи или без Мулуны ничего не делает.
local filter = data.paranoidal_space_age_filter
local raw = data.raw
local INTERSTELLAR = "interstellar-science-pack"
if not (filter and filter.is_space_age and raw.planet and raw.planet["muluna"] and raw.recipe[INTERSTELLAR]
	and raw.technology[INTERSTELLAR]) then return end

local DATA_FLUID = "muluna-astronomical-data"
local DATA_PORT = 30 -- порт данных сборочного автомата данных (planet-muluna, prototypes/final-fixes/data-cells.lua)
local report = {}

local function item_exists(name)
	for kind in pairs(defines.prototypes.item) do
		if raw[kind] and raw[kind][name] then return true end
	end
	return false
end

local function add_prerequisite(technology, name)
	technology.prerequisites = technology.prerequisites or {}
	for _, existing in ipairs(technology.prerequisites) do
		if existing == name then return end
	end
	technology.prerequisites[#technology.prerequisites + 1] = name
end

local function add_pack(technology, pack)
	local unit = technology.unit
	if not unit then return end
	for _, ingredient in ipairs(unit.ingredients or {}) do
		if (ingredient[1] or ingredient.name) == pack then return end
	end
	unit.ingredients[#unit.ingredients + 1] = {pack, 1}
end

-- Значок с наложением астрономических данных: size — ожидаемый размер значка (64 у предмета, 256 у технологии).
local data_fluid = raw.fluid[DATA_FLUID]
local function with_data(layers, size)
	if data_fluid and data_fluid.icon then
		local px = data_fluid.icon_size or 64
		layers[#layers + 1] = {icon = data_fluid.icon, icon_size = px, scale = (size / 4) / px, shift = {size / 8, size / 8}}
	end
	return layers
end
local function icon_layers(prototype, default_size)
	if prototype.icons then return table.deepcopy(prototype.icons) end
	return {{icon = prototype.icon, icon_size = prototype.icon_size or default_size}}
end

---------------------------------------------------------------------------------------------- 1. звёздные карты
local maps = {
	{location = "vulcanus", packs = 10, data = 1000},
	{location = "fulgora", packs = 10, data = 1000},
	{location = "gleba", packs = 10, data = 1000},
	{location = "moshine", packs = 15, data = 1500},
	{location = "aquilo", packs = 20, data = 2000},
	{location = "maraxsis", packs = 20, data = 2000},
	-- Секрету видно только сквозь оптику из триплекса Мараксиса: она открывается после Мараксиса.
	{location = "secretas", packs = 30, data = 3000, parts = {{"maraxsis-glass-panes", 10}},
		prerequisites = {"maraxsis-glassworking"}},
}
local CARTOGRAPHY = "paranoidal-star-cartography"
local conditions = table.deepcopy(raw.recipe[INTERSTELLAR].surface_conditions)
local subgroup = (raw["item-subgroup"]["muluna-telescope"] and "muluna-telescope")
	or (raw.item[INTERSTELLAR] and raw.item[INTERSTELLAR].subgroup)
local unlocks, made = {}, {}
for index, map in ipairs(maps) do
	local location = raw.planet[map.location] or raw["space-location"][map.location]
	local discovery = raw.technology["planet-discovery-" .. map.location]
	if location and discovery and data_fluid then
		local name = "paranoidal-star-map-" .. map.location
		local place = {"space-location-name." .. map.location}
		local ingredients = {{type = "item", name = INTERSTELLAR, amount = map.packs},
			{type = "fluid", name = DATA_FLUID, amount = map.data, fluidbox_index = DATA_PORT}}
		for _, part in ipairs(map.parts or {}) do
			if item_exists(part[1]) then ingredients[#ingredients + 1] = {type = "item", name = part[1], amount = part[2]} end
		end
		local prerequisites = {CARTOGRAPHY}
		for _, technology in ipairs(map.prerequisites or {}) do
			if raw.technology[technology] then prerequisites[#prerequisites + 1] = technology end
		end
		local tech_icon = icon_layers(discovery, 64)
		data:extend({
			{
				type = "item",
				name = name,
				localised_name = {"item-name.paranoidal-star-map", place},
				localised_description = {"item-description.paranoidal-star-map", place},
				icons = with_data(icon_layers(location, 64), 64),
				subgroup = subgroup,
				order = "z[paranoidal-star-map]-" .. index,
				stack_size = 10,
				auto_recycle = false,
			},
			{
				type = "recipe",
				name = name,
				localised_name = {"item-name.paranoidal-star-map", place},
				categories = {"crafting-with-fluid-and-data"},
				surface_conditions = table.deepcopy(conditions),
				energy_required = 60,
				enabled = false,
				ingredients = ingredients,
				results = {{type = "item", name = name, amount = 1}},
				main_product = name,
				allow_productivity = false,
				allow_quality = false,
				auto_recycle = false,
			},
			{
				type = "technology",
				name = name,
				localised_name = {"technology-name.paranoidal-star-map", place},
				localised_description = {"technology-description.paranoidal-star-map", place},
				icons = with_data({tech_icon[1]}, 256),
				prerequisites = prerequisites,
				research_trigger = {type = "craft-item", item = name},
				effects = {},
			},
		})
		-- карта — пропуск, а не материал: всегда обычного качества (реестр ic-more-qualities)
		local normal = raw["mod-data"] and raw["mod-data"]["ic-normal-result"]
		if normal then normal.data.recipes[name] = true end
		unlocks[#unlocks + 1] = {type = "unlock-recipe", recipe = name}
		add_prerequisite(discovery, name)
		add_pack(discovery, INTERSTELLAR)
		made[#made + 1] = map.location
	end
end
if #unlocks > 0 then
	local telescope = raw.technology["muluna-telescope"]
	data:extend({{
		type = "technology",
		name = CARTOGRAPHY,
		icons = with_data(telescope and {icon_layers(telescope, 64)[1]} or icon_layers(raw.technology[INTERSTELLAR], 64), 256),
		prerequisites = {INTERSTELLAR},
		unit = {count = 500, time = 60, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1},
			{"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1},
			{"space-science-pack", 1}, {INTERSTELLAR, 1}}},
		effects = unlocks,
	}})
end
report[#report + 1] = "star maps: " .. table.concat(made, ", ")

---------------------------------------------------------------------------------------------- 2. детали в пакетах
local pack_parts = {
	[INTERSTELLAR] = {{"rocket-control-unit", 1}},
	["metallurgic-science-pack"] = {{"aluminum-plate", 1}, {"bob-nitinol-alloy", 1}},
	["electromagnetic-science-pack"] = {{"silicon-cell", 1}, {"bob-advanced-processing-unit", 1}},
	["agricultural-science-pack"] = {{"muluna-microcellular-plastic", 1}},
	["cryogenic-science-pack"] = {{"paranoidal-pobedit", 1}, {"bob-silicon-nitride", 1}},
	["hydraulic-science-pack"] = {{"paranoidal-refractory-beam", 1}, {"bob-titanium-plate", 1}},
	["golden-science-pack"] = {{"maraxsis-glass-panes", 2}},
}
local woven = {}
for recipe_name, parts in pairs(pack_parts) do
	local recipe = raw.recipe[recipe_name]
	if recipe and recipe.ingredients then
		for _, part in ipairs(parts) do
			local present = false
			for _, ingredient in ipairs(recipe.ingredients) do
				if ingredient.name == part[1] and ingredient.type ~= "fluid" then present = true end
			end
			if not present and item_exists(part[1]) then
				recipe.ingredients[#recipe.ingredients + 1] = {type = "item", name = part[1], amount = part[2]}
				woven[#woven + 1] = recipe_name .. "+" .. part[1]
			end
		end
	end
end
table.sort(woven)
report[#report + 1] = "pack parts: " .. table.concat(woven, ", ")

---------------------------------------------------------------------------------------------- 3. домашние цепочки
local factories = {
	{category = "paranoidal-planet-foundry", machines = {"foundry"}, home = {"angels-induction-smelting",
		"angels-induction-smelting-2", "angels-induction-smelting-3", "angels-induction-smelting-4", "angels-casting",
		"angels-casting-2", "angels-casting-3", "angels-casting-4", "angels-strand-casting", "angels-strand-casting-2",
		"angels-strand-casting-3", "angels-strand-casting-4", "angels-blast-smelting", "angels-blast-smelting-2",
		"angels-blast-smelting-3", "angels-blast-smelting-4", "angels-chemical-smelting", "angels-chemical-smelting-2",
		"angels-chemical-smelting-3", "angels-chemical-smelting-4", "molten-alloy-mixing", "molten-alloy-mixing-2",
		"molten-alloy-mixing-3", "molten-alloy-mixing-4", "bob-mixing-furnace"}},
	{category = "paranoidal-planet-electromagnetics", machines = {"electromagnetic-plant"},
		home = {"electronics", "electronics-machine", "electronics-with-fluid"}},
	{category = "paranoidal-planet-organic", machines = {"biochamber"}, home = {"angels-bio-processor",
		"angels-bio-processing", "angels-bio-processing-2", "angels-bio-processing-3", "angels-bio-processing-4",
		"angels-nutrient-extractor", "angels-bio-pressing", "angels-seed-extractor", "biofarm-mod-bioreactor",
		"biofarm-mod-bioreactor-2", "biofarm-mod-bioreactor-3"}},
	{category = "paranoidal-planet-cryogenics", machines = {"cryogenic-plant"}, home = {"angels-liquifying",
		"angels-cooling", "angels-petrochem-air-filtering", "angels-gas-refining", "angels-advanced-gas-refining",
		"angels-advanced-chemistry", "chemistry"}},
	{category = "paranoidal-planet-crushing", machines = {"crusher"}, home = {"angels-ore-refining-t1", "y-crushing"}},
	{category = "paranoidal-planet-hydro", machines = {"maraxsis-hydro-plant", "maraxsis-hydro-plant-extra-module-slots"},
		home = {"angels-water-treatment", "angels-washing-plant", "angels-salination-plant", "angels-filtering",
		"angels-filtering-2", "angels-filtering-3"}},
	{category = "paranoidal-planet-greenhouse", machines = {"muluna-greenhouse-wood"}, home = {"angels-arboretum",
		"angels-tree", "angels-tree-temperate", "angels-tree-swamp", "angels-tree-desert"}},
}

local function fluid_boxes(machine)
	local inputs, outputs = 0, 0
	for _, box in ipairs(machine.fluid_boxes or {}) do
		local kind = box.production_type
		if kind == "input" or kind == "input-output" then inputs = inputs + 1 end
		if kind == "output" or kind == "input-output" then outputs = outputs + 1 end
	end
	return inputs, outputs
end
local function fluids(list)
	local count = 0
	for _, part in ipairs(list or {}) do
		if part.type == "fluid" then count = count + 1 end
	end
	return count
end

local research_productivity = {}
for _, technology in pairs(raw.technology) do
	for _, effect in ipairs(technology.effects or {}) do
		if effect.type == "change-recipe-productivity" and effect.recipe then research_productivity[effect.recipe] = true end
	end
end

local counts = {}
for _, factory in ipairs(factories) do
	local machines = {}
	for _, name in ipairs(factory.machines) do
		if raw["assembling-machine"][name] then machines[#machines + 1] = raw["assembling-machine"][name] end
	end
	if #machines > 0 then
		local main = machines[1]
		local inputs, outputs = fluid_boxes(main)
		local productive = false
		for _, machine in ipairs(machines) do
			local base = machine.effect_receiver and machine.effect_receiver.base_effect
			if base and (base.productivity or 0) > 0 then productive = true end
		end
		local home = {}
		for _, category in ipairs(factory.home) do home[category] = true end
		data:extend({{type = "recipe-category", name = factory.category}})
		for _, machine in ipairs(machines) do
			machine.crafting_categories = machine.crafting_categories or {}
			table.insert(machine.crafting_categories, factory.category)
		end
		local count = 0
		for _, recipe in pairs(raw.recipe) do
			if not recipe.hidden and not filter.is_space_age(recipe) then
				local categories = recipe.categories or {"crafting"}
				local match, already = false, false
				for _, category in ipairs(categories) do
					if home[category] then match = true end
					if category == factory.category then already = true end
				end
				if match and not already and fluids(recipe.ingredients) <= inputs and fluids(recipe.results) <= outputs
					and not (productive and (recipe.allow_productivity or research_productivity[recipe.name])) then
					local list = {}
					for _, category in ipairs(categories) do list[#list + 1] = category end
					list[#list + 1] = factory.category
					recipe.categories = list
					if productive then recipe.maximum_productivity = 0 end
					count = count + 1
				end
			end
		end
		counts[#counts + 1] = factory.machines[1] .. " " .. count
	end
end
report[#report + 1] = "home recipes in planet factories: " .. table.concat(counts, ", ")
log("zzzparanoidal space-age-weaving: " .. table.concat(report, "; "))
