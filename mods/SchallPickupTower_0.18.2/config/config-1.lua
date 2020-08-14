local config = {}

config.tier_max = settings.startup["pickuptower-tier-max"].value -- 2
config.pickuptower_name = "Schall-pickup-tower"
config.pickuptower_name_upper_suffix = "-upper"

function config.PT_range(tier)
  return tonumber(tier) * 32
end

function config.PT_interval(tier)
  return 30 * tier -- "s"
end

function config.PT_energy_usage(tier)
  return 250000 * tier^2 -- "W"
end

function config.PT_energy_per_sector(tier)
  return config.PT_energy_usage(tier) * config.PT_interval(tier) --"J"
end



return config