-- Final fixes

-- Copy the small-lamp's signal-to-color mapping in case any other mods have changed it.
local lamps = data.raw.lamp
local lamp = lamps["small-lamp"]

if lamp.signal_to_color_mapping then
  --~ for f, flat_lamp in pairs({"flat-lamp", "flat-lamp-big"}) do
  for f, flat_lamp in pairs(INLAID_LAMP_NAMES) do
    if lamps[flat_lamp] then
      lamps[flat_lamp].signal_to_color_mapping = lamp.signal_to_color_mapping
    end
  end
end
