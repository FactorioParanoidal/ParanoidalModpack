local S = require("shared")

local styles = data.raw["gui-style"]["default"]

-- solid bars for the load history chart and colour stripes
for _, c in ipairs({ "green", "yellow", "red", "grey", "blue" }) do
  styles["ppd_bar_" .. c] = {
    type = "empty_widget_style",
    graphical_set = { base = { filename = S.GFX .. "gui/bar-" .. c .. ".png", position = { 0, 0 }, corner_size = 1 } },
    width = 6,
    height = 2,
  }
end
styles["ppd_chart_frame"] = {
  type = "frame_style",
  parent = "deep_frame_in_shallow_frame",
  height = 76,
  padding = 4,
  horizontal_flow_style = { type = "horizontal_flow_style", horizontal_spacing = 1, vertical_align = "bottom" },
}
styles["ppd_marker_label"] = { type = "label_style", font = "default-small-semibold", top_padding = -4, bottom_padding = -4 }

local sprites = {}
for i, c in ipairs(S.COLORS) do
  sprites[#sprites + 1] = { type = "sprite", name = "ppd-color-" .. i, filename = S.GFX .. "gui/chip.png", size = 32,
    tint = c, flags = { "gui-icon" } }
end
sprites[#sprites + 1] = { type = "sprite", name = "ppd-gear-white", filename = S.GFX .. "gui/gear-white.png", size = 32, flags = { "gui-icon" } }
sprites[#sprites + 1] = { type = "sprite", name = "ppd-gear-black", filename = S.GFX .. "gui/gear-black.png", size = 32, flags = { "gui-icon" } }
data:extend(sprites)

data:extend({
  {
    type = "custom-input",
    name = "ppd-dispatcher",
    key_sequence = "CONTROL + SHIFT + D",
    consuming = "none",
    action = "lua",
  },
  {
    type = "shortcut",
    name = "ppd-dispatcher",
    action = "lua",
    toggleable = true,
    associated_control_input = "ppd-dispatcher",
    technology_to_unlock = S.TECH.t40,
    unavailable_until_unlocked = true,
    icon = S.GFX .. "gui/shortcut-32.png",
    icon_size = 32,
    small_icon = S.GFX .. "gui/shortcut-24.png",
    small_icon_size = 24,
    order = "e[ppd-dispatcher]",
  },
})

-- tips and tricks
local function tip(name, order, title)
  return {
    type = "tips-and-tricks-item",
    name = "ppd-" .. name,
    category = "ppd",
    order = order,
    is_title = title or nil,
    indent = (not title) and 1 or nil,
    dependencies = (not title) and { "ppd-districts" } or nil,
    trigger = { type = "research", technology = S.TECH.t40 },
    tag = "[item=ppd-transformer-80]",
  }
end
data:extend({
  { type = "tips-and-tricks-item-category", name = "ppd", order = "c-[electric-network]-z" },
  tip("districts", "a", true),
  tip("green-zone", "b"),
  tip("matching", "c"),
  tip("smoothing", "d"),
  tip("priorities", "e"),
})
