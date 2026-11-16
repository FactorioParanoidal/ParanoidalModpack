-- Material warnings belong to the hazard mod; Bio Industries and Bob Logistics are optional.
local materials = require("scripts.config").PIPE_MATERIALS
for _, kind in ipairs { "pipe", "pipe-to-ground" } do
  for name, material in pairs(materials) do
    local pipe = data.raw[kind] and data.raw[kind][name]
    if pipe then pipe.localised_description = { material.description } end
  end
end
