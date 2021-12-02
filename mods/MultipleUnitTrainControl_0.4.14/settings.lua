--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: settings.lua
 * Description: Setting to control MU operation.
--]]

data:extend{
  {
    type = "string-setting",
    name = "multiple-unit-train-control-mode",
    order = "aa",
    setting_type = "runtime-global",
    default_value = "tech-unlock",
    allowed_values = {"disabled","basic","advanced","tech-unlock"}
  },
  {
    type = "int-setting",
    name = "multiple-unit-train-control-on_nth_tick",
    order = "ab",
    setting_type = "runtime-global",
    minimum_value = 0,
    default_value = 300
  },
  {
    type = "string-setting",
    name = "multiple-unit-train-control-debug",
    order = "ac",
    setting_type = "runtime-global",
    default_value = "info",
    allowed_values = {"none","error","info","debug"}
  },
  {
    type = "bool-setting",
    name = "multiple-unit-train-control-allow_yuoki_steam",
    order = "aa",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "string-setting",
    name = "multiple-unit-train-control-blacklist",
    order = "ab",
    setting_type = "startup",
    default_value = "",
    allow_blank = true
  },
}
