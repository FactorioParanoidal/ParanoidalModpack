data:extend{
  {
    type = "string-setting",
    name = "aai-loaders-mode",
    setting_type = "startup",
    default_value = "lubricated",
    allowed_values = {"lubricated", "expensive", "graphics-only"},
    order = "a"
  },
  {
    type = "bool-setting",
    name = "aai-loaders-require-electricity",
    setting_type = "startup",
    default_value = false,
    hidden = true,
    order = "b"
  },
  {
    type = "string-setting",
    name = "aai-loaders-lubricant-recipe",
    setting_type = "startup",
    default_value = "auto",
    allowed_values = {"auto", "enabled", "disabled"},
    order = "c"
  },
  {
    type = "bool-setting",
    name = "aai-loaders-fit-assemblers",
    setting_type = "startup",
    default_value = true,
    order = "d"
  },
  {
    type = "string-setting",
    name = "aai-loaders-belt-stacking-mode",
    setting_type = "startup",
    default_value = "off",
    allowed_values = {"off", "opt-in", "opt-out"},
    order = "e"
  },
}
