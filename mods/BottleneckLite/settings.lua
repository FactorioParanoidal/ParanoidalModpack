local constants = require("constants")

data:extend({
  {
    type = "bool-setting",
    name = "bnl-enable",
    setting_type = "startup",
    default_value = true,
    order = "aa",
  },
  {
    type = "bool-setting",
    name = "bnl-glow",
    setting_type = "startup",
    default_value = true,
    order = "ab",
  },
  {
    type = "bool-setting",
    name = "bnl-include-mining-drills",
    setting_type = "startup",
    default_value = true,
    order = "ac",
  },
  {
    type = "string-setting",
    name = "bnl-indicator-size",
    setting_type = "startup",
    default_value = constants.default_size,
    allowed_values = constants.size_settings,
    order = "ad",
  },
})

local color_settings = {}
for name, spec in pairs(constants.status_settings) do
  color_settings[#color_settings + 1] = {
    type = "string-setting",
    name = "bnl-color-" .. name,
    localised_name = { "mod-setting-name.bnl-color-setting", { "mod-setting-name.bnl-status-" .. name } },
    setting_type = "startup",
    default_value = spec.color,
    allowed_values = constants.color_settings,
    order = spec.order,
  }
end

data:extend(color_settings)
