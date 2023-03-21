local data_util = require("__flib__.data-util")
local styles = data.raw["gui-style"].default

styles.milestones_settings_outer_flow = {
    type = "vertical_flow_style",
    horizontal_align = "center",
    vertical_spacing = 8,
    padding = 15
}

styles.milestones_settings_scroll = {
  type = "scroll_pane_style",
  parent = "flib_naked_scroll_pane",
  padding = 0
}

styles.milestones_deep_frame_in_shallow_frame = {
  type = "frame_style",
  parent = "deep_frame_in_shallow_frame",
  left_padding = 8,
  right_padding = 8,
  top_padding = 4,
  bottom_padding = 4,
  minimal_width = 400
}

styles.milestones_horizontal_flow_center = {
  type = "horizontal_flow_style",
  parent = "horizontal_flow",
  vertical_align = "center",
}

styles.milestones_horizontal_flow_big_settings = {
  type = "horizontal_flow_style",
  parent = "milestones_horizontal_flow_center",
  minimal_width = 150,
  horizontal_spacing = 8,
}

styles.milestones_horizontal_flow_big_display = {
  type = "horizontal_flow_style",
  parent = "milestones_horizontal_flow_big_settings",
  left_padding = 16,
  right_padding = 16
}

styles.milestones_table_style = {
  type = "table_style",
  horizontal_spacing = 0
}

styles.milestones_small_button = {
  type = "button_style",
  parent = "frame_button",
  width = 16,
  height = 16
}

styles.milestones_grey_button = {
  type = "button_style",
  parent = "tool_button",
  width = 24,
  height = 24,
  padding = 0
}

styles.milestones_selected_grey_button = {
  type = "button_style",
  parent = "flib_selected_tool_button",
  width = 24,
  height = 24,
  padding = 0
}

styles.milestones_confirm_button = {
  type = "button_style",
  parent = "tool_button_green",
  width = 24,
  height = 24,
  padding = 0
}

styles.milestones_empty_button = {
  type = "empty_widget_style",
  width = 16,
  height = 16
}

styles.milestones_small_dropdown = {
  type = "dropdown_style",
  minimal_width = 75
}

styles.milestones_small_textfield = {
  type = "textbox_style",
  width = 70,
  natural_width = 70
}

styles.milestones_import_export_textbox = {
  type = "textbox_style",
  width = 600,
  minimal_height = 300
}

styles.milestones_very_short_textfield = {
  type = "textbox_style",
  width = 40
}

styles.milestones_very_short_spacer = {
  type = "empty_widget_style",
  width = 40
}

styles.milestones_line_left = table.deepcopy(styles.line)
styles.milestones_line_left.border.right_end = styles.line.border.horizontal_line

styles.milestones_line_right = table.deepcopy(styles.line)
styles.milestones_line_right.border.left_end = styles.line.border.horizontal_line

styles.milestones_line_center = table.deepcopy(styles.line)
styles.milestones_line_center.border.right_end = styles.line.border.horizontal_line
styles.milestones_line_center.border.left_end = styles.line.border.horizontal_line


data:extend{
    {
        type = "custom-input",
        name = "milestones_toggle_gui",
        key_sequence = "CONTROL + ALT + M",
        order = "a"
    },
    {
      type = "custom-input",
      name = "milestones_confirm_settings",
      key_sequence = "",
      linked_game_control = "confirm-gui"
    },
    {
      type = "custom-input",
      name = "milestones_cancel_settings",
      key_sequence = "",
      linked_game_control = "toggle-menu"
    }
}

local shortcut_icon = "__Milestones__/graphics/shortcut-icon.png"
data:extend{
  {
    type = "shortcut",
    name = "milestones_toggle_gui",
    icon = data_util.build_sprite(nil, {0,0}, shortcut_icon, 32, 2),
    disabled_icon = data_util.build_sprite(nil, {48,0}, shortcut_icon, 32, 2),
    small_icon = data_util.build_sprite(nil, {0,32}, shortcut_icon, 24, 2),
    disabled_small_icon = data_util.build_sprite(nil, {36,32}, shortcut_icon, 24, 2),
    associated_control_input = "milestones_toggle_gui",
    toggleable = true,
    action = "lua"
  }
}

-- Sprites
local toolbar_icons = "__Milestones__/graphics/toolbar-icons.png"
local infinity_icon = "__Milestones__/graphics/infinity-icon.png"
local arrows = "__Milestones__/graphics/arrows.png"
local item_icons = "__Milestones__/graphics/item-icons.png"
data:extend{
  data_util.build_sprite("milestones_main_icon_white", {48,0}, shortcut_icon, 32, 2),

  data_util.build_sprite("milestones_infinity_icon", {0, 0}, infinity_icon, 32),

  data_util.build_sprite("milestones_settings_black", {0, 0}, toolbar_icons, 32),
  data_util.build_sprite("milestones_settings_white", {32, 0}, toolbar_icons, 32),
  data_util.build_sprite("milestones_settings_disabled", {64, 0}, toolbar_icons, 32),
  data_util.build_sprite("milestones_pin_black", {0, 32}, toolbar_icons, 32),
  data_util.build_sprite("milestones_pin_white", {32, 32}, toolbar_icons, 32),
  data_util.build_sprite("milestones_pin_disabled", {64, 32}, toolbar_icons, 32),

  data_util.build_sprite("milestones_arrow_up", {0, 0}, arrows, 16),
  data_util.build_sprite("milestones_arrow_down", {16, 0}, arrows, 16),

  data_util.build_sprite("milestones_icon_item", {0, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_item_black", {0, 16}, item_icons, 16),
  data_util.build_sprite("milestones_icon_fluid", {16, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_fluid_black", {16, 16}, item_icons, 16),
  data_util.build_sprite("milestones_icon_technology", {32, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_technology_black", {32, 16}, item_icons, 16),
  data_util.build_sprite("milestones_icon_kill", {48, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_kill_black", {48, 16}, item_icons, 16),
  data_util.build_sprite("milestones_icon_group", {64, 0}, item_icons, 16),
  data_util.build_sprite("milestones_icon_group_black", {64, 16}, item_icons, 16),
}
