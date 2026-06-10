-- Частичный порт мода angels-smelting-extended (Pezzawinkle, 1.1-only).
-- Оригинальный мод в 2.0 не портирован — восстанавливаем рабочие куски.
--
-- Секции:
--   0) PER-METAL SUBGROUPS для сплавов (визуальное разделение в Factoriopedia)
--   1) PIPE CASTING       — литьё труб из расплавов для 7 металлов
--   2) ALLOY ROLLS        — сплавы → roll-coils для 7 сплавов
--   3) TECH UNLOCKS       — привязки рецептов к техам
--
-- Техи angels-alloys-smelting-1/2/3 определены в data-stage отдельно
-- (prototypes/technology/angels-alloys-smelting.lua).

require("__zzzparanoidal__.paralib")

local items = {}
local recipes = {}

-- =============================================================================
-- 0. PER-METAL SUBGROUPS для сплавов (визуальное разделение в Factoriopedia)
-- =============================================================================
-- В 2.0 Angels положил все 6 сплавов (bronze/brass/gunmetal/invar/cobalt-steel/
-- nitinol) в один subgroup angels-alloys-casting → в Factoriopedia они слипаются
-- в одну кашу. Создаём per-metal subgroups (как у Angels уже сделано для
-- iron/copper/steel/titanium/tungsten/...), вставляем их в позиции u-a..u-f
-- (сразу после существующего angels-alloys-casting с order=u), и миграруем
-- существующие прототипы из angels-alloys-casting по имени.
--
-- Подгруппа angels-alloys-casting остаётся для "общих" вещей (rubber-rolls,
-- tungsten-carbide и прочее, что не привязано к одному из этих 6 сплавов).

local alloy_subgroups = {
	{ metal = "bronze",       order = "u-a" },
	{ metal = "brass",        order = "u-b" },
	{ metal = "gunmetal",     order = "u-c" },
	{ metal = "invar",        order = "u-d" },
	{ metal = "cobalt-steel", order = "u-e" },
	{ metal = "nitinol",      order = "u-f" },
}

do
	local new_subgroups = {}
	for _, s in ipairs(alloy_subgroups) do
		table.insert(new_subgroups, {
			type = "item-subgroup",
			name = "angels-" .. s.metal .. "-casting",
			group = "angels-casting",
			order = s.order,
		})
	end
	data:extend(new_subgroups)
end

-- Миграция существующих прототипов из angels-alloys-casting в per-metal.
-- Порядок проверки важен: cobalt-steel прежде steel/cobalt; nitinol не пересекается.
local function pick_alloy_subgroup(name)
	if string.find(name, "cobalt%-steel") then return "angels-cobalt-steel-casting" end
	if string.find(name, "nitinol", 1, true) then return "angels-nitinol-casting" end
	if string.find(name, "gunmetal", 1, true) then return "angels-gunmetal-casting" end
	if string.find(name, "invar", 1, true) then return "angels-invar-casting" end
	if string.find(name, "bronze", 1, true) then return "angels-bronze-casting" end
	if string.find(name, "brass", 1, true) then return "angels-brass-casting" end
	return nil
end

local function migrate_alloys_subgroup(t)
	for _, proto in pairs(t) do
		if proto.subgroup == "angels-alloys-casting" then
			local target = pick_alloy_subgroup(proto.name)
			if target then proto.subgroup = target end
		end
	end
end

migrate_alloys_subgroup(data.raw.item)
migrate_alloys_subgroup(data.raw.recipe)
migrate_alloys_subgroup(data.raw.fluid)

