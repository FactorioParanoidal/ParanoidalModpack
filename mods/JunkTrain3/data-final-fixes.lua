-- Reassert parity-sensitive values after pack-wide train normalization.
local locomotive = data.raw.locomotive.yir_usl
locomotive.max_speed = 0.25
locomotive.max_power = "200kW"
locomotive.energy_source.fuel_categories = {"chemical"}
locomotive.localised_description = {"entity-description.yir_usl"}

-- MultipleUnitTrainControl copy (zzzparanoidal rebuilds it before this file): same values, double power.
local mu = data.raw.locomotive["yir_usl-mu"]
if mu then
  mu.max_speed = locomotive.max_speed
  mu.max_power = "400kW"
  mu.energy_source.fuel_categories = {"chemical"}
end

local wagon = data.raw["cargo-wagon"].yir_us_cargo
wagon.max_speed = 0.5
wagon.localised_description = {"entity-description.yir_us_cargo"}
