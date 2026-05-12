_G.factorissimo = factorissimo or {}

require "table"
require "string"
require "defines"
require "color"

if data and data.raw and not data.raw.item["iron-plate"] then
    factorissimo.stage = "settings"
elseif data and data.raw then
    factorissimo.stage = "data"
    require "data-stage"
elseif script then
    factorissimo.stage = "control"
    require "control-stage"
else
    error("Could not determine load order stage.")
end
