--[[ Copyright (c) 2017 Optera
 * Part of Lighted Electric Poles +
 *
 * See LICENSE.md in the project directory for license information.
--]]

data:extend({
 {
    type = "item",
    name = "hidden-small-lamp",
    icon = "__base__/graphics/icons/small-lamp.png",
    icon_size = 32,
    flags = {"hidden"},
    subgroup = "circuit-network",
    order = "a[light]-b[hidden-small-lamp]",
    place_result = "hidden-small-lamp",
    stack_size = 50
  }
})