local config = {}

config.mod_prefix         = "Schall-PT-"
config.mod_prefix_ptrn    = "Schall%-PT%-"

config.tier_max           = settings.startup[config.mod_prefix .. "tier-max"].value -- 2
config.PT_name            = "Schall-pickup-tower"
config.PT_upper_suffix    = "-upper"
config.PT_range_color     = settings.startup[config.mod_prefix .. "range-colour"].value

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