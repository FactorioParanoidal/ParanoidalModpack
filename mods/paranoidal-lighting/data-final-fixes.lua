-- Follow the vanilla lamp colours in case another mod added signals to them.
local colours = data.raw.lamp["small-lamp"].signal_to_color_mapping
if colours then
  for _, name in pairs({"deadlock-large-lamp", "deadlock-electric-copper-lamp", "deadlock-floor-lamp", "flat-lamp", "flat-lamp-big"}) do
    local lamp = data.raw.lamp[name]
    if lamp then lamp.signal_to_color_mapping = table.deepcopy(colours) end
  end
end

require("prototypes.status-lights").train_stops()
