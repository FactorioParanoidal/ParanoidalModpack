local data_util = require("__flib__.data-util")

local frame_action_icons = "__RecipeBook__/graphics/frame-action-icons.png"
local tool_icons = "__RecipeBook__/graphics/tool-icons.png"
local small_tool_icons = "__RecipeBook__/graphics/small-tool-icons.png"

data:extend({
  -- Frame action icons
  data_util.build_sprite("rb_nav_backward_black", { 0, 0 }, frame_action_icons, 32),
  data_util.build_sprite("rb_nav_backward_white", { 32, 0 }, frame_action_icons, 32),
  data_util.build_sprite("rb_nav_backward_disabled", { 64, 0 }, frame_action_icons, 32),
  data_util.build_sprite("rb_nav_forward_black", { 0, 32 }, frame_action_icons, 32),
  data_util.build_sprite("rb_nav_forward_white", { 32, 32 }, frame_action_icons, 32),
  data_util.build_sprite("rb_nav_forward_disabled", { 64, 32 }, frame_action_icons, 32),
  data_util.build_sprite("rb_pin_black", { 0, 64 }, frame_action_icons, 32),
  data_util.build_sprite("rb_pin_white", { 32, 64 }, frame_action_icons, 32),
  data_util.build_sprite("rb_settings_black", { 0, 96 }, frame_action_icons, 32),
  data_util.build_sprite("rb_settings_white", { 32, 96 }, frame_action_icons, 32),
  data_util.build_sprite("rb_expand_black", { 0, 128 }, frame_action_icons, 32),
  data_util.build_sprite("rb_expand_white", { 32, 128 }, frame_action_icons, 32),
  data_util.build_sprite("rb_detach_black", { 0, 160 }, frame_action_icons, 32),
  data_util.build_sprite("rb_detach_white", { 32, 160 }, frame_action_icons, 32),
  -- Tool icons
  data_util.build_sprite("rb_favorite_black", { 0, 0 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_clipboard_black", { 0, 32 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_fluid_black", { 0, 64 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_technology_gui_black", { 0, 96 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_list_nav_backward_black", { 0, 128 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_list_nav_forward_black", { 0, 160 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_export_black", { 0, 192 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_collapsed", { 0, 224 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_expanded", { 0, 256 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_filter", { 0, 288 }, tool_icons, 32, 2),
  data_util.build_sprite("rb_swap", { 0, 320 }, tool_icons, 32, 2),
  -- Small tool icons
  data_util.build_sprite("rb_plus_black", { 0, 0 }, small_tool_icons, 16, 2),
  data_util.build_sprite("rb_minus_black", { 0, 16 }, small_tool_icons, 16, 2),
  -- Slot button icons
  data_util.build_sprite("rb_favorite_slot", { 0, 0 }, "__RecipeBook__/graphics/favorite-slot-button-icon.png", 32, 1),
})
