-- Warheads data stage first: it defines the shared tables (warheads, weaponTypes, ...) True Nukes fills.
require("warheads-data")

require("prototypes.nukes.data-nukes")

if(settings.startup["enable-small-thermobarics"].value or settings.startup["enable-medium-thermobarics"].value or settings.startup["enable-large-thermobarics"].value) then
  require("prototypes.thermobarics.data-thermobaric")
end

require("MushroomCloudInBuilt.explosions")
require("MushroomCloudInBuilt.radiation_noise")
require("MushroomCloudInBuilt.ground_zero")
require("MushroomCloudInBuilt.explosion_sizes")


local fireutil = require("__base__.prototypes.fire-util")

data:extend({
  fireutil.add_basic_fire_graphics_and_effects_definitions
  {
    type = "fire",
    name = "thermobaric-wave-fire",
    flags = {"placeable-off-grid", "not-on-map"},
    damage_per_tick = {amount = 130 / 20, type = "fire"},
    maximum_damage_multiplier = 6,
    damage_multiplier_increase_per_added_fuel = 1,
    damage_multiplier_decrease_per_tick = 0.005,

    spawn_entity = "fire-flame-on-tree",

    spread_delay = 300,
    spread_delay_deviation = 180,
    maximum_spread_count = 100,

    emissions_per_second = {pollution=0.005},

    initial_lifetime = 50,
    lifetime_increase_by = 150,
    lifetime_increase_cooldown = 4,
    maximum_lifetime = 1800,
    delay_between_initial_flames = 10,
  --initial_flame_count = 1,

  }})
