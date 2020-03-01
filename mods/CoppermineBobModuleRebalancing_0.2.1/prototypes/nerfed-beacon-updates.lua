if settings.startup["coppermine-bob-module-nerfed-beacons"].value then
  data.raw.beacon["beacon-2"].supply_area_distance = 5
  data.raw.beacon["beacon-3"].supply_area_distance = 7
  data.raw.beacon["beacon-2"].module_specification.module_slots = 3
  data.raw.beacon["beacon-3"].module_specification.module_slots = 4
  data.raw.beacon["beacon-2"].energy_usage = "1000kW"
  data.raw.beacon["beacon-3"].energy_usage = "1500kW"
  data.raw.beacon["beacon-2"].energy_source["emissions"] = 0.01
  data.raw.beacon["beacon-3"].energy_source["emissions"] = 0.02
end
