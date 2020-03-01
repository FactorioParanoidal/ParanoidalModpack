--[[ Copyright (c) 2017 Optera
 * Part of Lighted Electric Poles +
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- local hidden_lamp = table.deepcopy(data.raw["lamp"]["small-lamp"])
-- hidden_lamp.name = "hidden-small-lamp"

local hidden_lamp = optera_lib.copy_prototype(data.raw["lamp"]["small-lamp"], "hidden-small-lamp")
hidden_lamp.icon = "__base__/graphics/icons/small-lamp.png"
hidden_lamp.icon_size = 32
hidden_lamp.flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"}
hidden_lamp.selectable_in_game = false
hidden_lamp.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
hidden_lamp.selection_box = {{-0.4, -0.4}, {0.4, 0.4}}
hidden_lamp.collision_mask = { "resource-layer" }
hidden_lamp.energy_usage_per_tick = "5KW"
hidden_lamp.picture_off =
{
  filename = "__core__/graphics/empty.png",
  priority = "high",
  width = 1,
  height = 1,
  frame_count = 1,
  axially_symmetrical = false,
  direction_count = 1,
}
hidden_lamp.picture_on =
{
  filename = "__core__/graphics/empty.png",
  priority = "high",
  width = 1,
  height = 1,
  frame_count = 1,
  axially_symmetrical = false,
  direction_count = 1,
}

data:extend({ hidden_lamp })

