local util = require("scripts.util")

return function(database)
  --- @type table<string, LuaItemPrototype>
  local prototypes = global.prototypes.item
  for name, prototype in pairs(prototypes) do
    if prototype.type == "tool" then
      database.science_pack[name] = {
        class = "science_pack",
        order = prototype.order,
        prototype_name = name,
      }
      util.add_to_dictionary("science_pack", name, prototype.localised_name)
      util.add_to_dictionary("science_pack_description", name, prototype.localised_description)
    end
  end
end
