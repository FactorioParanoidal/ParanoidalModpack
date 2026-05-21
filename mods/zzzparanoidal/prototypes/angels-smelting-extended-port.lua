-- Переходный/частичный порт мода angels-smelting-extended (Pezzawinkle, 1.0.13, 1.1-only)
-- на 2.0. Оригинальный мод не портирован, его прототипы пропали при порте 1.1 → 2.0.
-- Здесь восстанавливаем рабочие куски без переноса всего мода.
--
-- В одном файле:
--   1) PIPE CASTING       — 7 металлов × 2 типа труб (PR #234)
--   2) ALLOY ROLLS        — brass/bronze/tungsten × {casting, converting, fast}
--   3) TECH UNLOCKS       — все привязки к существующим angels-X-smelting-N
--
-- НЕ переносим (нужно отдельным усилием):
--   - pipe-casting спец-кейсы (tungsten/plastic/stone/copper-tungsten/ceramic — sintering/gas/powder)
--   - alloy-rolls для nitinol/invar/cobalt-steel/gunmetal (нужны новые angels-alloys-smelting-N техи)
--   - gear-wheel casting (5 ironworks-N техов)
--   - alloy ingot-mixing (3 alloys-smelting-N техов)
--   - shielding coils (angelsindustries-overhaul-зависимое)
--   - stacks (girder stacks etc)

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
-- 1. PIPE CASTING (litie trub iz rasplavov)
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
	{ "nitinol",  "bob-nitinol-pipe",      "bob-nitinol-pipe-to-ground",      230, "angels-nitinol-casting",  "f" },
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

-- =============================================================================
-- 2. ALLOY ROLLS (compressing-extended) — brass / bronze / tungsten
-- =============================================================================
-- В 1.1 шло через mod angels-smelting-extended/prototypes/recipes/compressing-extended.lua.
-- Для каждого металла 3 рецепта: casting (T1) / converting (1 roll → 4 plate с productivity) /
-- casting-fast (T2 с coolant). Plus новый item angels-roll-X.
--
-- Эти 3 сплава выбраны потому что в 2.0 уже есть angels-X-smelting-2/3 техи —
-- новые техи не требуются. Для nitinol/invar/cobalt-steel/gunmetal нужны новые техи
-- angels-alloys-smelting-N — это отдельная задача.
--
-- Иконка: тинтованный roll-iron.png из angelssmeltinggraphics (как 1.1 extended делал
-- с roll-blank.png).

-- molten_amount задаёт базовое количество для T1; T2 = molten_amount * 1.75.
-- В 1.1 для tungsten базовое было 20 (gas), для остальных — 80 (molten).
--
-- Layout в Factoriopedia (важно для row-wrap):
-- Для brass/bronze (metal_letter заданный) кладём roll item + 2 casting рецепта
-- ВНУТРЬ metal-кластера на сабблок `c[roll-<metal>]`. После 5 item-в-кластере
-- (fluid + 3 molten + alloy) roll-кластер (item + T1 + T2 = 3 шт) аккуратно
-- занимает позиции 6-8 первого ряда — все рулоны рядом друг с другом, как в
-- iron/tin. Converting (1 roll → 4 plate) живёт отдельно на сабблоке
-- `d[plate-<metal>-from-roll]` — как у Angels' iron-plate-2 (l[angels-plate-X]-d).
--
-- Для tungsten metal_letter нет — используем Angels' iron convention:
-- item на плоском `j`, casting recipes на `j[angels-roll-<metal>]-{a,b}`,
-- converting на `l[angels-plate-<metal>]-d`.
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
		plate         = "bob-tungsten-plate",
		subgroup      = "angels-tungsten-casting",
		metal_letter  = nil, -- собственная subgroup без metal-letter convention
		tint          = { r = 136 / 256, g = 98 / 256, b = 65 / 256, a = 1 },
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
-- 3. TECH UNLOCKS (привязка рецептов к existing angels-X-smelting-N техам)
-- =============================================================================
-- В 1.1 эти юнлоки шли через override.lua extended мода. Воспроизводим тот же
-- паттерн через paralib helper.

-- 3a. Pipe casting: каждый pipe-casting открывается на angels-<metal>-smelting-1.
-- nitinol особый — у него AKMF-рокада на bob-nitinol-processing (см. ниже).
for _, metal in ipairs({ "iron", "copper", "steel", "brass", "bronze", "titanium" }) do
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-1",
		"angels-" .. metal .. "-pipe-casting"
	)
	paralib.bobmods.lib.tech.add_recipe_unlock(
		"angels-" .. metal .. "-smelting-1",
		"angels-" .. metal .. "-pipe-to-ground-casting"
	)
end
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("bob-nitinol-processing", "angels-nitinol-pipe-to-ground-casting")

-- 3b. Alloy rolls: подвязываем на angels-X-smelting-2 (T1 + converting) и -3 (T2 fast).
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
