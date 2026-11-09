require "string"
require "defines"
require "color"

if data and data.raw and not data.raw.item["iron-plate"] then
    maraxsis.stage = "settings"
elseif data and data.raw then
    maraxsis.stage = "data"
    require "data-stage"
elseif script then
    maraxsis.stage = "control"
    require "control-stage"
else
    error("Could not determine load order stage.")
end
