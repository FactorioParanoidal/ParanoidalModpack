local search_shortcut = {
  type = "shortcut",
  name = "search-factory",
  action = "lua",
  associated_control_input = "search-factory",
  toggleable = true,
  order = "a",
  icon = {
    filename = "__core__/graphics/icons/search-black.png",
    size = 32,
    flags = {"gui-icon"}
  },
  --[[small_icon = {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut-24.png",
    size = 24,
    flags = {"gui-icon"}
  },]]
  disabled_icon = {
    filename = "__core__/graphics/icons/search-white.png",
    size = 32,
    flags = {"gui-icon"}
  },
  --[[disabled_small_icon =
  {
    filename = "__SpidertronEnhancements__/graphics/follow-shortcut-white-24.png",
    size = 24,
    flags = {"gui-icon"}
  }]]
}
local search_input = {
	type = "custom-input",
	name = "search-factory",
	key_sequence = "SHIFT + F",
  consuming = "none",
  order = "a"
}

data:extend{search_shortcut, search_input}