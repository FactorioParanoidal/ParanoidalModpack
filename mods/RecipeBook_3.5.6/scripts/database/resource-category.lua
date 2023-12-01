local util = require("scripts.util")

return function(database)
  for name, prototype in pairs(global.prototypes.resource_category) do
    database.resource_category[name] = {
      class = "resource_category",
      enabled_at_start = true,
      mining_drills = {},
      prototype_name = name,
      resources = util.unique_obj_array({}),
    }
    util.add_to_dictionary("resource_category", name, prototype.localised_name)
    util.add_to_dictionary("resource_category_description", name, prototype.localised_description)
  end
end
