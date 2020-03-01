data:extend
{
  {
    type = "recipe",
    name = "wireless-charging-lo-power-induction-coil",
    enabled = false,
    energy = 5,
    ingredients =
    {
      {"iron-plate", 5},
      {"electronic-circuit", 2},
      {"plastic-bar", 5},
      {"copper-cable", 20},
    },
    result = "wireless-charging-lo-power-induction-coil",
  },
  {
    type = "recipe",
    name = "wireless-charging-hi-power-induction-coil",
    enabled = false,
    energy = 5,
    ingredients =
    {
      {"wireless-charging-lo-power-induction-coil", 1},
      {"processing-unit", 1},
      {"effectivity-module-2", 5},
      {"speed-module-2", 5},
    },
    result = "wireless-charging-hi-power-induction-coil",
  },
  {
    type = "recipe",
    name = "wireless-charging-lo-power-induction-station",
    enabled = false,
    energy = 10,
    ingredients =
    {
      {"wireless-charging-lo-power-induction-coil", 1},
      {"electronic-circuit", 10},
      {"steel-plate", 10},
    },
    result = "wireless-charging-lo-power-induction-station",
  },
  {
    type = "recipe",
    name = "wireless-charging-hi-power-induction-station",
    enabled = false,
    energy = 10,
    ingredients =
    {
      {"wireless-charging-lo-power-induction-station", 1},
      {"wireless-charging-hi-power-induction-coil", 1},
      {"substation", 1},
    },
    result = "wireless-charging-hi-power-induction-station",
  },
  {
    type = "recipe",
    name = "wireless-charging-lo-power-induction-rail",
    enabled = false,
    ingredients =
    {
      {"wireless-charging-lo-power-induction-station", 1},
      {"rail", 1},
    },
    result = "wireless-charging-lo-power-induction-rail",
  },
  {
    type = "recipe",
    name = "wireless-charging-hi-power-induction-rail",
    enabled = false,
    ingredients =
    {
      {"wireless-charging-lo-power-induction-rail", 1},
      {"wireless-charging-hi-power-induction-coil", 1},
      {"substation", 1},
    },
    result = "wireless-charging-hi-power-induction-rail",
  },
}
