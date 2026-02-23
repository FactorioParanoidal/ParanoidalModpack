data:extend{
  {
    type = "sprite",
    name = "wsx-combined-wires",
    filename = "__WireShortcutX__/graphics/combined-shortcut.png",
    size = 64,
  },
  {
    type = "sprite",
    name = "wsx-red-green-wires",
    filename = "__WireShortcutX__/graphics/red-green-shortcut.png",
    size = 64,
  },
  {
    type = "custom-input",
    name = "wsx-give-wire",
    localised_name = { "shortcut.wsx-make-wire" },
    key_sequence = "ALT + W",
    order = "a",
  },
}

local number_of_shortcuts = settings.startup["wsx-number-of-shortcuts"].value

if number_of_shortcuts == "one" or number_of_shortcuts == "two" then
  data:extend{
    {
      type = "shortcut",
      name = "wsx-give-wire",
      action = "lua",
      localised_name = {"shortcut.wsx-make-wire"},
      associated_control_input = "wsx-give-wire",
      technology_to_unlock = "electronics",
      icon = "__WireShortcutX__/graphics/combined-shortcut.png",
      icon_size = 64,
      small_icon = "__WireShortcutX__/graphics/combined-shortcut.png",
      small_icon_size = 64,
      order = "wsx-a",
    },
  }
end
if number_of_shortcuts == "one" then
  data.raw.shortcut["wsx-give-wire"].icon = "__WireShortcutX__/graphics/combined-shortcut.png"
elseif number_of_shortcuts == "two" then
  data.raw.shortcut["wsx-give-wire"].icon = "__WireShortcutX__/graphics/red-green-shortcut.png"
end

if number_of_shortcuts == "two" or number_of_shortcuts == "three" then
  data:extend{
    {
      type = "shortcut",
      name = "wsx-give-copper-wire",
      action = "spawn-item",
      localised_name = {"shortcut.make-copper-wire"},
      associated_control_input = "give-copper-wire",
      technology_to_unlock = "electronics",
      item_to_spawn = "copper-wire",
      icon = "__WireShortcutX__/graphics/copper-wire-shortcut.png",
      icon_size = 64,
      small_icon = "__WireShortcutX__/graphics/copper-wire-shortcut.png",
      small_icon_size = 64,
      order = "wsx-d",
    },
  }
end

if number_of_shortcuts == "three" then
  data:extend{
    {
      type = "shortcut",
      name = "wsx-give-red-wire",
      action = "spawn-item",
      localised_name = {"shortcut.make-red-wire"},
      associated_control_input = "give-red-wire",
      technology_to_unlock = "circuit-network",
      item_to_spawn = "red-wire",
      icon =  "__WireShortcutX__/graphics/red-wire-shortcut.png",
      icon_size = 64,
      small_icon = "__WireShortcutX__/graphics/red-wire-shortcut.png",
      small_icon_size = 64,
      order = "wsx-b",
    },
    {
      type = "shortcut",
      name = "wsx-give-green-wire",
      action = "spawn-item",
      localised_name = {"shortcut.make-green-wire"},
      associated_control_input = "give-green-wire",
      technology_to_unlock = "circuit-network",
      item_to_spawn = "green-wire",
      icon = "__WireShortcutX__/graphics/green-wire-shortcut.png",
      icon_size = 64,
      small_icon = "__WireShortcutX__/graphics/green-wire-shortcut.png",
      small_icon_size = 64,
      order = "wsx-c",
    },
  }
end