-- Final fixes

-- Copy the small-lamp's signal to color mapping in case any other mods have changed it.
local lamp = data.raw["lamp"]["small-lamp"]

if lamp["signal_to_color_mapping"] then
  local flat_lamp = data.raw["lamp"]["flat-lamp"]
  flat_lamp.signal_to_color_mapping = lamp.signal_to_color_mapping
  local flat_lamp_big = data.raw["lamp"]["flat-lamp-big"]
  flat_lamp_big.signal_to_color_mapping = lamp.signal_to_color_mapping
end
