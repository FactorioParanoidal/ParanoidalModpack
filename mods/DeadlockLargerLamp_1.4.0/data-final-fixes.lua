local DLL = require("prototypes.globals")

-- re-apply signal colours from vanilla lamp in case any other mod has added more

local signal_colours = data.raw.lamp["small-lamp"].signal_to_color_mapping
if signal_colours then
	data.raw.lamp[DLL.name].signal_to_color_mapping = signal_colours
end
