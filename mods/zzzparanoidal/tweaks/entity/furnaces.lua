require("__zzzparanoidal__.paralib")
-- подкрутка печек чтобы использовать рецепт со шлаком
data.raw["furnace"]["stone-furnace"].result_inventory_size = 2
data.raw["furnace"]["steel-furnace"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-2"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-3"].result_inventory_size = 2

--Исправление загрязнения для отстойника и факельной стойки
data.raw["furnace"]["angels-clarifier"].energy_source.emissions_per_minute = { pollution = 75 }
data.raw["furnace"]["angels-flare-stack"].energy_source.emissions_per_minute = { pollution = 75 }

-- баланс электрички
if mods["BatteryElectricTrain"] then
	data.raw.furnace["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
	data.raw.item["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
	data.raw.recipe["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
	data.raw.recipe["bet-charger-1"].icon_size = 32

	data.raw.furnace["bet-charger-1"].graphics_set.working_visualisations[1].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av1_sheet.png",
		width = 320,
		height = 320,
		shift = { 1.0, -1.0 },
		frame_count = 16,
		line_length = 4,
		animation_speed = 0.3,
		scale = 0.5,
	}

	data.raw.furnace["bet-charger-1"].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av1_sheet.png",
		width = 320,
		height = 320,
		shift = { 1.0, -1.0 },
		frame_count = 16,
		line_length = 4,
		animation_speed = 0.3,
		scale = 0.5,
	}
	-------------------------------------------------------------------------------------------------
	data.raw.furnace["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
	data.raw.item["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
	data.raw.recipe["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
	data.raw.recipe["bet-charger-2"].icon_size = 32
	data.raw.technology["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/bet-charger-2_tech.png"
	data.raw.technology["bet-charger-2"].icon_size = 256
	data.raw.technology["bet-charger-2"].icon_mipmaps = 4
	data.raw.furnace["bet-charger-2"].graphics_set.working_visualisations[1].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av2_sheet.png",
		width = 256,
		height = 256,
		shift = { 0.5, -0.5 },
		frame_count = 36,
		line_length = 6,
		animation_speed = 0.1,
		scale = 0.5,
	}

	data.raw.furnace["bet-charger-2"].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av2_sheet.png",
		width = 256,
		height = 256,
		shift = { 0.5, -0.5 },
		frame_count = 36,
		line_length = 6,
		animation_speed = 0.1,
		scale = 0.5,
	}
	-------------------------------------------------------------------------------------------------
	data.raw.furnace["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
	data.raw.item["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
	data.raw.recipe["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
	data.raw.recipe["bet-charger-3"].icon_size = 32
	data.raw.technology["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/bet-charger-3_tech.png"
	data.raw.technology["bet-charger-3"].icon_size = 256
	data.raw.technology["bet-charger-3"].icon_mipmaps = 4

	data.raw.furnace["bet-charger-3"].graphics_set.working_visualisations[1].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av3_sheet.png",
		width = 256,
		height = 256,
		shift = { 0.4, -0.5 },
		frame_count = 25,
		line_length = 5,
		animation_speed = 0.05,
		scale = 0.5,
	}

	data.raw.furnace["bet-charger-3"].animation = {
		filename = "__zzzparanoidal__/graphics/train/electric/av3_sheet.png",
		width = 256,
		height = 256,
		shift = { 0.4, -0.5 },
		frame_count = 25,
		line_length = 5,
		animation_speed = 0.05,
		scale = 0.5,
	}
end

