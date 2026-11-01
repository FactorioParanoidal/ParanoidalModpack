-- Компактное окно «Создание». Высоту сетки задаёт самая длинная вкладка, поэтому короткие однотипные
-- строки сливаются в одну, а рецепты бочек скрываются из ручного крафта. Только размещение в меню:
-- рецепты, предметы, открытия и механика не меняются. После всех раскладок меню и вкладки «Жидкости».
-- Строка = первая подгруппа списка; остальные вливаются в неё блоками в порядке списка (префикс order).
-- Подгруппа из другой вкладки = перенос туда. Предметы и их здания/оборудование следуют за рецептами.
local rows = {
	-- circuit
	{ -- Лампы и факел
		"paranoidal-circuit-visual", "paranoidal-organized-production-torch",
	},
	-- transport
	{ -- Рельсы и опоры
		"paranoidal-transport-rail", "paranoidal-transport-rail-elevated",
	},
	{ -- Танки Schall: лёгкие, средние, тяжёлые, сверхтяжёлые
		"paranoidal-transport-tanks-l", "paranoidal-transport-tanks-m", "paranoidal-transport-tanks-h", "paranoidal-transport-tanks-sh",
	},
	{ -- Оборуд.: топливные ячейки (MK + размерные)
		"paranoidal-organized-transport-equipment-fission-cells", "paranoidal-organized-transport-equipment-extra-fuel-cells",
	},
	{ -- Оборуд.: реакторы (MK + ядерный)
		"paranoidal-organized-transport-equipment-fission-reactors", "paranoidal-organized-transport-equipment-extra-reactor",
	},
	{ -- Оборуд.: аккумуляторы (MK + транспортные)
		"paranoidal-organized-transport-equipment-batteries", "paranoidal-organized-transport-equipment-extra-batteries",
	},
	{ -- Оборуд.: щиты (MK + транспортные)
		"paranoidal-organized-transport-equipment-shields", "paranoidal-organized-transport-equipment-extra-shields",
	},
	-- production
	{ -- Ремонт и наноботы
		"paranoidal-organized-production-repair", "paranoidal-organized-production-nanobots", "equipment",
	},
	{ -- Буры
		"paranoidal-organized-production-drills", "paranoidal-organized-production-area-drills",
	},
	{ -- Добыча жидкостей
		"paranoidal-organized-production-pumpjacks", "paranoidal-organized-production-water-pumps", "paranoidal-production-extraction",
	},
	{ -- Печи
		"paranoidal-organized-production-furnaces", "paranoidal-organized-production-mixing-furnaces",
	},
	{ -- Центрифуги и переработчики
		"paranoidal-organized-production-centrifuges", "smelting-machine",
	},
	{ -- Лаборатории
		"paranoidal-organized-production-labs", "paranoidal-organized-production-special-labs",
	},
	{ -- Котлы
		"paranoidal-organized-production-boilers", "paranoidal-organized-production-fluid-boilers", "paranoidal-organized-production-special-boilers",
	},
	{ -- Паровые двигатели, турбины, генераторы
		"paranoidal-organized-production-steam-engines", "paranoidal-organized-production-steam-turbines", "paranoidal-organized-production-generators",
	},
	{ -- Солнечные панели
		"paranoidal-organized-production-solar-1", "paranoidal-organized-production-solar-2", "paranoidal-organized-production-solar-3", "paranoidal-organized-production-special-solar",
	},
	{ -- Аккумуляторы
		"paranoidal-organized-production-accumulators-1", "paranoidal-organized-production-accumulators-2", "paranoidal-organized-production-accumulators-3", "paranoidal-organized-production-special-accumulators",
	},
	{ -- Реакторы и РИТЭГ
		"paranoidal-organized-production-reactors", "paranoidal-organized-production-angels-reactor", "paranoidal-organized-production-rtg",
	},
	{ -- Теплообменники и тепловые трубы
		"paranoidal-organized-production-heat-exchangers", "paranoidal-organized-production-heat-pipes",
	},
	{ -- Yuoki: машины линии 1
		"y_line1", "y_line1b",
	},
	-- intermediate-products
	{ -- Аккумуляторы (обычные и поездные)
		"paranoidal-components-batteries", "paranoidal-components-train-batteries",
	},
	{ -- Переработка урановой и ториевой руды
		"paranoidal-components-ore-processing", "paranoidal-organized-intermediate-products-nuclear-processing",
	},
	{ -- Переработка ядерного топлива и плутоний
		"paranoidal-components-uranium-reprocessing", "paranoidal-components-plutonium",
	},
	{ -- Детали мехов, пушка паука, каркасы дронов
		"paranoidal-components-mech-parts", "paranoidal-organized-intermediate-products-spider-cannon", "paranoidal-components-drone-frames",
	},
	{ -- Научные компоненты
		"paranoidal-components-science-components", "paranoidal-components-advanced-science-components",
	},
	{ -- Yuoki: торговля
		"yie_trades_line1", "yie_trades_line2", "yie_trades_import_line1",
	},
	-- combat
	{ -- Армия роботов (дроиды и их здания)
		"robotarmy-droids", "production-machine",
	},
	-- angels-resource-refining
	{ -- Продвинутая сортировка: дроблёная руда и куски
		"paranoidal-refining-advanced-crushed", "paranoidal-refining-advanced-chunk",
	},
	{ -- Продвинутая сортировка: кристаллы и чистая руда
		"paranoidal-refining-advanced-crystal", "paranoidal-refining-advanced-pure",
	},
	{ -- Катализаторы, фильтры, дробильные насадки
		"paranoidal-refining-catalysts-filters", "paranoidal-refining-milling-drums",
	},
	{ -- Машины: дробилки и сортировщики
		"paranoidal-refining-crushers", "paranoidal-refining-sorters",
	},
	{ -- Машины: флотация, выщелачивание, очистка
		"paranoidal-refining-floatation", "paranoidal-refining-leaching", "paranoidal-refining-refineries",
	},
	{ -- Машины: измельчители и электролиз
		"paranoidal-refining-powderizers", "paranoidal-refining-electrowinning",
	},
	{ -- Машины: термальные воды, фильтрация, кристаллизация
		"paranoidal-refining-thermal", "paranoidal-refining-filter-plants", "paranoidal-refining-crystallizers",
	},
	{ -- УК-A2: ресурсы → УК-A2
		"j-y-atomics-1", "j-y-atomics-2", "j-y-atomics-4", "j-y-atomics-5", "j-y-atomics-7",
	},
	{ -- УК-A2: УК-A2 → ресурсы
		"j-y-atomics-11", "j-y-atomics-13", "j-y-atomics-14", "j-y-atomics-16",
	},
	-- angels-smelting
	{ -- Медь (+ чистая медь Yuoki)
		"paranoidal-smelting-angels-copper", "angels-copper-casting",
	},
	{ -- Железо (+ чистое железо Yuoki)
		"paranoidal-smelting-angels-iron", "angels-iron-casting",
	},
	{ -- Вольфрам и карбид вольфрама
		"paranoidal-smelting-angels-tungsten", "paranoidal-smelting-angels-tungsten-carbide",
	},
	{ -- Уран и обеднённый уран
		"paranoidal-smelting-clowns-uranium", "paranoidal-smelting-clowns-depleted-uranium",
	},
	{ -- Машины: переработка руды, грануляция, смешивание порошка
		"paranoidal-smelting-angels-processing-machine", "paranoidal-smelting-angels-pellet-press", "paranoidal-smelting-angels-powder-mixer",
	},
	{ -- Машины: доменные и химические печи
		"paranoidal-smelting-angels-blast-furnace", "paranoidal-smelting-angels-chemical-furnace",
	},
	-- angels-casting
	{ -- Кобальт и никель
		"paranoidal-casting-cobalt", "paranoidal-casting-nickel",
	},
	{ -- Медь
		"paranoidal-casting-copper-metal", "paranoidal-casting-copper-wire-pipes",
	},
	{ -- Обеднённый уран, осмий, магний (Clowns)
		"paranoidal-casting-clowns-depleted-uranium", "paranoidal-casting-clowns-osmium", "clowns-magnesium-casting",
	},
	{ -- Железо
		"paranoidal-casting-iron-melts", "paranoidal-casting-iron-products", "paranoidal-casting-iron-gears",
	},
	{ -- Свинец и цинк
		"paranoidal-casting-lead", "paranoidal-casting-zinc",
	},
	{ -- Титан
		"paranoidal-casting-titanium-metal", "paranoidal-casting-titanium-details",
	},
	{ -- Сталь: расплавы (+ хром и марганец для легирования)
		"paranoidal-casting-steel-melts", "paranoidal-casting-chrome", "paranoidal-casting-manganese",
	},
	{ -- Сталь: изделия и шестерни
		"paranoidal-casting-steel-products", "paranoidal-casting-steel-gears",
	},
	{ -- Припой
		"paranoidal-casting-solder-melts", "paranoidal-casting-solder-products",
	},
	{ -- Карбид вольфрама и медь-вольфрам
		"paranoidal-casting-tungsten-carbide", "paranoidal-casting-copper-tungsten",
	},
	{ -- Резина, изолированный провод, пластиковые трубы
		"paranoidal-casting-insulated-wire", "paranoidal-casting-rubber", "paranoidal-casting-plastic-stone-pipes",
	},
	{ -- Бронза
		"paranoidal-casting-bronze-melts", "paranoidal-casting-bronze-products",
	},
	{ -- Латунь
		"paranoidal-casting-brass-melts", "paranoidal-casting-brass-products", "paranoidal-casting-brass-details",
	},
	{ -- Пушечная бронза и инвар
		"paranoidal-casting-gunmetal", "paranoidal-casting-invar",
	},
	{ -- Формы, индукционные печи, смешиватели
		"paranoidal-casting-mold", "paranoidal-casting-induction-furnace", "paranoidal-casting-aragas-molten-alloy-mixer",
	},
	{ -- Литейные машины и печи спекания
		"paranoidal-casting-casting-machine", "paranoidal-casting-strand-casting-machine", "paranoidal-casting-sintering-oven",
	},
	-- angels-petrochem-refining
	{ -- Уголь
		"paranoidal-petrochem-coal-1", "paranoidal-petrochem-coal-2",
	},
	{ -- Твёрдое, дизельное и ядерное топливо
		"paranoidal-petrochem-fuel-1", "paranoidal-components-diesel", "paranoidal-petrochem-fuel-3",
	},
	{ -- Нефть (+ переработка нефти)
		"paranoidal-petrochem-oil-feed", "fluid-recipes",
	},
	{ -- Крекинг
		"paranoidal-petrochem-cracking-1", "paranoidal-petrochem-cracking-2",
	},
	{ -- Электролиз воды (обычный и каталитический)
		"paranoidal-petrochem-water-electrolysis", "paranoidal-petrochem-catalytic-electrolysis",
	},
	{ -- Оксиды углерода и газы воздуха
		"paranoidal-petrochem-carbon-oxides", "paranoidal-petrochem-air-gases",
	},
	{ -- Натрий
		"paranoidal-petrochem-sodium-base", "paranoidal-petrochem-sodium-special",
	},
	{ -- Галогены: хлор и фтор
		"paranoidal-petrochem-chlorine-inorganic", "paranoidal-petrochem-chlorine-organic", "paranoidal-petrochem-chlorine-polymers", "paranoidal-petrochem-fluorine",
	},
	{ -- Азот и ракетная химия
		"paranoidal-petrochem-nitrogen-oxides", "paranoidal-petrochem-nitrogen-organic", "paranoidal-petrochem-rocket-chemistry",
	},
	{ -- Пластик и смолы
		"paranoidal-petrochem-plastics", "paranoidal-petrochem-resins",
	},
	{ -- Резина
		"paranoidal-petrochem-rubber-additives", "paranoidal-petrochem-rubber-processing", "paranoidal-petrochem-rubber-products",
	},
	{ -- Электроды и катализаторы
		"paranoidal-petrochem-catalysts-1", "paranoidal-petrochem-catalysts-2",
	},
	{ -- Машины: электролизёры, компрессоры, разжижители
		"paranoidal-petrochem-machines-electrolyser", "paranoidal-petrochem-machines-air-filter", "paranoidal-petrochem-machines-liquifier",
	},
	{ -- Машины: химзаводы
		"paranoidal-petrochem-machines-chemical-plant", "paranoidal-petrochem-machines-advanced-chemical-plant",
	},
	{ -- Машины: газопереработка
		"paranoidal-petrochem-machines-gas-refinery", "paranoidal-petrochem-machines-advanced-gas-refinery",
	},
	{ -- Машины: нефтепереработка и разделители
		"paranoidal-petrochem-machines-oil-refinery", "paranoidal-petrochem-machines-separator",
	},
	{ -- Машины: паровой крекинг и факел
		"paranoidal-petrochem-machines-steam-cracker", "paranoidal-petrochem-flare-stack",
	},
	{ -- Yuoki: жидкости
		"y-fluid", "y_refine_parts",
	},
	{ -- Yuoki: машины, катализаторы, сырьё
		"y_refine_material", "y_refine_machinery", "y_refine_raws",
	},
	-- angels-fluid-control
	{ -- Малые и специальные баки
		"paranoidal-fluid-small-tanks", "paranoidal-fluid-angels-tanks",
	},
	-- space-exploration
	{ -- Наземные сооружения и площадки
		"paranoidal-organized-space-exploration-ground", "paranoidal-organized-production-space-sites",
	},
	{ -- Компоненты ракеты
		"paranoidal-organized-space-exploration-rocket-components", "paranoidal-components-space-parts",
	},
}

