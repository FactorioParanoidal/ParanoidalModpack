local config = {}

local PT_range_color_specs =
{
  ["red"]     = {r=0.5, g=0.2, b=0.2},
  ["yellow"]  = {r=0.5, g=0.5, b=0.2},
  ["green"]   = {r=0.2, g=0.5, b=0.2},
  ["cyan"]    = {r=0.2, g=0.5, b=0.5},
  ["blue"]    = {r=0.2, g=0.2, b=0.5},
  ["magenta"] = {r=0.5, g=0.2, b=0.5},
  ["white"]   = {r=0.5, g=0.5, b=0.5},
}

config.tier_max           = settings.startup["pickuptower-tier-max"].value -- 2
config.PT_name            = "Schall-pickup-tower"
config.PT_upper_suffix    = "-upper"
config.PT_range_color     = PT_range_color_specs[settings.startup["pickuptower-range-color"].value]

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