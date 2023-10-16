local util = require("scripts.util")

return function(database)
  for name, prototype in pairs(global.prototypes.item) do
    local type = prototype.type
    local type_data = database.item_type[type]
    if not type_data then
      type_data = {
        class = "item_type",
        items = {},
        prototype_name = type,
      }
      database.item_type[type] = type_data
      util.add_to_dictionary("item_type", type, { "item-type." .. type })
      util.add_to_dictionary("item_type_description", type, { "item-type-description." .. type })
    end

    table.insert(type_data.items, { class = "item", name = name })
  end
end
