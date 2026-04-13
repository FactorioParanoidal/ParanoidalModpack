if not mods["space-age"] then
  return
end

data.raw["furnace"]["air-filter-machine"].heating_energy = "100kW"
data.raw["furnace"]["air-filter-machine"].energy_source.emissions_per_minute["spores"] = -40
data.raw["furnace"]["air-filter-machine"].graphics_set.reset_animation_when_frozen = true
-- Ensure circuit network properties are preserved
data.raw["furnace"]["air-filter-machine"].circuit_wire_max_distance = 7.5
data.raw["furnace"]["air-filter-machine"].draw_copper_wires = true
data.raw["furnace"]["air-filter-machine"].draw_circuit_wires = true

data.raw["furnace"]["air-filter-machine-mk2"].heating_energy = "200kW"
data.raw["furnace"]["air-filter-machine-mk2"].energy_source.emissions_per_minute["spores"] = -80
data.raw["furnace"]["air-filter-machine-mk2"].graphics_set.reset_animation_when_frozen = true
-- Ensure circuit network properties are preserved
data.raw["furnace"]["air-filter-machine-mk2"].circuit_wire_max_distance = 7.5
data.raw["furnace"]["air-filter-machine-mk2"].draw_copper_wires = true
data.raw["furnace"]["air-filter-machine-mk2"].draw_circuit_wires = true

data.raw["furnace"]["air-filter-machine-mk3"].heating_energy = "800kW"
data.raw["furnace"]["air-filter-machine-mk3"].energy_source.emissions_per_minute["spores"] = -400
data.raw["furnace"]["air-filter-machine-mk3"].graphics_set.reset_animation_when_frozen = true
-- Ensure circuit network properties are preserved
data.raw["furnace"]["air-filter-machine-mk3"].circuit_wire_max_distance = 7.5
data.raw["furnace"]["air-filter-machine-mk3"].draw_copper_wires = true
data.raw["furnace"]["air-filter-machine-mk3"].draw_circuit_wires = true
