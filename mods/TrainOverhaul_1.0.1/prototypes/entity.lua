--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

local flib = require('__flib__.data-util')

engine_working_sound = {
  sound = {
    filename = "__TrainOverhaul__/sound/train-engine.ogg",
    volume = 0.6
  },
  match_speed_to_activity = true,
  max_sounds_per_type = 2,
}
nuclear_working_sound = {
  sound = {
    filename = "__TrainOverhaul__/sound/fan-howl.ogg",
    volume = 1.2
  },
  match_speed_to_activity = true,
  max_sounds_per_type = 2,
}
wheel_working_sound = {
  sound = {
    filename = "__TrainOverhaul__/sound/train-wheels.ogg",
    volume = 0.6
  },
  match_volume_to_activity = true
}

tie_sound = {
  type = "play-sound",
  sound = {
    {
      filename = "__TrainOverhaul__/sound/train-tie-1.ogg",
      volume = 0.6
    },
    {
      filename = "__TrainOverhaul__/sound/train-tie-2.ogg",
      volume = 0.6
    },
    {
      filename = "__TrainOverhaul__/sound/train-tie-3.ogg",
      volume = 0.6
    },
    {
      filename = "__TrainOverhaul__/sound/train-tie-4.ogg",
      volume = 0.6
    },
  }
}

local base_loco = data.raw["locomotive"]["locomotive"]
base_loco.icon = "__TrainOverhaul__/graphics/icons/locomotive.png"
base_loco.icon_size = 64
base_loco.icon_mipmaps = 0
base_loco.icons = nil
base_loco.max_health = 1000
base_loco.weight = 4000 * settings.startup["train-overhaul-weight-multiplicator"].value
-- base_loco.max_speed = 1.2 --259.2km/h
base_loco.max_speed = 1.0 --216.0km/h
-- base_loco.max_power = multiply_energy_value("1000kW", settings.startup["train-overhaul-power-multiplicator"].value)
base_loco.max_power = (1000000 * settings.startup["train-overhaul-power-multiplicator"].value).."W"
base_loco.reversing_power_modifier = 1 --no effect on automatic trains
base_loco.braking_force = 20
base_loco.friction_force = 0.50 -- constant acceleration reduction
base_loco.air_resistance = 0.0075 -- exponential max_speed reduction
base_loco.burner.effectivity = 0.80 -- tooltip "Energy Consumption" = max_power/efficiency
base_loco.burner.fuel_inventory_size = 3
if settings.startup["train-overhaul-old-sounds"].value then
  base_loco.working_sound = engine_working_sound
  base_loco.drive_over_tie_trigger = tie_sound
end

local heavy_loco = flib.copy_prototype(base_loco, "heavy-locomotive")
heavy_loco.icon = "__TrainOverhaul__/graphics/icons/heavy-locomotive.png"
heavy_loco.color = {r = 0, g = 0.53, b = 0, a = 0.5}
heavy_loco.max_health = 1500
heavy_loco.weight = 6400 * settings.startup["train-overhaul-weight-multiplicator"].value
heavy_loco.max_speed = 0.95 --205,2km/h
-- heavy_loco.max_power = multiply_energy_value("2610kW", settings.startup["train-overhaul-power-multiplicator"].value)
heavy_loco.max_power = (2610000 * settings.startup["train-overhaul-power-multiplicator"].value).."W"
heavy_loco.reversing_power_modifier = 1
heavy_loco.braking_force = 40
heavy_loco.friction_force = 0.50
heavy_loco.air_resistance = 0.015
heavy_loco.burner.effectivity = 0.90
heavy_loco.burner.fuel_inventory_size = 4

local express_loco = flib.copy_prototype(base_loco, "express-locomotive")
express_loco.icon = "__TrainOverhaul__/graphics/icons/express-locomotive.png"
express_loco.color = {r = 0.10, g = 0.19, b = 0.80, a = 0.5}
express_loco.max_health = 800
express_loco.weight = 3800 * settings.startup["train-overhaul-weight-multiplicator"].value
-- express_loco.max_speed = 1.5 --324,0km/h
express_loco.max_speed = 1.4 --302,4km/h
-- express_loco.max_power = multiply_energy_value("1200kW", settings.startup["train-overhaul-power-multiplicator"].value)
express_loco.max_power = (1200000 * settings.startup["train-overhaul-power-multiplicator"].value).."W"
express_loco.reversing_power_modifier = 1
express_loco.braking_force = 32
express_loco.friction_force = 0.50
express_loco.air_resistance = 0.0062
express_loco.burner.effectivity = 0.60
express_loco.burner.fuel_inventory_size = 4

local nuclear_loco = flib.copy_prototype(base_loco, "nuclear-locomotive")
nuclear_loco.icon = "__TrainOverhaul__/graphics/icons/nuclear-locomotive.png"
nuclear_loco.color = { r = 0, g = 0.75, b = 0.5, a = 0.5 }
nuclear_loco.max_health = 2500
nuclear_loco.weight = 8000 * settings.startup["train-overhaul-weight-multiplicator"].value
-- nuclear_loco.max_speed = 1.4 --302.4km/h
nuclear_loco.max_speed = 1.2 --259.2km/h
-- nuclear_loco.max_power = multiply_energy_value("3200kW", settings.startup["train-overhaul-power-multiplicator"].value)
nuclear_loco.max_power = (3200000 * settings.startup["train-overhaul-power-multiplicator"].value).."W"
nuclear_loco.reversing_power_modifier = 1
nuclear_loco.braking_force = 40
nuclear_loco.friction_force = 0.50
nuclear_loco.air_resistance = 0.015
nuclear_loco.burner.fuel_category = "nuclear"
nuclear_loco.burner.effectivity = 0.80
nuclear_loco.burner.fuel_inventory_size = 1
nuclear_loco.burner.burnt_inventory_size = 1
nuclear_loco.working_sound = nuclear_working_sound

