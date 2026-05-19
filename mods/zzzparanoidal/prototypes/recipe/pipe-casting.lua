-- Port литья труб из расплавов angels-smelting-extended 1.0.13 (1.1) на 2.0.
-- Оригинальный мод не портирован, в 2.0 трубы делаются только через bob-плитовую схему.
-- Восстанавливаем альтернативный путь: 40 angels-liquid-molten-X → 4 X-pipe,
-- N angels-liquid-molten-X → 2 X-pipe-to-ground (где N зависит от металла).

-- 7 «чистых» металлов без спец-кейсов. Tungsten/plastic/stone/copper-tungsten/ceramic
-- в 1.1 шли через отдельные cycles (sintering, gas, item-stone, powder-mix) — здесь не
-- портируем, по необходимости — отдельным PR.

-- В 2.0 сабгруппы для сплавов (brass/bronze/nitinol) объединены в angels-alloys-casting;
-- остальные металлы имеют per-metal subgroup. Тип фиксируется в 5-м поле.
local pipe_metals = {
	-- metal               pipe item                 pipe-to-ground item                 ug_amount  subgroup
	{ "iron",     "pipe",                  "pipe-to-ground",                  150,       "angels-iron-casting" },
	{ "copper",   "bob-copper-pipe",       "bob-copper-pipe-to-ground",       150,       "angels-copper-casting" },
	{ "steel",    "bob-steel-pipe",        "bob-steel-pipe-to-ground",        170,       "angels-steel-casting" },
	{ "brass",    "bob-brass-pipe",        "bob-brass-pipe-to-ground",        190,       "angels-alloys-casting" },
	{ "bronze",   "bob-bronze-pipe",       "bob-bronze-pipe-to-ground",       170,       "angels-alloys-casting" },
	{ "titanium", "bob-titanium-pipe",     "bob-titanium-pipe-to-ground",     210,       "angels-titanium-casting" },
	{ "nitinol",  "bob-nitinol-pipe",      "bob-nitinol-pipe-to-ground",      230,       "angels-alloys-casting" },
}

local recipes = {}
for _, m in ipairs(pipe_metals) do
	local metal, pipe_item, ug_item, ug_amount, subgroup = m[1], m[2], m[3], m[4], m[5]
	local molten = "angels-liquid-molten-" .. metal

	-- pipe casting
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
		order = "y-a[" .. metal .. "-pipe]",
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(molten),
	})

	-- pipe-to-ground casting
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
		order = "y-b[" .. metal .. "-pipe-to-ground]",
		crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint(molten),
	})
end

data:extend(recipes)
