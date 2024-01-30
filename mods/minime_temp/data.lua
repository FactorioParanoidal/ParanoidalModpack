local minime = require("__minime_temp__/common")("minime_temp")

------------------------------------------------------------------------------------
-- Define GUI styles

data.raw['gui-style'].default.minime_button_off = {
  type = "button_style",
  parent = "button",
  padding = 4,
}

data.raw['gui-style'].default.minime_button_on = {
  type = "button_style",
  parent = "green_button",
  padding = 4,
}

data.raw['gui-style'].default.minime_button_warning = {
  type = "button_style",
  parent = "red_button",
  padding = 4,
}

data.raw['gui-style'].default.minime_toggle_button = {
  type = "button_style",
  padding = 4,
}

data.raw['gui-style'].default.minime_separator_line = {
  type = "line_style",
  top_padding = 0,
  bottom_padding = 0,
  top_margin = 6,
  bottom_margin = 6,
  border = {
    border_width = 4,
    left_end = {position = {336, 0}, size = {4, 4}},
    horizontal_line = {position = {340, 0}, size = {1, 4}},
    right_end = {position = {341, 0}, size = {4, 4}}
  }

}

------------------------------------------------------------------------------------
-- Define dummy character
-- The character needs an insane inventory size so we can store inventories even of
-- characters with a huge inventory created by other mods.
local dummy = table.deepcopy(data.raw.character["character"])
dummy.name = minime.dummy_character_name
dummy.inventory_size = 1000
data.raw.character[minime.dummy_character_name] = dummy