-- Общие подгруппы содержат и чужие предметы (например, здания Bio Industries в production-machine):
-- из них переносятся только рецепты, их основные продукты и связанные здания/оборудование.
local shared = {
	["production-machine"] = true, ["smelting-machine"] = true, equipment = true, ["fluid-recipes"] = true,
}

local raw = data.raw
local subgroups = raw["item-subgroup"]

local function find_product(result)
	if result.type == "fluid" then return raw.fluid[result.name] end
	for kind in pairs(defines.prototypes.item) do
		local prototype = raw[kind] and raw[kind][result.name]
		if prototype then return prototype end
	end
end

local function main_product(recipe)
	if recipe.main_product == "" then return end
	local results = recipe.results or {}
	for _, result in ipairs(results) do
		if result.name == recipe.main_product or (not recipe.main_product and #results == 1) then
			return find_product(result)
		end
	end
end

-- Итоговое размещение рецептов до любых переносов (подгруппа и order могут наследоваться от продукта).
local placement, recipes_in, others_in = {}, {}, {}
for name, recipe in pairs(raw.recipe) do
	local product = main_product(recipe)
	local place = {
		subgroup = recipe.subgroup or (product and product.subgroup),
		order = recipe.order or (product and product.order) or "",
		product = product,
	}
	placement[name] = place
	if place.subgroup then
		recipes_in[place.subgroup] = recipes_in[place.subgroup] or {}
		table.insert(recipes_in[place.subgroup], name)
	end
end
for kind, prototypes in pairs(raw) do
	if kind ~= "recipe" then
		for _, prototype in pairs(prototypes) do
			if type(prototype) == "table" and prototype.subgroup then
				others_in[prototype.subgroup] = others_in[prototype.subgroup] or {}
				table.insert(others_in[prototype.subgroup], prototype)
			end
		end
	end
end

local function linked(item)
	local list = {}
	for kind in pairs(defines.prototypes.entity) do
		local entity = raw[kind] and item.place_result and raw[kind][item.place_result]
		if entity then list[#list + 1] = entity end
	end
	for kind in pairs(defines.prototypes.equipment) do
		local equipment = raw[kind] and item.place_as_equipment_result and raw[kind][item.place_as_equipment_result]
		if equipment then list[#list + 1] = equipment end
	end
	return list
end

local done, moved_products = {}, {}
local stats = {rows = 0, recipes = 0, other = 0, missing = 0}
local function move(prototype, target, prefix)
	if done[prototype] then return false end
	done[prototype] = true
	prototype.subgroup = target
	prototype.order = (prefix .. (prototype.order or "")):sub(1, 200)
	return true
end

for _, row in ipairs(rows) do
	local target = row[1]
	if not subgroups[target] then
		stats.missing = stats.missing + 1
		log("[crafting-menu-compaction] missing row subgroup: " .. target)
	else
		stats.rows = stats.rows + 1
		for index, source in ipairs(row) do
			if not subgroups[source] then
				stats.missing = stats.missing + 1
				log("[crafting-menu-compaction] missing subgroup: " .. source)
			else
				local prefix = string.format("%02d-", index)
				for _, name in ipairs(recipes_in[source] or {}) do
					local recipe, place = raw.recipe[name], placement[name]
					if not done[recipe] and not (shared[source] and recipe.hidden) then
						done[recipe] = true
						recipe.subgroup = target
						recipe.order = (prefix .. place.order):sub(1, 200)
						stats.recipes = stats.recipes + 1
						local product = place.product
						if product and product.subgroup == source then
							if move(product, target, prefix) then stats.other = stats.other + 1 end
							moved_products[product] = true
							for _, related in ipairs(linked(product)) do
								if related.subgroup == source and move(related, target, prefix) then
									stats.other = stats.other + 1
								end
							end
						end
					end
				end
				if not shared[source] then
					for _, prototype in ipairs(others_in[source] or {}) do
						if move(prototype, target, prefix) then stats.other = stats.other + 1 end
						moved_products[prototype] = true
					end
				end
			end
		end
	end
end

-- Рецепты в других строках, бравшие order у перенесённого продукта, остаются на своих местах.
for name, recipe in pairs(raw.recipe) do
	local place = placement[name]
	if not done[recipe] and place.product and moved_products[place.product] then
		recipe.subgroup = recipe.subgroup or place.subgroup
		recipe.order = recipe.order or place.order
	end
end

-- Наполнение и опустошение бочек делает только насос для бочек; в базовой 2.0 они скрыты из ручного крафта.
local barrels = 0
for _, recipe in pairs(raw.recipe) do
	if recipe.category == "angels-barreling-pump" and not recipe.hidden and not recipe.hide_from_player_crafting then
		recipe.hide_from_player_crafting = true
		barrels = barrels + 1
	end
end

log(string.format("[crafting-menu-compaction] rows=%d recipes=%d other=%d missing=%d barrels-hidden=%d",
	stats.rows, stats.recipes, stats.other, stats.missing, barrels))
