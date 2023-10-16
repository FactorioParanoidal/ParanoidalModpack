local util = require("scripts.util")

return function(database)
  for name, prototype in pairs(global.prototypes.item_group) do
    database.group[name] = {
      class = "group",
      enabled_at_start = true,
      fluids = util.unique_obj_array({}),
      items = util.unique_obj_array({}),
      prototype_name = name,
      recipes = util.unique_obj_array({}),
    }
    util.add_to_dictionary("group", name, prototype.localised_name)
    -- NOTE: Groups do not have descriptions
  end
end
