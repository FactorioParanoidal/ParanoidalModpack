if feature_flags["freezing"] then
  data.raw["assembling-machine"]["burner-assembling-machine"].heating_energy = nil
  data.raw["lab"]["burner-lab"].heating_energy = nil
  data.raw["assembling-machine"]["industrial-furnace"].heating_energy = "300kW" -- same as the unlockables in space-age
end
