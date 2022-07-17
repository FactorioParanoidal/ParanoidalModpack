local global_data = {}

function global_data.init()
  global.players = {}
  global.update_search_results = {}
end

function global_data.build_strings()
  local strings = {}
  local i = 0
  for name, prototype in pairs(game.item_prototypes) do
    i = i + 1
    strings[i] = {
      dictionary = "items",
      internal = name,
      localised = prototype.localised_name,
    }
  end

  global.strings = strings
end

return global_data
