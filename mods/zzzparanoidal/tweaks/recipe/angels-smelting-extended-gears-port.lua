-- Частичный порт мода angels-smelting-extended (Pezzawinkle, 1.1-only):
-- gear-wheel casting из расплавов металлов и расходные/постоянные dies.
--
-- 3 die-item recipes (sand/metal/metal-wash) + iron base 3 рецепта (regular/
-- expendable/advanced) + 6 alloys × 3 рецепта = 24 рецепта.
-- Tungsten уникален: использует angels-casting-powder-tungsten + категорию
-- angels-sintering вместо molten metal.
--
-- Items (ASE-sand-die / ASE-metal-die / ASE-spent-metal-die) определены в
-- prototypes/item/gear-dies.lua. Техи angels-ironworks-1..5 — в
-- prototypes/technology/angels-ironworks.lua.

require("__zzzparanoidal__.paralib")

local recipes = {}

-- 1. Die items recipes.
table.insert(recipes, {
	type = "recipe",
	name = "ASE-sand-die",
	category = "angels-sintering",
	subgroup = "angels-mold-casting",
	energy_required = 8,
	enabled = false,
	auto_recycle = false,
	icons = {
		{ icon = "__angelssmeltinggraphics__/graphics/icons/expendable-mold.png", icon_size = 32 },
		{ icon = "__angelssmeltinggraphics__/graphics/icons/expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
		{ icon = "__aai-industry__/graphics/icons/sand.png", icon_size = 64, scale = 0.21875, shift = { 10, -10 } },
	},
	icon_size = 32,
	ingredients = {
		{ type = "item", name = "angels-solid-sand", amount = 40 },
		{ type = "item", name = "angels-powder-steel", amount = 1 },
	},
	results = { { type = "item", name = "ASE-sand-die", amount = 8 } },
	order = "aa",
})

table.insert(recipes, {
	type = "recipe",
	name = "ASE-metal-die",
	category = "angels-sintering",
	subgroup = "angels-mold-casting",
	energy_required = 8,
	enabled = false,
	auto_recycle = false,
	icons = {
		{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32 },
		{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
	},
	icon_size = 32,
	ingredients = {
		{ type = "item", name = "angels-solid-zinc-oxide", amount = 40 },
		{ type = "item", name = "angels-powder-steel", amount = 10 },
	},
	results = { { type = "item", name = "ASE-metal-die", amount = 8 } },
	order = "ab",
})

table.insert(recipes, {
	type = "recipe",
	name = "ASE-metal-die-wash",
	category = "crafting-with-fluid",
	subgroup = "angels-mold-casting",
	energy_required = 8,
	enabled = false,
	auto_recycle = false,
	icons = {
		{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32 },
		{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
	},
	icon_size = 32,
	ingredients = {
		{ type = "item", name = "ASE-spent-metal-die", amount = 3 },
		{ type = "fluid", name = "angels-liquid-nitric-acid", amount = 20 },
	},
	results = {
		{ type = "item", name = "ASE-metal-die", amount = 3 },
		{ type = "fluid", name = "angels-water-red-waste", amount = 20 },
	},
	order = "ac",
})

-- 2. Iron base gear-wheel casting (отдельно от alloy-цикла, потому что
-- параметры в 1.1 ASE отличались: iron — 80 molten → 8 gears, alloys — 40 → 9).
table.insert(recipes, {
	type = "recipe",
	name = "angels-iron-gear-wheel-casting",
	localised_name = { "recipe-name.reg-casting", { "lookup.iron" }, { "string.gear" } },
	category = "angels-casting",
	subgroup = "angels-iron-casting",
	energy_required = 2,
	enabled = false,
	auto_recycle = false,
	ingredients = { { type = "fluid", name = "angels-liquid-molten-iron", amount = 80 } },
	results = { { type = "item", name = "iron-gear-wheel", amount = 8 } },
	order = "yc",
	crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-iron"),
})

table.insert(recipes, {
	type = "recipe",
	name = "ASE-iron-gear-casting-expendable",
	localised_name = { "recipe-name.sand-casting", { "lookup.iron" }, { "string.gear" } },
	category = "angels-casting",
	subgroup = "angels-iron-casting",
	energy_required = 0.5,
	enabled = false,
	auto_recycle = false,
	ingredients = {
		{ type = "fluid", name = "angels-liquid-molten-iron", amount = 80 },
		{ type = "item", name = "ASE-sand-die", amount = 2 },
	},
	results = {
		{ type = "item", name = "iron-gear-wheel", amount = 11 },
		{ type = "item", name = "angels-solid-sand", amount = 5 },
	},
	main_product = "iron-gear-wheel",
	order = "yd",
	crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-iron"),
})

table.insert(recipes, {
	type = "recipe",
	name = "ASE-iron-gear-casting-advanced",
	localised_name = { "recipe-name.die-casting", { "lookup.iron" }, { "string.gear" } },
	category = "angels-casting",
	subgroup = "angels-iron-casting",
	energy_required = 0.5,
	enabled = false,
	auto_recycle = false,
	ingredients = {
		{ type = "fluid", name = "angels-liquid-molten-iron", amount = 80 },
		{ type = "item", name = "ASE-metal-die", amount = 3 },
	},
	results = {
		{ type = "item", name = "iron-gear-wheel", amount = 15 },
		{ type = "item", name = "ASE-spent-metal-die", amount = 3 },
	},
	main_product = "iron-gear-wheel",
	order = "ye",
	crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-iron"),
})

-- 3. Alloy gear-wheel casting: 6 металлов × 3 варианта = 18 рецептов.
local gear_alloys = {
	{ metal = "steel",        gear = "bob-steel-gear-wheel" },
	{ metal = "nitinol",      gear = "bob-nitinol-gear-wheel" },
	{ metal = "titanium",     gear = "bob-titanium-gear-wheel" },
	{ metal = "brass",        gear = "bob-brass-gear-wheel" },
	{ metal = "cobalt-steel", gear = "bob-cobalt-steel-gear-wheel" },
	{ metal = "tungsten",     gear = "bob-tungsten-gear-wheel", sinter = true },
}

for _, m in ipairs(gear_alloys) do
	local metal, gear = m.metal, m.gear
	local subgroup = "angels-" .. metal .. "-casting"
	-- Tungsten: 12 casting-powder-tungsten + angels-sintering.
	-- Остальные: molten metal (40 для regular, 80 для expendable/advanced) + angels-casting.
	local regular_input, ext_input, category, tint
	if m.sinter then
		regular_input = { type = "item", name = "angels-casting-powder-tungsten", amount = 12 }
		ext_input = regular_input
		category = "angels-sintering"
		tint = nil
	else
		regular_input = { type = "fluid", name = "angels-liquid-molten-" .. metal, amount = 40 }
		ext_input = { type = "fluid", name = "angels-liquid-molten-" .. metal, amount = 80 }
		category = "angels-casting"
		tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-" .. metal)
	end

	table.insert(recipes, {
		type = "recipe",
		name = "angels-" .. metal .. "-gear-wheel-casting",
		localised_name = { "recipe-name.reg-casting", { "lookup." .. metal }, { "string.gear" } },
		category = category,
		subgroup = subgroup,
		energy_required = 2,
		enabled = false,
		auto_recycle = false,
		ingredients = { regular_input },
		results = { { type = "item", name = gear, amount = 9 } },
		order = "yc",
		crafting_machine_tint = tint,
	})

	table.insert(recipes, {
		type = "recipe",
		name = "ASE-" .. metal .. "-gear-casting-expendable",
		localised_name = { "recipe-name.sand-casting", { "lookup." .. metal }, { "string.gear" } },
		category = category,
		subgroup = subgroup,
		energy_required = 0.5,
		enabled = false,
		auto_recycle = false,
		ingredients = {
			ext_input,
			{ type = "item", name = "ASE-sand-die", amount = 2 },
		},
		results = {
			{ type = "item", name = gear, amount = 11 },
			{ type = "item", name = "angels-solid-sand", amount = 5 },
		},
		main_product = gear,
		order = "yd",
		crafting_machine_tint = tint,
	})

	table.insert(recipes, {
		type = "recipe",
		name = "ASE-" .. metal .. "-gear-casting-advanced",
		localised_name = { "recipe-name.die-casting", { "lookup." .. metal }, { "string.gear" } },
		category = category,
		subgroup = subgroup,
		energy_required = 0.5,
		enabled = false,
		auto_recycle = false,
		ingredients = {
			ext_input,
			{ type = "item", name = "ASE-metal-die", amount = 3 },
		},
		results = {
			{ type = "item", name = gear, amount = 15 },
			{ type = "item", name = "ASE-spent-metal-die", amount = 3 },
		},
		main_product = gear,
		order = "ye",
		crafting_machine_tint = tint,
	})
end

data:extend(recipes)

-- 4. Tech unlocks. Карта из 1.1 ASE (mods/angels-smelting-extended/prototypes/
-- technology/smelting-extended.lua) — angels-ironworks-1..5.
local unlocks = {
	["angels-ironworks-1"] = {
		"angels-iron-gear-wheel-casting",
	},
	["angels-ironworks-2"] = {
		"ASE-sand-die",
		"ASE-iron-gear-casting-expendable",
		"angels-steel-gear-wheel-casting",
		"angels-cobalt-steel-gear-wheel-casting",
		"angels-brass-gear-wheel-casting",
	},
	["angels-ironworks-3"] = {
		"ASE-metal-die",
		"ASE-metal-die-wash",
		"ASE-iron-gear-casting-advanced",
		"angels-titanium-gear-wheel-casting",
		"ASE-brass-gear-casting-expendable",
		"ASE-cobalt-steel-gear-casting-expendable",
		"ASE-steel-gear-casting-expendable",
	},
	["angels-ironworks-4"] = {
		"angels-tungsten-gear-wheel-casting",
		"angels-nitinol-gear-wheel-casting",
		"ASE-titanium-gear-casting-expendable",
		"ASE-brass-gear-casting-advanced",
		"ASE-steel-gear-casting-advanced",
		"ASE-cobalt-steel-gear-casting-advanced",
	},
	["angels-ironworks-5"] = {
		"ASE-tungsten-gear-casting-expendable",
		"ASE-nitinol-gear-casting-expendable",
		"ASE-titanium-gear-casting-advanced",
		"ASE-tungsten-gear-casting-advanced",
		"ASE-nitinol-gear-casting-advanced",
	},
}

for tech, recipe_list in pairs(unlocks) do
	for _, recipe in ipairs(recipe_list) do
		paralib.bobmods.lib.tech.add_recipe_unlock(tech, recipe)
	end
end
