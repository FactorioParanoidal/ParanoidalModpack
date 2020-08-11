data:extend({
  {
    type = "fluid",
    name = "liquid-dichlorobutene", --C4H6Cl2
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/dichlorobutene.png",icon_size=72},"chl"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    base_color =fluid_flow_colour({"C4","H6","Cl2"}),-- {r = 172/255, g = 172/255, b = 172/255}, --C4H6
    flow_color = fluid_flow_colour({"C4","H6","Cl2"}),--{r = 180/255, g = 197/255, b = 129/255}, --C4H6Cl2
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-chlorobutadiene", --C4H5Cl
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/chloroprene.png",icon_size=72},"chl"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C4","H5","Cl"}),--{r = 44/255, g = 44/255, b = 114/255}, -- CN
    flow_color = fluid_flow_colour({"C4","H5","Cl"}),--{r = 150/255, g = 150/255, b = 185/255}, --HCN
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-hydrogen-cyanide", --HCN
    icons =angelsmods.functions.create_gas_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/hydrogen-cyanide.png",icon_size=72},"chn"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"H","C","N"}),--{r = 44/255, g = 44/255, b = 114/255}, -- CN
    flow_color = fluid_flow_colour({"H","C","N"}),--{r = 150/255, g = 150/255, b = 185/255}, --HCN
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-acetone-cyanohydrin", --C4H7NO
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/acetone-cyanohydrin.png",icon_size=72},"cno"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C4","H7","N","O"}),--{r = 63/255, g = 63/255, b = 85/255}, --C4H7N {taken as (C3, H7) blended with 1 N}
    flow_color = fluid_flow_colour({"C4","H7","N","O"}),--{r = 146/255, g = 38/255, b = 73/255}, --C4H7NO
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-acrylonitrile",
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/acrylonitrile.png",icon_size=72},"chn"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C3","H3","N"}),--{r = 151/255, g = 151/255, b = 151/255}, -- C3H3
    flow_color = fluid_flow_colour({"C3","H3","N"}),--{r = 96/255, g = 96/255, b = 166/255}, --C3H3N
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-methyl-methacrylate",
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/methyl-methacrylate.png",icon_size=72},"cho"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C5","H8","O2"}),--{r = 186/255, g = 186/255, b = 186/255}, --C5H8 {taken as (C4, H8)}
    flow_color = fluid_flow_colour({"C5","H8","O2"}),--{r = 200/255, g = 128/255, b = 128/255}, --C5H8O2 {Taken as (C2,H4,O)}
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-vinyl-chloride", --C2H3Cl
    icons =angelsmods.functions.create_gas_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/vinyl-chloride.png",icon_size=72},"clh"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C2","H3","Cl"}),--{r = 172/255, g = 172/255, b = 172/255}, --C2H3
    flow_color = fluid_flow_colour({"C2","H3","Cl"}),--{r = 180/255, g = 197/255, b = 129/255}, --C2H3Cl
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-acetylene", --C2H2
    icons =angelsmods.functions.create_gas_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/acetylene.png",icon_size=72},"chl"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C2","H2"}),--{r = 172/255, g = 172/255, b = 172/255}, --C2H2
    flow_color = fluid_flow_colour({"C2","H2"}),--{r = 172/255, g = 172/255, b = 172/255}, --C2H2
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-vinyl-acetylene", --C4H6O2
    icons =angelsmods.functions.create_gas_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/vinyl-acetylene.png",icon_size=72},"cch"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"C4","H6","O2"}),--{r = 172/255, g = 172/255, b = 172/255}, --C4H6
    flow_color = fluid_flow_colour({"C4","H6","O2"}),--{r = 172/255, g = 172/255, b = 172/255}, --C4H6O2
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "gas-nitrous-oxide",
    icons =angelsmods.functions.create_gas_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/nitrous-oxide.png",icon_size=72},"chl"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"N2","O"}),--{r = 41/255, g = 41/255, b = 180/255}, --NN
    flow_color = fluid_flow_colour({"N2","O"}),--{r = 1180/255, g = 41/255, b = 180/255}, --NNO
    max_temperature = 100,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-lactic-acid",--C3H6O3
    icons =angelsmods.functions.create_liquid_fluid_icon({icon="__PCPRedux__/graphics/icons/raw/lactic-acid.png",icon_size=72},"coh"),
    subgroup = "petrochem-chlorine-fluids",
    default_temperature = 25,
    heat_capacity = "1KJ",
    base_color = fluid_flow_colour({"c3","H6","O3"}),--{r = 1, g = 1, b = 1},
    flow_color = fluid_flow_colour({"c3","H6","O3"}),--{r = 1, g = 1, b = 1},
    max_temperature = 100,
    pressure_to_speed_ratio = 0.3,
    flow_to_energy_ratio = 0.2,
    auto_barrel=true,
  },
  {
    type = "fluid",
    name = "liquid-rubber-pre",
    icons ={{icon="__PCPRedux__/graphics/icons/liquid-rubber-pre.png",icon_size=64}},
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
    icons={{icon="__PCPRedux__/graphics/icons/liquid-rubber-masterbatch.png",icon_size=64}},
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
