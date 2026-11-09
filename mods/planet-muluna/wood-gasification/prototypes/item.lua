Muluna:extend({
  {
    type = "fluid",
    name = "tar",
    subgroup = "fluid",
    default_temperature = 180,
    max_temperature = 250,
    heat_capacity = "1470000J",
    base_color = {r=0.05, g=0.05, b=0.05},
    flow_color = {r=0.1, g=0.1, b=0.1},
    icon = "__muluna-graphics__/graphics/wood-gasification/icon/tar.png",
    icon_size = 64,
    order = "a[fluid]-t[tar]",
    -- pressure_to_speed_ratio = 0.2,
    -- flow_to_energy_ratio = 0.80,
  },
  -- {
  --   type = "item",
  --   name = "I-greenhouse",
  --   icon = "__muluna-graphics__/graphics/wood-gasification/greenhouse/greenhouse_icon.png",
  --   icon_size = 64,
  --   subgroup = mods["space-age"] and "agriculture" or "production-machine",
  --   order = "0",
  --   stack_size = 10,
  --   place_result = "E-greenhouse",
  --   weight = 100*kg
  -- },
  {
    type = "sprite",
    name = "sigma-symbol",
    filename = "__muluna-graphics__/graphics/wood-gasification/icon/sigma_symbol.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    shift = {0,0.2}
  },
})
