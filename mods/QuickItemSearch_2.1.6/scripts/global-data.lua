local dictionary = require("__flib__/dictionary-lite")

local global_data = {}

function global_data.init()
  global.players = {}
  global.update_search_results = {}
end

function global_data.build_dictionary()
  dictionary.new("item")
  for name, prototype in pairs(game.item_prototypes) do
    dictionary.add("item", name, prototype.localised_name)
  end
end

return global_data
