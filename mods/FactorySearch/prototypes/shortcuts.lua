local search_shortcut = {
  type = "shortcut",
  name = "search-factory",
  action = "lua",
  associated_control_input = "search-factory",
  toggleable = true,
  order = "d",
  icon = "__FactorySearch__/graphics/search.png",
  icon_size = 64,
  small_icon = "__FactorySearch__/graphics/search.png",
  small_icon_size = 64,
}
local search_input = {
	type = "custom-input",
	name = "search-factory",
	key_sequence = "SHIFT + F",
  consuming = "none",
  order = "a"
}

data:extend{search_shortcut, search_input}