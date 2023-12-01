local constants = require("constants")

local util = require("scripts.util")

return function(database)
  for class in pairs(constants.prototypes.filtered_entities) do
    if class ~= "resource" then
      for name, prototype in pairs(global.prototypes[class]) do
        local type = prototype.type
        local type_data = database.entity_type[type]
        if not type_data then
          type_data = {
            class = "entity_type",
            entities = {},
            prototype_name = type,
          }
          database.entity_type[type] = type_data
          util.add_to_dictionary("entity_type", type, { "entity-type." .. type })
          util.add_to_dictionary("entity_type_description", type, { "entity-type-description." .. type })
        end

        table.insert(type_data.entities, { class = "entity", name = name })
      end
    end
  end
end
