require("__core__/lualib/sound-util")
require("__base__/prototypes/entity/rail-pictures")


-------------------------------------------------------------------------------------------------
if mods["JunkTrain3"] then
	data:extend({
		--добавляем рецепт для модернизации рельс
		{
			type = "recipe",
			name = "scrap-rail-to-rail",
			main_product = "",
			icons = {
				{
					icon = "__JunkTrain3__/graphics/icons/rail.png",
					icon_size = 32,
					--icon_mipmaps = 4
				},
				{
					icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
					icon_size = 16,
					icon_mipmaps = 1,
					scale = 0.9,
					shift = { -10, -10 },
				},
			},
			category = "crafting",
			group = "transport",
			subgroup = "transport-rail",
			order = "aa",
			energy_required = 0.5,
			enabled = false,
			allow_decomposition = false,
			always_show_products = true,
			ingredients = {
				{ type = "item", name = "scrap-rail", amount = 2 },
				{ type = "item", name = "concrete", amount = 6 },
			},
			results = { { type = "item", name = "rail", amount = 2 } },
		},
		-------------------------------------------------------------------------------------------------
		--добавляем рецепт для модернизации светофора
		{
			type = "recipe",
			name = "rail-signal-scrap-to-rail-signal",
			main_product = "",
			icons = {
				{
					icon = "__base__/graphics/icons/rail-signal.png",
					icon_size = 64,
					icon_mipmaps = 4,
					tint = { r = 170, g = 130, b = 1 },
				},
				{
					icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
					icon_size = 16,
					icon_mipmaps = 1,
					scale = 0.9,
					shift = { -10, -10 },
				},
			},
			category = "crafting",
			group = "transport",
			subgroup = "transport-rail-other",
			order = "aa",
			energy_required = 0.5,
			enabled = false,
			allow_decomposition = false,
			always_show_products = true,
			ingredients = {
				{ type = "item", name = "rail-signal-scrap", amount = 1 },
				{ type = "item", name = "electronic-circuit", amount = 1 },
			},
			results = { { type = "item", name = "rail-signal", amount = 1 } },
		},
		-------------------------------------------------------------------------------------------------
		--добавляем рецепт для модернизации проходного светофора
		{
			type = "recipe",
			name = "rail-chain-signal-scrap-to-rail-chain-signal",
			main_product = "",
			icons = {
				{
					icon = "__base__/graphics/icons/rail-chain-signal.png",
					icon_size = 64,
					icon_mipmaps = 4,
					tint = { r = 170, g = 130, b = 1 },
				},
				{
					icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
					icon_size = 16,
					icon_mipmaps = 1,
					scale = 0.9,
					shift = { -10, -10 },
				},
			},
			category = "crafting",
			group = "transport",
			subgroup = "transport-rail-other",
			order = "ba",
			energy_required = 0.5,
			enabled = false,
			allow_decomposition = false,
			always_show_products = true,
			ingredients = {
				{ type = "item", name = "rail-chain-signal-scrap", amount = 1 },
				{ type = "item", name = "electronic-circuit", amount = 1 },
			},
			results = { { type = "item", name = "rail-chain-signal", amount = 1 } },
		},
		-------------------------------------------------------------------------------------------------
		--добавляем рецепт для модернизации станции
		{
			type = "recipe",
			name = "train-stop-scrap-to-train-stop",
			main_product = "",
			icons = {
				{
					icon = "__base__/graphics/icons/train-stop.png",
					icon_size = 64,
					icon_mipmaps = 4,
					tint = { r = 170, g = 130, b = 1 },
				},
				{
					icon = "__zzzparanoidal__/graphics/upgrade-icon.png",
					icon_size = 16,
					icon_mipmaps = 1,
					scale = 0.9,
					shift = { -10, -10 },
				},
			},
			category = "crafting",
			group = "transport",
			subgroup = "transport-rail-other",
			order = "ca",
			energy_required = 0.5,
			enabled = false,
			allow_decomposition = false,
			always_show_products = true,
			ingredients = {
				{ type = "item", name = "train-stop-scrap", amount = 1 },
				{ type = "item", name = "electronic-circuit", amount = 5 },
				{ type = "item", name = "steel-plate", amount = 10 },
			},
			results = { { type = "item", name = "train-stop", amount = 1 } },
		},
	})
end
