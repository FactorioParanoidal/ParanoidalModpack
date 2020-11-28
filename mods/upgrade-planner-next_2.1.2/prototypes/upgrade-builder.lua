data:extend({
  {
    type = "selection-tool",
    name = "upgrade-builder",
    icon = "__upgrade-planner-next__/graphics/icons/item/builder.png",
    icon_size = 32,
    stack_size = 1,
    subgroup = "tool",
    order = "c[automated-construction]-d[upgrade-builder]",
    flags = {"hidden"},
    selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    alt_selection_color = {r = 0.2, g = 0.2, b = 0.8, a = 0.2},
    selection_mode = {"buildable-type"},
    alt_selection_mode = {"buildable-type"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "copy",
    can_be_mod_opened = true,
    show_in_library = false,
  }, {
    type = "shortcut",
    name = "upgrade-builder",
    item_to_create = "upgrade-builder",
    order = "a[alt-mode]-b[copy]",
    action = "create-blueprint-item",
    localised_name = {"shortcut.upgrade-builder"},
    icon = {
      filename = "__upgrade-planner-next__/graphics/icons/shortcut-bar/shortcut-32.png",
      priority = "extra-high-no-scale",
      size = 32,
      scale = 1,
      flags = {"icon"},
    },
    small_icon = {
      filename = "__upgrade-planner-next__/graphics/icons/shortcut-bar/shortcut-24.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 1,
      flags = {"icon"},
    },
    disabled_small_icon = {
      filename = "__upgrade-planner-next__/graphics/icons/shortcut-bar/shortcut-24-disabled.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 1,
      flags = {"icon"},
    },
    style = "green",
  },
})

data:extend{
  {type = "custom-input", name = "upgrade-planner", key_sequence = "U"}, {
    type = "custom-input",
    name = "upgrade-planner-hide",
    key_sequence = "CONTROL + U",
  },
}
