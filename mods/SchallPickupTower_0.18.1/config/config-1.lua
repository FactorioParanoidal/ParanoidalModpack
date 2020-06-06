local config = {}

config.tier_max = settings.startup["Schall-pickup-tower-tier-max"].value -- 4

function config.PT_range(tier)
  return tier * 32
end

function config.PT_interval(tier)
  return 30 * tier -- "s"
end

function config.PT_energy_usage(tier)
  -- return 0.250 * tier^2 -- "MW"
  return 250000 * tier^2 -- "W"
end

function config.PT_energy_per_sector(tier)
  -- return config.PT_energy_usage(tier) * config.PT_interval(tier) --"MJ"
  return config.PT_energy_usage(tier) * config.PT_interval(tier) --"J"
end



return config