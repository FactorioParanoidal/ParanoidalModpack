local offshore_pump = data.raw["offshore-pump"]["offshore-pump"]
offshore_pump.energy_source = {
  type = "electric",
  usage_priority = "secondary-input"
}
offshore_pump.energy_usage = "50kW"
