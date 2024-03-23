data:extend{
  {
    type = "bool-setting",
    name = "rc-interact-in-game",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "a",
  },
  {
    type = "bool-setting",
    name = "rc-ghost-build-in-map",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "b",
  },
}

if mods["CursorEnhancements"] then
  data.raw["bool-setting"]["rc-ghost-build-in-map"].localised_description = {"mod-setting-description.rc-ghost-build-in-map-cursor-enhancements", {"mod-setting-name.cen-auto-ghost-cursor"}, {"mod-name.CursorEnhancements"}}
end