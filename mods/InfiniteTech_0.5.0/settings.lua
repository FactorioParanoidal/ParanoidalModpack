data:extend({
  {
    type = "bool-setting",
    name = "inf-tech-mining-productivity-log-formula",
    order = "aa",
    setting_type = "startup",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = "inf-tech-follower-count-log-formula",
    order = "ba",
    setting_type = "startup",
    default_value = true,
  },
  {
    type = "int-setting",
    name = "inf-tech-follower-count-time",
    order = "bb",
    setting_type = "startup",
    default_value = 60,
    minimum_value = 10,
    maximum_value = 10000,
  },

})