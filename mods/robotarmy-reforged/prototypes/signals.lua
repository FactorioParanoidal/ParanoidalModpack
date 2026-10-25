-- Virtual signals of the droid counter (the number of each droid kind is output as the item
-- signal of that droid). Icon: the counter icon with a small vanilla signal icon on top.
local shared = require("lib.shared")

local COUNTER_ICON = shared.mod_path .. "/graphics/icons/signal_droid_counter.png"

local prototypes = {}
for i, s in pairs(shared.signals) do
  local icons = {{icon = COUNTER_ICON, icon_size = 64}}
  if s.overlay then
    icons[2] = {icon = "__base__/graphics/icons/signal/" .. s.overlay .. ".png", icon_size = 64, scale = 0.3, shift = {8, 8}}
  end
  prototypes[i] = {
    type = "virtual-signal",
    name = s.name,
    icons = icons,
    subgroup = "virtual-signal-number",
    order = string.format("r[droid]-[%02d]", i),
  }
end

data:extend(prototypes)
