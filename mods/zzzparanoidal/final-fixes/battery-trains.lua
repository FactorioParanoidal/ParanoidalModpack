-- баланс электрички
if mods["BatteryElectricTrain"] then
	data.raw.locomotive["bet-locomotive"].max_health = 2000
	data.raw.locomotive["bet-locomotive"].max_speed = 2
	data.raw.locomotive["bet-locomotive"].max_power = "1000kW"
	data.raw.locomotive["bet-locomotive"].reversing_power_modifier = 1
	data.raw.locomotive["bet-locomotive"].braking_force = 20
	data.raw.locomotive["bet-locomotive"].friction_force = 0.25
	data.raw.locomotive["bet-locomotive"].air_resistance = 0.004
	data.raw.locomotive["bet-locomotive"].resistances[1] = { type = "fire", decrease = 50, percent = 70 }
	data.raw.locomotive["bet-locomotive"].resistances[2] = { type = "physical", decrease = 30, percent = 50 }
	data.raw.locomotive["bet-locomotive"].resistances[3] = { type = "impact", decrease = 100, percent = 80 }
	data.raw.locomotive["bet-locomotive"].resistances[4] = { type = "explosion", decrease = 30, percent = 50 }
	data.raw.locomotive["bet-locomotive"].resistances[5] = { type = "acid", decrease = 70, percent = 80 }
	--[[
data.raw.locomotive["bet-locomotive"].minimap_representation.filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-minimap-representation.png"
data.raw.locomotive["bet-locomotive"].minimap_representation.flags = {"icon"}
data.raw.locomotive["bet-locomotive"].minimap_representation.size = {20, 40}
data.raw.locomotive["bet-locomotive"].minimap_representation.scale = 0.5

data.raw.locomotive["bet-locomotive"].selected_minimap_representation.filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-selected-minimap-representation.png"
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.flags = {"icon"}
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.size = {20, 40}
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.scale = 0.5
]]
	-------------------------------------------------------------------------------------------------
	--баланс акб
	data.raw.item["bet-fuel-1-full"].fuel_acceleration_multiplier = 1.5
	data.raw.item["bet-fuel-1-full"].fuel_top_speed_multiplier = 1

	data.raw.item["bet-fuel-2-full"].fuel_acceleration_multiplier = 2
	data.raw.item["bet-fuel-2-full"].fuel_top_speed_multiplier = 1.5

	data.raw.item["bet-fuel-3-full"].fuel_acceleration_multiplier = 2.5
	data.raw.item["bet-fuel-3-full"].fuel_top_speed_multiplier = 2

	data.raw.item["bet-fuel-4-full"].fuel_acceleration_multiplier = 3.5
	data.raw.item["bet-fuel-4-full"].fuel_top_speed_multiplier = 3

	bobmods.lib.tech.add_prerequisite("bet-fuel-2", "bob-battery-2")
	bobmods.lib.recipe.replace_ingredient("bet-fuel-2-empty", "battery", "bob-lithium-ion-battery")

	bobmods.lib.tech.add_prerequisite("bet-fuel-3", "bob-battery-3")
	bobmods.lib.recipe.replace_ingredient("bet-fuel-3-empty", "battery", "bob-silver-zinc-battery")

	bobmods.lib.tech.add_prerequisite("bet-fuel-4", "speed-module-3")
	bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "battery", "bob-silver-zinc-battery")
	bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "effectivity-module-3", "speed-module-3")
	bobmods.lib.recipe.add_ingredient("bet-fuel-4-empty", { type = "item", name = "bob-advanced-processing-unit", amount = 3})

	-------------------------------------------------------------------------------------------------
	--зарядные
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