data:extend({
  heavy_loco,
  express_loco,
  nuclear_loco,
})

local base_cargo_wagon = data.raw["cargo-wagon"]["cargo-wagon"]
base_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/cargo-wagon.png"
base_cargo_wagon.icon_size = 32
base_cargo_wagon.icon_mipmaps = 0
base_cargo_wagon.icons = nil
base_cargo_wagon.max_health = 800 --base 600
base_cargo_wagon.weight = 3000 * settings.startup["train-overhaul-weight-multiplicator"].value -- base 1000
base_cargo_wagon.max_speed = 1.0 -- base 1.5
base_cargo_wagon.braking_force = 5
if settings.startup["train-overhaul-old-sounds"].value then
  base_cargo_wagon.working_sound = wheel_working_sound
  base_cargo_wagon.drive_over_tie_trigger = tie_sound
end

local base_fluid_wagon = data.raw["fluid-wagon"]["fluid-wagon"]
base_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/fluid-wagon.png"
base_fluid_wagon.icon_size = 32
base_fluid_wagon.icon_mipmaps = 0
base_fluid_wagon.icons = nil
base_fluid_wagon.max_health = 800 --base 600
base_fluid_wagon.weight = 3000 * settings.startup["train-overhaul-weight-multiplicator"].value -- base 1000
base_fluid_wagon.max_speed = 1.0 -- base 1.5
base_fluid_wagon.braking_force = 5
base_fluid_wagon.capacity = 25000 -- base 25000
base_fluid_wagon.color = {r = 0, g = 0, b = 0, a = 0}
if settings.startup["train-overhaul-old-sounds"].value then
  base_fluid_wagon.working_sound = wheel_working_sound
  base_fluid_wagon.drive_over_tie_trigger = tie_sound
end

local artillery_wagon = data.raw["artillery-wagon"]["artillery-wagon"]
artillery_wagon.max_health = 1200 --base 600
artillery_wagon.weight = 8000 * settings.startup["train-overhaul-weight-multiplicator"].value -- base 4000
artillery_wagon.max_speed = 0.95 -- base 1.5
artillery_wagon.braking_force = 6
if settings.startup["train-overhaul-old-sounds"].value then
  artillery_wagon.working_sound = wheel_working_sound
  artillery_wagon.drive_over_tie_trigger = tie_sound
end

local heavy_cargo_wagon = flib.copy_prototype(base_cargo_wagon, "heavy-cargo-wagon")
heavy_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/heavy-cargo-wagon.png"
heavy_cargo_wagon.color = {r = 0, g = 0.53, b = 0, a = 0.5}
heavy_cargo_wagon.max_health = 1000
heavy_cargo_wagon.weight = 3500 * settings.startup["train-overhaul-weight-multiplicator"].value
heavy_cargo_wagon.max_speed = 1.09 -- 235.4 km/h
heavy_cargo_wagon.braking_force = 6
heavy_cargo_wagon.inventory_size = 60

local heavy_fluid_wagon = flib.copy_prototype(base_fluid_wagon, "heavy-fluid-wagon")
heavy_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/heavy-fluid-wagon.png"
heavy_fluid_wagon.color = {r = 0, g = 0.53, b = 0, a = 0.5}
heavy_fluid_wagon.max_health = 1000
heavy_fluid_wagon.weight = 3500 * settings.startup["train-overhaul-weight-multiplicator"].value
heavy_fluid_wagon.max_speed = 1.09
heavy_fluid_wagon.braking_force = 6
heavy_fluid_wagon.capacity = 35000

local express_cargo_wagon = flib.copy_prototype(base_cargo_wagon, "express-cargo-wagon")
express_cargo_wagon.icon = "__TrainOverhaul__/graphics/icons/express-cargo-wagon.png"
express_cargo_wagon.color = {r = 0.10, g = 0.19, b = 0.80, a = 0.5}
express_cargo_wagon.max_health = 500
express_cargo_wagon.weight = 2500 * settings.startup["train-overhaul-weight-multiplicator"].value
express_cargo_wagon.max_speed = 1.4
express_cargo_wagon.braking_force = 7
express_cargo_wagon.inventory_size = 40

local express_fluid_wagon = flib.copy_prototype(base_fluid_wagon, "express-fluid-wagon")
express_fluid_wagon.icon = "__TrainOverhaul__/graphics/icons/express-fluid-wagon.png"
express_fluid_wagon.color = {r = 0.10, g = 0.19, b = 0.80, a = 0.5}
express_fluid_wagon.max_health = 500
express_fluid_wagon.weight = 2500 * settings.startup["train-overhaul-weight-multiplicator"].value
express_fluid_wagon.max_speed = 1.4
express_fluid_wagon.braking_force = 7
express_fluid_wagon.capacity = 25000

data:extend({
  heavy_cargo_wagon,
  heavy_fluid_wagon,
  express_cargo_wagon,
  express_fluid_wagon,
})