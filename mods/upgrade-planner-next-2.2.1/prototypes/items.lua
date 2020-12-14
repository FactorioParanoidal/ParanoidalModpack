data:extend({
  {
    type = "selection-tool",
    name = "upgrade-builder",
    icon = "__upgrade-planner-next__/graphics/icons/item/builder.png",
    icon_size = 32,
    stack_size = 1,
    subgroup = "tool",
    order = "c[automated-construction]-d[upgrade-builder]",
    flags = {"hidden", "spawnable", "mod-openable"},
    selection_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2},
    alt_selection_color = {r = 0.2, g = 0.2, b = 0.8, a = 0.2},
    selection_mode = {"buildable-type"},
    alt_selection_mode = {"buildable-type"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "copy",
  },
})
