local util = require("scripts.util")

return function(database)
  for name, prototype in pairs(global.prototypes.recipe_category) do
    database.recipe_category[name] = {
      class = "recipe_category",
      enabled_at_start = true,
      fluids = util.unique_obj_array({}),
      items = util.unique_obj_array({}),
      prototype_name = name,
      recipes = util.unique_obj_array({}),
    }
    util.add_to_dictionary("recipe_category", name, prototype.localised_name)
    util.add_to_dictionary("recipe_category_description", name, prototype.localised_description)
  end
end