-- =============================================================================
-- 0b. ALLOY-MIXING (angelsextended-remelting-fixed): subgroup + tier rebalance
-- =============================================================================
-- Recipes molten-X-alloy-mixing* живут в собственных subgroup'ах
-- aragas-X-alloy-mixing → визуально отрываются от своих металлов. Переносим
-- в angels-<metal>-casting на хвост через "z[alloy-mixing]-N".
for name, recipe in pairs(data.raw.recipe) do
	local metal, suffix = name:match("^molten%-(.+)%-alloy%-mixing%-?(.*)$")
	if metal then
		local target = "angels-" .. metal .. "-casting"
		-- Защита: если subgroup для нового сплава ещё не создан, оставляем
		-- original (иначе Factorio упадёт при prototype validation).
		if data.raw["item-subgroup"][target] then
			recipe.subgroup = target
			recipe.order = "z[alloy-mixing]-" .. (suffix ~= "" and suffix or "1")
		end
	end
end

-- Steel rebalance: парность alloy-mixing ↔ native ingot-рецептов.
--   native -4 (steel+cobalt+nickel, на steel-3) ↔ NEW *-cobalt-nickel
--   native -5 (steel+chrome+tungsten, на steel-4) ↔ *-alloy-mixing-4 (был на steel-3)
-- Default remelting-fixed ставил alloy-mixing-4 на steel-3 (нет ingot-аналога
-- с chrome+tungsten на этом тире) + для cobalt+nickel вообще не было пары.
-- Alloy-mixer имеет 3 fluid input → cobalt идёт как powder (паттерн как у -4
-- с tungsten powder), nickel остаётся fluid'ом.
table.insert(recipes, {
	type = "recipe",
	name = "molten-steel-alloy-mixing-cobalt-nickel",
	-- T2 mixer (MK2+, синяя наука): ингредиенты на уровне alloy-mixing -2/-3.
	-- Категорию ставим здесь, а не через recipe_tier_overrides ниже: рецепт
	-- добавляется в data.raw через data:extend(recipes) в конце файла —
	-- override-loop его не догонит.
	category = "molten-alloy-mixing-2",
	subgroup = "angels-steel-casting",
	order = "z[alloy-mixing]-3-cobalt",
	enabled = false,
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "angels-liquid-molten-iron", amount = 240 },
		{ type = "fluid", name = "angels-liquid-molten-nickel", amount = 120 },
		{ type = "fluid", name = "angels-gas-oxygen", amount = 60 },
		{ type = "item", name = "angels-powder-cobalt", amount = 12 },
	},
	results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 440 } },
	icons = {
		{ icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png" },
		{
			icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
			tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
			scale = 0.32,
			shift = { -12, -12 },
		},
	},
	icon_size = 64,
})

do
	local OV = angelsmods.functions.OV
	OV.remove_unlock("angels-steel-smelting-3", "molten-steel-alloy-mixing-4")
	OV.add_unlock("angels-steel-smelting-4", "molten-steel-alloy-mixing-4")
	OV.add_unlock("angels-steel-smelting-3", "molten-steel-alloy-mixing-cobalt-nickel")
end

-- Alloy-mixer tiers: default — все 4 mixer'а с одной категорией molten-alloy-
-- mixing → MK1 и MK4 craftят то же самое, тиры теряют смысл. Делаем как у
-- angels-induction-furnace: per-tier категории + cumulative по тиру здания.
-- Сами категории определены в prototypes/recipe-category/alloy-mixing-tiers.lua
-- (требуют data-stage). Здесь только привязка к зданиям и recipe-categorization.
data.raw["assembling-machine"]["alloy-mixer"].crafting_categories = {
	"molten-alloy-mixing",
}
data.raw["assembling-machine"]["alloy-mixer-2"].crafting_categories = {
	"molten-alloy-mixing", "molten-alloy-mixing-2",
}
data.raw["assembling-machine"]["alloy-mixer-3"].crafting_categories = {
	"molten-alloy-mixing", "molten-alloy-mixing-2", "molten-alloy-mixing-3",
}
data.raw["assembling-machine"]["alloy-mixer-4"].crafting_categories = {
	"molten-alloy-mixing", "molten-alloy-mixing-2", "molten-alloy-mixing-3", "molten-alloy-mixing-4",
}

