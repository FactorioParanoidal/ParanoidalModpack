--[[ Copyright (c) 2019 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

if mods["FARL"] then
  local loco = data.raw["locomotive"]["farl"]
  if loco then
    loco.max_health = 2500
    loco.weight = 7500 * settings.startup["train-overhaul-weight-multiplicator"].value
    loco.max_speed = 0.8 --172.8km/h
    loco.max_power = optera_lib.multiply_energy_value("2500kW", settings.startup["train-overhaul-power-multiplicator"].value)
    loco.reversing_power_modifier = 1 --no effect on automatic trains
    loco.braking_force = 60
    loco.friction_force = 0.60 -- constant acceleration reduction
    loco.air_resistance = 0.015 -- exponential max_speed reduction
    loco.burner.effectivity = 0.80 -- tooltip "Energy Consumption" = max_power/efficiency
    loco.burner.fuel_inventory_size = 4
  end
end
