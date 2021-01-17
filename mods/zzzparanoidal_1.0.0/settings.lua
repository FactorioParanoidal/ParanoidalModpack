data:extend(
{
  {
    type = "double-setting",
    name = "paranoidal-miniloader-energy-multiplier",
    setting_type = "startup",
    default_value = 4,
    minimum_value = 0.01,
    maximum_value = 100,
    order = "a"
  },
  {
    type = "double-setting",
    name = "paranoidal-flowfix-min-time",
    setting_type = "startup",
    default_value = 0.5,
    minimum_value = 0.5,
    maximum_value = 100,
    order = "a"
  }
}
)
if mods.research_evolution_factor then
  data:extend
  {
    {
      type = "bool-setting",
      name = "paranoidal-disable-vanilla-evolution",
      setting_type = "runtime-global",
      default_value = true,
      order = "a"
    }
  }
end
