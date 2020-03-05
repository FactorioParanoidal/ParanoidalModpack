--[[
Black={r = 47/255, g = 47/255, b = 47/255} -- Carbon
White={r = 255/255, g = 255/255, b = 255/255} -- Hydrogen
Red={r = 229/255, g = 13/255, b = 13/255} -- Oxygen
Blue={r = 41/255, g = 41/255, b = 180/255} -- Nitrogen
Green={r = 196/255, g = 248/255, b = 42/255} -- Chlorine
Brown={r = 41/255, g = 41/255, b = 180/255} -- Complex
PaleYellow={r = 233/255, g = 254/255, b = 127/255} -- Fluoride
Base=Major blended mid
Flow=Base blended minor]]

data:extend({
  {
    type = "fluid",
    name = "liquid-dichlorobutene", --c4h6cl2
    icons =generate_fluid_icons("dichlorobutene","clh","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    base_color = {r = 172/255, g = 172/255, b = 172/255}, --C4H6
    flow_color = {r = 180/255, g = 197/255, b = 129/255}, --C4H6Cl2
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-chlorobutadiene",
    icons =generate_fluid_icons("chlorobutadiene","clh","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 44/255, g = 44/255, b = 114/255}, -- CN
    flow_color = {r = 150/255, g = 150/255, b = 185/255}, --HCN
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-hydrogen-cyanide",
    icons =generate_fluid_icons("hydrogen_cyanide","chn","gas"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 44/255, g = 44/255, b = 114/255}, -- CN
    flow_color = {r = 150/255, g = 150/255, b = 185/255}, --HCN
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-acetone-cyanohydrin",
    icons =generate_fluid_icons("acetone_cyanohydrin","cno","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 63/255, g = 63/255, b = 85/255}, --C4H7N {taken as (C3, H7) blended with 1 N}
    flow_color = {r = 146/255, g = 38/255, b = 73/255}, --C4H7NO
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-acrylonitrile",
    icons =generate_fluid_icons("acrylonitrile","chn","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 151/255, g = 151/255, b = 151/255}, -- C3H3
    flow_color = {r = 96/255, g = 96/255, b = 166/255}, --C3H3N
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-methyl-methacrylate",
    icons =generate_fluid_icons("methyl_methacrylate","cho","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 186/255, g = 186/255, b = 186/255}, --C5H8 {taken as (C4, H8)}
    flow_color = {r = 200/255, g = 128/255, b = 128/255}, --C5H8O2 {Taken as (C2,H4,O)}
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-vinyl-chloride",
    icons =generate_fluid_icons("vinyl_chloride","clh","gas"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 172/255, g = 172/255, b = 172/255}, --C2H3
    flow_color = {r = 180/255, g = 197/255, b = 129/255}, --C2H3Cl
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-acetylene",
    icons =generate_fluid_icons("acetylene","cch","gas"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 172/255, g = 172/255, b = 172/255}, --C2H3
    flow_color = {r = 172/255, g = 172/255, b = 172/255}, --C2H3Cl
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-vinyl-acetylene",
    icons =generate_fluid_icons("vinyl_acetylene","cch","gas"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 172/255, g = 172/255, b = 172/255}, --C2H3
    flow_color = {r = 172/255, g = 172/255, b = 172/255}, --C2H3Cl
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-nitrous-oxide",
    icons =generate_fluid_icons("nitrous_oxide","nno","gas"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 41/255, g = 41/255, b = 180/255}, --NN
    flow_color = {r = 1180/255, g = 41/255, b = 180/255}, --NNO
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-lactic-acid",
    icons =generate_fluid_icons("lactic_acid","coh","liq"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 1, g = 1, b = 1},
    flow_color = {r = 1, g = 1, b = 1},
    max_temperature = 100,
    pressure_to_speed_ratio = 0.3,
    flow_to_energy_ratio = 0.2,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-rubber-pre",
    icons ={{icon="__PCP__/graphics/icons/liquid-rubber-pre.png",icon_size=64}},
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 1, g = 1, b = 1},
    flow_color = {r = 1, g = 1, b = 1},
    max_temperature = 100,
    pressure_to_speed_ratio = 0.3,
    flow_to_energy_ratio = 0.2,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-rubber-masterbatch",
    icons={{icon="__PCP__/graphics/icons/liquid-rubber-masterbatch.png",icon_size=64}},
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = {r = 1, g = 1, b = 1},
    flow_color = {r = 1, g = 1, b = 1},
    max_temperature = 100,
    pressure_to_speed_ratio = 0.3,
    flow_to_energy_ratio = 0.2,
    auto_barrel=true,
  },
})
