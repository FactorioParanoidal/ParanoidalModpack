-- подкрутка чтобы сборщик1 мог собирать сам себя
data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 5
-------------------------------------------------------------------------------------------------
-- подкрутка печек чтобы использовать рецепт со шлаком
data.raw["furnace"]["stone-furnace"].result_inventory_size = 2
data.raw["furnace"]["steel-furnace"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-2"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-3"].result_inventory_size = 2
-- data.raw["furnace"]["electric-steel-furnace"].result_inventory_size = 2 -- from MilesBobExpansion
-------------------------------------------------------------------------------------------------
-- подкрутка рецепта погрузчика/разгрузчика
--bobmods.lib.recipe.replace_ingredient("railloader", "rail", "bi-rail-wood")
--bobmods.lib.recipe.replace_ingredient("railunloader", "rail", "bi-rail-wood")


-- твики из TrainOverhaul
data.raw.item["solid-fuel"].fuel_acceleration_multiplier = 1.05 --base 1.2
data.raw.item["solid-fuel"].fuel_top_speed_multiplier = 1 -- base 1.05

data.raw.item["rocket-fuel"].fuel_acceleration_multiplier = 1.2 -- base 1.8
data.raw.item["rocket-fuel"].fuel_top_speed_multiplier = 1 -- base 1.5


--баланс поездов
--локомотив мк1
data.raw.locomotive.locomotive.max_health = 1200
data.raw.locomotive.locomotive.weight = 2000
data.raw.locomotive.locomotive.max_speed = 1.2
data.raw.locomotive.locomotive.max_power = "800kW"
data.raw.locomotive.locomotive.reversing_power_modifier = 0.5
data.raw.locomotive.locomotive.braking_force = 14
data.raw.locomotive.locomotive.friction_force = 0.27
data.raw.locomotive.locomotive.air_resistance = 0.008
data.raw.locomotive.locomotive.energy_per_hit_point = 5
data.raw.locomotive.locomotive.energy_source.effectivity = 0.8
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
--вагон мк1
data.raw["cargo-wagon"]["cargo-wagon"].weight = 1000
data.raw["cargo-wagon"]["cargo-wagon"].max_speed = 1.5
data.raw["cargo-wagon"]["cargo-wagon"].braking_force = 3
data.raw["cargo-wagon"]["cargo-wagon"].friction_force = 0.3
data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["cargo-wagon"]["bob-cargo-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--вагон-цистерна мк1
data.raw["fluid-wagon"]["fluid-wagon"].weight = 1000
data.raw["fluid-wagon"]["fluid-wagon"].max_speed = 1.5
data.raw["fluid-wagon"]["fluid-wagon"].braking_force = 3
data.raw["fluid-wagon"]["fluid-wagon"].friction_force = 0.3
data.raw["fluid-wagon"]["fluid-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["fluid-wagon"]["bob-fluid-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--артиллерийский вагон мк1
data.raw["artillery-wagon"]["artillery-wagon"].weight = 4000
data.raw["artillery-wagon"]["artillery-wagon"].max_speed = 1.5
data.raw["artillery-wagon"]["artillery-wagon"].braking_force = 3
data.raw["artillery-wagon"]["artillery-wagon"].friction_force = 0.5
data.raw["artillery-wagon"]["artillery-wagon"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
data.raw["artillery-wagon"]["bob-artillery-wagon-3"].max_speed = 5

--Исправление загрязнения для отстойника и факельной стойки
data.raw["furnace"]["angels-clarifier"].energy_source.emissions_per_minute = { pollution = 75 }
data.raw["furnace"]["angels-flare-stack"].energy_source.emissions_per_minute = { pollution = 75 }

--Маяки больше не действуют на термальные скважины
data.raw["mining-drill"]["angels-thermal-extractor"].allowed_effects = { "consumption", "pollution" }
data.raw["mining-drill"]["angels-thermal-bore"].allowed_effects = { "consumption", "pollution" }

--фикс расположения робоспота для транспорта
data.raw["item"]["bob-vehicle-roboport-equipment-3"].subgroup = "vehicle-misc1"
data.raw["item"]["bob-vehicle-roboport-equipment-4"].subgroup = "vehicle-misc1"
data.raw["item"]["bob-vehicle-roboport-equipment-3"].order = "v[vehicle-equipment]-f[roboport-3]"
data.raw["item"]["bob-vehicle-roboport-equipment-4"].order = "v[vehicle-equipment]-f[roboport-4]"
