-- Names shared by the settings, data and control stages.
return {
  path = "__MultipleUnitTrainControl-reforged__",
  suffix = "-mu",            -- MU twin of locomotive "<name>" is "<name>-mu"
  power_multiplier = 2,      -- the twin facing forward pulls for both locomotives of the pair
  catalog = "mutc-reforged-locomotives", -- mod-data: std name -> {mu = twin name, bonus = %}
  sprite = "mutc-pair",
  tech_basic = "multiple-unit-train-control",
  tech_wireless = "adv-multiple-unit-train-control",
  setting_mode = "mutc-mode",
  setting_fuel = "mutc-share-fuel",
  setting_labels = "mutc-show-labels",
}
