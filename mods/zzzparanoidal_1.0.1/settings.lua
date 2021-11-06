data:extend({
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
  },
-------------------------------------------------------------------------------------------------
{type = "bool-setting", name = "stone-path-concrete", setting_type = "startup", default_value = true, order = "2"},
{type = "bool-setting", name = "fitolamps", setting_type = "startup", default_value = true, order = "1"},
-------------------------------------------------------------------------------------------------
--рескин поездов
{type = "bool-setting", name = "res_loc_1", setting_type = "startup", default_value = true, order = "3"},
{type = "bool-setting", name = "res_loc_2", setting_type = "startup", default_value = true, order = "4"},
{type = "bool-setting", name = "res_loc_3", setting_type = "startup", default_value = true, order = "5"},
{type = "bool-setting", name = "res_loc_e", setting_type = "startup", default_value = true, order = "6"},
-------------------------------------------------------------------------------------------------
})

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