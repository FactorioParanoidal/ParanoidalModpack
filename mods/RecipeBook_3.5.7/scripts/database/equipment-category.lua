local util = require("scripts.util")

local equipment_category_proc = {}

function equipment_category_proc.build(database)
  for name, prototype in pairs(global.prototypes.equipment_category) do
    database.equipment_category[name] = {
      class = "equipment_category",
      enabled_at_start = true,
      equipment = {},
      prototype_name = name,
    }
    util.add_to_dictionary("equipment_category", name, prototype.localised_name)
    util.add_to_dictionary("equipment_category_description", name, prototype.localised_description)
  end
end

-- When calling the module directly, call equipment_category_proc.build
setmetatable(equipment_category_proc, {
  __call = function(_, ...)
    return equipment_category_proc.build(...)
  end,
})

return equipment_category_proc
