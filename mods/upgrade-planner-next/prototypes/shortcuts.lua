data:extend({
  {
    type = "shortcut",
    name = "upgrade-builder-sc",
    item_to_spawn = "upgrade-builder",
    order = "a[alt-mode]-b[copy]",
    action = "spawn-item",
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
