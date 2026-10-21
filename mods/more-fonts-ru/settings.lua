local families = require("families")

local allowed = { "default" }
for _, family in ipairs(families) do
  allowed[#allowed + 1] = family.id
end

data:extend({
  {
    type = "string-setting",
    name = "more-fonts-ru-font-family",
    setting_type = "startup",
    default_value = "default",
    allowed_values = allowed,
    order = "a",
  },
})
