data:extend({
--    {
--        type = "string-setting",
--        name = "my-mod-global-setting-one",
--        setting_type = "runtime-global",
--        default_value = "yes"
--        allowed_values = {"yes", "no"}
--    },
  {
    type = "bool-setting",
    name = "blueprint_flip_and_turn_show_buttons",
    setting_type = "runtime-per-user",
    default_value = true
  }
})
