-- Отливка железных прутьев из расплава по образцу шестерён (решение пользователя 2026-10-29).
-- Прямая отливка: 80 расплава -> 8 прутьев (angels-ironworks-1).
-- Связка: 80 расплава + 40 воды -> 2 связки (angels-iron-casting-2),
-- 140 расплава + 40 хладагента -> 4 связки (angels-iron-casting-3), 1 связка -> 5 прутьев.
-- Связка и её рецепты — скрытые прототипы angelssmelting (rod trigger выключен); здесь они
-- раскрываются до graphics-atlas, чтобы тот не заменил их иконки пустыми.
local tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-molten-iron")
-- Итоговая иконка предмета iron-stick (bobicons-beta8 ставит её позже этого файла).
local stick_layers = {
	{ icon = "__zzzparanoidal__/graphics/bobicons-beta8/bobicons/graphics/icons/angelssmelting/rod-iron-64.png", icon_size = 64, scale = 0.5 },
}
-- Иконка прута + наложение (по образцу рецептов шестерён).
local function stick_with(overlay)
	local icons = table.deepcopy(stick_layers)
	table.insert(icons, overlay)
	return icons
end
local stack_icon = { icon = "__angelssmeltinggraphics__/graphics/icons/rod-stack-iron.png", icon_size = 32 }

local item = data.raw.item["angels-rod-stack-iron"]
item.hidden = nil
item.icon, item.icon_size, item.icons = stack_icon.icon, stack_icon.icon_size, nil
item.subgroup = "paranoidal-casting-iron-gears"
item.order = "08"

data:extend({
	{
		type = "recipe",
		name = "paranoidal-iron-stick-casting",
		localised_name = { "item-name.iron-stick" },
		category = "angels-casting",
		subgroup = "paranoidal-casting-iron-gears",
		order = "10",
		energy_required = 2,
		enabled = false,
		auto_recycle = false,
		allow_productivity = false,
		ingredients = { { type = "fluid", name = "angels-liquid-molten-iron", amount = 80 } },
		results = { { type = "item", name = "iron-stick", amount = 8 } },
		icons = stick_with({ icon = "__zzzparanoidal__/graphics/casting-water-menu-beta8/830646e4b79471704798.png", icon_size = 64, scale = 0.21875, shift = { -10, -10 } }),
		crafting_machine_tint = tint,
	},
})

local function patch(name, spec)
	local recipe = data.raw.recipe[name]
	recipe.hidden = nil
	recipe.enabled = false
	recipe.localised_name = { "item-name.angels-rod-stack-iron" }
	recipe.subgroup = "paranoidal-casting-iron-gears"
	for key, value in pairs(spec) do recipe[key] = value end
end

patch("angels-rod-stack-iron", {
	order = "07",
	energy_required = 4,
	allow_productivity = false,
	ingredients = {
		{ type = "fluid", name = "angels-liquid-molten-iron", amount = 80 },
		{ type = "fluid", name = "water", amount = 40 },
	},
	results = { { type = "item", name = "angels-rod-stack-iron", amount = 2 } },
	main_product = "angels-rod-stack-iron",
	icons = {
		{ icon = stack_icon.icon, icon_size = 32 },
		{ icon = "__zzzparanoidal__/graphics/num_1-64.png", icon_size = 64, tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 }, scale = 0.2, shift = { -12, -12 } },
	},
})
patch("angels-rod-stack-iron-2", {
	order = "07b",
	energy_required = 2,
	allow_productivity = false,
	ingredients = {
		{ type = "fluid", name = "angels-liquid-molten-iron", amount = 140 },
		{ type = "fluid", name = "angels-liquid-coolant", amount = 40, maximum_temperature = 50 },
	},
	results = {
		{ type = "item", name = "angels-rod-stack-iron", amount = 4 },
		{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
	},
	main_product = "angels-rod-stack-iron",
	icons = {
		{ icon = stack_icon.icon, icon_size = 32 },
		{ icon = "__zzzparanoidal__/graphics/num_2-64.png", icon_size = 64, tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 }, scale = 0.2, shift = { -12, -12 } },
	},
})
patch("angels-rod-iron-2", {
	localised_name = { "item-name.iron-stick" },
	order = "09",
	energy_required = 0.5,
	allow_productivity = true,
	allow_decomposition = false,
	ingredients = { { type = "item", name = "angels-rod-stack-iron", amount = 1 } },
	results = { { type = "item", name = "iron-stick", amount = 5 } },
	icons = stick_with({ icon = stack_icon.icon, icon_size = 32, scale = 0.4, shift = { -12, -12 } }),
})

paralib.bobmods.lib.tech.add_recipe_unlock("angels-ironworks-1", "paranoidal-iron-stick-casting")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-2", "angels-rod-stack-iron")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-2", "angels-rod-iron-2")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-iron-casting-3", "angels-rod-stack-iron-2")
