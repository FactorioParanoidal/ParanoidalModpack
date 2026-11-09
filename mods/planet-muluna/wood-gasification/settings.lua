
local hidden, default = true, false
if mods["space-age"] then
  default = true
  hidden = false
  l_name = "__base__/graphics/empty.png"
end
data:extend({
  -- {
  --   type = "bool-setting",
  --   name = "require-gleba-for-greenhouse-tech",
  --   localised_name = {"", "[planet=gleba]", " ?"} or "",
  --   setting_type = "startup",
  --   default_value = false,
  --   order = "a",
  --   hidden = hidden
  -- },
  {
    type = "double-setting",
    name = "tree-seed-probability",
    localised_name = {"", "[img=sigma-symbol]", {"item-name.tree-seed"}, " ?"},
    setting_type = "startup",
    default_value = 0.1,
    minimum_value = 0,
    maximum_value = 1,
    order = "z",
    hidden = true
  },
  -- {
  --   type = "double-setting",
  --   name = "greenhouse-output-pr-sec-wood",
  --   setting_type = "startup",
  --   default_value = 0.3333,
  --   minimum_value = 0.001,
  --   order = "c",
  -- },
  -- {
  --   type = "double-setting",
  --   name = "greenhouse-output-pr-sec-yumako",
  --   setting_type = "startup",
  --   default_value = 0.3333,
  --   minimum_value = 0.001,
  --   order = "d",
  --   hidden = hidden
  -- },
  -- {
  --   type = "double-setting",
  --   name = "greenhouse-output-pr-sec-jellynut",
  --   setting_type = "startup",
  --   default_value = 0.3333,
  --   minimum_value = 0.001,
  --   order = "e",
  --   hidden = hidden
  -- }
})