-- Tier = science-tier техи, в которой unlock'ается рецепт (а не суффикс -N).
-- Default rule: суффикс -N → tier N. Без суффикса → base T1.
-- Overrides для рецептов где tier по науке расходится с суффиксом:
--   steel-3 на steel-smelting-2 (RG) → T2
--   solder-3 на solder-smelting-3 (RG+chemical) → T2 (а не T3)
--   bronze-3 на bronze-smelting-3 (RG+chemical) → T2 (а не T3)
-- brass-3 на brass-smelting-3 (RG+chemical+production) → T3 (по rule, OK).
local tier_special = {
	["molten-steel-alloy-mixing-3"]  = 2,
	["molten-solder-alloy-mixing-3"] = 2,
	["molten-bronze-alloy-mixing-3"] = 2,
}
for name, recipe in pairs(data.raw.recipe) do
	if name:match("^molten%-.*%-alloy%-mixing") then
		local tier = tier_special[name] or tonumber(name:match("-(%d+)$"))
		if tier and tier >= 2 and tier <= 4 then
			recipe.category = "molten-alloy-mixing-" .. tier
		end
	end
end

-- Build cost: tier-N alloy-mixer требует 2× tier-(N-1) (default было 1×).
-- Поддерживаем оба формата ingredient'ов: long {name=,amount=} и short {n,a}.
for _, m in ipairs({
	{ recipe = "alloy-mixer-2", prev = "alloy-mixer" },
	{ recipe = "alloy-mixer-3", prev = "alloy-mixer-2" },
	{ recipe = "alloy-mixer-4", prev = "alloy-mixer-3" },
}) do
	local r = data.raw.recipe[m.recipe]
	if r and r.ingredients then
		for _, ing in ipairs(r.ingredients) do
			if ing.name == m.prev then
				ing.amount = 2
			elseif ing[1] == m.prev then
				ing[2] = 2
			end
		end
	end
end

-- =============================================================================
-- 1. PIPE CASTING (литъё труб из расплавов)
-- =============================================================================
-- В 1.1 шло через mod angels-smelting-extended/prototypes/recipes/ironworks.lua.
-- 2.0-bob делает трубы только через plate+brick; этот альтернативный путь
-- (molten metal → pipe) возвращает 1.1-механику.
--
-- metal_letter — для сплавов, чьи существующие Angels-прототипы используют
-- конвенцию <letter>[<metal>]-<sub-block> (bronze=a, brass=b, nitinol=f).
-- Когда metal_letter задан, мы кладём свои pipes ВНУТРЬ этого кластера
-- (`<letter>[<metal>]-e[<metal>-pipe]`), чтобы они стояли вплотную к metal-
-- items и не толкали roll-кластер за row-break в Factoriopedia.
-- Для чистых металлов (iron/copper/steel/titanium/tungsten) metal_letter нет —
-- pipes стоят в общем хвосте subgroup на слоте `n`.
local pipe_metals = {
	-- metal       pipe item              pipe-to-ground item              ug_amount  subgroup                  metal_letter
	{ "iron",     "pipe",                  "pipe-to-ground",                  150, "angels-iron-casting",     nil },
	{ "copper",   "bob-copper-pipe",       "bob-copper-pipe-to-ground",       150, "angels-copper-casting",   nil },
	{ "steel",    "bob-steel-pipe",        "bob-steel-pipe-to-ground",        170, "angels-steel-casting",    nil },
	{ "brass",    "bob-brass-pipe",        "bob-brass-pipe-to-ground",        190, "angels-brass-casting",    "b" },
	{ "bronze",   "bob-bronze-pipe",       "bob-bronze-pipe-to-ground",       170, "angels-bronze-casting",   "a" },
	{ "titanium", "bob-titanium-pipe",     "bob-titanium-pipe-to-ground",     210, "angels-titanium-casting", nil },
}

