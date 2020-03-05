--train_overhaul.lua
--Compatibility layer for the TrainOverhaul mod

if mods["TrainOverhaul"] then

	local loco_1 = data.raw["locomotive"]["ret-electric-locomotive"]
	local loco_2 = data.raw["locomotive"]["ret-electric-locomotive-mk2"]
	local loco_modular = data.raw["locomotive"]["ret-modular-locomotive"]

	local loco_1_power = 1200 * settings.startup["train-overhaul-power-multiplicator"].value
	local loco_2_power = 2600 * settings.startup["train-overhaul-power-multiplicator"].value
	local loco_modular_power = 4200 * settings.startup["train-overhaul-power-multiplicator"].value
	local loco_effectivity = 0.95

	loco_1.max_power = loco_1_power .. "kW"
	loco_1.max_health = 1500
	loco_1.max_speed = 1.2
	loco_1.weight = 4000 * settings.startup["train-overhaul-weight-multiplicator"].value
	loco_1.reversing_power_modifier = 1
	loco_1.braking_force = 32
	loco_1.friction_force = 0.50 -- constant acceleration reduction, default: 0.5
	loco_1.air_resistance = 0.015 -- exponential max_speed reduction, default: 0.0075
	loco_1.burner.effectivity = loco_effectivity

	loco_2.max_power = loco_2_power .. "kW"
	loco_2.max_health = 1500
	loco_2.max_speed = 1.4
	loco_2.weight = 4500 * settings.startup["train-overhaul-weight-multiplicator"].value
	loco_2.reversing_power_modifier = 1
	loco_2.braking_force = 40
	loco_2.friction_force = 0.50 -- constant acceleration reduction, default: 0.5
	loco_2.air_resistance = 0.015 -- exponential max_speed reduction, default: 0.0075
	loco_2.burner.effectivity = loco_effectivity

	loco_modular.max_power = loco_modular_power .. "kW"
	loco_modular.max_health = 1500
	loco_modular.max_speed = 1.4
	loco_modular.weight = 5000 * settings.startup["train-overhaul-weight-multiplicator"].value
	loco_modular.reversing_power_modifier = 1
	loco_modular.braking_force = 48
	loco_modular.friction_force = 0.50 -- constant acceleration reduction, default: 0.5
	loco_modular.air_resistance = 0.015 -- exponential max_speed reduction, default: 0.0075
	loco_modular.burner.effectivity = loco_effectivity


	local dummy_fuel_1 = data.raw["item"]["ret-dummy-fuel-1"]
	local dummy_fuel_2 = data.raw["item"]["ret-dummy-fuel-2"]

	dummy_fuel_1.fuel_value = store(loco_1_power / loco_effectivity * 2) .. "kJ"
	dummy_fuel_1.fuel_acceleration_multiplier = 1.2

	dummy_fuel_2.fuel_value = store(loco_2_power / loco_effectivity * 2) .. "kJ"
	dummy_fuel_2.fuel_acceleration_multiplier = 1.2

	for s = 0, 4 do
	for p = 0, 4 - s do
		for e = 0, 4 - s - p do
			for b = 0, 4 - s - p - e do
				if s + p + e + b <= 4 then
					local name = get_module_string(s, p, e, b)
					local stats = get_module_stats(s, p, e, b)

					local item = data.raw["item"]["ret-dummy-fuel-modular-"..name]
					item.fuel_value = toJ(store(loco_modular_power * 2000) + stats.storage / stats.power)
				end
			end
		end
	end
end
end
