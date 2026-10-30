local sets = require("sets")

local settings_list = {}
for index, set in ipairs(sets) do
  settings_list[#settings_list + 1] = {
    type = "bool-setting",
    name = "runames-set-" .. set.id,
    setting_type = "runtime-global",
    default_value = set.default,
    order = string.format("a%02d", index),
  }
end
data:extend(settings_list)