local function pipe_order(metal_letter, metal, sub_letter)
	if metal_letter then
		return metal_letter .. "[" .. metal .. "]-e[" .. metal .. "-pipe]-" .. sub_letter
	else
		return "n[" .. metal .. "-pipe]-" .. sub_letter
	end
end

for _, m in ipairs(pipe_metals) do
	local metal, pipe_item, ug_item, ug_amount, subgroup, ml = m[1], m[2], m[3], m[4], m[5], m[6]
	local molten = "angels-liquid-molten-" .. metal

	table.insert(recipes, {
		type = "recipe",
		name = "angels-" .. metal .. "-pipe-casting",
		localised_name = { "item-name." .. pipe_item },
		category = "angels-casting",
		subgroup = subgroup,
		energy_required = 4,
		enabled = false,
		auto_recycle = false,
		ingredients = { { type = "fluid", name = molten, amount = 40 } },
		results = { { type = "item", name = pipe_item, amount = 4 } },
		order = pipe_order(ml, metal, "a"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(molten),
	})

	table.insert(recipes, {
		type = "recipe",
		name = "angels-" .. metal .. "-pipe-to-ground-casting",
		localised_name = { "item-name." .. ug_item },
		category = "angels-casting",
		subgroup = subgroup,
		energy_required = 2,
		enabled = false,
		auto_recycle = false,
		ingredients = { { type = "fluid", name = molten, amount = ug_amount } },
		results = { { type = "item", name = ug_item, amount = 2 } },
		order = pipe_order(ml, metal, "b"),
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(molten),
	})
end

-- 1b. Pipe casting спец-кейсы из 1.1 ASE — не на molten-<metal>:
--   plastic — fluid liquid-plastic
--   stone   — item stone (sintering, vanilla)
-- Tungsten + copper-tungsten в 1.1 paranoidal modpack были скрыты и unlock'и
-- удалены (см. 1.1 zzzparanoidal/prototypes/micro-final-fix.lua) — здесь
-- их не портируем, повторяя поведение 1.1 modpack.
-- Subgroup — общая angels-alloys-casting.
local special_pipe_recipes = {
	-- plastic (default casting, liquid-plastic 40 / 170).
	-- Regular pipe в 1.1 имел amount=4 (баг автора), подогнал к 40 как у
	-- остальных металлов.
	{
		name = "angels-plastic-pipe-casting",
		pipe_item = "bob-plastic-pipe",
		category = "angels-casting",
		ingredients = { { type = "fluid", name = "angels-liquid-plastic", amount = 40 } },
		results_amount = 4,
		tint_fluid = "angels-liquid-plastic",
	},
	{
		name = "angels-plastic-pipe-to-ground-casting",
		pipe_item = "bob-plastic-pipe-to-ground",
		category = "angels-casting",
		ingredients = { { type = "fluid", name = "angels-liquid-plastic", amount = 170 } },
		results_amount = 2,
		energy_required = 2,
		tint_fluid = "angels-liquid-plastic",
	},
	-- stone (sintering): 20 stone → 4 pipe, 75 stone → 2 pipe-to-ground.
	-- Faithful 1.1: amounts = base×5 / ug_multi×5 (ug_multi=15, см. 1.1
	-- ironworks.lua:55).
	{
		name = "angels-stone-pipe-casting",
		pipe_item = "pipe",
		category = "angels-sintering",
		ingredients = { { type = "item", name = "stone", amount = 20 } },
		results_amount = 4,
	},
	{
		name = "angels-stone-pipe-to-ground-casting",
		pipe_item = "pipe-to-ground",
		category = "angels-sintering",
		ingredients = { { type = "item", name = "stone", amount = 75 } },
		results_amount = 2,
		energy_required = 2,
	},
}

for _, r in ipairs(special_pipe_recipes) do
	local recipe = {
		type = "recipe",
		name = r.name,
		localised_name = { "item-name." .. r.pipe_item },
		category = r.category,
		subgroup = "angels-alloys-casting",
		energy_required = r.energy_required or 4,
		enabled = false,
		auto_recycle = false,
		ingredients = r.ingredients,
		results = { { type = "item", name = r.pipe_item, amount = r.results_amount } },
		order = "n[" .. r.pipe_item .. "]",
	}
	if r.tint_fluid then
		recipe.crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(r.tint_fluid)
	end
	table.insert(recipes, recipe)
end

-- =============================================================================
-- 2. ALLOY ROLLS (compressing-extended) — 7 сплавов
-- =============================================================================
-- Для каждого металла: 1 item angels-roll-<metal> + 3 рецепта (casting T1,
-- converting, casting-fast T2). Иконка — тинтованный roll-iron.png.
--
-- Привязка к техам:
--   brass/bronze/tungsten         → angels-<metal>-smelting-2/3
--   invar/cobalt-steel/gunmetal   → angels-alloys-smelting-2/3 (секция 3)
--   nitinol                       → bob-nitinol-processing (все 3 рецепта)
--
-- molten_amount — базовое количество для T1. T2 fast = molten_amount × 1.75.
-- Для tungsten вместо molten metal используется gas-tungsten-hexafluoride,
-- базовый объём 20 (а не 80).
--
-- Layout в Factoriopedia: для металлов с metal_letter кладём roll-item +
-- T1/T2 рецепты внутрь metal-кластера на сабблоке c[roll-<metal>] —
-- roll-кластер плотно стоит с molten/alloy рецептами без row-wrap.
-- Converting (1 roll → 4 plate) выносится на отдельный сабблок
-- d[plate-<metal>-from-roll] (как Angels' iron-plate-2 на l[plate-iron]-d).
-- Для tungsten metal_letter нет — Angels' iron-convention: item на плоском
-- `j`, recipes на j[angels-roll-tungsten]-{a,b}, converting на
-- l[angels-plate-tungsten]-d.
local roll_alloys = {
	brass = {
		molten        = "angels-liquid-molten-brass",
		molten_amount = 80,
		plate         = "bob-brass-alloy",
		subgroup      = "angels-brass-casting",
		metal_letter  = "b",
		tint          = { r = 204 / 256, g = 153 / 256, b = 102 / 256, a = 1 },
	},
	bronze = {
		molten        = "angels-liquid-molten-bronze",
		molten_amount = 80,
		plate         = "bob-bronze-alloy",
		subgroup      = "angels-bronze-casting",
		metal_letter  = "a",
		tint          = { r = 224 / 256, g = 155 / 256, b = 58 / 256, a = 1 },
	},
	tungsten = {
		-- tungsten уникален: вместо molten metal использует gas-tungsten-hexafluoride
		-- и в 1.1 имел сильно меньший базовый объём (20 газа вместо 80 расплава).
		molten        = "angels-gas-tungsten-hexafluoride",
		molten_amount = 20,
		plate         = "tungsten-plate",
		subgroup      = "angels-tungsten-casting",
		metal_letter  = nil, -- собственная subgroup без metal-letter convention
		tint          = { r = 136 / 256, g = 98 / 256, b = 65 / 256, a = 1 },
	},
	-- Сплавы из общей подгруппы angels-alloys-casting (см. секцию 0).
	-- metal_letter — позиция в per-metal subgroups: bronze=a, brass=b,
	-- gunmetal=c, invar=d, cobalt-steel=e, nitinol=f. Tints из 1.1 ASE.
	nitinol = {
		molten        = "angels-liquid-molten-nitinol",
		molten_amount = 80,
		plate         = "bob-nitinol-alloy",
		subgroup      = "angels-nitinol-casting",
		metal_letter  = "f",
		tint          = { r = 106 / 256, g = 92 / 256, b = 153 / 256, a = 1 },
	},
	invar = {
		molten        = "angels-liquid-molten-invar",
		molten_amount = 80,
		plate         = "bob-invar-alloy",
		subgroup      = "angels-invar-casting",
		metal_letter  = "d",
		tint          = { r = 95 / 256, g = 125 / 256, b = 122 / 256, a = 1 },
	},
	["cobalt-steel"] = {
		molten        = "angels-liquid-molten-cobalt-steel",
		molten_amount = 80,
		plate         = "bob-cobalt-steel-alloy",
		subgroup      = "angels-cobalt-steel-casting",
		metal_letter  = "e",
		tint          = { r = 61 / 256, g = 107 / 256, b = 153 / 256, a = 1 },
	},
	gunmetal = {
		molten        = "angels-liquid-molten-gunmetal",
		molten_amount = 80,
		plate         = "bob-gunmetal-alloy",
		subgroup      = "angels-gunmetal-casting",
		metal_letter  = "c",
		tint          = { r = 224 / 256, g = 103 / 256, b = 70 / 256, a = 1 },
	},
}

-- Roll item: внутри metal-кластера на сабблоке c[roll-<metal>] (для tungsten —
-- плоский `j`, как у Angels iron-roll item: smelting-iron items.lua).
-- Recipes (casting T1, casting-fast T2): -a, -b в той же позиции — стоят
-- вплотную к item.
local function roll_order(metal_letter, metal, sub_letter)
	if metal_letter then
		return metal_letter .. "[" .. metal .. "]-c[roll-" .. metal .. "]"
			.. (sub_letter and ("-" .. sub_letter) or "")
	else
		return "j[angels-roll-" .. metal .. "]" .. (sub_letter and ("-" .. sub_letter) or "")
	end
end

-- Converting (1 roll → 4 plate, productivity) стоит отдельно от roll-кластера —
-- логически это рецепт PLATE, а не roll. Angels следует тому же паттерну для
-- iron: angels-plate-iron-2 на l[angels-plate-iron]-d (см. smelting-iron.lua:430).
local function converting_order(metal_letter, metal)
	if metal_letter then
		return metal_letter .. "[" .. metal .. "]-d[plate-" .. metal .. "-from-roll]"
	else
		return "l[angels-plate-" .. metal .. "]-d"
	end
end

local roll_icon = "__angelssmeltinggraphics__/graphics/icons/roll-iron.png"

for metal, p in pairs(roll_alloys) do
	local roll = "angels-roll-" .. metal
	local icons = { { icon = roll_icon, tint = p.tint, icon_size = 64 } }

	table.insert(items, {
		type = "item",
		name = roll,
		icons = icons,
		subgroup = p.subgroup,
		order = roll_order(p.metal_letter, metal, nil),
		stack_size = 200,
	})

	table.insert(recipes, {
		type = "recipe",
		name = roll .. "-casting",
		localised_name = { "item-name." .. roll },
		category = "angels-strand-casting",
		subgroup = p.subgroup,
		energy_required = 4,
		enabled = false,
		auto_recycle = false,
		ingredients = {
			{ type = "fluid", name = p.molten, amount = p.molten_amount },
			{ type = "fluid", name = "water", amount = 10 },
		},
		results = { { type = "item", name = roll, amount = 2 } },
		icons = icons,
		order = roll_order(p.metal_letter, metal, "a"),
	})

	-- Converting вынесен из roll-кластера — стоит отдельно на сабблоке
	-- d[plate-<metal>-from-roll] (для tungsten — l[angels-plate-tungsten]-d).
	table.insert(recipes, {
		type = "recipe",
		name = roll .. "-converting",
		localised_name = { "item-name." .. p.plate },
		category = "advanced-crafting",
		subgroup = p.subgroup,
		energy_required = 0.5,
		enabled = false,
		auto_recycle = false,
		allow_decomposition = false,
		allow_productivity = true,
		ingredients = { { type = "item", name = roll, amount = 1 } },
		results = { { type = "item", name = p.plate, amount = 4 } },
		order = converting_order(p.metal_letter, metal),
	})

	table.insert(recipes, {
		type = "recipe",
		name = roll .. "-casting-fast",
		localised_name = { "item-name." .. roll },
		category = "angels-strand-casting-2",
		subgroup = p.subgroup,
		energy_required = 2,
		enabled = false,
		auto_recycle = false,
		ingredients = {
			{ type = "fluid", name = p.molten, amount = math.floor(p.molten_amount * 1.75) },
			{ type = "fluid", name = "angels-liquid-coolant", amount = 40, ignored_by_stats = 32 },
		},
		results = {
			{ type = "item", name = roll, amount = 4 },
			{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
		},
		main_product = roll,
		icons = icons,
		order = roll_order(p.metal_letter, metal, "b"),
	})
end

data:extend(items)
data:extend(recipes)

-- =============================================================================
-- 3. TECH UNLOCKS
-- =============================================================================
-- Сами техи angels-alloys-smelting-1/2/3 создаются в data-stage отдельно
-- (prototypes/technology/angels-alloys-smelting.lua) — это нужно чтобы
-- research_evolution_factor успел применить свой evolution-factor effect
-- в своём data-final-fixes (он проходит по всем существующим техам).

-- 3a. Pipe casting: на angels-<metal>-smelting-1 для большинства металлов.
-- Iron — особый: pipe-casting переехал на angels-ironworks-1 (вместе с iron
-- gear-wheel casting, для тематической связности — обе операции в литейной).
-- Nitinol pipe — на bob-nitinol-processing (свой tech-tree).
for _, metal in ipairs({ "copper", "steel", "brass", "bronze", "titanium" }) do
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-1",
		"angels-" .. metal .. "-pipe-casting"
	)
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-1",
		"angels-" .. metal .. "-pipe-to-ground-casting"
	)
end
paralib.bobmods.lib.tech.add_recipe_unlock("angels-ironworks-1", "angels-iron-pipe-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-ironworks-1", "angels-iron-pipe-to-ground-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-to-ground-casting")

-- Спец-кейсы pipe-casting (см. секцию 1b). Каждый на своей T1-техе по 1.1 ASE.
paralib.bobmods.lib.tech.add_recipe_unlock("angels-plastic-1", "angels-plastic-pipe-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-plastic-1", "angels-plastic-pipe-to-ground-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-powder-metallurgy-1", "angels-stone-pipe-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-powder-metallurgy-1", "angels-stone-pipe-to-ground-casting")

-- 3b. Roll'ы brass/bronze/tungsten: на existing angels-<metal>-smelting-2/3.
for _, metal in ipairs({ "brass", "bronze", "tungsten" }) do
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-2",
		"angels-roll-" .. metal .. "-casting"
	)
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-2",
		"angels-roll-" .. metal .. "-converting"
	)
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-3",
		"angels-roll-" .. metal .. "-casting-fast"
	)
end

-- 3c. Roll'ы invar/cobalt-steel/gunmetal: на angels-alloys-smelting-2/3.
-- nitinol целиком на bob-nitinol-processing (вне alloys-smelting тех-дерева).
for _, metal in ipairs({ "invar", "cobalt-steel", "gunmetal" }) do
	paralib.bobmods.lib.tech.add_recipe_unlock("angels-alloys-smelting-2", "angels-roll-" .. metal .. "-casting")
	paralib.bobmods.lib.tech.add_recipe_unlock("angels-alloys-smelting-2", "angels-roll-" .. metal .. "-converting")
	paralib.bobmods.lib.tech.add_recipe_unlock("angels-alloys-smelting-3", "angels-roll-" .. metal .. "-casting-fast")
end
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-roll-nitinol-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-roll-nitinol-converting")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-roll-nitinol-casting-fast")
