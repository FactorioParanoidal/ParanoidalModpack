data:extend
{
  {
    type = "item-subgroup",
    name = "train-control-signals",
    group = "signals",
    order = "f"
  },
  {
    type = "virtual-signal",
    name = "refuel-signal",
    localised_name = {"refuel-signal"},
    localised_description = {"refuel-signal-description"},
    icon = "__Train_Control_Signals__/refuel-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    subgroup = "train-control-signals",
    order = "aa"
  },
  {
    type = "virtual-signal",
    name = "depot-signal",
    localised_name = {"depot-signal"},
    localised_description = {"depot-signal-description"},
    icon = "__Train_Control_Signals__/depot-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    subgroup = "train-control-signals",
    order = "ba"
  },
  {
    type = "virtual-signal",
    name = "skip-signal",
    localised_name = {"skip-signal"},
    localised_description = {"skip-signal-description"},
    icon = "__Train_Control_Signals__/skip-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    subgroup = "train-control-signals",
    order = "ca"
  },
}