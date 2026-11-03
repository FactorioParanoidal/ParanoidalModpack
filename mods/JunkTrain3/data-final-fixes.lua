-- Reassert parity-sensitive values after pack-wide train normalization.
local locomotive = data.raw.locomotive.yir_usl
locomotive.max_speed = 0.25
locomotive.max_power = "200kW"
locomotive.energy_source.fuel_categories = {"chemical"}
locomotive.localised_description = {"entity-description.yir_usl"}

-- Factorio 2.1 (Paranoidal decision G22): no max_speed on the wagon. 2.1 takes a train's max speed as the average
-- max_speed of the rolling stock that sets it (2.0: the minimum), so the trailer goes at the speed of its locomotive.
local wagon = data.raw["cargo-wagon"].yir_us_cargo
wagon.max_speed = nil
wagon.localised_description = {"entity-description.yir_us_cargo"}
